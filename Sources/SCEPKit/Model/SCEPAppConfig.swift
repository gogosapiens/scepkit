//
//  File.swift
//  
//
//  Created by Illia Harkavy on 07/08/2024.
//

import Foundation
import UIKit

struct SCEPAppConfig: Codable {
        
    let termsURL: URL
    let privacyURL: URL
    let feedbackURL: URL
    
    let appleAppId: String
    let adaptyApiKey: String
    
    let interface: Interface
    
    var reviewURL: URL { .init(string: "https://itunes.apple.com/app/id\(appleAppId)?action=write-review")! }
    
    struct Interface: Codable {
        let style: SCEPKitInternal.InterfaceStyle
        let fontNames: [String: String]
        let mainButton: MainButton
        
        func font(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
            var fontName: String?
            switch weight {
            case .medium:
                fontName = fontNames["medium"]
            case .semibold:
                fontName = fontNames["semibold"]
            case .bold:
                fontName = fontNames["bold"]
            default:
                fontName = nil
            }
            if let fontName, let font = UIFont(name: fontName, size: size) {
                return font
            } else {
                return .systemFont(ofSize: size, weight: weight)
            }
        }
        
        struct MainButton: Codable {
            let cornerRadius: CGFloat
            let fontSize: CGFloat
        }
    }
    
    static let temp = SCEPAppConfig(
        termsURL: .init(string: "https://apple.com")!,
        privacyURL: .init(string: "https://apple.com")!,
        feedbackURL: .init(string: "https://apple.com")!,
        appleAppId: "6526484220",
        adaptyApiKey: "public_live_CsJs0kBU.Q8hsYwGXGkH459XYUKTL",
        interface: .init(
            style: .dark,
            fontNames: [
                "medium": "InstrumentSans-Regular_SemiBold",
                "semibold": "InstrumentSans-Regular_Bold",
                "bold": "InstrumentSans-Regular_Bold"
            ],
            mainButton: .init(
                cornerRadius: 16,
                fontSize: 18
            )
        )
    )
}
