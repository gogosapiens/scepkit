import UIKit
import Adapty
import AdaptyUI
import GoogleMobileAds

final public class SCEPKit {
    
    private init() {}
    
    public static var isOnboardingCompleted: Bool {
        SCEPKitInternal.shared.isOnboardingCompleted
    }
    
    public static var isShowingAppOpenAd: Bool {
        SCEPAdManager.shared.isShowingAppOpen
    }
    
    public static var onboardingCompletedNotification: Notification.Name {
        SCEPKitInternal.shared.onboardingCompletedNotification
    }
    public static var premiumUpdatedNotification: Notification.Name {
        SCEPMonetization.shared.premiumStatusUpdatedNotification
    }
    public static var creditsUpdatedNotification: Notification.Name {
        SCEPMonetization.shared.creditsUpdatedNotification
    }
    public static var appOpenAdDismissedNotification: Notification.Name {
        SCEPAdManager.appOpenDismissedNotification
    }
    
    @MainActor public static func launch(rootViewController: UIViewController) {
        SCEPKitInternal.shared.launch(rootViewController: rootViewController)
    }
    
    public static func paywallController(for placement: SCEPPaywallPlacement, source: String, successHandler: (() -> Void)? = nil) -> SCEPPaywallController {
        SCEPKitInternal.shared.paywallController(for: placement, successHandler: successHandler)
    }
    
    public static func canAccessContent(for requirement: SCEPContentRequirement) -> Bool {
        SCEPKitInternal.shared.canAccessContent(for: requirement)
    }
    
//    public func requestAccessToContent(for requirement: SCEPContentRequirement, from controller: UIViewController, placement: SCEPPaywallPlacement, handler: @escaping () -> Void) {
//        SCEPKitInternal.shared.requestAccessToContent(for: requirement, from: controller, placement: placement, handler: handler)
//    }
    
    public static func provideContent(for requirement: SCEPContentRequirement, from controller: UIViewController, placement: SCEPPaywallPlacement, handler: @escaping () -> Void) {
        SCEPKitInternal.shared.provideContent(for: requirement, from: controller, placement: placement, handler: handler)
    }
    
    public static var creditsString: String {
        SCEPKitInternal.shared.creditsString
    }
    
    public static func settingsController() -> SCEPSettingsController {
        SCEPKitInternal.shared.settingsController()
    }
    
    @discardableResult @MainActor public static func showInterstitialAd(from controller: UIViewController?, placement: String) -> Bool {
        SCEPAdManager.shared.showInterstitialAd(from: controller, placement: placement)
    }
    
    @MainActor public static func showRewardedAd(from controller: UIViewController, placement: String, customLoadingCompletion: ((Bool) -> Void)? = nil, completion: @escaping (Bool) -> Void) {
        SCEPAdManager.shared.loadAndShowRewardedAd(from: controller, placement: placement, customLoadingCompletion: customLoadingCompletion, completion: completion)
    }
    
    @MainActor public static func getBannerView(placement: String, completion: (SCEPBannerAdView) -> Void, dismissHandler: @escaping (SCEPBannerAdView) -> Void) {
        SCEPAdManager.shared.getBannerAdView(placement: placement, completion: completion, dismissHandler: dismissHandler)
    }
    
    public static func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        SCEPKitInternal.shared.trackEvent(name, properties: properties)
    }
    
    public static func setUserProperties(_ properties: [String: Any]) {
        SCEPKitInternal.shared.setUserProperties(properties)
    }
    
    public static func performWhenApplicationIsVisible(_ block: @escaping () -> Void) {
        SCEPKitInternal.shared.performWhenApplicationIsVisible(block)
    }
}

public enum SCEPPaywallPlacement: Hashable {
    case onboarding
    case main
    case custom(String)
    
    var id: String {
        switch self {
        case .onboarding:
            return "_onboarding"
        case .main:
            return "_main"
        case .custom(let id):
            return id
        }
    }
    
    init(id: String) {
        switch id {
        case "_onboarding":
            self = .onboarding
        case "_main":
            self = .main
        default:
            self = .custom(id)
        }
    }
}
