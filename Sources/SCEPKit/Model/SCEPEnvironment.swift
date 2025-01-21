//
//  SCEPEnvironment.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 23/12/2024.
//

enum SCEPEnvironment: String {
    case main
    case testflight
    case camouflage
    case prodtest
    case appstore
    
    var isUsingProductionProducts: Bool {
        switch self {
        case .main, .testflight, .camouflage:
            return false
        case .prodtest, .appstore:
            return true
        }
    }
    
    var isUsingProductionAds: Bool {
        switch self {
        case .main, .testflight, .camouflage, .prodtest:
            return false
        case .appstore:
            return true
        }
    }
}
