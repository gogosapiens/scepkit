import UIKit
import SafariServices

extension UIViewController {
    
    public static func instantiate(storyboardName: String? = nil, bundle: Bundle = .main) -> Self {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName ?? identifier, bundle: bundle)
        return storyboard.instantiateInitialViewController() as! Self
    }
}

extension UIViewController: SFSafariViewControllerDelegate {
    
    static var safariDismissHandler: (() -> Void)?
    
    func openURL(_ url: URL, isExternal: Bool = false, dismissHandler: (() -> Void)? = nil) {
        if isExternal, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            Self.safariDismissHandler = dismissHandler
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true)
        }
    }
}
