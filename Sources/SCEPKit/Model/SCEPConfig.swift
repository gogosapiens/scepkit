//
//  File.swift
//  
//
//  Created by Illia Harkavy on 07/08/2024.
//

import Foundation
import UIKit

struct SCEPConfig: Codable {
    
    let app: App
    let onboarding: Onboarding
    let settings: Settings
    let paywalls: [String: Paywall]
    
    enum ProductType: String, Codable {
        case short, shortTrial, long
    }
    
    func paywall(for placement: SCEPPaywallPlacement) -> Paywall {
        return paywalls[placement.id]!
    }
    
    struct App: Codable {
        
        let termsURL: URL
        let privacyURL: URL
        let feedbackURL: URL
        
        let appleAppId: String
        let adaptyApiKey: String
        
        let style: InterfaceStyle
        let fontNames: [String: String]
        
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
        
        var reviewURL: URL { .init(string: "https://itunes.apple.com/app/id\(appleAppId)?action=write-review")! }
        
        let productsIds: [String: String]
    }
    
    struct Onboarding: Codable {
        
        let buttonTitle: String
        let slides: [Slide]
        
        struct Slide: Codable {
            let imageURL: URL
            let title: String
        }
    }
    
    enum Paywall: Codable {
        case vertical(config: SCEPPaywallVerticalController.Config)
        case single(config: SCEPPaywallSingleController.Config)
        case adapty(placementId: String)
        
        var adaptyPlacementId: String {
            if case .adapty(let placementId) = self {
                return placementId
            } else {
                return "custom"
            }
        }
        
        var imageURLs: [URL] {
            switch self {
            case .vertical(let config):
                return [config.imageURL]
            case .single(let config):
                return [config.imageURL]
            case .adapty:
                return []
            }
        }
    }
    
    struct Settings: Codable {
        let title: String
        let titleAccents: [String]
        let subtitle: String?
        let features: [String]
        let buttonTitle: String
        let imageURL: URL
    }
    
    enum InterfaceStyle: String, Codable {
        case screensOneDark, screensOneLight, screensTwoDark, screensThreeDark, screensFourDark
        
        var uiUserInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .screensOneDark: return .dark
            case .screensOneLight:  return .light
            case .screensTwoDark: return .dark
            case .screensThreeDark: return .dark
            case .screensFourDark: return .dark
            }
        }
    }
}
