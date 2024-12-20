//
//  UIImage.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 19/12/2024.
//

import UIKit

extension UIImage {
    
    convenience init?(moduleAssetName: String, design: SCEPConfig.InterfaceStyle.Design?) {
        var name = ""
        if !moduleAssetName.hasPrefix("SCEP") {
            name = "SCEP"
        }
        name += moduleAssetName
        if let design {
            name += "-" + design.rawValue
        }
        self.init(named: name, in: .module, with: nil)
    }
}
