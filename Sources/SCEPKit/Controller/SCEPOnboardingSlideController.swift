import UIKit

class SCEPOnboardingSlideController: UIViewController {
    
    var config: SCEPKitInternal.OnboardingConfig.Slide!
    var index: Int!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = config.title
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
    }
}
