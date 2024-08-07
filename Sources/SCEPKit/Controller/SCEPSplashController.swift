import UIKit

class SCEPSplashController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImageView.image = .init(named: "SCEPAppIcon")
        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 5
        rotation.repeatCount = Float.infinity
        loaderImageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    
}
