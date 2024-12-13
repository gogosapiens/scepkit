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
        
        let style = SCEPKitInternal.shared.config.style
        
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
        case .classicoDark, .classicoLight: return .bottom
        case .salsicciaDark, .salsicciaLight: return .top
        case .buratinoDark, .buratinoLight: return .bottom
        case .giornaleDark, .giornaleLight: return .imageBottom
        }
    }
    
    var onboardingOverlayHidden: Bool {
        switch self {
        case .classicoDark, .classicoLight: return false
        case .salsicciaDark, .salsicciaLight: return false
        case .buratinoDark, .buratinoLight: return false
        case .giornaleDark, .giornaleLight: return true
        }
    }
    
    var onboardingIsImageAtTop: Bool {
        switch self {
        case .classicoDark, .classicoLight: return true
        case .salsicciaDark, .salsicciaLight: return false
        case .buratinoDark, .buratinoLight: return true
        case .giornaleDark, .giornaleLight: return true
        }
    }
}
