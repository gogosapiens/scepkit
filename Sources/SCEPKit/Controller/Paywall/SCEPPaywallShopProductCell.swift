import UIKit

class SCEPPaywallShopProductCell: UICollectionViewCell {
    
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var balanceImageView: UIImageView!
    @IBOutlet weak var buttonView: SCEPBackgroundView!
    @IBOutlet weak var borderView: SCEPBackgroundView!
    @IBOutlet weak var badgeTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        badgeLabel.text = "POPULAR".localized()
        badgeView.layer.maskedCorners = .layerMinXMaxYCorner
        badgeView.layer.cornerRadius = 8
        
        let design = SCEPKitInternal.shared.config.style.design
        contentView.layer.cornerRadius = design.paywallShopProductCornerRadius
        contentView.layer.borderColor = UIColor.scepShade2.cgColor
        buttonView.layer.cornerRadius = design.paywallShopProductButtonCornerRadius
        badgeTrailingConstraint.constant = design.paywallShopProductButtonBadgeLeadingPadding

        borderView.layer.cornerRadius = design.paywallShopProductCornerRadius
        borderView.layer.borderColor = UIColor.scepShade2.cgColor
        borderView.layer.borderWidth = 2
    }
}

extension SCEPConfig.InterfaceStyle.Design {
    
    var paywallShopProductCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 32
        case .buratino: return 8
        case .giornale: return 12
        }
    }
    
    var paywallShopProductButtonCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 18
        case .buratino: return 8
        case .giornale: return 12
        }
    }
    
    var paywallShopProductButtonBadgeLeadingPadding: CGFloat {
        switch self {
        case .classico: return 10
        case .salsiccia: return 16
        case .buratino: return 8
        case .giornale: return 8
        }
    }
}
