//
//  SCEPFont.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import UIKit

public enum SCEPFont: CaseIterable {
    
    public enum Weight {
        case light, regular, medium, semiBold, bold, extraBold
        var uiWeight: UIFont.Weight {
            switch self {
            case .light:        return .light
            case .regular:      return .regular
            case .medium:       return .medium
            case .semiBold:     return .semibold
            case .bold:         return .bold
            case .extraBold:    return .heavy
            }
        }
        init(uiWeight: UIFont.Weight) {
            switch uiWeight {
            case .light: self = .light
            case .regular: self = .regular
            case .medium: self = .medium
            case .semibold: self = .semiBold
            case .bold: self = .bold
            case .heavy: self = .extraBold
            default: self = .regular
            }
        }
    }
    
    case inter, notoSans, manrope, poppins, system
    
    var familyName: String {
        switch self {
        case .inter:
            return "Inter24pt"
        case .notoSans:
            return "NotoSans"
        case .manrope:
            return "Manrope"
        case .poppins:
            return "Poppins"
        case .system:
            return ""
        }
    }
    
    func uiFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        return uiFont(ofSize: size, weight: .init(uiWeight: weight))
    }
    
    func uiFont(ofSize size: CGFloat, weight: Weight) -> UIFont? {
        guard self != .system else {
            return UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        }
        switch weight {
        case .light:
            return .init(name: "\(familyName)-Light", size: size)
        case .regular:
            return .init(name: "\(familyName)-Regular", size: size)
        case .medium:
            return .init(name: "\(familyName)-Medium", size: size)
        case .semiBold:
            return .init(name: "\(familyName)-SemiBold", size: size)
        case .bold:
            return .init(name: "\(familyName)-Bold", size: size)
        case .extraBold:
            return .init(name: "\(familyName)-ExtraBold", size: size)
        }
    }
}
