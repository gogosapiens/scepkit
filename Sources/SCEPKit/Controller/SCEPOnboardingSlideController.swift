import UIKit

class SCEPOnboardingSlideController: UIViewController {
    
    var config: SCEPConfig.Onboarding.Slide!
    var index: Int!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style = SCEPKitInternal.shared.config.app.style
        
        titleLabel.text = config.title.localized()
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleTopConstraint.isActive = style.onboardingTitlePosition == .top
        titleBottomConstraint.isActive = style.onboardingTitlePosition == .bottom
        titleImageBottomConstraint.isActive = style.onboardingTitlePosition == .imageBottom
        imageTopConstraint.constant = style.onboardingIsImageAtTop ? 0 : 100
        imageBottomConstraint.isActive = style.onboardingIsImageAtTop
        overlayImageView.isHidden = style.onboardingOverlayHidden
    }
    
    enum TitlePosition {
        case top, bottom, imageBottom
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var onboardingTitlePosition: SCEPOnboardingSlideController.TitlePosition {
        switch self {
        case .screensOneDark, .screensOneLight, .screensThreeDark:
            return .bottom
        case .screensTwoDark:
            return .top
        case .screensFourDark:
            return .imageBottom
        }
    }
    
    var onboardingOverlayHidden: Bool {
        switch self {
        case .screensOneDark, .screensOneLight, .screensThreeDark, .screensTwoDark:
            return false
        case .screensFourDark:
            return true
        }
    }
    
    var onboardingIsImageAtTop: Bool {
        switch self {
        case .screensOneDark, .screensOneLight, .screensFourDark, .screensThreeDark:
            return true
        case .screensTwoDark:
            return false
        }
    }
}
