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
        layer.cornerRadius = SCEPKitInternal.shared.config.style.mainButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setTitleColor(.scepButtonTextColor, for: .normal)
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: 18, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle {
    
    var mainButtonCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 28
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 1
        }
    }
}
