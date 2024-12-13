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
        let initialCredits: Int
        let trialCredits: Int
        let premiumWeeklyCredits: Int
        let placements: [String: Placement]
        let ads: Ads
        let paywalls: [String: SCEPPaywallConfig]
        
        struct Placement: Codable {
            let premium: String?
            let credits: String?
            let noTrialPremium: String?
            
            var all: [String] {
                [premium, credits, noTrialPremium].compactMap(\.self)
            }
        }
        
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
        case classicoDark = "classico.dark"
        case salsicciaDark = "salsiccia.dark"
        case buratinoDark = "buratino.dark"
        case giornaleDark = "giornale.dark"
        case classicoLight = "classico.light"
        case salsicciaLight = "salsiccia.light"
        case buratinoLight = "buratino.light"
        case giornaleLight = "giornale.light"
        
        var uiUserInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .classicoDark, .salsicciaDark, .buratinoDark, .giornaleDark:
                return .dark
            case .classicoLight, .salsicciaLight, .buratinoLight, .giornaleLight:
                return .light
            }
        }
    }
}
