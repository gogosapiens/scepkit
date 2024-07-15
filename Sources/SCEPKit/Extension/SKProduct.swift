import Foundation
import StoreKit

extension String {
    
    func insertingPrice(for product: SKProduct?) -> String {
        if let product {
            return product.string(from: self)
        } else {
            let units: [SKProduct.PeriodUnit] = [.day, .week, .month, .year]
            var string = self
            for unit in units {
                string = string.replacingOccurrences(of: "{\(unit.string.lowercased())}", with: "-")
            }
            return string
        }
    }
}

extension SKProduct {
    
    func string(from template: String) -> String {
        let units: [SKProduct.PeriodUnit] = [.day, .week, .month, .year]
        var string = template
        for unit in units {
            string = string.replacingOccurrences(
                of: "{\(unit.string.lowercased())}",
                with: localizedPriceForPeriod(unit: unit, numberOfUnits: 1)
            )
        }
        return string
    }
    
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
    
    var stringWithNumber: String {
        if unit == .day, numberOfUnits == 7 {
            return "1 \(SKProduct.PeriodUnit.week.string.lowercased())"
        } else {
            return "\(numberOfUnits) \(unit.string.lowercased())\(numberOfUnits == 1 ? "" : "s")"
        }
    }
    
    var string: String {
        if unit == .day, numberOfUnits == 7 {
            return SKProduct.PeriodUnit.week.string
        } else if numberOfUnits == 1 {
            return unit.string
        } else {
            return stringWithNumber
        }
    }
    
    var shortStringWithNumber: String {
        if unit == .day, numberOfUnits == 7 {
            return "1 \(SKProduct.PeriodUnit.week.shortString)"
        } else {
            return "\(numberOfUnits) \(unit.shortString)"
        }
    }
    
    var shortString: String {
        if unit == .day, numberOfUnits == 7 {
            return SKProduct.PeriodUnit.week.shortString
        } else if numberOfUnits == 1 {
            return unit.string
        } else {
            return stringWithNumber
        }
    }
    
    var duration: TimeInterval {
        TimeInterval(numberOfUnits) * unit.duration
    }
}

extension SKProduct.PeriodUnit {
    
    var string: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        @unknown default: return "IDK"
        }
    }
    
    var shortString: String {
        switch self {
        case .day: return "dy"
        case .week: return "week"
        case .month: return "mo"
        case .year: return "yr"
        @unknown default: return "idk"
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
