import UIKit
import Adapty
import AdaptyUI

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
    
    public static func launch(rootViewController: UIViewController) {
        SCEPKitInternal.shared.launch(rootViewController: rootViewController)
    }
    
    public static func paywallController(for placement: SCEPPaywallPlacement, source: String) -> SCEPPaywallController {
        SCEPKitInternal.shared.paywallController(for: placement, source: source)
    }
    
    public static func settingsController() -> SCEPSettingsController {
        SCEPKitInternal.shared.settingsController()
    }
    
}

public enum SCEPPaywallPlacement: CaseIterable, Hashable {
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
