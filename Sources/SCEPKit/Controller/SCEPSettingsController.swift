import UIKit

public class SCEPSettingsController: UIViewController {
    
    var config: SCEPConfig.Settings!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerTitleLabel: SCEPLabel!
    @IBOutlet weak var bannerSubtitleLabel: SCEPLabel!
    @IBOutlet weak var bannerFeature0Label: SCEPLabel!
    @IBOutlet weak var bannerFeature1Label: SCEPLabel!
    @IBOutlet weak var bannerFeature2Label: SCEPLabel!
    @IBOutlet weak var bannerFeature3Label: SCEPLabel!
    @IBOutlet weak var bannerButton: SCEPMainButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var bannerTopStackView: UIStackView!
    @IBOutlet var bannerFeaturesStackViews: [UIStackView]!
    @IBOutlet weak var debugStackView: UIStackView!
    @IBOutlet var buttonStackViews: [UIStackView]!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var feedbackImageView: UIImageView!
    @IBOutlet weak var privacyImageView: UIImageView!
    @IBOutlet weak var termsImageView: UIImageView!
    @IBOutlet weak var rateChevronImageView: UIImageView!
    @IBOutlet weak var feedbackChevronImageView: UIImageView!
    @IBOutlet weak var privacyChevronImageView: UIImageView!
    @IBOutlet weak var termsChevronImageView: UIImageView!
    @IBOutlet weak var mainLabel: SCEPLabel!
    @IBOutlet weak var legalLabel: SCEPLabel!
    @IBOutlet weak var rateButton: SCEPSecondaryButton!
    @IBOutlet weak var feedbackButton: SCEPSecondaryButton!
    @IBOutlet weak var privacyButton: SCEPSecondaryButton!
    @IBOutlet weak var termsButton: SCEPSecondaryButton!
    @IBOutlet weak var premiumStatusButton: SCEPSecondaryButton!
    @IBOutlet weak var recurringCreditsButton: SCEPSecondaryButton!
    @IBOutlet weak var additionalCreditsButton: SCEPSecondaryButton!
    @IBOutlet weak var resetOnboardingButton: SCEPSecondaryButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.config.settings
        let design = SCEPKitInternal.shared.config.style.design
        bannerTitleLabel.text = config.title.localized()
        bannerTitleLabel.styleTextWithBraces()
        bannerSubtitleLabel.text = config.subtitle?.localized()
        bannerSubtitleLabel.alpha = 0.8
        bannerSubtitleLabel.isHidden = config.subtitle == nil
        [bannerFeature0Label, bannerFeature1Label, bannerFeature2Label, bannerFeature3Label].enumerated().forEach { index, label in
            if index < config.features.count {
                label?.superview?.isHidden = false
                label?.text = config.features[index].localized()
            } else {
                label?.superview?.isHidden = false
            }
            if let stackView = label?.superview?.superview as? UIStackView, stackView.arrangedSubviews.last == label?.superview {
                stackView.isHidden = stackView.arrangedSubviews.allSatisfy(\.isHidden)
            }
        }
        bannerImageView.image = .init(named: "SCEPAppIcon")
        
        bannerView.layer.cornerRadius = 24
        bannerTopStackView.axis = design.settingsTopAxis
        bannerTopStackView.alignment = design.settingsTopAxis == .horizontal ? .fill : .center
        bannerFeaturesStackViews.forEach { $0.axis = design.settingsFeatureAxis }
        bannerTopStackView.removeArrangedSubview(bannerImageView)
        bannerTopStackView.insertArrangedSubview(bannerImageView, at: design.settingsImageIndex)
        bannerTitleLabel.textAlignment = design.settingsTextAlignment
        bannerSubtitleLabel.textAlignment = design.settingsTextAlignment
        buttonStackViews.forEach { $0.axis = design.settingsButtonAxis }
        [rateChevronImageView, feedbackChevronImageView, privacyChevronImageView, termsChevronImageView].forEach { $0?.isHidden = design.settingsButtonAxis == .horizontal }
        rateImageView.image = design.settingsRateImage
        feedbackImageView.image = design.settingsFeedbackImage
        privacyImageView.image = design.settingsPrivacyImage
        termsImageView.image = design.settingsTermsImage
        
        titleLabel.text = .init(localized: "Settings", bundle: .module)
        bannerButton.title = .init(localized: "Get started", bundle: .module)
        mainLabel.text = .init(localized: "MAIN", bundle: .module)
        legalLabel.text = .init(localized: "LEGAL", bundle: .module)
        rateButton.title = .init(localized: "Rate us", bundle: .module)
        feedbackButton.title = .init(localized: "Feedback", bundle: .module)
        privacyButton.title = .init(localized: "Privacy Policy", bundle: .module)
        termsButton.title = .init(localized: "Terms of Use", bundle: .module)
        
        debugStackView.isHidden = !isDebug
                
        premiumStatusUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(premiumStatusUpdated), name: SCEPMonetization.shared.premiumStatusUpdatedNotification, object: nil)
        
        creditsUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(creditsUpdated), name: SCEPMonetization.shared.creditsUpdatedNotification, object: nil)
    }
    
    @objc func premiumStatusUpdated() {
        bannerView.isHidden = SCEPMonetization.shared.isPremium
        let title: String
        switch SCEPMonetization.shared.premuimStatus {
        case .free:
            title = "Free"
        case .trial:
            title = "Trial"
        case .paid:
            title = "Paid"
        }
        premiumStatusButton.setTitle("Premium st.: \(title)", for: .normal)
    }
    
    @objc func creditsUpdated() {
        recurringCreditsButton.setTitle("Recurring cr.: \(SCEPMonetization.shared.recurringCredits)", for: .normal)
        additionalCreditsButton.setTitle("Additional cr.: \(SCEPMonetization.shared.additionalCredits)", for: .normal)
    }
    
    @IBAction func bannerButtonTapped(_ sender: SCEPMainButton) {
        let paywallController = SCEPKitInternal.shared.paywallController(for: .main, successHandler: nil)
        present(paywallController, animated: true)
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
    
    @IBAction func feedbackTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.feedbackURL)
    }
    
    @IBAction func rateTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.reviewURL)
    }
    
    @IBAction func premiumStatusTapped(_ sender: SCEPSecondaryButton) {
        let alert = UIAlertController(title: "Change premium status", message: nil, preferredStyle: .alert)
        let free = UIAlertAction(title: "Free", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.free)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Free")
        }
        alert.addAction(free)
        let trial = UIAlertAction(title: "Trial", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.trial)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Trial")
        }
        alert.addAction(trial)
        let paid = UIAlertAction(title: "Paid", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.paid)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Paid")
        }
        alert.addAction(paid)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func resetOnboardingTapped(_ sender: SCEPSecondaryButton) {
        SCEPKitInternal.shared.isOnboardingCompleted = false
        showInfoAlert(title: "Onboarding Reset", message: "Onboarding will be shown on next app launch")
    }
    
    @IBAction func recurringCreditsTapped(_ sender: SCEPSecondaryButton) {
        showNumberFieldAlert(title: "Set Recurring Credits", message: "Enter NEW value for recurring credits", placeholder: SCEPMonetization.shared.recurringCredits) { [weak self] value in
            SCEPMonetization.shared.setRecurringCredits(value)
            self?.showInfoAlert(title: "Recurring Credits Set", message: "New value is \(SCEPMonetization.shared.recurringCredits)")
        }
    }
    
    @IBAction func additionalCreditsTapped(_ sender: SCEPSecondaryButton) {
        showNumberFieldAlert(title: "Add Additional Credits", message: "Enter value to ADD to additional credits. Enter negative value to decrement", placeholder: 0) { [weak self] value in
            SCEPMonetization.shared.incrementAdditionalCredits(by: value)
            self?.showInfoAlert(title: "Additional Credits Added", message: "New value is \(SCEPMonetization.shared.additionalCredits)")
        }
    }
    
    func showNumberFieldAlert(title: String, message: String? = nil, placeholder: Int, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.placeholder = String(placeholder)
        }
        let enter = UIAlertAction(title: "Enter", style: .default) { _ in
            if let textField = alert.textFields?.first, let value = Int(textField.text ?? "") {
                completion(value)
            } else {
                self.showInfoAlert(title: "Invalid Value", message: "Please enter a valid number")
            }
        }
        alert.addAction(enter)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showInfoAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var settingsTopAxis: NSLayoutConstraint.Axis {
        switch self {
        case .classico: return .horizontal
        case .salsiccia: return .horizontal
        case .buratino: return .horizontal
        case .giornale: return .vertical
        }
    }
    
    var settingsFeatureAxis: NSLayoutConstraint.Axis {
        switch self {
        case .classico: return .horizontal
        case .salsiccia: return .horizontal
        case .buratino: return .vertical
        case .giornale: return .horizontal
        }
    }
    
    var settingsImageIndex: Int {
        switch self {
        case .classico: return 1
        case .salsiccia: return 0
        case .buratino: return 0
        case .giornale: return 0
        }
    }
    
    var settingsTextAlignment: NSTextAlignment {
        switch self {
        case .classico: return .left
        case .salsiccia: return .left
        case .buratino: return .left
        case .giornale: return .center
        }
    }
    
    var settingsButtonAxis: NSLayoutConstraint.Axis {
        switch self {
        case .classico: return .vertical
        case .salsiccia: return .vertical
        case .buratino: return .vertical
        case .giornale: return .horizontal
        }
    }
    
    var settingsRateImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsRate-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsRate-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsRate-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsRate-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsFeedbackImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsFeedback-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsFeedback-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsFeedback-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsFeedback-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsPrivacyImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsPrivacy-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsPrivacy-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsPrivacy-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsPrivacy-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsTermsImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsTerms-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsTerms-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsTerms-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsTerms-screensFour", in: .module, with: nil)!
        }
    }
}
