import UIKit

class SCEPOnboardingSlideController: UIViewController {
    
    var configTitle: LocalizedString!
    var configImageURL: URL!
    var index: Int!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var titleImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageTopScreenTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopTitleBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageBottomTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomTitleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomScreenBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imagePaddingLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagePaddingRightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let style = SCEPKitInternal.shared.config.style
        
        titleLabel.text = configTitle.localized()
        titleLabel.textAlignment = style.design.onboardingTitleAlignment
        imageView.image = nil
        Downloader.downloadImage(from: configImageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleTopConstraint.isActive = style.onboardingTitlePosition == .top
        titleBottomConstraint.isActive = style.onboardingTitlePosition == .bottom
        titleImageBottomConstraint.isActive = style.onboardingTitlePosition == .imageBottom
        
        imageTopScreenTopConstraint.isActive = style.onboardingImageTopPosition == .screenTop
        imageTopTitleBottomConstraint.isActive = style.onboardingImageTopPosition == .titleBottom
        
        imageBottomTitleTopConstraint.isActive = style.onboardingImageBottomPosition == .titleTop
        imageBottomTitleBottomConstraint.isActive = style.onboardingImageBottomPosition == .titleBottom
        imageBottomScreenBottomConstraint.isActive = style.onboardingImageBottomPosition == .screenBottom
        imageBottomButtonTopConstraint.isActive = style.onboardingImageBottomPosition == .buttonTop
        
        let isImageSmall = style.design == .salsiccia && style.theme == .light
        imagePaddingLeftConstraint.constant = isImageSmall ? 16 : 0
        imagePaddingRightConstraint.constant = isImageSmall ? 16 : 0
        imageContainerView.layer.cornerRadius = isImageSmall ? 32 : 0
        
        overlayImageView.image = .init(moduleAssetName: "OnboardingSlideOverlay", design: style.design)
        overlayImageView.isHidden = style.onboardingImageOverlayHidden
    }
    
    enum TitlePosition {
        case top, bottom, imageBottom
    }
    
    enum ImageTopPosition {
        case screenTop, titleBottom
    }
    
    enum ImageBottomPosition {
        case titleTop, titleBottom, screenBottom, buttonTop
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var onboardingTitlePosition: SCEPOnboardingSlideController.TitlePosition {
        switch self.design {
        case .classico: return .bottom
        case .salsiccia: return .top
        case .buratino: return .bottom
        case .giornale: return theme == .dark ? .imageBottom : .bottom
        }
    }
    
    var onboardingImageTopPosition: SCEPOnboardingSlideController.ImageTopPosition {
        switch self.design {
        case .classico: return .screenTop
        case .salsiccia: return theme == .dark ? .screenTop : .titleBottom
        case .buratino: return .screenTop
        case .giornale: return .screenTop
        }
    }
    
    var onboardingImageBottomPosition: SCEPOnboardingSlideController.ImageBottomPosition {
        switch self.design {
        case .classico: return .screenBottom
        case .salsiccia: return theme == .dark ? .screenBottom : .buttonTop
        case .buratino: return .screenBottom
        case .giornale: return theme == .dark ? .titleBottom : .titleTop
        }
    }
    
    var onboardingImageOverlayHidden: Bool {
        switch self.design {
        case .classico: return false
        case .salsiccia: return theme == .dark ? false : true
        case .buratino: return theme == .dark ? false : true
        case .giornale: return theme == .dark ? false : true
        }
    }
}

extension SCEPConfig.InterfaceStyle.Design {
    
    var onboardingTitleAlignment: NSTextAlignment {
        switch self {
        case .classico: return .center
        case .salsiccia: return .center
        case .buratino: return .center
        case .giornale: return .left
        }
    }
}
