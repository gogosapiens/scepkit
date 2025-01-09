import UIKit

class SCEPOnboardingSlideController: UIViewController {
    
    var configTitle: LocalizedString!
    var configImageURL: URL!
    var index: Int!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var imageLargeConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageSmallConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let design = SCEPKitInternal.shared.config.style.design
        
        titleLabel.text = configTitle.localized()
        Downloader.downloadImage(from: configImageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleTopConstraint.isActive = design.onboardingTitlePosition == .top
        titleBottomConstraint.isActive = design.onboardingTitlePosition == .bottom
        titleImageBottomConstraint.isActive = design.onboardingTitlePosition == .imageBottom
        imageLargeConstraint.isActive = design.onboardingImageIsLarge
        imageSmallConstraint.isActive = !design.onboardingImageIsLarge
        
        overlayImageView.image = .init(moduleAssetName: "OnboardingSlideOverlay", design: design)
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
    
    var onboardingImageIsLarge: Bool {
        switch self {
        case .classico: return true
        case .salsiccia: return true
        case .buratino: return true
        case .giornale: return false
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
