import UIKit
import Adapty

class SCEPPaywallRobotController: SCEPPaywallController {
    
    struct Config: Codable {
        let positions: [SCEPPaywallConfig.Position]
        let texts: Texts
        let meta: Meta
        struct Texts: Codable {
            let title: LocalizedString
            let feature0: LocalizedString
            let feature1: LocalizedString
            let feature2: LocalizedString
            let feature3: LocalizedString
        }
        struct Meta: Codable {
            let imageURL: URL
        }
    }
    var config: Config!
    
    var selectedProductIndex: Int!
    
    var displayProducts: [SCEPPaywallProduct] { products.enumerated().map { $1 ?? otherProducts[$0]! } }
    var products: [SCEPPaywallProduct?] { trialSwitch.isOn ? trialProducts : nonTrialProducts }
    var otherProducts: [SCEPPaywallProduct?] { trialSwitch.isOn ? nonTrialProducts : trialProducts }
    
    var trialProducts: [SCEPPaywallProduct?] {
        if config.positions.count == 3 {
            return [ nil, config.positions[2].product ]
        } else {
            return [ nil, nil ]
        }
    }
    var nonTrialProducts: [SCEPPaywallProduct?] {
        [
            config.positions[0].product,
            config.positions[1].product
        ]
    }

    @IBOutlet weak var continueButton: SCEPMainButton!
    @IBOutlet weak var trialSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trialView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: SCEPLabel!
    @IBOutlet weak var feature0Label: SCEPLabel!
    @IBOutlet weak var feature1Label: SCEPLabel!
    @IBOutlet weak var feature2Label: SCEPLabel!
    @IBOutlet weak var feature3Label: SCEPLabel!
    @IBOutlet weak var trialLabel: SCEPLabel!
    @IBOutlet weak var cancelAnytimeLabel: SCEPLabel!
    @IBOutlet weak var termsButton: SCEPButton!
    @IBOutlet weak var privacyButton: SCEPButton!
    @IBOutlet weak var restoreButton: SCEPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if placement == .onboarding {
            continueButton.alpha = 0
        }
        selectedProductIndex = 0
        trialSwitch.isOn = false
        trialSwitch.onTintColor = .scepAccent
        trialSwitch.thumbTintColor = .scepTextColor
        trialView.layer.borderColor = UIColor.scepShade2.cgColor
        trialView.layer.borderWidth = 2
        trialView.layer.cornerRadius = SCEPKitInternal.shared.config.style.design.paywallTrialSwitchCornerRadius
        trialView.isHidden = trialProducts.allSatisfy { $0 == nil }
        
        setupTexts()
        imageView.image = nil
        Downloader.downloadImage(from: config.meta.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        trialLabel.text = "Enable free trial".localized()
        cancelAnytimeLabel.text = "CANCEL ANYTIME".localized()
        termsButton.title = "Terms".localized()
        privacyButton.title = "Privacy".localized()
        restoreButton.title = "Restore".localized()
        continueButton.title = "Continue".localized()
    }
    
    func setupTexts() {
        titleLabel.text = config.texts.title.localized()
        titleLabel.styleTextWithBraces()
        let labels = [feature0Label, feature1Label, feature2Label, feature3Label]
        let features = [config.texts.feature0, config.texts.feature1, config.texts.feature2, config.texts.feature3]
        for (label, feature) in zip(labels, features) {
            label?.text = feature.localized()
        }
    }
    
    @IBAction func trialSwitchValueChanged(_ sender: UISwitch) {
        trialSwitch.setOn(trialSwitch.isOn, animated: true)
        if products[selectedProductIndex] == nil {
            selectedProductIndex = selectedProductIndex == 0 ? 1 : 0
        }
        tableView.reloadData()
    }
    
    @IBAction func continueTapped(_ sender: SCEPMainButton) {
        guard let product = products[selectedProductIndex] else { return }
        purchase(product)
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.privacyURL)
    }
    
    @IBAction func restoreTapped(_ sender: UIButton) {
        restore()
    }
    
    override func showContinueButton() {
        super.showContinueButton()
        continueButton.alpha = 1
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close(success: false)
    }
}

extension SCEPPaywallRobotController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: SCEPPaywallRobotProductCell.self, for: indexPath)
        let product = displayProducts[indexPath.row]
        let isSelected = indexPath.row == selectedProductIndex
        
        let periods = displayProducts.map { $0.subscriptionPeriod! }
        let shortPeroid = periods.min(by: { $0.duration < $1.duration })!
        let period = product.subscriptionPeriod!
        let introductoryPeriod = product.introductoryPeriod
        
        cell.outlineView.layer.borderColor = isSelected ? UIColor.scepAccent.cgColor : UIColor.scepShade2.cgColor
        
        if indexPath.row == 0 {
            cell.badgeShadowView.isHidden = isSelected
            cell.badgeView.isHidden = false
            cell.badgeLabel.text = "BEST OFFER".localized()
            cell.leftTitleLabel.text = "{0} ACCESS".localized().insertingArguments(period.displayUnitLocalizedAdjective.uppercased())
            cell.leftSubtitleLabel.text = "Just {0} per {1}".localized().insertingArguments(product.localizedPrice, period.displayUnitLocalizedNoun)
            cell.leftSubtitleLabel.isHidden = false
            cell.rightTitleLabel.text = product.localizedPrice(for: shortPeroid)
            cell.rightSubtitleLabel.text = "per {0}".localized().insertingArguments(shortPeroid.displayUnitLocalizedNoun.lowercased())
            cell.rightSubtitleLabel.isHidden = false
        } else {
            
            cell.badgeShadowView.isHidden = true
            cell.badgeView.isHidden = true
            if let introductoryPeriod {
                cell.leftTitleLabel.text = "{0}-DAY FREE TRIAL".localized().insertingArguments(introductoryPeriod.displayNumberOfUnits)
            } else {
                cell.leftTitleLabel.text = "{0} ACCESS".localized().insertingArguments(period.displayUnitLocalizedAdjective.uppercased())
            }
            cell.leftSubtitleLabel.isHidden = true
            cell.rightTitleLabel.text = product.localizedPrice(for: shortPeroid)
            cell.rightSubtitleLabel.text = "per {0}".localized().insertingArguments(shortPeroid.displayUnitLocalizedNoun.lowercased())
            cell.rightSubtitleLabel.isHidden = false
        }
        
        return cell
    }
}

extension SCEPPaywallRobotController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        selectedProductIndex = indexPath.row
        if products[selectedProductIndex] == nil {
            trialSwitch.setOn(!trialSwitch.isOn, animated: true)
        }
        tableView.reloadData()
    }
}
