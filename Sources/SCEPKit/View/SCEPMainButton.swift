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
        
        let design = SCEPKitInternal.shared.config.style.design
        
        backgroundColor = .scepAccent
        clipsToBounds = true
        layer.cornerRadius = design.mainButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setTitleColor(.scepButtonTextColor, for: .normal)
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: design.mainButtonTitleFontSize, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var mainButtonCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 28
        case .buratino: return 8
        case .giornale: return 1
        }
    }
    
    var mainButtonTitleFontSize: CGFloat {
        switch self {
        case .classico: return 18
        case .salsiccia: return 18
        case .buratino: return 22
        case .giornale: return 18
        }
    }
}
