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
        
        let style = SCEPKitInternal.shared.config.style
        
        backgroundColor = .scepAccent
        clipsToBounds = true
        layer.cornerRadius = style.mainButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setTitleColor(.scepButtonTextColor, for: .normal)
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: style.mainButtonTitleFontSize, weight: .bold)
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
    
    var mainButtonTitleFontSize: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 18
        case .salsicciaDark, .salsicciaLight: return 18
        case .buratinoDark, .buratinoLight: return 22
        case .giornaleDark, .giornaleLight: return 18
        }
    }
}
