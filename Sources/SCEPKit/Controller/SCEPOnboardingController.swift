import UIKit

class SCEPOnboardingController: UIViewController {

    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var slidesStackView: UIStackView!
    @IBOutlet weak var slidesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var config: SCEPConfig.Onboarding!
    var slideIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.onboardingConfig
        continueButton.title = config.buttonTitle
        showSlideController(slideController(with: config.slides.first!, index: 0), animated: false, isLast: false)
    }
    
    func showSlideController(_ controller: UIViewController, animated: Bool, isLast: Bool, completion: (() -> Void)? = nil) {
        pageControl.currentPage = slidesStackView.arrangedSubviews.count
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        slidesStackView.addArrangedSubview(controller.view)
        controller.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        controller.didMove(toParent: self)
        view.layoutIfNeeded()
        slidesLeadingConstraint.constant = CGFloat(slidesStackView.arrangedSubviews.count - 1) * view.frame.width
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
            showSlideController(slideController, animated: true, isLast: false)
            slideIndex = nextSlideIndex
        } else {
            continueButton.isUserInteractionEnabled = false
            let paywallController = SCEPKitInternal.shared.paywallController(for: .onboarding, source: "Onboarding")
            UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                if paywallController is SCEPPaywallAdaptyController {
                    self.continueButton.transform = .init(translationX: -self.view.frame.width, y: 0)
                }
                self.pageControl.transform = .init(translationX: -self.view.frame.width, y: 0)
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
