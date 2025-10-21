import UIKit
import StoreKit

class SCEPOnboardingController: UIViewController {
    
    let numberOfSlides: Int = 3

    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var slidesStackView: UIStackView!
    @IBOutlet weak var slidesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var page0WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var page1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var page2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageStackView: UIStackView!
    
    var config: SCEPConfig.Onboarding!
    var slideIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.onboardingConfig
        let design = SCEPKitInternal.shared.config.style.design
        pageStackView.superview!.isHidden = design.onboardingIsPageHidden
        showSlideController(slideController(index: 0), animated: false)
        continueButton.title = "Continue".localized()
    }
    
    func showSlideController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        let design = SCEPKitInternal.shared.config.style.design
        let currentIndex = slidesStackView.arrangedSubviews.count
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        slidesStackView.addArrangedSubview(controller.view)
        controller.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        controller.didMove(toParent: self)
        view.layoutIfNeeded()
        slidesLeadingConstraint.constant = CGFloat(slidesStackView.arrangedSubviews.count - 1) * view.frame.width
        for (index, constraint) in [page0WidthConstraint, page1WidthConstraint, page2WidthConstraint].enumerated() {
            let isCurrent = index == currentIndex
            constraint?.constant = isCurrent ? design.onboardingSelectedPageWidth : 8
            pageStackView.arrangedSubviews[index].backgroundColor = isCurrent ? .scepOnboardingTextColor : .scepShade2
        }
        UIView.animate(withDuration: animated ? 0.66 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        let nextSlideIndex = slideIndex + 1
        if nextSlideIndex < numberOfSlides {
            let slideController = slideController(index: nextSlideIndex)
            showSlideController(slideController, animated: true)
            slideIndex = nextSlideIndex
            if slideIndex == 2, config.meta.showRateUs ?? false {
                if #available(iOS 14.0, *) {
                    if let scene = UIApplication.shared.connectedScenes.first(
                        where: { $0.activationState == .foregroundActive }
                    ) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                } else {
                    SKStoreReviewController.requestReview()
                }
            }
        } else {
            guard let paywallController = SCEPKitInternal.shared.onboardingPaywallController() else {
                SCEPKitInternal.shared.completeOnboarding()
                return
            }
            continueButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
//                if paywallController is SCEPPaywallAdaptyController {
//                    self.continueButton.transform = .init(translationX: -self.view.frame.width, y: 0)
//                }
                self.pageStackView.superview!.transform = .init(translationX: -self.view.frame.width, y: 0)
            }
            showSlideController(paywallController, animated: true) { [weak paywallController, weak self] in
                UIView.animate(withDuration: 0.33) {
                    self?.continueButton.alpha = 0
                }
                paywallController?.showContinueButton()
            }
        }
    }
    
    func slideController(index: Int) -> SCEPOnboardingSlideController {
        let controller = SCEPOnboardingSlideController.instantiate(bundle: .module)
        let titles = [config.texts.title0, config.texts.title1, config.texts.title2]
        let imageURLs = [config.meta.imageURL0, config.meta.imageURL1, config.meta.imageURL2]
        controller.configTitle = titles[index]
        controller.configImageURL = imageURLs[index]
        controller.index = index
        return controller
    }
}


extension SCEPConfig.InterfaceStyle.Design {
    
    var onboardingSelectedPageWidth: CGFloat {
        switch self {
        case .classico: return 8
        case .salsiccia: return 8
        case .buratino: return 24
        case .giornale: return 24
        }
    }
    
    var onboardingIsPageHidden: Bool {
        switch self {
        case .classico: return false
        case .salsiccia: return true
        case .buratino: return false
        case .giornale: return false
        }
    }
}
