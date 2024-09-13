import Foundation
import StoreKit

extension SKProduct {
    
    var localizedPrice: String {
        guard let subscriptionPeriod else { return "-" }
        return localizedPriceForPeriod(unit: subscriptionPeriod.unit, numberOfUnits: subscriptionPeriod.numberOfUnits)
    }
    
    func priceForPeriod(unit: SKProduct.PeriodUnit, numberOfUnits: Int) -> Double? {
        guard let subscriptionPeriod else { return nil }
        if unit == subscriptionPeriod.unit, numberOfUnits == subscriptionPeriod.numberOfUnits {
            return price.doubleValue
        } else {
            return price.doubleValue / subscriptionPeriod.duration * unit.duration * Double(numberOfUnits)
        }
    }
    
    func localizedPrice(for period: SKProductSubscriptionPeriod) -> String {
        localizedPriceForPeriod(unit: period.unit, numberOfUnits: period.numberOfUnits)
    }
    
    func localizedPriceForPeriod(unit: SKProduct.PeriodUnit, numberOfUnits: Int) -> String {
        if let price = priceForPeriod(unit: unit, numberOfUnits: numberOfUnits) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            return formatter.string(from: .init(value: price)) ?? "-"
        } else {
            return "-"
        }
    }
    
    var localizedIntroductoryPrice: String {
        guard let subscriptionPeriod else { return "-" }
        return localizedIntroductoryPrice(for: subscriptionPeriod)
    }
    
    func introductoryPrice(for period: SKProductSubscriptionPeriod) -> Double? {
        guard let subscriptionPeriod else { return nil }
        let price = introductoryPrice?.price ?? price
        if period == subscriptionPeriod {
            return price.doubleValue
        } else {
            return price.doubleValue / subscriptionPeriod.duration * period.duration
        }
    }
    
    func localizedIntroductoryPrice(for period: SKProductSubscriptionPeriod) -> String {
        if let price = introductoryPrice(for: period) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            return formatter.string(from: .init(value: price)) ?? "-"
        } else {
            return "-"
        }
    }
}

extension SKProductSubscriptionPeriod {
    
    var displayNumberOfUnits: Int {
        if unit == .day, numberOfUnits == 7 {
            return 1
        } else {
            return numberOfUnits
        }
    }
    
    var displayUnit: SKProduct.PeriodUnit {
        if unit == .day, numberOfUnits == 7 {
            return .week
        } else {
            return unit
        }
    }
    
    var displayUnitLocalizedNoun: String {
        displayUnit.localizedNoun
    }
    
    var displayUnitLocalizedAdjective: String {
        displayUnit.localizedAdjective
    }
    
    var duration: TimeInterval {
        TimeInterval(numberOfUnits) * unit.duration
    }
}

fileprivate extension SKProduct.PeriodUnit {
    
    var localizedNoun: String {
        switch self {
        case .day: return .init(localized: "Day", bundle: .module)
        case .week: return .init(localized: "Week", bundle: .module)
        case .month: return .init(localized: "Month", bundle: .module)
        case .year: return .init(localized: "Year", bundle: .module)
        @unknown default: return "-"
        }
    }
    
    var localizedAdjective: String {
        switch self {
        case .day: return .init(localized: "Daily", bundle: .module)
        case .week: return .init(localized: "Weekly", bundle: .module)
        case .month: return .init(localized: "Monthly", bundle: .module)
        case .year: return .init(localized: "Yearly", bundle: .module)
        @unknown default: return "-"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .day: return 86_400
        case .week: return 604_800
        case .month: return 2_629_800
        case .year: return 31_557_600
        @unknown default: return 86_400
        }
    }
}
