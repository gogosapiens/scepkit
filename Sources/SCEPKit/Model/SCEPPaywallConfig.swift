//
//  SCEPPaywall.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import Foundation

enum SCEPPaywallConfig {
    case robot(config: SCEPPaywallRobotController.Config)
    case cat(config: SCEPPaywallCatController.Config)
    case shop(config: SCEPPaywallShopController.Config)
    case adapty(placementId: String)
    
    var adaptyPlacementId: String {
        if case .adapty(let placementId) = self {
            return placementId
        } else {
            return "custom"
        }
    }
    
    var imageURLs: Set<URL> {
        switch self {
        case .robot(let config):
            return [config.meta.imageURL]
        case .cat(let config):
            return [config.meta.imageURL]
        case .shop(let config):
            return [config.meta.imageURL]
        case .adapty:
            return []
        }
    }
    
    enum Position: Codable {
        case productId(test: String?, prod: String?), rewardedAdId(test: String?, prod: String?)
        
        enum CodingKeys: CodingKey {
            case testProductId
            case prodProductId
            case testRewardedAdId
            case prodRewardedAdId
        }
        
        var productId: String? {
            if case .productId(let testId, let prodId) = self {
                return SCEPKitInternal.shared.environment.isUsingProductionProducts ? prodId : testId
            } else {
                return nil
            }
        }
        
        var rewardedAdId: String? {
            if case .rewardedAdId(let testId, let prodId) = self {
                return SCEPKitInternal.shared.environment.isUsingProductionAds ? prodId : testId
            } else {
                return nil
            }
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var allKeys = ArraySlice(container.allKeys)
            if container.allKeys.contains(.testProductId) || container.allKeys.contains(.prodProductId) {
                let testId = try container.decodeIfPresent(String.self, forKey: .testProductId)
                let prodId = try container.decodeIfPresent(String.self, forKey: .prodProductId)
                self = .productId(test: testId, prod: prodId)
            } else if container.allKeys.contains(.testRewardedAdId) || container.allKeys.contains(.prodRewardedAdId) {
                let testId = try container.decodeIfPresent(String.self, forKey: .testRewardedAdId)
                let prodId = try container.decodeIfPresent(String.self, forKey: .prodRewardedAdId)
                self = .rewardedAdId(test: testId, prod: prodId)
            } else {
                throw DecodingError.typeMismatch(SCEPPaywallConfig.Position.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found", underlyingError: nil))
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: SCEPPaywallConfig.Position.CodingKeys.self)
            switch self {
            case .productId(let test, let prod):
                try container.encodeIfPresent(test, forKey: .testProductId)
                try container.encodeIfPresent(prod, forKey: .prodProductId)
            case .rewardedAdId(let test, let prod):
                try container.encodeIfPresent(test, forKey: .testRewardedAdId)
                try container.encodeIfPresent(prod, forKey: .prodRewardedAdId)
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
        case robot, cat, shop, adapty
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(BaseType.self, forKey: .style) {
        case .robot:
            self = .robot(config: try .init(from: decoder))
        case .cat:
            self = .cat(config: try .init(from: decoder))
        case .shop:
            self = .shop(config: try .init(from: decoder))
        case .adapty:
            let placementId = try container.decode(String.self, forKey: .placementId)
            self = .adapty(placementId: placementId)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .robot(let config):
            try container.encode(BaseType.robot, forKey: .style)
            try config.encode(to: encoder)
        case .cat(let config):
            try container.encode(BaseType.cat, forKey: .style)
            try config.encode(to: encoder)
        case .shop(let config):
            try container.encode(BaseType.shop, forKey: .style)
            try config.encode(to: encoder)
        case .adapty(let placementId):
            try container.encode(BaseType.adapty, forKey: .style)
            try container.encode(placementId, forKey: .placementId)
        }
    }
}
