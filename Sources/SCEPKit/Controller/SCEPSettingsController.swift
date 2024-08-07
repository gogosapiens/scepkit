import UIKit

public class SCEPSettingsController: UIViewController {
    
    struct Config: Codable {
        let title: String
        let titleAccents: [String]
        let subtitle: String
        let features: [String]
        let buttonTitle: String
        let imageURL: URL
    }
    var config: Config!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bannerTitleLabel: SCEPLabel!
    @IBOutlet weak var bannerSubtitleLabel: SCEPLabel!
    @IBOutlet weak var bannerFeature0Label: SCEPLabel!
    @IBOutlet weak var bannerFeature1Label: SCEPLabel!
    @IBOutlet weak var bannerFeature2Label: SCEPLabel!
    @IBOutlet weak var bannerFeature3Label: SCEPLabel!
    @IBOutlet weak var bannerButton: SCEPMainButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.remoteConfigValue(for: "scepkit_settings")
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
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.bannerImageView.image = image
        }
    }
    
    @IBAction func bannerButtonTapped(_ sender: SCEPMainButton) {
        let paywallController = SCEPKitInternal.shared.paywallController(for: .main, source: "SettingsBanner")
        present(paywallController, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func termsTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.appConfig.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.appConfig.privacyURL)
    }
    
    @IBAction func feedbackTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.appConfig.feedbackURL)
    }
    
    @IBAction func rateTapped(_ sender: SCEPSecondaryButton) {
        openURL(SCEPKitInternal.shared.appConfig.reviewURL)
    }
}
