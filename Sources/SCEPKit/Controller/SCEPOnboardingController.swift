import UIKit

class SCEPOnboardingController: UIViewController {

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
        let style = SCEPKitInternal.shared.config.style
        pageStackView.isHidden = style.onboardingIsPageHidden
        showSlideController(slideController(with: config.slides.first!, index: 0), animated: false)
        continueButton.title = .init(localized: "Continue", bundle: .module)
    }
    
    func showSlideController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        let style = SCEPKitInternal.shared.config.style
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
            constraint?.constant = isCurrent ? style.onboardingSelectedPageWidth : 8
            pageStackView.arrangedSubviews[index].backgroundColor = isCurrent ? .scepTextColor : .scepShade1
        }
        UIView.animate(withDuration: animated ? 0.66 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        let nextSlideIndex = slideIndex + 1
        if nextSlideIndex < config.slides.count {
            let slideController = slideController(with: config.slides[nextSlideIndex], index: nextSlideIndex)
            showSlideController(slideController, animated: true)
            slideIndex = nextSlideIndex
        } else {
            guard let paywallController = SCEPKitInternal.shared.onboardingPaywallController() else {
                SCEPKitInternal.shared.completeOnboarding()
                return
            }
            continueButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                if paywallController is SCEPPaywallAdaptyController {
                    self.continueButton.transform = .init(translationX: -self.view.frame.width, y: 0)
                }
                self.pageStackView.transform = .init(translationX: -self.view.frame.width, y: 0)
            }
            showSlideController(paywallController, animated: true) { [weak paywallController, weak self] in
                UIView.animate(withDuration: 0.33) {
                    self?.continueButton.alpha = 0
                }
                paywallController?.showContinueButton()
            }
        }
    }
    
    func slideController(with config: SCEPConfig.Onboarding.Slide, index: Int) -> SCEPOnboardingSlideController {
        let controller = SCEPOnboardingSlideController.instantiate(bundle: .module)
        controller.config = config
        controller.index = index
        return controller
    }
}


extension SCEPConfig.InterfaceStyle {
    
    var onboardingSelectedPageWidth: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 8
        case .salsicciaDark, .salsicciaLight: return 8
        case .buratinoDark, .buratinoLight: return 24
        case .giornaleDark, .giornaleLight: return 24
        }
    }
    
    var onboardingIsPageHidden: Bool {
        switch self {
        case .classicoDark, .classicoLight: return false
        case .salsicciaDark, .salsicciaLight: return true
        case .buratinoDark, .buratinoLight: return false
        case .giornaleDark, .giornaleLight: return false
        }
    }
}
