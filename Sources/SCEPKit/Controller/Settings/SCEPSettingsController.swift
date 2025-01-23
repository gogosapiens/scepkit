import UIKit

public class SCEPSettingsController: UIViewController {
    
    public struct Action {
        var title: String
        var image: UIImage?
        var handler: (SCEPSettingsController) -> Void
        
        public init(title: String, image: UIImage?, handler: @escaping (SCEPSettingsController) -> Void) {
            self.title = title
            self.image = image
            self.handler = handler
        }
    }
    
    var actions: [Action] = []
    
    var design: SCEPConfig.InterfaceStyle.Design { SCEPKitInternal.shared.config.style.design }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Settings".localized()
             
        premiumStatusUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(premiumStatusUpdated), name: SCEPMonetization.shared.premiumStatusUpdatedNotification, object: nil)
        
        creditsUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(creditsUpdated), name: SCEPMonetization.shared.creditsUpdatedNotification, object: nil)
    }
    
    @objc func premiumStatusUpdated() {
        collectionView.reloadData()
    }
    
    @objc func creditsUpdated() {
        collectionView.reloadData()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func changePremiumStatus() {
        let alert = UIAlertController(title: "Change premium status", message: nil, preferredStyle: .alert)
        let free = UIAlertAction(title: "Free", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.free)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Free")
        }
        alert.addAction(free)
        let trial = UIAlertAction(title: "Trial", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.trial)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Trial")
        }
        alert.addAction(trial)
        let paid = UIAlertAction(title: "Paid", style: .default) { [weak self] _ in
            SCEPMonetization.shared.setPremuimStatus(.paid)
            self?.showInfoAlert(title: "Premium Status Changed", message: "New status: Paid")
        }
        alert.addAction(paid)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func resetOnboarding() {
        SCEPKitInternal.shared.isOnboardingCompleted = false
        showInfoAlert(title: "Onboarding Reset", message: "Onboarding will be shown on next app launch")
    }
    
    func changeRecurringCredits() {
        showNumberFieldAlert(title: "Set Recurring Credits", message: "Enter NEW value for recurring credits", placeholder: SCEPMonetization.shared.recurringCredits) { [weak self] value in
            SCEPMonetization.shared.setRecurringCredits(value)
            self?.showInfoAlert(title: "Recurring Credits Set", message: "New value is \(SCEPMonetization.shared.recurringCredits)")
        }
    }
    
    func changeAdditionalCredits() {
        showNumberFieldAlert(title: "Add Additional Credits", message: "Enter value to ADD to additional credits. Enter negative value to decrement", placeholder: 0) { [weak self] value in
            SCEPMonetization.shared.incrementAdditionalCredits(by: value)
            self?.showInfoAlert(title: "Additional Credits Added", message: "New value is \(SCEPMonetization.shared.additionalCredits)")
        }
    }
    
    func showPaywalls() {
        let ids = SCEPKitInternal.shared.config.monetization.paywalls.keys.sorted()
        let alert = UIAlertController(title: "Select Paywall", message: nil, preferredStyle: .actionSheet)
        for id in ids {
            let action = UIAlertAction(title: id, style: .default) { _ in
                SCEPKitInternal.shared.showDebugPaywallController(from: self, id: id)
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showNumberFieldAlert(title: String, message: String? = nil, placeholder: Int, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numbersAndPunctuation
            textField.placeholder = String(placeholder)
        }
        let enter = UIAlertAction(title: "Enter", style: .default) { _ in
            if let textField = alert.textFields?.first, let value = Int(textField.text ?? "") {
                completion(value)
            } else {
                self.showInfoAlert(title: "Invalid Value", message: "Please enter a valid number")
            }
        }
        alert.addAction(enter)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showInfoAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    var sections: [Section] {
        var sections: [Section] = []
        if !SCEPMonetization.shared.isPremium || !SCEPKitInternal.shared.hasPremiumPaywalls {
            sections.append(.banner)
        }
        if !actions.isEmpty {
            sections.append(.actions(header: nil, actions: actions))
        }
        let mainActions: [Action] = [
            .init(title: "Rate us".localized(), image: design.settingsRateImage) { controller in
                controller.openURL(SCEPKitInternal.shared.reviewURL)
            },
            .init(title: "Feedback".localized(), image: design.settingsFeedbackImage) { controller in
                controller.openURL(SCEPKitInternal.shared.feedbackURL)
            },
        ]
        sections.append(.actions(header: "MAIN".localized(), actions: mainActions))
        let legalActions: [Action] = [
            .init(title: "Privacy Policy".localized(), image: design.settingsPrivacyImage) { controller in
                controller.openURL(SCEPKitInternal.shared.privacyURL)
            },
            .init(title: "Terms of Use".localized(), image: design.settingsTermsImage) { controller in
                controller.openURL(SCEPKitInternal.shared.termsURL)
            },
        ]
        sections.append(.actions(header: "LEGAL".localized(), actions: legalActions))
        if SCEPKitInternal.shared.environment != .appstore {
            var debugActions: [Action] = [
                .init(title: "Reset onboarding", image: .init(moduleAssetName: "SettingsDebug")!) { controller in
                    controller.resetOnboarding()
                },
                .init(title: "Show paywalls", image: .init(moduleAssetName: "SettingsDebug")!) { controller in
                    controller.showPaywalls()
                }
            ]
            if !SCEPKitInternal.shared.environment.isUsingProductionProducts {
                debugActions.append(
                    contentsOf: [
                        .init(title: "Premium status: \(SCEPMonetization.shared.premuimStatus.rawValue)", image: .init(moduleAssetName: "SettingsDebug")!) { controller in
                            controller.changePremiumStatus()
                        },
                        .init(title: "Recurring credits: \(SCEPMonetization.shared.recurringCredits)", image: .init(moduleAssetName: "SettingsDebug")!) { controller in
                            controller.changeRecurringCredits()
                        },
                        .init(title: "Additional credits: \(SCEPMonetization.shared.additionalCredits)", image: .init(moduleAssetName: "SettingsDebug")!) { controller in
                            controller.changeAdditionalCredits()
                        }
                    ]
                )
            }
            sections.append(.actions(header: "DEBUG", actions: debugActions))
        }
        return sections
    }
    
    enum Section {
        case banner
        case actions(header: String?, actions: [Action])
    }
}

extension SCEPSettingsController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .banner:
            return 1
        case .actions(_, let buttons):
            return buttons.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .banner:
            let cell = collectionView.dequeueReusableCell(of: SCEPSettingsBannerCell.self, for: indexPath)
            return cell
        case .actions(_, let actions):
            let cell = collectionView.dequeueReusableCell(of: SCEPSettingsActionCell.self, for: indexPath)
            let action = actions[indexPath.item]
            cell.imageView.image = action.image
            cell.imageView.isHidden = action.image == nil
            cell.titleLabel.text = action.title
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var text: String?
        if case .actions(let header, _) = sections[indexPath.section] {
            text = header
        }
        let headerView = collectionView.dequeueReusableSupplementaryView(of: SCEPSettingsHeaderView.self, kind: kind, for: indexPath)
        headerView.titleLabel.text = text
        return headerView
    }
    
    
}

extension SCEPSettingsController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .banner:
            SCEPKitInternal.shared.showPaywallController(from: self, placement: .main)
        case .actions(_, let actions):
            let action = actions[indexPath.item]
            action.handler(self)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
        switch sections[indexPath.section] {
        case .banner:
            return .init(width: width, height: design.settingsBannerHeight)
        case .actions:
            return .init(width: width, height: 56)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        switch sections[section] {
        case .banner:
            return .zero
        case .actions(let header, _):
            return header == nil ? .zero : layout.headerReferenceSize
        }
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var settingsRateImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsRate-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsRate-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsRate-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsRate-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsFeedbackImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsFeedback-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsFeedback-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsFeedback-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsFeedback-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsPrivacyImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsPrivacy-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsPrivacy-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsPrivacy-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsPrivacy-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsTermsImage: UIImage {
        switch self {
        case .classico: return .init(named: "SCEPSettingsTerms-screensOne", in: .module, with: nil)!
        case .salsiccia: return .init(named: "SCEPSettingsTerms-screensTwo", in: .module, with: nil)!
        case .buratino: return .init(named: "SCEPSettingsTerms-screensThree", in: .module, with: nil)!
        case .giornale: return .init(named: "SCEPSettingsTerms-screensFour", in: .module, with: nil)!
        }
    }
    
    var settingsBannerHeight: CGFloat {
        switch self {
        case .classico: return 305
        case .salsiccia: return 305
        case .buratino: return 385
        case .giornale: return 400
        }
    }
}
