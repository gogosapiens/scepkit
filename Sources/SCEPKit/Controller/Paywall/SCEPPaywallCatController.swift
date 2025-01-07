import UIKit
import Adapty
import SwiftyGif

class SCEPPaywallCatController: SCEPPaywallController {
    
    struct Config: Codable {
        let positions: [SCEPPaywallConfig.Position]
        let texts: Texts
        let meta: Meta
        struct Texts: Codable {
            let title: LocalizedString
            let feature0: LocalizedString
            let feature1: LocalizedString
            let feature2: LocalizedString
            let feature3: LocalizedString
            let laurel: LocalizedString
        }
        struct Meta: Codable {
            let imageURL: URL
        }
    }
    var config: Config!
    
    var selectedProductIndex: Int!
    
    var displayProduct: AdaptyPaywallProduct { trialSwitch.isOn ? trialProduct! : nonTrialProduct }
    
    var trialProduct: AdaptyPaywallProduct? {
        if config.positions.count > 1 {
            return config.positions[1].product
        } else {
            return nil
        }
    }
    var nonTrialProduct: AdaptyPaywallProduct {
        return config.positions[0].product!
    }
    
    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var crownImageView: UIImageView!
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
        
        if let image = try? UIImage(gifName: "SCEPPaywallCatCrown", bundle: .module) {
            crownImageView.setGifImage(image)
            crownImageView.startAnimatingGif()
        }
        
        selectedProductIndex = 0
        trialSwitch.isOn = false
        trialSwitch.onTintColor = .scepAccent
        trialSwitch.thumbTintColor = .scepTextColor
        trialView.layer.borderColor = UIColor.scepShade2.cgColor
        trialView.layer.borderWidth = 2
        trialView.layer.cornerRadius = SCEPKitInternal.shared.config.style.design.paywallTrialSwitchCornerRadius
        trialView.isHidden = trialProduct == nil
        
        setupTexts()
        Downloader.downloadImage(from: config.meta.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        updatePriceLabel()
        
        trialLabel.text = "Enable free trial".localized()
        cancelAnytimeLabel.text = "CANCEL ANYTIME".localized()
        termsButton.title = "Terms".localized()
        privacyButton.title = "Privacy".localized()
        restoreButton.title = "Restore".localized()
        continueButton.title = "Continue".localized()
    }
    
    func setupTexts() {
        titleLabel.text = config.texts.title.localized()
        laurelLabel.text = config.texts.laurel.localized()
        let labels = [feature0Label, feature1Label, feature2Label, feature3Label]
        let features = [config.texts.feature0, config.texts.feature1, config.texts.feature2, config.texts.feature3]
        for (label, feature) in zip(labels, features) {
            label?.text = feature.localized()
            label?.styleTextWithBraces()
        }
    }
    
    func updatePriceLabel() {
        guard let subscriptionPeriod = displayProduct.skProduct.subscriptionPeriod else {
            priceLabel.text = "Error".localized()
            return
        }
        priceLabel.text = "\(subscriptionPeriod.displayUnitLocalizedAdjective), \(displayProduct.skProduct.localizedPrice)/\(subscriptionPeriod.displayUnitLocalizedNoun.lowercased())\n" + "Auto-renewable. Cancel anytime".localized()
    }
    
    @IBAction func trialSwitchValueChanged(_ sender: UISwitch) {
        updatePriceLabel()
    }
    
    @IBAction func continueTapped(_ sender: SCEPMainButton) {
        purchase(displayProduct)
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.privacyURL)
    }
    
    @IBAction func restoreTapped(_ sender: UIButton) {
        restore()
    }
    
    override func showContinueButton() {
        super.showContinueButton()
        continueButton.alpha = 1
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close(success: false)
    }
}
