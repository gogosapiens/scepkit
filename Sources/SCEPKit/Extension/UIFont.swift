import UIKit

extension UIFont {
    
    var weight: UIFont.Weight {
        let traits = fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        let weightValue = traits?[.weight] as? CGFloat ?? UIFont.Weight.regular.rawValue
        return UIFont.Weight(rawValue: weightValue)
    }
}
