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
    @IBOutlet var bannerFeaturesStackViews: [UIStackView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let design = SCEPKitInternal.shared.config.style.design
        let config = SCEPKitInternal.shared.config.settings
        let texts = config.texts
        
        bannerButton.title = "Get started".localized()
        
        bannerTitleLabel.text = texts.title.localized()
        bannerTitleLabel.styleTextWithBraces()
        bannerSubtitleLabel.text = texts.subtitle?.localized()
        bannerSubtitleLabel.alpha = 0.8
        bannerSubtitleLabel.isHidden = texts.subtitle == nil
        let featureLabels: [SCEPLabel] = [bannerFeature0Label!, bannerFeature1Label!, bannerFeature2Label!, bannerFeature3Label!]
        let featureTexts = [texts.feature0, texts.feature1, texts.feature2, texts.feature3]
        for (label, text) in zip(featureLabels, featureTexts) {
            label.text = text.localized()
        }
        bannerImageView.image = .init(named: "SCEPAppIcon")
        
        layer.cornerRadius = design.settingsBannerCornerRadius
        bannerTopStackView.axis = design.settingsTopAxis
        bannerTopStackView.alignment = design.settingsTopAxis == .horizontal ? .fill : .center
        bannerFeaturesStackViews.forEach { $0.axis = design.settingsFeatureAxis }
        bannerTopStackView.removeArrangedSubview(bannerImageView)
        bannerTopStackView.insertArrangedSubview(bannerImageView, at: design.settingsImageIndex)
        bannerTitleLabel.textAlignment = design.settingsTextAlignment
        bannerSubtitleLabel.textAlignment = design.settingsTextAlignment
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
    
    var settingsTopAxis: NSLayoutConstraint.Axis {
        switch self {
        case .classico: return .horizontal
        case .salsiccia: return .horizontal
        case .buratino: return .horizontal
        case .giornale: return .vertical
        }
    }
    
    var settingsFeatureAxis: NSLayoutConstraint.Axis {
        switch self {
        case .classico: return .horizontal
        case .salsiccia: return .horizontal
        case .buratino: return .vertical
        case .giornale: return .horizontal
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
    
    var settingsTextAlignment: NSTextAlignment {
        switch self {
        case .classico: return .left
        case .salsiccia: return .left
        case .buratino: return .left
        case .giornale: return .center
        }
    }
}
