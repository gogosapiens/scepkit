import UIKit

class SCEPKitInternal {
    
    public static let shared = SCEPKitInternal()
    private init() {}
    
    var rootViewController: UIViewController!
    var window: UIWindow!
    
    func launch(rootViewController: UIViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashController = SCEPSplashController.instantiate(bundle: .module)
        window.rootViewController = splashController
        window.makeKeyAndVisible()
        self.rootViewController = rootViewController
    }
}
