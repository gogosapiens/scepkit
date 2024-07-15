import UIKit

class SCEPSecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.cornerRadius = SCEPKitInternal.shared.plistValue(for: .mainButton, .cornerRadius)
        titleLabel?.font = .main(ofSize: SCEPKitInternal.shared.plistValue(for: .mainButton, .fontSize), weight: .bold)
        print(1)
    }
}
