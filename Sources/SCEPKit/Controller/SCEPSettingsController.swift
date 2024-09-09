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
    @IBOutlet var buttonStackViews: [UIStackView]!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var feedbackImageView: UIImageView!
    @IBOutlet weak var privacyImageView: UIImageView!
    @IBOutlet weak var termsImageView: UIImageView!
    @IBOutlet weak var rateChevronImageView: UIImageView!
    @IBOutlet weak var feedbackChevronImageView: UIImageView!
    @IBOutlet weak var privacyChevronImageView: UIImageView!
    @IBOutlet weak var termsChevronImageView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.config.settings
        let style = SCEPKitInternal.shared.config.app.style
        bannerTitleLabel.text = config.title
        let attributedTitle = NSMutableAttributedString(attributedString: bannerTitleLabel.attributedText!)
        for accent in config.titleAccents {
            attributedTitle.addAttributes(
                [.foregroundColor: UIColor.scepAccent],
                range: NSString(string: attributedTitle.string).range(of: accent)
            )
        }
        bannerTitleLabel.attributedText = attributedTitle
        bannerSubtitleLabel.text = config.subtitle
        bannerSubtitleLabel.alpha = 0.8
        bannerSubtitleLabel.isHidden = config.subtitle == nil
        [bannerFeature0Label, bannerFeature1Label, bannerFeature2Label, bannerFeature3Label].enumerated().forEach { index, label in
            if index < config.features.count {
                label?.superview?.isHidden = false
                label?.text = config.features[index]
            } else {
                label?.superview?.isHidden = false
            }
            if let stackView = label?.superview?.superview as? UIStackView, stackView.arrangedSubviews.last == label?.superview {
                stackView.isHidden = stackView.arrangedSubviews.allSatisfy(\.isHidden)
            }
        }
        bannerButton.title = config.buttonTitle
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.bannerImageView.image = image
        }
        
        bannerView.layer.cornerRadius = 24
        bannerTopStackView.axis = style.settingsTopAxis
        bannerTopStackView.alignment = style.settingsTopAxis == .horizontal ? .fill : .center
        bannerFeaturesStackViews.forEach { $0.axis = style.settingsFeatureAxis }
        bannerTopStackView.removeArrangedSubview(bannerImageView)
        bannerTopStackView.insertArrangedSubview(bannerImageView, at: style.settingsImageIndex)
        bannerTitleLabel.textAlignment = style.settingsTextAlignment
        bannerSubtitleLabel.textAlignment = style.settingsTextAlignment
        buttonStackViews.forEach { $0.axis = style.settingsButtonAxis }
        [rateChevronImageView, feedbackChevronImageView, privacyChevronImageView, termsChevronImageView].forEach { $0?.isHidden = style.settingsButtonAxis == .horizontal }
        rateImageView.image = style.settingsRateImage
        feedbackImageView.image = style.settingsFeedbackImage
        privacyImageView.image = style.settingsPrivacyImage
        termsImageView.image = style.settingsTermsImage
    }
    
    @IBAction func bannerButtonTapped(_ sender: SCEPMainButton) {
        let paywallController = SCEPKitInternal.shared.paywallController(for: .main, source: "SettingsBanner")
        present(paywallController, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func termsTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.config.app.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.config.app.privacyURL)
    }
    
    @IBAction func feedbackTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.config.app.feedbackURL)
    }
    
    @IBAction func rateTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.config.app.reviewURL)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle {
    
    var settingsTopAxis: NSLayoutConstraint.Axis {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark, .screensThreeDark:
            return .horizontal
        case .screensFourDark:
            return .vertical
        }
    }
    
    var settingsFeatureAxis: NSLayoutConstraint.Axis {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark, .screensFourDark:
            return .horizontal
        case .screensThreeDark:
            return .vertical
        }
    }
    
    var settingsImageIndex: Int {
        switch self {
        case .screensOneDark, .screensOneLight:
            return 1
        case .screensTwoDark, .screensThreeDark, .screensFourDark:
            return 0
        }
    }
    
    var settingsTextAlignment: NSTextAlignment {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark, .screensThreeDark:
            return .left
        case .screensFourDark:
            return .center
        }
    }
    
    var settingsButtonAxis: NSLayoutConstraint.Axis {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark, .screensThreeDark:
            return .vertical
        case .screensFourDark:
            return .horizontal
        }
    }
    
    var settingsRateImage: UIImage {
        switch self {
        case .screensOneDark, .screensOneLight:
            return .init(named: "SCEPSettingsRate-screensOne", in: .module, with: nil)!
        case .screensTwoDark:
            return .init(named: "SCEPSettingsRate-screensTwo", in: .module, with: nil)!
        case .screensThreeDark:
            return .init(named: "SCEPSettingsRate-screensThree", in: .module, with: nil)!
        case .screensFourDark:
            return .init(named: "SCEPSettingsRate-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsFeedbackImage: UIImage {
        switch self {
        case .screensOneDark, .screensOneLight:
            return .init(named: "SCEPSettingsFeedback-screensOne", in: .module, with: nil)!
        case .screensTwoDark:
            return .init(named: "SCEPSettingsFeedback-screensTwo", in: .module, with: nil)!
        case .screensThreeDark:
            return .init(named: "SCEPSettingsFeedback-screensThree", in: .module, with: nil)!
        case .screensFourDark:
            return .init(named: "SCEPSettingsFeedback-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsPrivacyImage: UIImage {
        switch self {
        case .screensOneDark, .screensOneLight:
            return .init(named: "SCEPSettingsPrivacy-screensOne", in: .module, with: nil)!
        case .screensTwoDark:
            return .init(named: "SCEPSettingsPrivacy-screensTwo", in: .module, with: nil)!
        case .screensThreeDark:
            return .init(named: "SCEPSettingsPrivacy-screensThree", in: .module, with: nil)!
        case .screensFourDark:
            return .init(named: "SCEPSettingsPrivacy-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsTermsImage: UIImage {
        switch self {
        case .screensOneDark, .screensOneLight:
            return .init(named: "SCEPSettingsTerms-screensOne", in: .module, with: nil)!
        case .screensTwoDark:
            return .init(named: "SCEPSettingsTerms-screensTwo", in: .module, with: nil)!
        case .screensThreeDark:
            return .init(named: "SCEPSettingsTerms-screensThree", in: .module, with: nil)!
        case .screensFourDark:
            return .init(named: "SCEPSettingsTerms-screensFour", in: .module, with: nil)!
        }
    }
}
