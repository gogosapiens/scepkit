import UIKit

class SCEPPaywallRobotProductCell: UITableViewCell {

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
        let style = SCEPKitInternal.shared.config.style
        let cornerRadius = style.paywallProductCornerRadius
        leftPaddingConstraint.constant = style.paywallProductLeftPadding
        outlineView.layer.borderWidth = 2
        outlineView.layer.cornerRadius = cornerRadius
        badgeShadowView.mask = badgeShadowMaskView
        badgeShadowView.layer.borderColor = UIColor.scepTextColor.cgColor
        badgeShadowView.layer.borderWidth = 2
        badgeShadowView.layer.cornerRadius = cornerRadius
    }
}
