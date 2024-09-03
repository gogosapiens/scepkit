import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let config = SCEPKitInternal.shared.config.app.interface.mainButton
        
        backgroundColor = .scepShade3
        clipsToBounds = true
        layer.cornerRadius = config.cornerRadius
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        titleLabel?.textColor = .scepText
        titleLabel?.font = SCEPKitInternal.shared.config.app.interface.font(ofSize: config.fontSize, weight: .bold)
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
