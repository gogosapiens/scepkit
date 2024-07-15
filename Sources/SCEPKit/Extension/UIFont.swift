//
//  File.swift
//  
//
//  Created by Illia Harkavy on 14/07/2024.
//

import UIKit

extension UIFont {
    
    static func main(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let name: String
        switch weight {
        case .medium:
            name = SCEPKitInternal.shared.plistString(for: .adaptyApiKey)
        case .semibold:
            suffix = "_SemiBold"
        case .bold:
            suffix = "_Bold"
        default:
            suffix = ""
        }
        return UIFont(name: "InstrumentSans-Regular\(suffix)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
}
