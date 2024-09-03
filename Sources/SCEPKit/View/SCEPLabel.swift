//
//  File.swift
//  
//
//  Created by Illia Harkavy on 01/08/2024.
//

import UIKit

class SCEPLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = SCEPKitInternal.shared.config.app.font(ofSize: font.pointSize, weight: font.weight)
    }
}
