import UIKit

class SCEPActivityController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .scepShade1.withAlphaComponent(0.5)
        activityIndicator.color = .scepTextColor
    }
}
