//
//  File.swift
//  
//
//  Created by Illia Harkavy on 13/09/2024.
//

import UIKit

extension UIButton {
    
    var title: String? {
        get {
            return title(for: .normal)
        }
        set {
            UIView.performWithoutAnimation {
                setTitle(newValue, for: .normal)
                layoutIfNeeded()
            }
        }
    }
}
