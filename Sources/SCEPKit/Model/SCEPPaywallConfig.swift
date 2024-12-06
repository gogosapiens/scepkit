//
//  SCEPPaywall.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import Foundation

enum SCEPPaywallConfig {
    case vertical(config: SCEPPaywallVerticalController.Config)
    case single(config: SCEPPaywallSingleController.Config)
    case credits(config: SCEPPaywallCreditsController.Config)
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
            return [config.meta.imageURL]
        case .single(let config):
            return [config.meta.imageURL]
        case .credits(let config):
            return [config.meta.imageURL, config.meta.balanceImageURL]
        case .adapty:
            return []
        }
    }
    
    enum Position: Codable {
        case productId(String), rewardedAdId(String)
        
        enum CodingKeys: CodingKey {
            case productId
            case rewardedAdId
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(SCEPPaywallConfig.Position.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
            }
            switch onlyKey {
            case .productId:
                let string = try container.decode(String.self, forKey: onlyKey)
                self = .productId(string)
            case .rewardedAdId:
                let string = try container.decode(String.self, forKey: onlyKey)
                self = .rewardedAdId(string)
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: SCEPPaywallConfig.Position.CodingKeys.self)
            switch self {
            case .productId(let string):
                try container.encode(string, forKey: .productId)
            case .rewardedAdId(let string):
                try container.encode(string, forKey: .rewardedAdId)
            }
        }
    }
}

extension SCEPPaywallConfig: Codable {
    
    private enum CodingKeys: CodingKey {
        case style
        case placementId
    }
    
    private enum BaseType: String, Codable {
        case vertical, single, credits, adapty
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(BaseType.self, forKey: .style) {
        case .vertical:
            self = .vertical(config: try .init(from: decoder))
        case .single:
            self = .single(config: try .init(from: decoder))
        case .credits:
            self = .credits(config: try .init(from: decoder))
        case .adapty:
            let placementId = try container.decode(String.self, forKey: .placementId)
            self = .adapty(placementId: placementId)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .vertical(let config):
            try container.encode(BaseType.vertical, forKey: .style)
            try config.encode(to: encoder)
        case .single(let config):
            try container.encode(BaseType.single, forKey: .style)
            try config.encode(to: encoder)
        case .credits(let config):
            try container.encode(BaseType.credits, forKey: .style)
            try config.encode(to: encoder)
        case .adapty(let placementId):
            try container.encode(BaseType.adapty, forKey: .style)
            try container.encode(placementId, forKey: .placementId)
        }
    }
}
