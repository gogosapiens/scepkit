//
//  File.swift
//  
//
//  Created by Illia Harkavy on 07/08/2024.
//

import Foundation
import UIKit

struct SCEPConfig: Decodable {
    
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
    
    struct InterfaceStyle: Decodable {
        
        let design: Design
        let theme: Theme
        
        enum Design: String, Codable {
            case classico
            case salsiccia
            case buratino
            case giornale
        }
        enum Theme: String, Codable {
            case dark
            case light
        }
        
        init(from decoder: any Decoder) throws {
            let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
            let id = try container.decode(String.self)
            let components = id.split(separator: ".")
            guard components.count == 2 else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid interface style ID")
            }
            design = .init(rawValue: String(components[0]))!
            theme = .init(rawValue: String(components[1]))!
        }
        
        var uiUserInterfaceStyle: UIUserInterfaceStyle {
            switch theme {
            case .dark:
                return .dark
            case .light:
                return .light
            }
        }
    }
}
