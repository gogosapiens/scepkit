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
        
        badgeLabel.text = .init(localized: "POPULAR", bundle: .module)
        badgeView.layer.maskedCorners = .layerMinXMaxYCorner
        badgeView.layer.cornerRadius = 8
        
        let style = SCEPKitInternal.shared.config.style
        contentView.layer.cornerRadius = style.paywallShopProductCornerRadius
        contentView.layer.borderColor = UIColor.scepShade2.cgColor
        buttonView.layer.cornerRadius = style.paywallShopProductButtonCornerRadius
        badgeTrailingConstraint.constant = style.paywallShopProductButtonBadgeLeadingPadding

        borderView.layer.cornerRadius = style.paywallShopProductCornerRadius
        borderView.layer.borderColor = UIColor.scepShade2.cgColor
        borderView.layer.borderWidth = 2
    }
}

extension SCEPConfig.InterfaceStyle {
    
    var paywallShopProductCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 32
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
    
    var paywallShopProductButtonCornerRadius: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 16
        case .salsicciaDark, .salsicciaLight: return 18
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 12
        }
    }
    
    var paywallShopProductButtonBadgeLeadingPadding: CGFloat {
        switch self {
        case .classicoDark, .classicoLight: return 10
        case .salsicciaDark, .salsicciaLight: return 16
        case .buratinoDark, .buratinoLight: return 8
        case .giornaleDark, .giornaleLight: return 8
        }
    }
}
