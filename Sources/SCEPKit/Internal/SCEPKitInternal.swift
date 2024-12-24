import UIKit
import AdSupport
import AppTrackingTransparency
import StoreKit
import Adapty
import AdaptyUI
import OSLog
import Firebase
import FirebaseRemoteConfig
import AmplitudeSwift

let logger = Logger(subsystem: "SCEPKit", category: "SCEPKitInternal")

class SCEPKitInternal: NSObject {
    
    public static let shared = SCEPKitInternal()
    private override init() {}
    
    var environment: SCEPEnvironment!
    
    var rootViewController: UIViewController!
    var window: UIWindow!
    var onboardingWindow: UIWindow?
    var plistDict: [String: Any]!
    var adaptyPaywalls: [String: AdaptyPaywall] = [:]
    var adaptyViewConfigurations: [String: AdaptyUI.LocalizedViewConfiguration] = [:]
    var adaptyProducts: [String: [AdaptyPaywallProduct]] = [:]
    var amplitude: Amplitude!
    var isApplicationShown: Bool = false
    var font: SCEPFont = .system
    private var isOnboardingResourcesLoadFailed: Bool = false
    private var isOnboardingPaywallResourcesLoadFailed: Bool = false
    
    @UserDefaultsValue(key: "isOnboardingCompleted", defaultValue: false)
    var isOnboardingCompleted: Bool
    
    @UserDefaultsValue(key: "firstLaunchDate", defaultValue: nil)
    var firstLaunchDate: Date!
    
    let onboardingCompletedNotification = Notification.Name("SCEPKitInternal.onboardingCompletedNotification")
    let applicationShownNotification = Notification.Name("SCEPKitInternal.applicationShownNotification")
    
    @MainActor func launch(rootViewController: UIViewController) {
        
        environment = .init(
            rawValue: Bundle.main.object(forInfoDictionaryKey: "SCEPEnvironment") as! String
        )
        
        FirebaseApp.configure()
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        remoteConfig.activate()
        
        let isFirstLaunch = firstLaunchDate == nil
        if isFirstLaunch {
            firstLaunchDate = .init()
            if config.legal.requestTracking {
                let requestTracking = {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                        let idfv = UIDevice.current.identifierForVendor?.uuidString
                        let properties = ["[SCEPKit] idfa": idfa, "[SCEPKit] idfv": idfv].compactMapValues { $0 }
                        self.setUserProperties(properties)
                        self.trackEvent("[SCEPKit] first_launch", properties: ["tracking_authorized": status == .authorized])
                    }
                }
                if UIApplication.shared.applicationState == .active {
                    requestTracking()
                } else {
                    NotificationCenter.default.addOneTimeObserver(forName: UIApplication.didBecomeActiveNotification) { _ in requestTracking()
                    }
                }
            }
        }

        font = SCEPFont.allCases.first(where: { $0.uiFont(ofSize: 10, weight: SCEPFont.Weight.medium) != nil }) ?? .system
        
        let group = DispatchGroup()
        
        group.enter()
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            remoteConfig.activate()
            group.leave()
            switch status {
            case .success:
                let keysAndValues = remoteConfig.allKeys(from: .remote).map { key in
                    ("[SCEPKit] \(key)", remoteConfig.configValue(forKey: key).stringValue ?? "none")
                }
                self.setUserProperties(.init(uniqueKeysWithValues: keysAndValues))
                if isFirstLaunch, self.isApplicationShown {
                    self.trackEvent("[SCEPKit] remote_config_fetch_late")
                }
            default:
                self.trackEvent("[SCEPKit] remote_config_fetch_error")
            }
        }
        
        Adapty.delegate = self
        group.enter()
        Adapty.activate(with: .init(withAPIKey: config.integrations.adaptyApiKey)) { error in
            group.leave()
        }
        AdaptyUI.activate()
        
        amplitude = Amplitude(configuration: .init(apiKey: config.integrations.amplitudeApiKey))
        
        let builder = AdaptyProfileParameters.Builder()
            .with(amplitudeUserId: amplitude.getUserId())
            .with(amplitudeDeviceId: amplitude.getDeviceId())
            .with(firebaseAppInstanceId: Analytics.appInstanceID())
        
        Adapty.updateProfile(params: builder.build())
                
        window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = config.style.uiUserInterfaceStyle
        let splashController = SCEPSplashController.instantiate(bundle: .module)
        window.rootViewController = splashController
        window.makeKeyAndVisible()
        self.rootViewController = rootViewController
        
        DispatchQueue.global().async {
            let result = group.wait(timeout: .now() + 5)
            if result == .success {
                logger.debug("All tasks completed within timeout, application shown")
            } else {
                logger.error("Timeout occurred, application shown")
            }
            
            self.loadResources {
                DispatchQueue.main.async {
                    self.showApplication()
                }
            }
        }
    }
    
    func loadResources(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        let paywallIds = config.monetization.placements.values.flatMap(\.all)
        let adaptyPlacementIds = Set(paywallIds.map { config.monetization.paywalls[$0]!.adaptyPlacementId })
        adaptyPlacementIds.forEach { placementId in
            guard !adaptyPaywalls.keys.contains(placementId) else { return }
            group.enter()
            Adapty.getPaywall(placementId: placementId) { result in
                switch result {
                case .success(let paywall):
                    DispatchQueue.main.async {
                        self.adaptyPaywalls[placementId] = paywall
                        print("PAYWALL:", placementId, paywall)
                    }
                    if paywall.hasViewConfiguration {
                        AdaptyUI.getViewConfiguration(forPaywall: paywall) { result in
                            switch result {
                            case .success(let viewConfiguration):
                                DispatchQueue.main.async {
                                    self.adaptyViewConfigurations[placementId] = viewConfiguration
                                }
                            case .failure(let error):
                                logger.debug("Paywall load error: \(error)")
                            }
                            group.leave()
                        }
                    } else {
                        Adapty.getPaywallProducts(paywall: paywall) { result in
                            switch result {
                            case .success(let products):
                                DispatchQueue.main.async {
                                    self.adaptyProducts[placementId] = products
                                }
                            case .failure(let error):
                                logger.debug("Paywall load error: \(error)")
                            }
                            group.leave()
                        }
                    }
                case .failure(let error):
                    logger.debug("Paywall load error: \(error)")
                    group.leave()
                }
            }
        }
        if !isOnboardingCompleted {
            let meta = config.onboarding.meta
            let onboardingImageURLs = [meta.imageURL0, meta.imageURL1, meta.imageURL2]
            for imageURL in onboardingImageURLs {
                group.enter()
                Downloader.downloadImage(from: imageURL) { image in
                    if image == nil {
                        self.isOnboardingResourcesLoadFailed = true
                    }
                    group.leave()
                }
            }
            let placement = config.monetization.placements[SCEPPaywallPlacement.onboarding.id]
            let paywallIds = [placement?.premium, placement?.credits].compactMap({ $0 })
            let paywallImageURLs = Set(paywallIds.flatMap { config.monetization.paywalls[$0]!.imageURLs })
            for imageURL in paywallImageURLs {
                group.enter()
                Downloader.downloadImage(from: imageURL) { image in
                    if image == nil {
                        self.isOnboardingPaywallResourcesLoadFailed = true
                    }
                    group.leave()
                }
            }
        }
        SCEPAdManager.shared.load()
        if SCEPAdManager.shared.isLoadingAppOpen {
            group.enter()
            NotificationCenter.default.addOneTimeObserver(forName: SCEPAdManager.appOpenLoadedNotification) { _ in
                group.leave()
            }
        }
        DispatchQueue.global().async {
            let result = group.wait(timeout: .now() + 7)
            if result == .timedOut {
                logger.log("Adapty apywall load timed out")
            }
            completion()
        }
    }
    
    var config: SCEPConfig {
        if let variations: [String: SCEPConfig] = remoteConfigValue(for: "scepkit_config"),
           let id: String = remoteConfigValue(for: "scepkit_variation_id"),
           let config = variations[id] {
            return config
        } else {
            return defaultConfig
        }
    }
    var defaultConfig: SCEPConfig {
        let variations: [String: SCEPConfig] = defaultRemoteConfigValue(for: "scepkit_config")!
        return variations[defaultRemoteConfigValue(for: "scepkit_config_var")!]!
    }
    
    var onboardingConfig: SCEPConfig.Onboarding {
        return (isOnboardingResourcesLoadFailed ? defaultConfig : config).onboarding
    }
    
    func paywallConfig(for placement: SCEPPaywallPlacement) -> SCEPPaywallConfig {
        let isDefault = placement == .onboarding && isOnboardingPaywallResourcesLoadFailed
        let config = isDefault ? defaultConfig : config
        let placementConfig = config.monetization.placements[placement.id]!
        let paywallId: String
        switch SCEPMonetization.shared.premuimStatus {
        case .free:
            paywallId = placementConfig.premium ?? placementConfig.credits!
        case .trial:
            paywallId = placementConfig.noTrialPremium ?? placementConfig.credits!
        case .paid:
            paywallId = placementConfig.credits!
        }
        return config.monetization.paywalls[paywallId]!
    }
    
    func product(with id: String) -> AdaptyPaywallProduct? {
        adaptyProducts["custom"]?.first(where: { $0.vendorProductId == id })
    }
    
    func paywallController(config: SCEPPaywallConfig, placement: SCEPPaywallPlacement, successHandler: (() -> Void)?) -> SCEPPaywallController {
        let paywallController: SCEPPaywallController
        switch config {
        case .adapty(let placementId):
            if let paywall = adaptyPaywalls[placementId],
               paywall.hasViewConfiguration,
               let viewConfiguration = SCEPKitInternal.shared.adaptyViewConfigurations[placementId] {
                let controller = SCEPPaywallAdaptyController.instantiate(bundle: .module)
                controller.paywall = paywall
                controller.viewConfiguration = viewConfiguration
                paywallController = controller
            } else {
                fatalError()
            }
        case .robot(let config):
            let controller = SCEPPaywallRobotController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        case .cat(let config):
            let controller = SCEPPaywallCatController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        case .shop(let config):
            let controller = SCEPPaywallShopController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        }
        paywallController.placement = placement
        paywallController.successHandler = successHandler
        return paywallController
    }
    
    func onboardingPaywallController() -> SCEPPaywallController? {
        if config.monetization.placements[SCEPPaywallPlacement.onboarding.id]!.credits != nil || !SCEPMonetization.shared.isPremium {
            let config = paywallConfig(for: .onboarding)
            return paywallController(config: config, placement: .onboarding, successHandler: nil)
        } else {
            return nil
        }
    }
    
    func showSettingsController(from controller: UIViewController) {
        let settingsController = SCEPSettingsController.instantiate(bundle: .module)
        controller.present(settingsController, animated: true)
    }
    
    func showApplication() {
        window.rootViewController = rootViewController
        if !isOnboardingCompleted {
            showOnboarding()
        }
        isApplicationShown = true
        NotificationCenter.default.post(name: applicationShownNotification, object: nil)
    }
    
    func showOnboarding() {
        let onboardingPageController = SCEPOnboardingController.instantiate(bundle: .module)
        onboardingWindow = UIWindow(frame: UIScreen.main.bounds)
        onboardingWindow?.overrideUserInterfaceStyle = config.style.uiUserInterfaceStyle
        onboardingWindow?.rootViewController = onboardingPageController
        onboardingWindow?.makeKeyAndVisible()
        trackEvent("[SCEPKit] onboarding_started")
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .keyboard) {
            self.onboardingWindow?.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        }
        animator.addCompletion { _ in
            self.onboardingWindow?.removeFromSuperview()
            self.onboardingWindow = nil
        }
        animator.startAnimation()
        NotificationCenter.default.post(name: onboardingCompletedNotification, object: nil)
        trackEvent("[SCEPKit] onboarding_finished")
    }
    
    func showPaywallController(from controller: UIViewController, placement: SCEPPaywallPlacement, successHandler: (() -> Void)? = nil) {
        let config = SCEPKitInternal.shared.paywallConfig(for: placement)
        let paywallController = paywallController(config: config, placement: placement, successHandler: successHandler)
        controller.present(paywallController, animated: true)
    }
    
    func showDebugPaywallController(from controller: UIViewController, id: String, successHandler: (() -> Void)? = nil) {
        let config = SCEPKitInternal.shared.config.monetization.paywalls[id]!
        let paywallController = paywallController(config: config, placement: .main, successHandler: successHandler)
        controller.present(paywallController, animated: true)
    }
    
    func accessPremiumContent(from controller: UIViewController, placement: SCEPPaywallPlacement, handler: @escaping () -> Void) {
        guard config.monetization.placements.values.contains(where: { $0.hasPremium }) else {
            fatalError("This app does not support premium content")
        }
        if SCEPMonetization.shared.isPremium {
            handler()
        } else {
            showPaywallController(from: controller, placement: placement, successHandler: handler)
        }
    }
    
    func accessCreditsContent(amount: Int, from controller: UIViewController, placement: SCEPPaywallPlacement, handler: @escaping (SCEPCreditsChargeHandler) -> Void) {
        guard config.monetization.placements.values.contains(where: { $0.hasPremium }) else {
            fatalError("This app does not support credits content")
        }
        let chargeHandler = {
            SCEPMonetization.shared.decrementCredits(by: amount)
        }
        if SCEPMonetization.shared.credits >= amount {
            handler(chargeHandler)
        } else {
            showPaywallController(from: controller, placement: placement) {
                if SCEPMonetization.shared.credits < amount {
                    handler(chargeHandler)
                }
            }
        }
    }
    
    var creditsString: String {
        SCEPMonetization.shared.credits.formatted()
    }
    
    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        guard environment == .production else {
            logger.log("Track event: \(name), properties: \(properties?.debugDescription ?? "[:]")")
            return
        }
        amplitude.track(eventType: name, eventProperties: properties)
        Analytics.logEvent(name, parameters: properties)
    }
    
    func setUserProperties(_ properties: [String: Any]) {
        guard environment == .production else {
            logger.log("Set user properties: \(properties.debugDescription)")
            return
        }
        amplitude.identify(userProperties: properties)
    }
    
    private func remoteConfigValue<Type: Decodable>(for key: String) -> Type? {
        let data = RemoteConfig.remoteConfig().configValue(forKey: key).dataValue
        guard let value = try? JSONDecoder().decode(Type.self, from: data) else { return nil }
        return value
    }
    
    private func defaultRemoteConfigValue<Type: Decodable>(for key: String) -> Type? {
        guard
            let data = RemoteConfig.remoteConfig().defaultValue(forKey: key)?.dataValue,
            let value = try? JSONDecoder().decode(Type.self, from: data)
        else {
//            try! JSONDecoder().decode(Type.self, from: RemoteConfig.remoteConfig().defaultValue(forKey: key)!.dataValue)
            return nil
        }
        return value
    }
    
    private func getUserDefaultsValue<T: Decodable>(for key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: "SCEPKitInternal." + key),
           let value = try? JSONDecoder().decode(T.self, from: data) {
            return value
        } else {
            return nil
        }
    }
    
    private func setUserDefaultsValue<T: Encodable>(_ value: T?, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: "SCEPKitInternal." + key)
        }
    }
    
    var termsURL: URL {
        return config.legal.termsURL
    }
    
    var privacyURL: URL {
        return config.legal.privacyURL
    }
    
    var feedbackURL: URL {
        return config.legal.feedbackURL
    }
    
    var reviewURL: URL {
        .init(string: "https://itunes.apple.com/app/id\(config.integrations.appleAppId)?action=write-review")!
    }
    
    func font(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return font.uiFont(ofSize: size, weight: weight) ?? .systemFont(ofSize: size, weight: weight)
    }
    
    func performWhenRootScreenIsVisible(_ block: @escaping () -> Void) {
        let group = DispatchGroup()
        if !SCEPKit.isOnboardingCompleted {
            group.enter()
            NotificationCenter.default.addOneTimeObserver(forName: onboardingCompletedNotification) { _ in
                group.leave()
            }
        }
        if SCEPKit.willShowAppOpenAd {
            group.enter()
            NotificationCenter.default.addOneTimeObserver(forName: SCEPAdManager.appOpenDismissedNotification) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main, execute: block)
    }
}

extension SCEPKitInternal: AdaptyDelegate {
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        guard environment == .production else { return }
        DispatchQueue.main.async {
            SCEPMonetization.shared.update(for: profile)
        }
    }
}

extension SCEPPaywallConfig.Position {
    
    var product: AdaptyPaywallProduct? {
        guard let productId else { return nil }
        return SCEPKitInternal.shared.product(with: productId)
    }
}
