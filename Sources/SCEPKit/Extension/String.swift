//
//  File.swift
//  
//
//  Created by Illia Harkavy on 13/09/2024.
//

import Foundation

extension String {
    
    func insertingArguments(_ arguments: LosslessStringConvertible...) -> String {
        var string = self
        for (index, argument) in arguments.enumerated() {
            string = string.replacingOccurrences(of: "{\(index)}", with: String(argument))
        }
        return string
    }
}
