//
//  File.swift
//  
//
//  Created by Illia Harkavy on 01/08/2024.
//

import UIKit

class SCEPButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let titleLabel {
            titleLabel.font = SCEPKitInternal.shared.config.app.font(ofSize: titleLabel.font.pointSize, weight: titleLabel.font.weight)
        }
    }
}
