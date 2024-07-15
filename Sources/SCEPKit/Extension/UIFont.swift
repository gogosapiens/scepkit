import UIKit

extension UIFont {
    
    static func main(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let name: String
        switch weight {
        case .medium:
            name = SCEPKitInternal.shared.plistString(for: .mainFont, .bold)
        case .semibold:
            name = SCEPKitInternal.shared.plistString(for: .mainFont, .bold)
        case .bold:
            name = SCEPKitInternal.shared.plistString(for: .mainFont, .bold)
        default:
            fatalError("Font weight \(weight) not supported")
        }
        return UIFont(name: name, size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
}
