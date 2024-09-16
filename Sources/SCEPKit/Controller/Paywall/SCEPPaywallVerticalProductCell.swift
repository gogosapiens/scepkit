import UIKit

class SCEPPaywallVerticalProductCell: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: SCEPLabel!
    @IBOutlet weak var leftTitleLabel: SCEPLabel!
    @IBOutlet weak var leftSubtitleLabel: SCEPLabel!
    @IBOutlet weak var rightTitleLabel: SCEPLabel!
    @IBOutlet weak var rightSubtitleLabel: SCEPLabel!
    @IBOutlet weak var badgeShadowView: UIView!
    @IBOutlet weak var badgeShadowMaskView: UIImageView!
    @IBOutlet weak var leftPaddingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cornerRadius = SCEPKitInternal.shared.config.app.style.paywallProductCornerRadius
        leftPaddingConstraint.constant = SCEPKitInternal.shared.config.app.style.paywallProductLeftPadding
        outlineView.layer.borderWidth = 2
        outlineView.layer.cornerRadius = cornerRadius
        badgeShadowView.mask = badgeShadowMaskView
        badgeShadowView.layer.borderColor = UIColor.scepShade0.cgColor
        badgeShadowView.layer.borderWidth = 2
        badgeShadowView.layer.cornerRadius = cornerRadius
    }
}
