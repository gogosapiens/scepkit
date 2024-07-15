import UIKit

class SCEPOnboardingController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var slidesStackView: UIStackView!
    @IBOutlet weak var slidesLeadingConstraint: NSLayoutConstraint!
    
    var config: SCEPKitInternal.OnboardingConfig!
    var slideIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config = SCEPKitInternal.shared.remoteConfigValue(for: "onboarding")
        continueButton.setTitle(config.buttonTitle, for: .normal)
        showSlideController(slideController(with: config.slides.first!), animated: false)
    }
    
    func showSlideController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
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
            let slideController = slideController(with: config.slides[nextSlideIndex])
            showSlideController(slideController, animated: true)
            slideIndex = nextSlideIndex
        } else {
            continueButton.isUserInteractionEnabled = false
            let paywallController = SCEPKitInternal.shared.paywallController(for: .onboarding, source: "Onboarding")
            if paywallController is SCEPPaywallAdaptyController {
                UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                    self.continueButton.transform = .init(translationX: -self.view.frame.width, y: 0)
                }
            }
            showSlideController(paywallController, animated: true) { [weak paywallController, weak self] in
                UIView.animate(withDuration: 0.33) {
                    self?.continueButton.alpha = 0
                }
                paywallController?.showContinueButton()
            }
        }
    }
    
    func slideController(with config: SCEPKitInternal.OnboardingConfig.Slide) -> SCEPOnboardingSlideController {
        let controller = SCEPOnboardingSlideController.instantiate(bundle: .module)
        controller.config = config
        return controller
    }
}
