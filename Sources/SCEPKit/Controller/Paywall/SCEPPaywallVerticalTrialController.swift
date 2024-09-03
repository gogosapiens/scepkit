//
//  SCEPPaywallVerticalTrialController.swift
//  
//
//  Created by Illia Harkavy on 01/08/2024.
//

import UIKit
import Adapty

class SCEPPaywallVerticalTrialController: SCEPPaywallController {
    
    struct Config: Codable {
        let imageURL: URL
        let title: String
        let titleAccents: [String]
        let features: [String]
        let buttonTitle: String
        let selectedIndex: Int
        let isTrialSelected: Bool
    }
    var config: Config!
    
    var selectedProductIndex: Int!
    
    var displayProducts: [AdaptyPaywallProduct] { products.enumerated().map { $1 ?? otherProducts[$0]! } }
    var products: [AdaptyPaywallProduct?] { trialSwitch.isOn ? trialProducts : nonTrialProducts }
    var otherProducts: [AdaptyPaywallProduct?] { trialSwitch.isOn ? nonTrialProducts : trialProducts }
    
    var trialProducts: [AdaptyPaywallProduct?] {
        [ nil, SCEPKitInternal.shared.product(with: .shortTrial) ]
    }
    var nonTrialProducts: [AdaptyPaywallProduct?] {
        [ SCEPKitInternal.shared.product(with: .long), SCEPKitInternal.shared.product(with: .short) ]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if placement == .onboarding {
            continueButton.alpha = 0
        }
        selectedProductIndex = config.selectedIndex
        trialSwitch.isOn = config.isTrialSelected
        trialView.layer.borderColor = UIColor.scepShade2.cgColor
        setupTexts()
        Downloader.downloadImage(from: config.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    func setupTexts() {
        continueButton.title = config.buttonTitle
        titleLabel.text = config.title
        let attributedTitle = NSMutableAttributedString(attributedString: titleLabel.attributedText!)
        for accent in config.titleAccents {
            attributedTitle.addAttributes(
                [.foregroundColor: UIColor.scepAccent],
                range: NSString(string: attributedTitle.string).range(of: accent)
            )
        }
        titleLabel.attributedText = attributedTitle
        [feature0Label, feature1Label, feature2Label, feature3Label].enumerated().forEach { index, label in
            if index < config.features.count {
                label?.text = config.features[index]
            } else {
                label?.superview?.superview?.isHidden = true
            }
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
        Adapty.makePurchase(product: product) { [weak self] result in
            switch result {
            case .success(let info):
//                logger.debug("Purchase success \(info)")
                self?.close()
            case .failure(let error):
                logger.error("Purchase error \(error)")
            }
        }
    }
    
    @IBAction func termsTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.config.app.termsURL)
    }
    
    @IBAction func privacyTapped(_ sender: UIButton) {
        openURL(SCEPKitInternal.shared.config.app.privacyURL)
    }
    
    @IBAction func restoreTapped(_ sender: UIButton) {
        Adapty.restorePurchases { result in
            switch result {
            case .success(let profile):
                print(profile)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func showContinueButton() {
        super.showContinueButton()
        continueButton.alpha = 1
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close()
    }
}

extension SCEPPaywallVerticalTrialController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: SCEPPaywallVerticalTrialProductCell.self, for: indexPath)
        let product = displayProducts[indexPath.row]
        let isSelected = indexPath.row == selectedProductIndex
        
        let periods = displayProducts.map { $0.skProduct.subscriptionPeriod! }
        let shortPeroid = periods.min(by: { $0.duration < $1.duration })!
        let period = product.skProduct.subscriptionPeriod!
        let introductoryPeriod = product.skProduct.introductoryPrice?.subscriptionPeriod
        
        cell.outlineView.layer.borderColor = isSelected ? UIColor.scepAccent.cgColor : UIColor.scepShade2.cgColor
        
        if indexPath.row == 0 {
            cell.badgeShadowImageView.isHidden = isSelected
            cell.badgeView.isHidden = false
            cell.badgeLabel.text = "BEST OFFER"
            cell.leftTitleLabel.text = "\(period.displayUnitString.uppercased())LY ACCESS"
            cell.leftSubtitleLabel.text = "Just \(product.skProduct.localizedPrice) per year"
            cell.leftSubtitleLabel.isHidden = false
            cell.rightTitleLabel.text = product.skProduct.localizedPrice(for: shortPeroid)
            cell.rightSubtitleLabel.text = "per \(shortPeroid.displayUnitString.lowercased())"
            cell.rightSubtitleLabel.isHidden = false
        } else {
            
            cell.badgeShadowImageView.isHidden = true
            cell.badgeView.isHidden = true
            if let introductoryPeriod {
                cell.leftTitleLabel.text = "\(introductoryPeriod.displayNumberOfUnits)-\(introductoryPeriod.displayUnitString.uppercased()) FREE TRIAL"
            } else {
                cell.leftTitleLabel.text = "\(period.displayUnitString.uppercased())LY ACCESS"
            }
            cell.leftSubtitleLabel.isHidden = true
            cell.rightTitleLabel.text = product.skProduct.localizedPrice(for: shortPeroid)
            cell.rightSubtitleLabel.text = "per \(shortPeroid.displayUnitString.lowercased())"
            cell.rightSubtitleLabel.isHidden = false
        }
        
        return cell
    }
}

extension SCEPPaywallVerticalTrialController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        selectedProductIndex = indexPath.row
        if products[selectedProductIndex] == nil {
            trialSwitch.setOn(!trialSwitch.isOn, animated: true)
        }
        tableView.reloadData()
    }
}
