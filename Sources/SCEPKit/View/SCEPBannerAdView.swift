//
//  SCEPBannerView.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 13/12/2024.
//

import UIKit
import GoogleMobileAds

public class SCEPBannerAdView: UIView {
    
    var dismissHandler: (SCEPBannerAdView) -> Void
    
    init(unitId: String, dismissHandler: @escaping (SCEPBannerAdView) -> Void) {
        self.dismissHandler = dismissHandler
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        let frame = CGRect(origin: .zero, size: adaptiveSize.size)
        super.init(frame: frame)
        
        let bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = unitId
        bannerView.load(GADRequest())
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)
        bannerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addToSuperview(_ superview: UIView, position: Position) {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        switch position {
        case .top:
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor).isActive = true
        case .bottom:
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    public enum Position {
        case top, bottom
    }
}
