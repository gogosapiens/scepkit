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
            let crossOpacity: Double?
        }
    }
    var config: Config!
    
    var selectedProductIndex: Int!
    
    var displayProduct: SCEPPaywallProduct { trialSwitch.isOn ? trialProduct! : nonTrialProduct }
    
    var trialProduct: SCEPPaywallProduct? {
        if config.positions.count > 1 {
            return config.positions[1].product
        } else {
            return nil
        }
    }
    var nonTrialProduct: SCEPPaywallProduct {
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
    @IBOutlet weak var laurelView: UIView!
    @IBOutlet weak var featuresView: UIView!
    @IBOutlet weak var darkContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var lightContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var darkHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var lightHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var lightOverlayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lightOverlayView: SCEPBackgroundView!
    @IBOutlet weak var darkOverlayView: SCEPTemplateImageView!
    @IBOutlet weak var laurelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var crossButton: SCEPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if placement == .onboarding {
            continueButton.alpha = 0
        }
        
        if let image = try? UIImage(gifName: "SCEPPaywallCatCrown", bundle: .module) {
            crownImageView.setGifImage(image)
            crownImageView.startAnimatingGif()
        }
        
        let style = SCEPKitInternal.shared.config.style
        selectedProductIndex = 0
        trialSwitch.isOn = false
        trialSwitch.onTintColor = .scepAccent
        trialView.layer.borderColor = UIColor.scepShade2.cgColor
        trialView.layer.borderWidth = 2
        trialView.layer.cornerRadius = style.design.paywallTrialSwitchCornerRadius
        trialView.isHidden = trialProduct == nil
        crossButton.alpha = config.meta.crossOpacity ?? 0.5
        
        darkContentConstraint.isActive = style.theme == .dark
        lightContentConstraint.isActive = style.theme == .light
        darkHeaderConstraint.isActive = style.theme == .dark
        lightHeaderConstraint.isActive = style.theme == .light
        lightOverlayHeightConstraint.constant = style.paywallLightOverlayCornerRadius
        lightOverlayView.layer.cornerRadius = style.paywallLightOverlayCornerRadius
        lightOverlayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        lightOverlayView.isHidden = style.theme != .light
        darkOverlayView.isHidden = style.theme != .dark
        laurelTopConstraint.constant = style.theme == .dark ? 26 : 15
        
        setupTexts()
        imageView.image = nil
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
        
        addShadow(to: titleLabel)
        addShadow(to: laurelView)
        addShadow(to: featuresView)
        addShadow(to: priceLabel)
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.scepShade4.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.shadowOffset.height = 2
    }
    
    func setupTexts() {
        titleLabel.text = config.texts.title.localized()
        titleLabel.styleTextColorWithBraces()
        laurelLabel.text = config.texts.laurel.localized()
        laurelLabel.font = SCEPKitInternal.shared.font(ofSize: 14, weight: .medium)
        laurelLabel.styleTextFontWithBraces(SCEPKitInternal.shared.font(ofSize: 14, weight: .bold))
        let labels = [feature0Label, feature1Label, feature2Label, feature3Label]
        let features = [config.texts.feature0, config.texts.feature1, config.texts.feature2, config.texts.feature3]
        for (label, feature) in zip(labels, features) {
            label?.text = feature.localized()
            label?.font = SCEPKitInternal.shared.font(ofSize: 18, weight: .regular)
            label?.styleTextFontWithBraces(SCEPKitInternal.shared.font(ofSize: 18, weight: .bold))
        }
    }
    
    func updatePriceLabel() {
        guard let subscriptionPeriod = displayProduct.subscriptionPeriod else {
            priceLabel.text = "Error".localized()
            return
        }
        priceLabel.text = "\(subscriptionPeriod.displayUnitLocalizedAdjective), \(displayProduct.localizedPrice)/\(subscriptionPeriod.displayUnitLocalizedNoun.lowercased())\n" + "Auto-renewable. Cancel anytime".localized()
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
