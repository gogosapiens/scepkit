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
        
        let config = SCEPKitInternal.shared.config.app.interface.mainButton
        
        backgroundColor = .scepAccent
        clipsToBounds = true
        layer.cornerRadius = config.cornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel?.textColor = .scepText
        titleLabel?.font = SCEPKitInternal.shared.config.app.interface.font(ofSize: config.fontSize, weight: .bold)
    }
    
    var title: String? {
        get {
            title(for: .normal)
        }
        set {
            UIView.performWithoutAnimation {
                setTitle(newValue, for: .normal)
                layoutIfNeeded()
            }
        }
    }
}
