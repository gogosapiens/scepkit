import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    enum Config: Codable {
        case single(config: SCEPPaywallSingleController.Config)
    }
    
    var paywall: AdaptyPaywall!
    var placement: SCEPPaywallPlacement!
    var source: String = ""
    var products: [AdaptyPaywallProduct]!

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
