//
//  File.swift
//  
//
//  Created by Illia Harkavy on 30/07/2024.
//

import UIKit

extension UIColor {
    
//    public static var scepText: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .accent.withHSB(saturation: 0.1)
//        case .dark:
//            return .accent.withSaturation(0.9)
//        }
//    }
//    
//    public static var scepContrastText: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .accent.withSaturation(0.1)
//        case .dark:
//            return .accent.withSaturation(0.9)
//        }
//    }
    
    static var scepAccent: UIColor { .scepShade(with: -1) }
    static var scepShade0: UIColor { .scepShade(with: 0) }
    static var scepShade1: UIColor { .scepShade(with: 1) }
    static var scepShade2: UIColor { .scepShade(with: 2) }
    static var scepShade3: UIColor { .scepShade(with: 3) }
    static var scepShade4: UIColor { .scepShade(with: 4) }
    
    static func scepShade(with index: Int) -> UIColor {
        if (0...4).contains(index) {
            return .init(named: "SCEPShade\(index)Color", in: .main, compatibleWith: nil) ?? .clear
        } else {
            return .init(named: "SCEPAccentColor", in: .main, compatibleWith: nil) ?? .clear
        }
    }
    
//    static var scepAccent: UIColor {
//        .init(named: "AccentColor", in: .main, compatibleWith: nil) ?? .red
//    }
//    
//    public static var scepShade1: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.6)
//        case .dark:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.4)
//        }
//    }
//    
//    public static var scepShade2: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.85)
//        case .dark:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.3)
//        }
//    }
//    
//    public static var scepShade3: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.9)
//        case .dark:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.15)
//        }
//    }
//    
//    public static var scepShade4: UIColor {
//        switch SCEPKitInternal.shared.interfaceStyle {
//        case .light:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 1)
//        case .dark:
//            return .scepAccent.withHSB(saturation: 0.1, brightness: 0.05)
//        }
//    }
    
    private func withHSB(hue: CGFloat? = nil, saturation: CGFloat? = nil, brightness: CGFloat? = nil, alpha: CGFloat? = nil) -> UIColor {
        var oldHue: CGFloat = 0
        var oldSaturation: CGFloat = 0
        var oldBrightness: CGFloat = 0
        var oldAlpha: CGFloat = 0
        
        if self.getHue(&oldHue, saturation: &oldSaturation, brightness: &oldBrightness, alpha: &oldAlpha) {
            return UIColor(
                hue: hue ?? oldHue,
                saturation: saturation ?? oldSaturation,
                brightness: brightness ?? oldBrightness,
                alpha: alpha ?? oldAlpha
            )
        } else {
            return self
        }
    }
    
    private func relativeLuminance() -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        func adjustColorComponent(_ component: CGFloat) -> CGFloat {
            return component < 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        
        let adjustedRed = adjustColorComponent(red)
        let adjustedGreen = adjustColorComponent(green)
        let adjustedBlue = adjustColorComponent(blue)
        
        return 0.2126 * adjustedRed + 0.7152 * adjustedGreen + 0.0722 * adjustedBlue
    }
}
