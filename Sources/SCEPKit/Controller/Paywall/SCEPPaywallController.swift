import UIKit
import Adapty

public class SCEPPaywallController: UIViewController {
    
    var placement: SCEPPaywallPlacement!
    var successHandler: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_shown", properties: ["placenemt": placement.id])
    }
    
    func showContinueButton() {}
    
    func purchase(_ product: AdaptyPaywallProduct) {
        if isDebug {
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
        } else {
            SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_started", properties: ["product_id": product.vendorProductId, "placenemt": placement.id])
            Adapty.makePurchase(product: product) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let info):
                    logger.debug("Purchase success \(String(describing: info))")
                    close(success: true)
                    SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribed", properties: ["product_id": product.vendorProductId, "placenemt": placement.id])
                case .failure(let error):
                    logger.error("Purchase error \(error)")
                    SCEPKitInternal.shared.trackEvent("[SCEPKit] subscribe_error", properties: ["product_id": product.vendorProductId, "placenemt": placement.id, "error": error.description])
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
    
    func close(success: Bool) {
        SCEPKitInternal.shared.trackEvent("[SCEPKit] paywall_closed", properties: ["placenemt": placement.id])
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

extension SCEPConfig.InterfaceStyle {
    
    var paywallTrialSwitchCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 12
        case .salsicciaDark, .salsicciaLight: return 24
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
    
    var paywallProductCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 33
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
    
    var paywallProductLeftPadding: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 24
        case .buratinoDark, .buratinoLight: return 16
        case .giornaleDark, .giornaleLight: return 16
        }
    }
}
