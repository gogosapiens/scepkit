//
//  File.swift
//  
//
//  Created by Illia Harkavy on 13/09/2024.
//

import Foundation

typealias LocalizedString = [String: String]

extension LocalizedString {
    
    func localized() -> String {
        for language in Locale.preferredLanguages {
            guard let code = language.split(separator: "-").first else { continue }
            if let localizedValue = self[String(code)] {
                return localizedValue
            }
        }
        return self["en"] ?? ""
    }
}
