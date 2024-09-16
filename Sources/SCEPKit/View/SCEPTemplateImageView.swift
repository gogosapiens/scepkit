//
//  File.swift
//  
//
//  Created by Illia Harkavy on 16/09/2024.
//

import UIKit

class SCEPTemplateImageView: UIImageView {
    
    @IBInspectable var shadeIndex: Int = 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = .scepShade(with: shadeIndex)
    }
}
