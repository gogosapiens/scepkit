//
//  SCEPProduct.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 22/01/2025.
//

import StoreKit
import Adapty

protocol SCEPPaywallProduct {
    
    var subscriptionPeriod: SCEPPaywallProductPeriod? { get }
    var price: NSDecimalNumber { get }
    var introductoryPeriod: SCEPPaywallProductPeriod? { get }
    var introductoryPrice: NSDecimalNumber? { get }
    var priceLocale: Locale { get }
}

struct SCEPFailedPaywallProduct: SCEPPaywallProduct {
    
    var introductoryPrice: NSDecimalNumber? = nil
    
    var subscriptionPeriod: SCEPPaywallProductPeriod? = .init(unit: .week, numberOfUnits: 1)
    
    var price: NSDecimalNumber = 0
    
    var introductoryPeriod: SCEPPaywallProductPeriod? = nil
    
    var priceLocale: Locale = .init(identifier: "en_US")
}

extension AdaptyPaywallProduct: SCEPPaywallProduct {
    
    var introductoryPrice: NSDecimalNumber? {
        return skProduct.introductoryPrice?.price
    }
    
    var price: NSDecimalNumber {
        return skProduct.price
    }
    
    var subscriptionPeriod: SCEPPaywallProductPeriod? {
        skProduct.subscriptionPeriod.map(SCEPPaywallProductPeriod.init)
    }
    
    var introductoryPeriod: SCEPPaywallProductPeriod? {
        if let introductoryPrice = skProduct.introductoryPrice {
            return .init(skPeriod: introductoryPrice.subscriptionPeriod)
        } else {
            return nil
        }
    }
    
    var priceLocale: Locale {
        return skProduct.priceLocale
    }
}

extension SCEPPaywallProduct {
    
    var localizedPrice: String {
        if price.doubleValue > 0 {
            return localize(price.doubleValue)
        } else {
            return "-"
        }
    }
    
    func priceForPeriod(unit: SKProduct.PeriodUnit, numberOfUnits: Int) -> Double? {
        guard let subscriptionPeriod else { return nil }
        if unit == subscriptionPeriod.unit, numberOfUnits == subscriptionPeriod.numberOfUnits {
            return price.doubleValue
        } else {
            return price.doubleValue / subscriptionPeriod.duration * unit.duration * Double(numberOfUnits)
        }
    }
    
    func localizedPrice(for period: SCEPPaywallProductPeriod) -> String {
        localizedPriceForPeriod(unit: period.unit, numberOfUnits: period.numberOfUnits)
    }
    
    func localizedPriceForPeriod(unit: SKProduct.PeriodUnit, numberOfUnits: Int) -> String {
        if let price = priceForPeriod(unit: unit, numberOfUnits: numberOfUnits), price != 0 {
            return localize(price)
        } else {
            return "-"
        }
    }
    
    private func localize(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: .init(value: price)) ?? "-"
    }
    
    var localizedIntroductoryPrice: String {
        guard let subscriptionPeriod else { return "-" }
        return localizedIntroductoryPrice(for: subscriptionPeriod)
    }
    
    func introductoryPrice(for period: SCEPPaywallProductPeriod) -> Double? {
        guard let subscriptionPeriod else { return nil }
        let price = introductoryPrice ?? price
        if period == subscriptionPeriod {
            return price.doubleValue
        } else {
            return price.doubleValue / subscriptionPeriod.duration * period.duration
        }
    }
    
    func localizedIntroductoryPrice(for period: SCEPPaywallProductPeriod) -> String {
        if let price = introductoryPrice(for: period), price != 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            return formatter.string(from: .init(value: price)) ?? "-"
        } else {
            return "-"
        }
    }
}
