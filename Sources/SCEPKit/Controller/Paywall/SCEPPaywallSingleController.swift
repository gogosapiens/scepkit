import UIKit
import StoreKit
import Adapty

class SCEPPaywallSingleController: SCEPPaywallController {
    
    struct Config: Codable {
        let title: String
        let subtitle: String
        let buttonTitle: String
        let productId: String
        var product: AdaptyPaywallProduct? { SCEPKitInternal.shared.product(with: productId) }
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
        
        titleLabel.text = config.title.insertingPrice(for: config.product?.skProduct)
        subtitleLabel.text = config.subtitle.insertingPrice(for: config.product?.skProduct)
        continueButton.setTitle(config.buttonTitle.insertingPrice(for: config.product?.skProduct), for: .normal)
    }
    
    @IBAction func continueTapped(_ sender: SCEPMainButton) {
        guard let product = config.product else { return }
        Adapty.makePurchase(product: product) { [weak self] result in
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
        openURL(SCEPKitInternal.shared.appConfig.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.appConfig.privacyURL)
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
