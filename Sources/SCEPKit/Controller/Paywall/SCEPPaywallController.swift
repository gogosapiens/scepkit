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
