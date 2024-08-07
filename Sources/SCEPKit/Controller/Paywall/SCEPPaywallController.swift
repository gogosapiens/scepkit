import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    enum Config: Codable {
        case single(config: SCEPPaywallSingleController.Config)
        case verticalTrial(config: SCEPPaywallVerticalTrialController.Config)
        case adapty(placementId: String)
        
        var adaptyPlacementId: String {
            if case .adapty(let placementId) = self {
                return placementId
            } else {
                return "custom"
            }
        }
        
        var imageURLs: [URL] {
            switch self {
            case .single(let config):
                return []
            case .verticalTrial(let config):
                return [config.imageURL]
            case .adapty(let placementId):
                return []
            }
        }
    }
    
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
