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
        
        let design = SCEPKitInternal.shared.config.style.design
        
        titleLabel.text = config.title.localized()
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleTopConstraint.isActive = design.onboardingTitlePosition == .top
        titleBottomConstraint.isActive = design.onboardingTitlePosition == .bottom
        titleImageBottomConstraint.isActive = design.onboardingTitlePosition == .imageBottom
        imageTopConstraint.constant = design.onboardingIsImageAtTop ? 0 : 100
        imageBottomConstraint.isActive = design.onboardingIsImageAtTop
        overlayImageView.isHidden = design.onboardingOverlayHidden
    }
    
    enum TitlePosition {
        case top, bottom, imageBottom
    }
}

extension SCEPConfig.InterfaceStyle.Design {
    
    var onboardingTitlePosition: SCEPOnboardingSlideController.TitlePosition {
        switch self {
        case .classico: return .bottom
        case .salsiccia: return .top
        case .buratino: return .bottom
        case .giornale: return .imageBottom
        }
    }
    
    var onboardingOverlayHidden: Bool {
        switch self {
        case .classico: return false
        case .salsiccia: return false
        case .buratino: return false
        case .giornale: return true
        }
    }
    
    var onboardingIsImageAtTop: Bool {
        switch self {
        case .classico: return true
        case .salsiccia: return false
        case .buratino: return true
        case .giornale: return true
        }
    }
}
