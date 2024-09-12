import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    var placement: SCEPPaywallPlacement!
    var source: String = ""

    public override func viewDidLoad() {
        super.viewDidLoad()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_shown", properties: ["placenemt": placement.id, "source": source])
    }
    
    func showContinueButton() {}
    
    func purchase(_ product: AdaptyPaywallProduct) {
        if isDebug {
            let alert = UIAlertController(title: "Purchase Product?", message: "Debug mode. The premium status will be reset on next launch", preferredStyle: .alert)
            let purchase = UIAlertAction(title: "Purchase", style: .default) { [unowned self] _ in
                SCEPKitInternal.shared.isSessionPremium = true
                NotificationCenter.default.post(name: SCEPKitInternal.shared.premiumStatusUpdatedNotification, object: nil)
                close()
            }
            alert.addAction(purchase)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: true)
        } else {
            SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_started", properties: ["product_id": product.vendorProductId, "placenemt": placement.id, "source": source])
            Adapty.makePurchase(product: product) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let info):
                    logger.debug("Purchase success \(String(describing: info))")
                    close()
                    SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribed", properties: ["product_id": product.vendorProductId, "placenemt": placement.id, "source": source])
                case .failure(let error):
                    logger.error("Purchase error \(error)")
                    SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_error", properties: ["product_id": product.vendorProductId, "placenemt": placement.id, "source": source, "error": error.description])
                }
            }
        }
    }
    
    func restore() {
        Adapty.restorePurchases { result in
            switch result {
            case .success(let profile):
                print(profile)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func close() {
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_closed", properties: ["placenemt": placement.id, "source": source])
        if parent is SCEPOnboardingController {
            SCEPKitInternal.shared.completeOnboarding()
        } else {
            dismiss(animated: true)
        }
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var paywallTrialSwitchCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 12
        case .screensOneLight:  return 12
        case .screensTwoDark: return 24
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
    
    var paywallProductCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 33
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
    
    var paywallProductLeftPadding: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 24
        case .screensThreeDark: return 16
        case .screensFourDark: return 16
        }
    }
}
