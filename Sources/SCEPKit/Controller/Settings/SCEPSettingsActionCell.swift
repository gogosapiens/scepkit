//
//  SCEPSettingsActionCell.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 24/12/2024.
//

import UIKit

class SCEPSettingsActionCell: SCEPAnimatedCollectionViewCell {
    
    @IBOutlet weak var imageView: SCEPTemplateImageView!
    @IBOutlet weak var titleLabel: SCEPLabel!
    @IBOutlet weak var chevronImageView: SCEPTemplateImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.style.design.settingsActionCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel.textColor = .scepTextColor
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: 16, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var settingsActionCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 28
        case .buratino: return 8
        case .giornale: return 12
        }
    }
}
