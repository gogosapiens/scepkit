//
//  File.swift
//  
//
//  Created by Illia Harkavy on 01/08/2024.
//

import UIKit

class SCEPLabel: UILabel {
    
    @IBInspectable var shadeIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = SCEPKitInternal.shared.font(ofSize: font.pointSize, weight: font.weight)
        textColor = .scepShade(with: shadeIndex)
    }
}
