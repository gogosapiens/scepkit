import UIKit
import Adapty
import AdaptyUI
import GoogleMobileAds

public typealias SCEPCreditsChargeHandler = () -> Void

final public class SCEPKit {
    
    
    private init() {}
    
    public static var isOnboardingCompleted: Bool {
        SCEPKitInternal.shared.isOnboardingCompleted
    }
    
    /// True when the app is not showing onboarding or app open ad
    public static var isApplicationReady: Bool {
        SCEPKitInternal.shared.isApplicationReady
    }
    
    public static var applicationDidBecomeReadyNotification: Notification.Name {
        SCEPKitInternal.shared.applicationDidBecomeReadyNotification
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
    
    @MainActor public static func launch(rootViewController: UIViewController) {
        SCEPKitInternal.shared.launch(rootViewController: rootViewController)
    }
    
    public static func showPaywallController(from controller: UIViewController, placement: String? = nil, successHandler: (() -> Void)? = nil) {
        let placement = placement.map(SCEPPaywallPlacement.custom) ?? .main
        SCEPKitInternal.shared.showPaywallController(from: controller, placement: placement, successHandler: successHandler)
    }
    
    public static var isPremium: Bool {
        SCEPMonetization.shared.isPremium
    }
    
    public static func hasCredits(_ amount: Int) -> Bool {
        return SCEPMonetization.shared.credits >= amount
    }
    
    public static func accessPremiumContent(from controller: UIViewController, placement: String? = nil, handler: @escaping () -> Void) {
        let placement = placement.map(SCEPPaywallPlacement.custom) ?? .main
        SCEPKitInternal.shared.accessPremiumContent(from: controller, placement: placement, handler: handler)
    }
    
    public static func accessCreditsContent(amount: Int, controller: UIViewController, placement: String? = nil, handler: @escaping (@escaping SCEPCreditsChargeHandler) -> Void) {
        let placement = placement.map(SCEPPaywallPlacement.custom) ?? .main
        SCEPKitInternal.shared.accessCreditsContent(amount: amount, from: controller, placement: placement, handler: handler)
    }
    
    public static var creditsString: String {
        SCEPKitInternal.shared.creditsString
    }
    
    public static func showSettingsController(from controller: UIViewController, customActions: [SCEPSettingsController.Action] = []) {
        SCEPKitInternal.shared.showSettingsController(from: controller, customActions: customActions)
    }
    
    /// Returns true if the ad is shown. Calls completion block when the ad was closed or immediately if the ad was skipped due to premium, it not being loaded or if the interstitial period did not pass yet. Boolean in completion block is true if ad was shown.
    @discardableResult @MainActor public static func showInterstitialAd(from controller: UIViewController?, placement: String? = nil, completion: ((Bool) -> Void)? = nil) -> Bool {
        SCEPAdManager.shared.showInterstitialAd(from: controller, placement: placement, completion: completion)
    }
    
    @MainActor public static func showRewardedAd(from controller: UIViewController, placement: String? = nil, customLoadingCompletion: ((Bool) -> Void)? = nil, completion: @escaping (Bool) -> Void) {
        SCEPAdManager.shared.loadAndShowRewardedAd(from: controller, placement: placement, customLoadingCompletion: customLoadingCompletion, completion: completion)
    }
    
    @MainActor public static func getBannerView(placement: String? = nil, completion: (SCEPBannerAdView) -> Void, dismissHandler: @escaping (SCEPBannerAdView) -> Void) {
        SCEPAdManager.shared.getBannerAdView(placement: placement, completion: completion, dismissHandler: dismissHandler)
    }
    
    public static func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        SCEPKitInternal.shared.trackEvent(name, properties: properties)
    }
    
    public static func setUserProperties(_ properties: [String: Any]) {
        SCEPKitInternal.shared.setUserProperties(properties)
    }
    
    public static func font(ofSize size: CGFloat, weight: SCEPFont.Weight) -> UIFont {
        SCEPKitInternal.shared.font(ofSize: size, weight: weight)
    }
    
    public static func remoteConfigValue<Type: Decodable>(for key: String) -> Type? {
        return SCEPKitInternal.shared.remoteConfigValue(for: key)
    }
    
    public static func remoteConfigValue<Type: Decodable>(of type: Type.Type, for key: String) -> Type? {
        return SCEPKitInternal.shared.remoteConfigValue(for: key)
    }
    
    public static func ignoreApplicationDidBecomeActive(for duration: TimeInterval) {
        SCEPAdManager.shared.ignoreApplicationDidBecomeActive(for: duration)
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
