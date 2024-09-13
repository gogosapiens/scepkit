//
//  SCEPButton.swift
//  
//
//  Created by Illia Harkavy on 14/07/2024.
//

import UIKit

class SCEPMainButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .scepAccent
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.app.style.mainButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel?.textColor = .scepText
        titleLabel?.font = SCEPKitInternal.shared.config.app.font(ofSize: 18, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle {
    
    var mainButtonCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 28
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
}
