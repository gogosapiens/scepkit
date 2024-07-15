import UIKit
import Adapty
import AdaptyUI

class SCEPPaywallAdaptyController: SCEPPaywallController {
    
    var viewConfiguration: AdaptyUI.LocalizedViewConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = try! AdaptyUI.paywallController(for: paywall, viewConfiguration: viewConfiguration, delegate: self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
        view.layoutIfNeeded()
//        Adapty.makePurchase(product: <#T##AdaptyPaywallProduct#>, <#T##completion: AdaptyResultCompletion<AdaptyPurchasedInfo>##AdaptyResultCompletion<AdaptyPurchasedInfo>##(AdaptyResult<AdaptyPurchasedInfo>) -> Void#>)
    }
}

extension SCEPPaywallAdaptyController: AdaptyPaywallControllerDelegate {
    
    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        switch action {
        case .close:
            close()
        case let .openURL(url):
            // handle URL opens (incl. terms and privacy links)
            UIApplication.shared.open(url, options: [:])
        case let .custom(id):
            if id == "login" {
                // implement login flow
            }
            break
        }
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didSelectProduct product: AdaptyPaywallProduct) {
    }
    func paywallController(_ controller: AdaptyPaywallController, didStartPurchase product: AdaptyPaywallProduct) {
    }
    func paywallController(_ controller: AdaptyPaywallController, didCancelPurchase product: AdaptyPaywallProduct) {
    }
    func paywallController(_ controller: AdaptyPaywallController, didFinishPurchase product: AdaptyPaywallProduct, purchasedInfo: AdaptyPurchasedInfo) {
        close()
    }
    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
    }
    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
        
    }
    func paywallController(_ controller: AdaptyPaywallController, didFinishRestoreWith profile: AdaptyProfile) {
    }
    func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
        
    }
    public func paywallController(_ controller: AdaptyPaywallController, didFailLoadingProductsWith error: AdaptyError) -> Bool {
        return true
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailRenderingWith error: AdaptyError) {
        
    }
}
