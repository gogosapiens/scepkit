import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.style.secondaryButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setTitleColor(.scepTextColor, for: .normal)
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: 16, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle {
    
    var secondaryButtonCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 28
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
}
