import UIKit
import Adapty
import AdaptyUI
import GoogleMobileAds

final public class SCEPKit {
    
    private init() {}
    
    public static var isPremium: Bool {
        SCEPKitInternal.shared.isPremium
    }
    
    public static var isOnboardingCompleted: Bool {
        SCEPKitInternal.shared.isOnboardingCompleted
    }
    
    public static var onboardingCompletedNotification: Notification.Name {
        SCEPKitInternal.shared.onboardingCompletedNotification
    }
    public static var premiumStatusUpdatedNotification: Notification.Name {
        SCEPKitInternal.shared.premiumStatusUpdatedNotification
    }
    
    @MainActor public static func launch(rootViewController: UIViewController) {
        SCEPKitInternal.shared.launch(rootViewController: rootViewController)
    }
    
    public static func paywallController(source: String) -> SCEPPaywallController {
        SCEPKitInternal.shared.paywallController(for: .main, source: source)
    }
    
    public static func settingsController() -> SCEPSettingsController {
        SCEPKitInternal.shared.settingsController()
    }
    
    @MainActor public static func showIntesstitialAd(from controller: UIViewController?, placement: String) {
        SCEPAdManager.shared.showInterstitialAd(from: controller, placement: placement)
    }
    
    @MainActor public static func showRewardedAd(from controller: UIViewController, placement: String, completion: @escaping (Bool) -> Void) {
        SCEPAdManager.shared.showRewardedAd(from: controller, placement: placement, completion: completion)
    }
    
    @MainActor public static func getBannerView(placement: String) -> GADBannerView? {
        SCEPAdManager.shared.getBannerAdView(placement: placement)
    }
}

enum SCEPPaywallPlacement: CaseIterable, Hashable {
    case onboarding
    case main
    
    var id: String {
        switch self {
        case .onboarding:
            return "onboarding"
        case .main:
            return "main"
        }
    }
}
