import UIKit

final public class SCEPKit {
    
    private init() {}
    
    public static func launch(rootViewController: UIViewController) {
        SCEPKitInternal.shared.launch(rootViewController: rootViewController)
    }
}
