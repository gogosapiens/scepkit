//
//  SCEPSettingsBannerCell.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 24/12/2024.
//

import UIKit

class SCEPSettingsBannerCell: SCEPAnimatedCollectionViewCell {
    
    @IBOutlet weak var bannerTitleLabel: SCEPLabel!
    @IBOutlet weak var bannerSubtitleLabel: SCEPLabel!
    @IBOutlet weak var bannerFeature0Label: SCEPLabel!
    @IBOutlet weak var bannerFeature1Label: SCEPLabel!
    @IBOutlet weak var bannerFeature2Label: SCEPLabel!
    @IBOutlet weak var bannerFeature3Label: SCEPLabel!
    @IBOutlet weak var bannerButton: SCEPMainButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var bannerTopStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let style = SCEPKitInternal.shared.config.style
        let config = SCEPKitInternal.shared.config.settings
        let texts = config.texts
        
        bannerButton.title = "Get started".localized()
        
        bannerTitleLabel.text = texts.title.localized()
        bannerTitleLabel.styleTextColorWithBraces()
        bannerTitleLabel.numberOfLines = texts.subtitle == nil ? 0 : 1
        bannerTitleLabel.textAlignment = style.isSettingsBannerVertical ? .center : .left
        bannerSubtitleLabel.text = texts.subtitle?.localized()
        bannerSubtitleLabel.alpha = 0.8
        bannerSubtitleLabel.isHidden = texts.subtitle == nil
        bannerSubtitleLabel.textAlignment = style.isSettingsBannerVertical ? .center : .left
        let featureLabels: [SCEPLabel] = [bannerFeature0Label!, bannerFeature1Label!, bannerFeature2Label!, bannerFeature3Label!]
        let featureTexts = [texts.feature0, texts.feature1, texts.feature2, texts.feature3]
        for (label, text) in zip(featureLabels, featureTexts) {
            label.text = text.localized()
        }
        bannerImageView.image = .init(named: "SCEPAppIcon")
        
        layer.cornerRadius = style.design.settingsBannerCornerRadius
        bannerTopStackView.removeArrangedSubview(bannerImageView)
        bannerTopStackView.insertArrangedSubview(bannerImageView, at: style.design.settingsImageIndex)
        bannerTopStackView.axis = style.isSettingsBannerVertical ? .vertical : .horizontal
        bannerTopStackView.alignment = .center
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var settingsBannerCornerRadius: CGFloat {
        switch self {
        case .classico: return 32
        case .salsiccia: return 32
        case .buratino: return 8
        case .giornale: return 32
        }
    }
    
    var settingsImageIndex: Int {
        switch self {
        case .classico: return 1
        case .salsiccia: return 0
        case .buratino: return 0
        case .giornale: return 0
        }
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var isSettingsBannerVertical: Bool {
        return design == .giornale && theme == .light
    }
}
