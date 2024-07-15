import UIKit
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
    var paywalls: [SCEPPaywallPlacement: AdaptyPaywall] = [:]
    var viewConfigurations: [SCEPPaywallPlacement: AdaptyUI.LocalizedViewConfiguration] = [:]
    var products: [SCEPPaywallPlacement: [AdaptyPaywallProduct]] = [:]
    
    @UserDefaultsValue(key: "SCEPKitInternal.isOnboardingCompleted", defaultValue: false)
    var isOnboardingCompleted: Bool
    
    @UserDefaultsValue(key: "SCEPKitInternal.isPremuim", defaultValue: false)
    var isPremium: Bool
    
    let onboardingCompletedNotification = Notification.Name("SCEPKitInternal.onboardingCompletedNotification")
    let premiumStatusUpdatedNotification = Notification.Name("SCEPKitInternal.premiumStatusUpdated")
    
    func launch(rootViewController: UIViewController) {
        
        let group = DispatchGroup()
        
        loadPlist()
        Adapty.delegate = self
        group.enter()
        Adapty.activate(with: .init(withAPIKey: plistString(for: .adaptyApiKey))) { error in
            self.loadPaywalls(group: group)
            group.leave()
        }
        AdaptyUI.activate()
        
        FirebaseApp.configure()
        let config = RemoteConfig.remoteConfig()
        group.enter()
        config.fetch(withExpirationDuration: 0) { status, error in
            config.activate()
            group.leave()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashController = SCEPSplashController.instantiate(bundle: .module)
        window.rootViewController = splashController
        window.makeKeyAndVisible()
        self.rootViewController = rootViewController
        
        DispatchQueue.global().async {
            let result = group.wait(timeout: .now() + 1)
            DispatchQueue.main.async {
                if result == .success {
                    logger.debug("All tasks completed within timeout, application shown")
                } else {
                    logger.error("Timeout occurred, application shown")
                }
                if config.lastFetchStatus == .noFetchYet {
                    config.setDefaults(fromPlist: "remote_config_defaults")
                    config.activate()
                }
                self.showApplication()
            }
        }
    }
    
    func loadPaywalls(group: DispatchGroup? = nil) {
        SCEPPaywallPlacement.allCases.forEach { placement in
            guard !paywalls.keys.contains(placement) else { return }
            group?.enter()
            Adapty.getPaywall(placementId: placement.id) { result in
                switch result {
                case .success(let paywall):
                    DispatchQueue.main.async {
                        self.paywalls[placement] = paywall
                        print("PAYWALL:", placement.id, paywall)
                    }
                    if paywall.hasViewConfiguration {
                        AdaptyUI.getViewConfiguration(forPaywall: paywall) { result in
                            switch result {
                            case .success(let viewConfiguration):
                                DispatchQueue.main.async {
                                    self.viewConfigurations[placement] = viewConfiguration
                                }
                            case .failure(let error):
                                logger.debug("Paywall load error: \(error)")
                            }
                            group?.leave()
                        }
                    } else {
                        Adapty.getPaywallProducts(paywall: paywall) { result in
                            switch result {
                            case .success(let products):
                                DispatchQueue.main.async {
                                    self.products[placement] = products
                                }
                            case .failure(let error):
                                logger.debug("Paywall load error: \(error)")
                            }
                            group?.leave()
                        }
                    }
                case .failure(let error):
                    logger.debug("Paywall load error: \(error)")
                    group?.leave()
                }
            }
        }
    }
    
    func getPaywall(for placement: SCEPPaywallPlacement) -> AdaptyPaywall? {
        return paywalls[placement]
    }
    
    func paywallController(for placement: SCEPPaywallPlacement, source: String) -> SCEPPaywallController {
        let paywall = SCEPKitInternal.shared.getPaywall(for: placement)
        let paywallController: SCEPPaywallController
        if let paywall {
            if paywall.hasViewConfiguration, let viewConfiguration = SCEPKitInternal.shared.viewConfigurations[placement] {
                let controller = SCEPPaywallAdaptyController.instantiate(bundle: .module)
                controller.viewConfiguration = viewConfiguration
                controller.products = []
                paywallController = controller
            } else if let data = paywall.remoteConfig?.jsonString.data(using: .utf8), let config = try? JSONDecoder().decode(SCEPPaywallController.Config.self, from: data), let products = self.products[placement] {
                switch config {
                case .single(let config):
                    let controller = SCEPPaywallSingleController.instantiate(bundle: .module)
                    controller.config = config
                    controller.products = products
                    paywallController = controller
                }
            } else {
                fatalError()
            }
        } else {
            fatalError()
        }
        paywallController.placement = placement
        paywallController.source = source
        paywallController.paywall = paywall
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
    
    var termsURL: URL { .init(string: plistValue(for: .termsURL))! }
    var privacyURL: URL { .init(string: plistValue(for: .privacyURL))! }
    var contactURL: URL { .init(string: plistValue(for: .contactURL))! }
    var appleId: String { plistValue(for: .appleId) }
    var reviewURL: URL { .init(string: "itms-apps://itunes.apple.com/app/id\(appleId)?mt=8&action=write-review")! }
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
