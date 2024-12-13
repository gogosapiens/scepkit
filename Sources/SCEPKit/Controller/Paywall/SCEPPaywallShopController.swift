//
//  SCEPPaywallCreditsController.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import UIKit
import Adapty
import GoogleMobileAds

class SCEPPaywallShopController: SCEPPaywallController {
    
    struct Config: Codable {
        let positions: [SCEPPaywallConfig.Position]
        let texts: Texts
        let meta: Meta
        struct Texts: Codable { }
        struct Meta: Codable {
            let imageURL: URL
            let balanceImageURL: URL
        }
    }
    var config: Config!
    
    var rewardedAd: GADRewardedAd?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var balanceImageView: UIImageView!
    @IBOutlet weak var balanceLabel: SCEPLabel!
    @IBOutlet weak var titleLabel: SCEPLabel!
    @IBOutlet weak var closeButton: SCEPButton!
    @IBOutlet weak var termsButton: SCEPButton!
    @IBOutlet weak var privacyButton: SCEPButton!
    @IBOutlet weak var restoreButton: SCEPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Downloader.downloadImage(from: config.meta.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        Downloader.downloadImage(from: config.meta.balanceImageURL) { [weak self] image in
            self?.balanceImageView.image = image
        }
        
        titleLabel.text = .init(localized: "Store", bundle: .module)
        termsButton.title = .init(localized: "Terms", bundle: .module)
        privacyButton.title = .init(localized: "Privacy", bundle: .module)
        restoreButton.title = .init(localized: "Restore", bundle: .module)
        
        balanceLabel.text = SCEPMonetization.shared.credits.formatted()
        
        let style = SCEPKitInternal.shared.config.style
        imageView.layer.cornerRadius = style.paywallShopImageCornerRadius
        
        if let rewardedAdId = config.positions.reduce(nil, { $1.rewardedAdId ?? $0 }) {
            SCEPAdManager.shared.loadRewardedAd(id: rewardedAdId) { [weak self] ad in
                guard let self else { return }
                rewardedAd = ad
                collectionView.reloadData()
            }
        }
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
    
    @IBAction func closeTapped(_ sender: UIButton) {
        close(success: false)
    }
    
    override func showContinueButton() {
        super.showContinueButton()
    }
}

extension SCEPPaywallShopController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: SCEPPaywallShopProductCell.self, for: indexPath)
        
        let position = config.positions[indexPath.item]
        
        switch position {
        case .rewardedAdId(let id):
            if let reward = rewardedAd?.adReward.amount.intValue {
                cell.creditsLabel.text = "\(reward)"
                cell.textLabel.text = .init(localized: "Watch an ad, earn {0} credits!", bundle: .module).insertingArguments(reward)
                cell.actionLabel.text = .init(localized: "Watch ad", bundle: .module)
            } else {
                cell.creditsLabel.text = "-"
                cell.textLabel.text = .init(localized: "Ad is loading. Please wait.", bundle: .module).insertingArguments("-")
                cell.actionLabel.text = .init(localized: "No ad yet", bundle: .module)
            }
            cell.badgeView.isHidden = true
        case .productId(let id):
            let titles = [
                "The perfect starting point.",
                "Perfect for regular use.",
                "Boost your experience.",
                "Go all in with max credits!"
            ]
            let credits = SCEPMonetization.shared.credits(for: id)
            cell.creditsLabel.text = String(credits)
            cell.textLabel.text = String(localized: .init(titles[indexPath.item]), bundle: .module)
            cell.actionLabel.text = position.product?.skProduct.localizedPrice
            cell.badgeView.isHidden = indexPath.item != 2
        }
        
        Downloader.downloadImage(from: config.meta.balanceImageURL) { image in
            cell.balanceImageView.image = image
        }
        
        return cell
    }
}

extension SCEPPaywallShopController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        guard [collectionView.frame.width, collectionView.frame.height].allSatisfy({ $0 > 0 }) else { return .zero }
        let width = (collectionView.frame.width - layout.minimumInteritemSpacing) / 2
        let height = (collectionView.frame.height - layout.minimumLineSpacing) / 2
        return .init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let position = config.positions[indexPath.item]
        
        switch position {
        case .rewardedAdId:
            guard let rewardedAd else { return }
            SCEPAdManager.shared.showRewardedAd(rewardedAd, from: self, placement: "PremiumCredits") { [weak self] rewarded in
                if let self, rewarded {
                    let amount = rewardedAd.adReward.amount.intValue
                    SCEPMonetization.shared.incrementAdditionalCredits(by: amount)
                    close(success: true)
                }
            }
        case .productId:
            guard let product = position.product else { return }
            purchase(product)
        }
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var paywallShopImageCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 32
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
}
