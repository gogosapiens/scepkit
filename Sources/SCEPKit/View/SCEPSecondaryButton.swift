import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.config.app.style.mainButtonCornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel?.textColor = .scepText
        titleLabel?.font = SCEPKitInternal.shared.config.app.font(ofSize: 18, weight: .bold)
    }
    
    var title: String? {
        get {
            title(for: .normal)
        }
        set {
            UIView.performWithoutAnimation {
                setTitle(newValue, for: .normal)
                layoutIfNeeded()
            }
        }
    }
}
