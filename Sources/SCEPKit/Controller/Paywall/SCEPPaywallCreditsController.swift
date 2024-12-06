//
//  SCEPPaywallCreditsController.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 05/12/2024.
//

import UIKit

class SCEPPaywallCreditsController: SCEPPaywallController {
    
    struct Config: Codable {
        let positions: [SCEPPaywallConfig.Position]
        let texts: Texts
        let meta: Meta
        struct Texts: Codable { }
        struct Meta: Codable {
            let imageURL: URL
            let balanceImageURL: URL
        }
    }
    var config: Config!
}
