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

public var isDebug: Bool {
#if DEBUG
    return true
#else
    return false
#endif
}

let logger = Logger(subsystem: "SCEPKit", category: "SCEPKitInternal")

class SCEPKitInternal: NSObject {
    
    public static let shared = SCEPKitInternal()
    private override init() {}
    
    var rootViewController: UIViewController!
    var window: UIWindow!
    var onboardingWindow: UIWindow?
    var plistDict: [String: Any]!
    var adaptyPaywalls: [String: AdaptyPaywall] = [:]
    var adaptyViewConfigurations: [String: AdaptyUI.LocalizedViewConfiguration] = [:]
    var adaptyProducts: [String: [AdaptyPaywallProduct]] = [:]
    var amplitude: Amplitude!
    var isApplicationShown: Bool = false
    var isSessionPremium: Bool = false
    private var isOnboardingResourcesLoadFailed: Bool = false
    private var isOnboardingPaywallResourcesLoadFailed: Bool = false
    
    @UserDefaultsValue(key: "SCEPKitInternal.isOnboardingCompleted", defaultValue: false)
    var isOnboardingCompleted: Bool
    
    @UserDefaultsValue(key: "SCEPKitInternal.isAdaptyPremuim", defaultValue: false)
    var isAdaptyPremium: Bool
    
    @UserDefaultsValue(key: "SCEPKitInternal.firstLaunchDate", defaultValue: nil)
    var firstLaunchDate: Date!
    
    var isPremium: Bool {
        return isAdaptyPremium || isSessionPremium
    }
    
    let onboardingCompletedNotification = Notification.Name("SCEPKitInternal.onboardingCompletedNotification")
    let applicationShownNotification = Notification.Name("SCEPKitInternal.applicationShownNotification")
    let premiumStatusUpdatedNotification = Notification.Name("SCEPKitInternal.premiumStatusUpdated")
    
    @MainActor func launch(rootViewController: UIViewController) {
        
        let isFirstLaunch = firstLaunchDate == nil
        if isFirstLaunch {
            firstLaunchDate = .init()
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
        
        let group = DispatchGroup()
        
        FirebaseApp.configure()
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        remoteConfig.activate()
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
        Adapty.activate(with: .init(withAPIKey: config.app.adaptyApiKey)) { error in
            group.leave()
        }
        AdaptyUI.activate()
        
        amplitude = Amplitude(configuration: .init(apiKey: config.app.adaptyApiKey))
        
        SCEPAdManager.shared.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = config.app.style.uiUserInterfaceStyle
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
        let adaptyPlacementIds = Set(SCEPPaywallPlacement.allCases.map { paywallConfig(for: $0).adaptyPlacementId })
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
            for imageURL in config.onboarding.slides.map(\.imageURL) {
                group.enter()
                Downloader.downloadImage(from: imageURL) { image in
                    if image == nil {
                        self.isOnboardingResourcesLoadFailed = true
                    }
                    group.leave()
                }
            }
            for imageURL in config.paywall(for: .onboarding).imageURLs {
                group.enter()
                Downloader.downloadImage(from: imageURL) { image in
                    if image == nil {
                        self.isOnboardingPaywallResourcesLoadFailed = true
                    }
                    group.leave()
                }
            }
        }
        DispatchQueue.global().async {
            let result = group.wait(timeout: .now() + 5)
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
        return variations[defaultRemoteConfigValue(for: "scepkit_variation_id")!]!
    }
    
    var onboardingConfig: SCEPConfig.Onboarding {
        return (isOnboardingResourcesLoadFailed ? defaultConfig : config).onboarding
    }
    
    func paywallConfig(for placement: SCEPPaywallPlacement) -> SCEPConfig.Paywall {
        let isDefault = placement == .onboarding && isOnboardingPaywallResourcesLoadFailed
        return (isDefault ? defaultConfig : config).paywall(for: placement)
    }
    
    func product(with type: SCEPConfig.ProductType) -> AdaptyPaywallProduct? {
        adaptyProducts["custom"]?.first(where: { $0.vendorProductId == config.app.productsIds[type.rawValue] })
    }
    
    func paywallController(for placement: SCEPPaywallPlacement, source: String) -> SCEPPaywallController {
        let paywallConfig = SCEPKitInternal.shared.paywallConfig(for: placement)
        let paywallController: SCEPPaywallController
        
        switch paywallConfig {
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
        case .vertical(let config):
            let controller = SCEPPaywallVerticalController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        case .single(let config):
            let controller = SCEPPaywallSingleController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        }
        paywallController.placement = placement
        paywallController.source = source
        return paywallController
    }
    
    func settingsController() -> SCEPSettingsController {
        let controller = SCEPSettingsController.instantiate(bundle: .module)
        return controller
    }
    
    func showApplication() {
        print(#function)
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
        onboardingWindow?.overrideUserInterfaceStyle = config.app.style.uiUserInterfaceStyle
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
    
    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        guard !isDebug else {
            logger.log("Track event: \(name), properties: \(properties?.debugDescription ?? "[:]")")
            return
        }
        amplitude.track(eventType: name, eventProperties: properties)
        Analytics.logEvent(name, parameters: properties)
    }
    
    func setUserProperties(_ properties: [String: Any]) {
        guard !isDebug else {
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
            return nil
        }
        return value
    }
}

extension SCEPKitInternal: AdaptyDelegate {
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        let isAdaptyPremium = profile.accessLevels["premium"]?.isActive ?? false
        if isAdaptyPremium != self.isAdaptyPremium {
            self.isAdaptyPremium = isAdaptyPremium
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.premiumStatusUpdatedNotification, object: nil)
            }
        }
    }
}
