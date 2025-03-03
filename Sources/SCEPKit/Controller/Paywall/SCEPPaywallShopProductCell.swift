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
        let scale = UIScreen.main.bounds.width / 375
        badgeLabel.font = SCEPKitInternal.shared.font(ofSize: 11 * scale, weight: .bold)
        badgeLabel.textColor = .scepTextColor
        
        let style = SCEPKitInternal.shared.config.style
        contentView.layer.cornerRadius = style.design.paywallShopProductCornerRadius
        contentView.layer.borderColor = UIColor.scepShade2.cgColor
        badgeTrailingConstraint.constant = style.design.paywallShopProductButtonBadgeLeadingPadding
        buttonView.layer.cornerRadius = style.design.paywallShopProductButtonCornerRadius
        buttonView.layer.borderColor = UIColor.scepShade1.cgColor
        buttonView.layer.borderWidth = style.theme == .light ? 1 : 0
        buttonView.shadeIndex = style.theme == .light ? 4 : 2
        buttonView.backgroundColor = .scepShade(with: buttonView.shadeIndex)

        borderView.layer.cornerRadius = style.design.paywallShopProductCornerRadius
        borderView.layer.borderColor = UIColor.scepShade2.cgColor
        borderView.layer.borderWidth = 2
        
        let isLarge = UIScreen.main.bounds.width > 410
        textLabel.font = SCEPKitInternal.shared.font(ofSize: isLarge ? 18 : 14, weight: .medium)
    }
}

extension SCEPConfig.InterfaceStyle.Design {
    
    var paywallShopProductCornerRadius: CGFloat {
        switch self {
        case .classico: return 16
        case .salsiccia: return 24
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
