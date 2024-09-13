//
//  File.swift
//  
//
//  Created by Illia Harkavy on 13/09/2024.
//

import UIKit

extension UILabel {
    
    func styleTextWithBraces() {
        guard let text = self.text else { return }
        
        // Regular expression to find text within curly braces
        let pattern = "\\{(.*?)\\}"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        // Mutable attributed string
        let attributedText = NSMutableAttributedString(attributedString: attributedText!)
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        
        // Find matches for curly braces
        let matches = regex.matches(in: text, options: [], range: nsRange)
        
        // Iterate over the matches in reverse order to avoid index issues
        for match in matches.reversed() {
            let range = match.range(at: 1) // Get the range of the text inside {}
            let braceRange = match.range // Get the range of the entire {}
            
            // Apply color to the text inside the braces
            attributedText.addAttribute(.foregroundColor, value: UIColor.scepAccent, range: braceRange)
            
            // Extract the inner text
            let startIndex = text.index(text.startIndex, offsetBy: braceRange.location + 1)
            let endIndex = text.index(text.startIndex, offsetBy: braceRange.location + braceRange.length - 1)
            let innerText = String(text[startIndex..<endIndex])
            
            // Replace the entire {} with just the inner text
            attributedText.replaceCharacters(in: braceRange, with: innerText)
        }
        
        // Set the final attributed text to the label
        self.attributedText = attributedText
    }
}
