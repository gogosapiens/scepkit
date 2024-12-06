//
//  File.swift
//  
//
//  Created by Illia Harkavy on 07/08/2024.
//

import Foundation
import UIKit

struct SCEPConfig: Codable {
    
    let style: InterfaceStyle
    let legal: Legal
    let integrations: Integrations
    let monetization: Monetization
    let onboarding: Onboarding
    let settings: Settings
    
    enum ProductType: String, Codable {
        case short, shortTrial, long
    }
    
    func paywall(for placement: SCEPPaywallPlacement) -> SCEPPaywallConfig {
        let paywallId = monetization.placements[placement.id]!
        return monetization.paywalls[paywallId]!
    }
    
    struct Legal: Codable {
        let termsURL: URL
        let privacyURL: URL
        let feedbackURL: URL
        let requestTracking: Bool
    }
    
    struct Integrations: Codable {
        let appleAppId: String
        let adaptyApiKey: String
        let amplitudeApiKey: String
    }
    
    struct Monetization: Codable {
        let placements: [String: String]
        let ads: Ads
        let paywalls: [String: SCEPPaywallConfig]
        
        struct Ads: Codable {
            let isEnabled: Bool
            let startDelay: TimeInterval?
            let interstitialInterval: TimeInterval?
            let interstitialId: String?
            let appOpenId: String?
            let bannerId: String?
            let rewardedId: String?
        }
    }
    
    struct Onboarding: Codable {
        
        let slides: [Slide]
        
        struct Slide: Codable {
            let imageURL: URL
            let title: LocalizedString
        }
    }
    
    struct Settings: Codable {
        let title: LocalizedString
        let subtitle: LocalizedString?
        let features: [LocalizedString]
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
