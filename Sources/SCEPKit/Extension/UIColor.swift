//
//  File.swift
//  
//
//  Created by Illia Harkavy on 30/07/2024.
//

import UIKit

extension UIColor {
    
    static var scepButtonTextColor: UIColor { .scepShade(with: -1) }
    static var scepTextColor: UIColor { .scepShade(with: 0) }
    static var scepShade1: UIColor { .scepShade(with: 1) }
    static var scepShade2: UIColor { .scepShade(with: 2) }
    static var scepShade3: UIColor { .scepShade(with: 3) }
    static var scepShade4: UIColor { .scepShade(with: 4) }
    static var scepAccent: UIColor { .scepShade(with: 5) }
    
    static func scepShade(with index: Int) -> UIColor {
        if index == -1 {
            return .init(named: "SCEPButtonTextColor", in: .main, compatibleWith: nil) ?? .clear
        } else if index == 0 {
            return .init(named: "SCEPTextColor", in: .main, compatibleWith: nil) ?? .clear
        } else if (1...4).contains(index) {
            return .init(named: "SCEPShade\(index)Color", in: .main, compatibleWith: nil) ?? .clear
        } else {
            return .init(named: "SCEPAccentColor", in: .main, compatibleWith: nil) ?? .clear
        }
    }
}
