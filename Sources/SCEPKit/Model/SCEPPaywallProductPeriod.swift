//
//  SCEPPaywallProductPeriod.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 22/01/2025.
//

import StoreKit

struct SCEPPaywallProductPeriod: Equatable {
    
    init(unit: SKProduct.PeriodUnit, numberOfUnits: Int) {
        self.unit = unit
        self.numberOfUnits = numberOfUnits
    }
    
    init(skPeriod: SKProductSubscriptionPeriod) {
        self.init(unit: skPeriod.unit, numberOfUnits: skPeriod.numberOfUnits)
    }
    
    var unit: SKProduct.PeriodUnit
    var numberOfUnits: Int
    
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

extension SKProduct.PeriodUnit {
    
    var localizedNoun: String {
        switch self {
        case .day: return "Day".localized()
        case .week: return "Week".localized()
        case .month: return "Month".localized()
        case .year: return "Year".localized()
        @unknown default: return "-"
        }
    }
    
    var localizedAdjective: String {
        switch self {
        case .day: return "Daily".localized()
        case .week: return "Weekly".localized()
        case .month: return "Monthly".localized()
        case .year: return "Yearly".localized()
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
