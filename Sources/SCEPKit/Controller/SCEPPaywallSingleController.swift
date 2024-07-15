import UIKit
import Adapty

class SCEPPaywallSingleController: SCEPPaywallController {
    
    struct Config: Codable {
        let title: String
        let subtitle: String
        let buttonTitle: String
    }
    var config: Config!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if placement == .onboarding {
            continueButton.alpha = 0
        }
        closeButton.setImage(.init(named: "SCEPClose"), for: .normal)
        
        titleLabel.font = .main(ofSize: 32, weight: .bold)
        subtitleLabel.font = .main(ofSize: 16, weight: .semibold)
        
        let product = products.first?.skProduct
        titleLabel.text = config.title.insertingPrice(for: product)
        subtitleLabel.text = config.subtitle.insertingPrice(for: product)
        continueButton.setTitle(config.buttonTitle.insertingPrice(for: product), for: .normal)
    }
    
    @IBAction func continueTapped(_ sender: SCEPMainButton) {
        Adapty.makePurchase(product: products.first!) { [weak self] result in
            switch result {
            case .success(let info):
//                logger.debug("Purchase success \(info)")
                self?.close()
            case .failure(let error):
                logger.error("Purchase error \(error)")
            }
        }
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.privacyURL)
    }
    
    @IBAction func restoreTapped(_ sender: UIButton) {
        Adapty.restorePurchases { result in
            switch result {
            case .success(let profile):
                print(profile)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func showContinueButton() {
        super.showContinueButton()
        continueButton.alpha = 1
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close()
    }
}
