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
        let enableAppsFlyer: Bool?
    }
    
    struct Integrations: Codable {
        let appleAppId: String
        let testAdaptyApiKey: String?
        let prodAdaptyApiKey: String?
        let amplitudeApiKey: String
        
        var adaptyApiKey: String {
            SCEPKitInternal.shared.environment.isUsingProductionProducts ? prodAdaptyApiKey! : testAdaptyApiKey!
        }
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
            
            var hasPremium: Bool { premium != nil || noTrialPremium != nil }
            var hasCredits: Bool { credits != nil }
        }
        
        struct Ads: Codable {
            let isEnabled: Bool
            let startDelay: TimeInterval?
            let interstitialInterval: TimeInterval?
            
            let testInterstitialId: String?
            let prodInterstitialId: String?
            var interstitialId: String? {
                SCEPKitInternal.shared.environment.isUsingProductionAds ? prodInterstitialId : testInterstitialId
            }
            
            let testAppOpenId: String?
            let prodAppOpenId: String?
            var appOpenId: String? {
                SCEPKitInternal.shared.environment.isUsingProductionAds ? prodAppOpenId : testAppOpenId
            }
            
            let testBannerId: String?
            let prodBannerId: String?
            var bannerId: String? {
                SCEPKitInternal.shared.environment.isUsingProductionAds ? prodBannerId : testBannerId
            }
            
            let testRewardedId: String?
            let prodRewardedId: String?
            var rewardedId: String? {
                SCEPKitInternal.shared.environment.isUsingProductionAds ? prodRewardedId : testRewardedId
            }
        }
    }
    
    struct Onboarding: Codable {
        let texts: Texts
        let meta: Meta
        
        struct Texts: Codable {
            let title0: LocalizedString
            let title1: LocalizedString
            let title2: LocalizedString
        }
        struct Meta: Codable {
            let imageURL0: URL
            let imageURL1: URL
            let imageURL2: URL
            let showRateUs: Bool?
        }
    }
    
    struct Settings: Codable {
        let texts: Texts
        let meta: Meta
        
        struct Texts: Codable {
            let title: LocalizedString
            let subtitle: LocalizedString?
            let feature0: LocalizedString
            let feature1: LocalizedString
            let feature2: LocalizedString
            let feature3: LocalizedString
        }
        struct Meta: Codable {}
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
        
        init(design: Design, theme: Theme) {
            self.design = design
            self.theme = theme
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
