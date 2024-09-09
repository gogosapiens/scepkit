import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    var placement: SCEPPaywallPlacement!
    var source: String = ""

    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showContinueButton() {}
    
    func close() {
        if parent is SCEPOnboardingController {
            SCEPKitInternal.shared.completeOnboarding()
        } else {
            dismiss(animated: true)
        }
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var paywallTrialSwitchCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 12
        case .screensOneLight:  return 12
        case .screensTwoDark: return 24
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
    
    var paywallProductCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 33
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
    
    var paywallProductLeftPadding: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 24
        case .screensThreeDark: return 16
        case .screensFourDark: return 16
        }
    }
}
