import UIKit
import Adapty

class SCEPPaywallSingleController: SCEPPaywallController {
    
    struct Config: Codable {
        let imageURL: URL
        let title: LocalizedString
        let features: [LocalizedString]
        let laurel: LocalizedString
    }
    var config: Config!
    
    var selectedProductIndex: Int!
    
    var displayProduct: AdaptyPaywallProduct { trialSwitch.isOn ? trialProduct! : nonTrialProduct }
    
    var trialProduct: AdaptyPaywallProduct? {
        SCEPKitInternal.shared.product(with: .shortTrial)
    }
    var nonTrialProduct: AdaptyPaywallProduct {
        SCEPKitInternal.shared.product(with: .short)!
    }
    
    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var trialSwitch: UISwitch!
    @IBOutlet weak var trialView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: SCEPLabel!
    @IBOutlet weak var laurelLabel: SCEPLabel!
    @IBOutlet weak var priceLabel: SCEPLabel!
    @IBOutlet weak var feature0Label: SCEPLabel!
    @IBOutlet weak var feature1Label: SCEPLabel!
    @IBOutlet weak var feature2Label: SCEPLabel!
    @IBOutlet weak var feature3Label: SCEPLabel!
    @IBOutlet weak var trialLabel: SCEPLabel!
    @IBOutlet weak var cancelAnytimeLabel: SCEPLabel!
    @IBOutlet weak var termsButton: SCEPButton!
    @IBOutlet weak var privacyButton: SCEPButton!
    @IBOutlet weak var restoreButton: SCEPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if placement == .onboarding {
            continueButton.alpha = 0
        }
        selectedProductIndex = 0
        trialSwitch.isOn = false
        trialView.layer.borderColor = UIColor.scepShade2.cgColor
        trialView.layer.borderWidth = 2
        trialView.layer.cornerRadius = SCEPKitInternal.shared.config.app.style.paywallTrialSwitchCornerRadius
        trialView.isHidden = trialProduct == nil
        
        setupTexts()
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        updatePriceLabel()
        
        trialLabel.text = .init(localized: "Enable free trial", bundle: .module)
        cancelAnytimeLabel.text = .init(localized: "CANCEL ANYTIME", bundle: .module)
        termsButton.title = .init(localized: "Terms", bundle: .module)
        privacyButton.title = .init(localized: "Privacy", bundle: .module)
        restoreButton.title = .init(localized: "Restore", bundle: .module)
        continueButton.title = .init(localized: "Continue", bundle: .module)
    }
    
    func setupTexts() {
        titleLabel.text = config.title.localized()
        laurelLabel.text = config.laurel.localized()
        [feature0Label, feature1Label, feature2Label, feature3Label].enumerated().forEach { index, label in
            guard let label else { return }
            if index < config.features.count {
                label.text = config.features[index].localized()
                label.styleTextWithBraces()
            } else {
                label.superview?.superview?.isHidden = true
            }
        }
    }
    
    func updatePriceLabel() {
        guard let subscriptionPeriod = displayProduct.skProduct.subscriptionPeriod else {
            priceLabel.text = .init(localized: "Error", bundle: .module)
            return
        }
        priceLabel.text = "\(subscriptionPeriod.displayUnitLocalizedAdjective), \(displayProduct.skProduct.localizedPrice)/\(subscriptionPeriod.displayUnitLocalizedNoun.lowercased())\n" + .init(localized: "Auto-renewable. Cancel anytime", bundle: .module)
    }
    
    @IBAction func trialSwitchValueChanged(_ sender: UISwitch) {
        updatePriceLabel()
    }
    
    @IBAction func continueTapped(_ sender: SCEPMainButton) {
        purchase(displayProduct)
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.config.app.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.config.app.privacyURL)
    }
    
    @IBAction func restoreTapped(_ sender: UIButton) {
        restore()
    }
    
    override func showContinueButton() {
        super.showContinueButton()
        continueButton.alpha = 1
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close()
    }
}
