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
        let design = SCEPKitInternal.shared.config.style.design
        loaderOneView.isHidden = true
        loaderTwoView.isHidden = true
        loaderTwoView.color = .scepAccent
        loaderThreeImageView.isHidden = true
        loaderFourView.isHidden = true
        switch design {
        case .classico:
            loaderOneView.isHidden = false
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 2
            rotation.repeatCount = Float.infinity
            loaderOneImageView.layer.add(rotation, forKey: "rotationAnimation")
        case .salsiccia:
            loaderTwoView.isHidden = false
            loaderTwoView.startAnimating()
        case .buratino:
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
        case .giornale:
            loaderFourView.isHidden = false
            loaderFourLeadingConstraint.constant = 60
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.loaderFourView.layoutIfNeeded()
            }
        }
        appNameLabel.isHidden = design.splashTitlePosition == .none
        titleToTopConstraint.isActive = design.splashTitlePosition == .top
        titleToImageConstraint.isActive = design.splashTitlePosition != .top
        iconWidthConstraint.constant = design.splashIconWidth
        iconCenterYConstraint.constant = design.splashTitlePosition == .imageBottom ? -30 : 0
        
        if SCEPKitInternal.shared.config.legal.requestTracking {
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

extension SCEPConfig.InterfaceStyle.Design {
    
    var splashTitlePosition: SCEPSplashController.TitlePosition {
        switch self {
        case .classico: return .imageBottom
        case .salsiccia: return .imageBottom
        case .buratino: return .none
        case .giornale: return .top
        }
    }
    
    var splashIconWidth: CGFloat {
        switch self {
        case .classico: return 122
        case .salsiccia: return 122
        case .buratino: return 84
        case .giornale: return 122
        }
    }
}
