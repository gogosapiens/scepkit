import UIKit

class SCEPSplashController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImageView.image = .init(named: "SCEPAppIcon")
        appNameLabel.font = .main(ofSize: 20, weight: .bold)
        appNameLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
    
    
}
