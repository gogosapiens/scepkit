//
//  File.swift
//  
//
//  Created by Illia Harkavy on 01/08/2024.
//

import UIKit

class SCEPButton: UIButton {
    
    @IBInspectable var shadeIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let titleLabel {
            titleLabel.font = SCEPKitInternal.shared.font(ofSize: titleLabel.font.pointSize, weight: titleLabel.font.weight)
        }
        setTitleColor(.scepShade(with: shadeIndex), for: .normal)
        tintColor = .scepShade(with: shadeIndex)
    }
}
