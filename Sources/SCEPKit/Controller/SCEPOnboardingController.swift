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
        let style = SCEPKitInternal.shared.config.app.style
        pageStackView.isHidden = style.onboardingIsPageHidden
        showSlideController(slideController(with: config.slides.first!, index: 0), animated: false, isLast: false)
        continueButton.title = .init(localized: "Continue", bundle: .module)
    }
    
    func showSlideController(_ controller: UIViewController, animated: Bool, isLast: Bool, completion: (() -> Void)? = nil) {
        let style = SCEPKitInternal.shared.config.app.style
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
            pageStackView.arrangedSubviews[index].backgroundColor = isCurrent ? .scepText : .scepShade1
        }
        UIView.animate(withDuration: animated ? 0.66 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    func updatePage(animated: Bool) {
        
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        let nextSlideIndex = slideIndex + 1
        if nextSlideIndex < config.slides.count {
            let slideController = slideController(with: config.slides[nextSlideIndex], index: nextSlideIndex)
            showSlideController(slideController, animated: true, isLast: false)
            slideIndex = nextSlideIndex
        } else {
            continueButton.isUserInteractionEnabled = false
            let paywallController = SCEPKitInternal.shared.paywallController(for: .onboarding, source: "Onboarding")
            UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                if paywallController is SCEPPaywallAdaptyController {
                    self.continueButton.transform = .init(translationX: -self.view.frame.width, y: 0)
                }
                self.pageStackView.transform = .init(translationX: -self.view.frame.width, y: 0)
            }
            
            showSlideController(paywallController, animated: true, isLast: true) { [weak paywallController, weak self] in
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
        case .screensOneDark, .screensOneLight, .screensTwoDark:
            return 8
        case .screensThreeDark, .screensFourDark:
            return 24
        }
    }
    
    var onboardingIsPageHidden: Bool {
        switch self {
        case .screensOneDark, .screensOneLight, .screensThreeDark, .screensFourDark:
            return false
        case .screensTwoDark:
            return true
        }
    }
}
