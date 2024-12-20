import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.style.design.secondaryButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setTitleColor(.scepTextColor, for: .normal)
        titleLabel?.font = SCEPKitInternal.shared.font(ofSize: 16, weight: .bold)
    }
}

fileprivate extension SCEPConfig.InterfaceStyle.Design {
    
    var secondaryButtonCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 28
        case .buratino: return 8
        case .giornale: return 12
        }
    }
}
