//
//  Locale.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 27/12/2024.
//

import Foundation

extension Locale {
    
    static var isCurrentLanguageLocalized: Bool {
        let locale = Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
        let localizations = Bundle.main.localizations.map(Locale.init).map(\.languageCode!)
        return localizations.contains(locale.languageCode!)
    }
}
