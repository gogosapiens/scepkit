import UIKit

public class SCEPSettingsController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = .main(ofSize: 16, weight: .semibold)
        closeButton.setImage(.init(named: "SCEPClose"), for: .normal)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func termsTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.privacyURL)
    }
    
    @IBAction func reviewTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.reviewURL)
    }
    
    @IBAction func contactTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.contactURL)
    }
}
