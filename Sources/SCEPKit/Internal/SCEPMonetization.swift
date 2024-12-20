//
//  SCEPMonetization.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 09/12/2024.
//

import Adapty
import UIKit

class SCEPMonetization {
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationShown), name: SCEPKitInternal.shared.applicationShownNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    static let shared = SCEPMonetization()
    
    var config: SCEPConfig.Monetization { SCEPKitInternal.shared.config.monetization }
    
    let premiumStatusUpdatedNotification = Notification.Name("SCEPMonetization.premiumStatusUpdated")
    let creditsUpdatedNotification = Notification.Name("SCEPMonetization.creditsUpdated")
    
    @KeychainValue(key: "premiumStatus", defaultValue: .free)
    var premuimStatus: PremiumStatus
    
    @KeychainValue(key: "recurringCredits", defaultValue: 0)
    var recurringCredits: Int
    
    @KeychainValue(key: "additionalCredits", defaultValue: 0)
    var additionalCredits: Int
    
    @KeychainValue(key: "lastPremiumCreditsSettingDate", defaultValue: nil)
    var lastPremiumCreditsSettingDate: Date?
    
    @KeychainValue(key: "isInitialCreditsSet", defaultValue: false)
    var isInitialCreditsSet: Bool
    
    @KeychainValue(key: "isTrialCreditsSet", defaultValue: false)
    var isTrialCreditsSet: Bool
    
    @KeychainValue(key: "processedPurchaseIds", defaultValue: [])
    var processedPurchaseIds: Set<String>
    
    var isPremium: Bool {
        return premuimStatus == .trial || premuimStatus == .paid
    }
    
    @MainActor @objc func applicationShown() {
        updateCreditsIfNeeded()
    }
    
    @MainActor @objc func applicationDidBecomeActive() {
        print("applicationDidBecomeActive", "SCEPMonetization")
        updateCreditsIfNeeded()
    }
    
    @MainActor func setPremuimStatus(_ premuimStatus: PremiumStatus) {
        guard premuimStatus != self.premuimStatus else { return }
        self.premuimStatus = premuimStatus
        updateCreditsIfNeeded()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: self.premiumStatusUpdatedNotification, object: nil)
        }
    }
    
    @MainActor func update(for profile: AdaptyProfile) {
        guard !isDebug else { return }
        
        if let subscription = profile.subscriptions.first(
            where: { $0.value.isActive && $0.key.split(separator: ".").contains("premium") }
        ) {
            if subscription.value.activeIntroductoryOfferType == "free_trial" {
                setPremuimStatus(.trial)
            } else {
                setPremuimStatus(.paid)
            }
        } else {
            setPremuimStatus(.free)
        }
        
        let purchases: [String: [String]] = profile.nonSubscriptions.mapValues { purchases in
            return purchases.compactMap { purchase in
                guard !purchase.isRefund, purchase.isConsumable else { return nil }
                return purchase.purchaseId
            }
        }
        
        var totalCreditsIncrement: Int = 0
        for (productId, purchaseIds) in purchases {
            let credits = credits(for: productId)
            guard credits > 0 else { continue }
            for purchaseId in purchaseIds {
                if !processedPurchaseIds.contains(purchaseId) {
                    totalCreditsIncrement += credits
                }
            }
        }
        if totalCreditsIncrement > 0 {
            incrementAdditionalCredits(by: totalCreditsIncrement)
        }
        processedPurchaseIds.formUnion(purchases.values.flatMap({ $0 }))
    }
    
    func credits(for productId: String) -> Int {
        for component in productId.split(separator: ".") {
            if component.hasPrefix("credits"),
               let creditsIncrement = Int(component.dropFirst(7)) {
                return creditsIncrement
            }
        }
        return 0
    }
    
    func setRecurringCredits(_ value: Int) {
        recurringCredits = value
        NotificationCenter.default.post(name: creditsUpdatedNotification, object: nil)
        
        updateUserProperties()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] recurring_credits_set", properties: ["value": value])
    }
    
    func incrementAdditionalCredits(by value: Int) {
        additionalCredits += value
        NotificationCenter.default.post(name: creditsUpdatedNotification, object: nil)
        
        updateUserProperties()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] additional_credits_added", properties: ["value": value])
    }
    
    var credits: Int {
        return recurringCredits + additionalCredits
    }
    
    func decrementCredits(by value: Int) {
        let recurringDecrement = min(value, recurringCredits)
        if recurringDecrement > 0 {
            recurringCredits -= recurringDecrement
        }
        let additionalDecrement = value - recurringDecrement
        if additionalDecrement > 0 {
            additionalCredits -= additionalDecrement
        }
        NotificationCenter.default.post(name: creditsUpdatedNotification, object: nil)
        
        updateUserProperties()
        SCEPKitInternal.shared.trackEvent("[SCEPKit] total_credits_substracted", properties: ["total_value": value, "additional_value": additionalDecrement, "recurring_value": recurringDecrement])
    }
    
    @MainActor private func updateCreditsIfNeeded() {
        guard SCEPKitInternal.shared.isApplicationShown else { return }
        var credits = 0
        
        if !isInitialCreditsSet {
            credits = config.initialCredits
            isInitialCreditsSet = true
        }
        switch premuimStatus {
        case .free:
            isTrialCreditsSet = false
            lastPremiumCreditsSettingDate = nil
        case .trial:
            lastPremiumCreditsSettingDate = nil
            if !isTrialCreditsSet {
                credits = config.trialCredits
                isTrialCreditsSet = true
            }
        case .paid:
            isTrialCreditsSet = false
            if Date() > (lastPremiumCreditsSettingDate ?? .distantPast).addingTimeInterval(86_400) {
                credits = config.premiumWeeklyCredits
                lastPremiumCreditsSettingDate = .init()
            }
        }
        if credits > 0 {
            setRecurringCredits(credits)
            lastPremiumCreditsSettingDate = .init()
        }
    }
    
    private func updateUserProperties() {
        let properties = [
            "[SCEPKit] total_credits": credits,
            "[SCEPKit] additional_credits": additionalCredits,
            "[SCEPKit] recurring_credits": recurringCredits,
        ]
        SCEPKitInternal.shared.setUserProperties(properties)
    }
    
    enum PremiumStatus: Codable {
        case free, trial, paid
    }
}
