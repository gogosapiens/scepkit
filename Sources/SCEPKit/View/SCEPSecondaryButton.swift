import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.app.style.secondaryButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel?.textColor = .scepText
        titleLabel?.font = SCEPKitInternal.shared.config.app.font(ofSize: 16, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle {
    
    var secondaryButtonCornerRadius: CGFloat {
        switch self {
        case .screensOneDark: return 16
        case .screensOneLight:  return 16
        case .screensTwoDark: return 28
        case .screensThreeDark: return 8
        case .screensFourDark: return 12
        }
    }
}
