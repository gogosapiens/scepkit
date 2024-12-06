//
//  SCEPFont.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import UIKit

enum SCEPFont: CaseIterable {
    
    case inter, notoSans, manrope, instrumentSans, poppins, system
    
    var familyName: String {
        switch self {
        case .inter:
            return "Inter28pt"
        case .notoSans:
            return "NotoSans"
        case .manrope:
            return "Manrope"
        case .instrumentSans:
            return "InstrumentSans"
        case .poppins:
            return "Poppins"
        case .system:
            return ""
        }
    }
    
    func uiFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        guard self != .system else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        switch weight {
        case .medium:
            return .init(name: "\(familyName)-Medium", size: size)
        case .semibold:
            return .init(name: "\(familyName)-SemiBold", size: size)
        case .bold:
            return .init(name: "\(familyName)-Bold", size: size)
        default:
            return nil
        }
    }
}
