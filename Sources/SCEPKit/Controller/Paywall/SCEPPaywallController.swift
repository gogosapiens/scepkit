import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    var placement: SCEPPaywallPlacement!
    var successHandler: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_shown", properties: ["placement": placement.id])
    }
    
    func showContinueButton() {}
    
    func purchase(_ product: SCEPPaywallProduct) {
        guard let product = product as? AdaptyPaywallProduct else {
            let alert = UIAlertController(title: "Failed to connect to AppStore", message: "Please check your internet connection and restart the app", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            present(alert, animated: true)
            return
        }
        if SCEPKitInternal.shared.environment.isUsingProductionProducts {
            let activityController = SCEPActivityController.instantiate(bundle: .module)
            present(activityController, animated: true)
            SCEPAdManager.shared.isPurchasing = true
            SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_started", properties: ["product_id": product.vendorProductId, "placement": placement.id])
            Adapty.makePurchase(product: product) { result in
                activityController.dismiss(animated: true) { [weak self] in
                    guard let self else { return }
                    switch result {
                    case .success(let info):
                        logger.debug("Purchase success \(String(describing: info))")
                        close(success: true)
                        SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribed", properties: ["product_id": product.vendorProductId, "placement": placement.id])
                    case .failure(let error):
                        logger.error("Purchase error \(error)")
                        SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_error", properties: ["product_id": product.vendorProductId, "placement": placement.id, "error": error.description])
                    }
                    SCEPAdManager.shared.isPurchasing = false
                }
            }
        } else {
            let isTrial = product.introductoryDiscount?.paymentMode == .freeTrial
            let credits = SCEPMonetization.shared.credits(for: product.vendorProductId)
            let title = credits > 0 ? "Increment credits by \(credits)?" : "Enable \(isTrial ? "trial" : "paid") status?"
            let alert = UIAlertController(title: title, message: "Debug mode", preferredStyle: .alert)
            let purchase = UIAlertAction(title: "Confirm", style: .default) { [unowned self] _ in
                if credits > 0 {
                    SCEPMonetization.shared.incrementAdditionalCredits(by: credits)
                } else {
                    SCEPMonetization.shared.setPremuimStatus(isTrial ? .trial : .paid)
                }
                close(success: true)
            }
            alert.addAction(purchase)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }
    
    func restore() {
        Adapty.restorePurchases { result in
            switch result {
            case .success(let profile):
                logger.info("Restored purchases: \(profile)")
            case .failure(let error):
                logger.error("Restoring purchases failed: \(error)")
            }
        }
    }
    
    func close(success: Bool) {
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_closed", properties: ["placement": placement.id])
        if parent is SCEPOnboardingController {
            SCEPKitInternal.shared.completeOnboarding()
        } else {
            dismiss(animated: true) { [successHandler] in
                if success {
                    successHandler?()
                }
            }
        }
    }
}

extension SCEPConfig.InterfaceStyle.Design {
    
    var paywallTrialSwitchCornerRadius: CGFloat {
        switch self {
        case .classico: return 12
        case .salsiccia: return 24
        case .buratino: return 8
        case .giornale: return 12
        }
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var paywallProductCornerRadius: CGFloat {
        switch self.design {
        case .classico: return 16
        case .salsiccia: return theme == .dark ? 33 : 16
        case .buratino: return 8
        case .giornale: return 12
        }
    }
    
    var paywallLightOverlayCornerRadius: CGFloat {
        switch self.design {
        case .classico: return 16
        case .salsiccia: return 33
        case .buratino: return 8
        case .giornale: return 12
        }
    }
    
    var paywallProductLeftPadding: CGFloat {
        switch self.design {
        case .classico: return 16
        case .salsiccia: return theme == .dark ? 24 : 16
        case .buratino: return 16
        case .giornale: return 16
        }
    }
}
