import UIKit
import AppTrackingTransparency

class SCEPSplashController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var loaderOneImageView: UIImageView!
    @IBOutlet weak var loaderOneView: UIView!
    @IBOutlet weak var loaderTwoView: UIActivityIndicatorView!
    @IBOutlet weak var loaderThreeImageView: UIImageView!
    @IBOutlet weak var loaderFourView: UIView!
    @IBOutlet weak var loaderFourLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleToImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iconImageView.image = .init(named: "SCEPAppIcon")
        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        let style = SCEPKitInternal.shared.config.app.style
        loaderOneView.isHidden = true
        loaderTwoView.isHidden = true
        loaderThreeImageView.isHidden = true
        loaderFourView.isHidden = true
        switch style {
        case .screensOneDark, .screensOneLight:
            loaderOneView.isHidden = false
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 2
            rotation.repeatCount = Float.infinity
            loaderOneImageView.layer.add(rotation, forKey: "rotationAnimation")
        case .screensTwoDark:
            loaderTwoView.isHidden = false
            loaderTwoView.startAnimating()
        case .screensThreeDark:
            loaderThreeImageView.isHidden = false
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 2
            rotation.repeatCount = Float.infinity
            loaderThreeImageView.layer.add(rotation, forKey: "rotationAnimation")
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.loaderThreeImageView.transform = .init(scaleX: 0.6, y: 0.6)
            }
        case .screensFourDark:
            loaderFourView.isHidden = false
            loaderFourLeadingConstraint.constant = 60
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.loaderFourView.layoutIfNeeded()
            }
        }
        appNameLabel.isHidden = style.splashTitlePosition == .none
        titleToTopConstraint.isActive = style.splashTitlePosition == .top
        titleToImageConstraint.isActive = style.splashTitlePosition != .top
        iconWidthConstraint.constant = style.splashIconWidth
        iconCenterYConstraint.constant = style.splashTitlePosition == .imageBottom ? -30 : 0
        
        if SCEPKitInternal.shared.config.app.requestTracking {
            ATTrackingManager.requestTrackingAuthorization { status in
                if case .authorized = status {
                    
                }
            }
        }
    }
    
    enum TitlePosition {
        case none, top, imageBottom
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var splashTitlePosition: SCEPSplashController.TitlePosition {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark:
            return .imageBottom
        case .screensThreeDark:
            return .none
        case .screensFourDark:
            return .top
        }
    }
    
    var splashIconWidth: CGFloat {
        switch self {
        case .screensOneDark, .screensOneLight, .screensTwoDark, .screensFourDark:
            return 122
        case .screensThreeDark:
            return 84
        }
    }
}
