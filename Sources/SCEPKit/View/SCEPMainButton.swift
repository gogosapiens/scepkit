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
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.plistValue(for: .mainButton, .cornerRadius)
        titleLabel?.font = .main(ofSize: SCEPKitInternal.shared.plistValue(for: .mainButton, .fontSize), weight: .bold)
        print(1)
    }
}
