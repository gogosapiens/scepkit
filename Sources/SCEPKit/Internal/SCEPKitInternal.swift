import UIKit
import StoreKit
import Adapty
import AdaptyUI
import OSLog
import Firebase
import FirebaseRemoteConfig

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
    private var isOnboardingResourcesLoadFailed: Bool = false
    private var isOnboardingPaywallResourcesLoadFailed: Bool = false
    
    @UserDefaultsValue(key: "SCEPKitInternal.isOnboardingCompleted", defaultValue: false)
    var isOnboardingCompleted: Bool
    
    @UserDefaultsValue(key: "SCEPKitInternal.isPremuim", defaultValue: false)
    var isPremium: Bool
    
    let onboardingCompletedNotification = Notification.Name("SCEPKitInternal.onboardingCompletedNotification")
    let premiumStatusUpdatedNotification = Notification.Name("SCEPKitInternal.premiumStatusUpdated")
    
    func launch(rootViewController: UIViewController) {
        
        let group = DispatchGroup()
        
        FirebaseApp.configure()
        let config = RemoteConfig.remoteConfig()
        config.setDefaults(fromPlist: "remote_config_defaults")
        config.activate()
        group.enter()
        config.fetch(withExpirationDuration: 0) { status, error in
            group.leave()
        }
        
        Adapty.delegate = self
        group.enter()
        Adapty.activate(with: .init(withAPIKey: appConfig.adaptyApiKey)) { error in
            group.leave()
        }
        AdaptyUI.activate()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = appConfig.interface.style.uiUserInterfaceStyle
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
            for imageURL in remoteOnboardingConfig.slides.map(\.imageURL) {
                group.enter()
                Downloader.downloadImage(from: imageURL) { image in
                    if image == nil {
                        self.isOnboardingResourcesLoadFailed = true
                    }
                    group.leave()
                }
            }
            for imageURL in remotePaywallConfig(for: .onboarding).imageURLs {
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
    
    var appConfig: SCEPAppConfig { remoteConfigValue(for: "scepkit_app")! }
    
    private var remoteOnboardingConfig: OnboardingConfig { remoteConfigValue(for: "scepkit_onboarding")! }
    private var defaultOnboardingConfig: OnboardingConfig { defaultRemoteConfigValue(for: "scepkit_onboarding")! }
    var onboardingConfig: OnboardingConfig {
        if isOnboardingResourcesLoadFailed {
            return defaultOnboardingConfig
        } else {
            return remoteOnboardingConfig
        }
    }
    
    private func remotePaywallConfig(for placement: SCEPPaywallPlacement) -> SCEPPaywallController.Config {
        remoteConfigValue(for: "scepkit_paywall_" + placement.id)!
    }
    private func defaultPaywallConfig(for placement: SCEPPaywallPlacement) -> SCEPPaywallController.Config {
        defaultRemoteConfigValue(for: "scepkit_paywall_" + placement.id)!
    }
    func paywallConfig(for placement: SCEPPaywallPlacement) -> SCEPPaywallController.Config {
        if placement == .onboarding, isOnboardingPaywallResourcesLoadFailed {
            return defaultPaywallConfig(for: placement)
        } else {
            return remotePaywallConfig(for: placement)
        }
    }
    
    func product(with id: String) -> AdaptyPaywallProduct? {
        adaptyProducts["custom"]?.first(where: { $0.vendorProductId == id })
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
        case .single(let config):
            let controller = SCEPPaywallSingleController.instantiate(bundle: .module)
            controller.config = config
            paywallController = controller
        case .verticalTrial(let config):
            let controller = SCEPPaywallVerticalTrialController.instantiate(bundle: .module)
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
    }
    
    func showOnboarding() {
        let onboardingPageController = SCEPOnboardingController.instantiate(bundle: .module)
        onboardingWindow = UIWindow(frame: UIScreen.main.bounds)
        onboardingWindow?.overrideUserInterfaceStyle = appConfig.interface.style.uiUserInterfaceStyle
        onboardingWindow?.rootViewController = onboardingPageController
        onboardingWindow?.makeKeyAndVisible()
//        KinderCode.shared.trackEvent("OnboardingStarted")
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
//        KinderCode.shared.trackEvent("OnboardingFinished")
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .keyboard) {
            self.onboardingWindow?.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        }
        animator.addCompletion { _ in
            self.onboardingWindow?.removeFromSuperview()
            self.onboardingWindow = nil
        }
        animator.startAnimation()
        NotificationCenter.default.post(name: onboardingCompletedNotification, object: nil)
    }
    
    enum InterfaceStyle: String, Codable {
        case light, dark
        
        var uiUserInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .light: return .light
            case .dark:  return .dark
            }
        }
    }
}

extension SCEPKitInternal: AdaptyDelegate {
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        let isPremium = profile.accessLevels["premium"]?.isActive ?? false
        if isPremium != self.isPremium {
            self.isPremium = isPremium
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.premiumStatusUpdatedNotification, object: nil)
            }
        }
    }
}
