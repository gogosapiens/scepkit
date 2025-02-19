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
        
        imageView.image = nil
        Downloader.downloadImage(from: config.meta.imageURL) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleLabel.text = "Store".localized()
        termsButton.title = "Terms".localized()
        privacyButton.title = "Privacy".localized()
        restoreButton.title = "Restore".localized()
        
        balanceLabel.text = SCEPMonetization.shared.credits.formatted()
        
        let design = SCEPKitInternal.shared.config.style.design
        imageView.superview?.layer.cornerRadius = design.paywallShopImageCornerRadius
        balanceImageView.image = design.paywallShopBalanceImage
        
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
            
        if position.rewardedAdId != nil {
            if let reward = rewardedAd?.adReward.amount.intValue {
                cell.creditsLabel.text = "\(reward)"
                cell.textLabel.text = "Watch an ad, earn {0} credits!".localized().insertingArguments(reward)
                cell.actionLabel.text = "Watch ad".localized()
            } else {
                cell.creditsLabel.text = "-"
                cell.textLabel.text = "Ad is loading. Please wait.".localized().insertingArguments("-")
                cell.actionLabel.text = "No ad yet".localized()
            }
            cell.badgeView.isHidden = true
        } else if let productId = position.productId {
            let titles = [
                "The perfect starting point.".localized(),
                "Perfect for regular use.".localized(),
                "Boost your experience.".localized(),
                "Go all in with max credits!".localized()
            ]
            let credits = SCEPMonetization.shared.credits(for: productId)
            cell.creditsLabel.text = String(credits)
            cell.textLabel.text = titles[indexPath.item]
            cell.actionLabel.text = position.product?.localizedPrice
            cell.badgeView.isHidden = indexPath.item != 2
        }
        
        let design = SCEPKitInternal.shared.config.style.design
        cell.balanceImageView.image = design.paywallShopBalanceImage
        
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

extension SCEPConfig.InterfaceStyle.Design {
    
    var paywallShopImageCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 24
        case .buratino: return 8
        case .giornale: return 12
        }
    }
    
    var paywallShopBalanceImage: UIImage {
        return .init(moduleAssetName: "PaywallShopBalance", design: self)!
    }
}
