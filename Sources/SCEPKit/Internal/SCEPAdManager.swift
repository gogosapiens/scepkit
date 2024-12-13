import GoogleMobileAds
import UIKit

class SCEPAdManager: NSObject {
    static let shared = SCEPAdManager()
    static let appOpenLoadedNotification = Notification.Name(rawValue: "AdManager.appOpenLoaded")
    static let appOpenDismissedNotification = Notification.Name("SCEPAdManager.appOpenAdDismissed")
    
    var lastInterstitialShowDate: Date = .distantPast
    var needsToShowAppOpenOnApplicationShown: Bool = false
    var isLoadingAppOpen: Bool = false
    var isShowingAppOpen: Bool = false
    var rewardedAdCompletion: ((Bool) -> Void)?
    var rewardedAdDidReward: Bool = false
    var shownRewardedAd: GADRewardedAd?
    
    private var interstitial: GADInterstitialAd?
    private var appOpenAd: GADAppOpenAd?
    
    private override init() {
        super.init()
    }
    
    var isStartDelayPassed: Bool {
        let startDelay: TimeInterval = SCEPKitInternal.shared.config.monetization.ads.startDelay ?? 0
        return Date() >= SCEPKitInternal.shared.firstLaunchDate.addingTimeInterval(startDelay)
    }
    
    var canShowAds: Bool {
        return !SCEPMonetization.shared.isPremium && isStartDelayPassed
    }
    
    @MainActor func start() {
        guard SCEPKitInternal.shared.config.monetization.ads.isEnabled else { return }
        if !SCEPMonetization.shared.isPremium {
            if SCEPKitInternal.shared.config.monetization.ads.interstitialId != nil {
                loadInterstitialAd()
            }
            if SCEPKitInternal.shared.config.monetization.ads.appOpenId != nil {
                isLoadingAppOpen = true
                loadAppOpenAd()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationShown), name: SCEPKitInternal.shared.applicationShownNotification, object: nil)
    }
    
    @MainActor @objc func applicationDidBecomeActive() {
        showAppOpenAd()
    }
    
    @MainActor @objc func applicationShown() {
        if needsToShowAppOpenOnApplicationShown {
            showAppOpenAd()
        }
    }
    
    private func loadInterstitialAd() {
        guard SCEPKitInternal.shared.config.monetization.ads.isEnabled else { return }
        guard interstitial == nil else { return }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/4411468910" : SCEPKitInternal.shared.config.monetization.ads.interstitialId!
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: unitId, request: request) { ad, error in
            guard let ad else {
                print("Failed to load interstitial ad with error: \(error?.localizedDescription ?? "none")")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    private func loadAppOpenAd() {
        guard SCEPKitInternal.shared.config.monetization.ads.isEnabled else { return }
        guard appOpenAd == nil else { return }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/5575463023" : SCEPKitInternal.shared.config.monetization.ads.appOpenId!
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: unitId, request: request) { ad, error in
            self.isLoadingAppOpen = false
            if let error = error {
                print("Failed to load app open ad with error: \(error.localizedDescription)")
                NotificationCenter.default.post(name: Self.appOpenLoadedNotification, object: nil)
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            NotificationCenter.default.post(name: Self.appOpenLoadedNotification, object: nil)
        }
    }
    @MainActor func showInterstitialAd(from viewController: UIViewController? = nil, placement: String) -> Bool {
        guard canShowAds else { return false }
        let interstitialInterval: TimeInterval = SCEPKitInternal.shared.config.monetization.ads.interstitialInterval ?? 60
        if let interstitial = interstitial, Date() > lastInterstitialShowDate + interstitialInterval {
            interstitial.present(fromRootViewController: viewController)
            lastInterstitialShowDate = Date()
            SCEPKitInternal.shared.trackEvent("[SCEPKit] interstitial_ad_shown", properties: ["placement": placement])
            return true
        } else {
            return false
        }
    }
    
    @MainActor func showAppOpenAd(from viewController: UIViewController? = nil) {
        guard self.canShowAds else { return }
        isShowingAppOpen = true
        if SCEPKitInternal.shared.isApplicationShown {
            if let appOpenAd = self.appOpenAd {
                appOpenAd.present(fromRootViewController: viewController)
                SCEPKitInternal.shared.trackEvent("[SCEPKit] app_open_ad_shown")
            } else {
                isShowingAppOpen = false
            }
        } else {
            needsToShowAppOpenOnApplicationShown = true
        }
    }
    
    @MainActor func getBannerAdView(placement: String) -> GADBannerView? {
        guard canShowAds else { return nil }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/2435281174" : SCEPKitInternal.shared.config.monetization.ads.bannerId!
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        let bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = unitId
        bannerView.load(GADRequest())
        SCEPKitInternal.shared.trackEvent("[SCEPKit] banner_ad_shown", properties: ["placement": placement])
        return bannerView
    }
    
    @MainActor func loadRewardedAd(id: String? = nil, completion: @escaping (GADRewardedAd?) -> Void) {
        let request = GADRequest()
        let unitId = isDebug ? "ca-app-pub-3940256099942544/1712485313" : id ?? SCEPKitInternal.shared.config.monetization.ads.rewardedId!
        GADRewardedAd.load(withAdUnitID: unitId, request: request) { ad, error in
            if let error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
            }
            completion(ad)
        }
    }
    
    @MainActor func showRewardedAd(_ ad: GADRewardedAd, from viewController: UIViewController, placement: String, completion: @escaping (Bool) -> Void) {
        rewardedAdCompletion = completion
        rewardedAdDidReward = false
        shownRewardedAd = ad
        ad.fullScreenContentDelegate = self
        ad.present(fromRootViewController: viewController) {
            self.rewardedAdDidReward = true
        }
        SCEPKitInternal.shared.trackEvent("[SCEPKit] rewarded_ad_shown", properties: ["placement": placement])
    }
    
    @MainActor func loadAndShowRewardedAd(from viewController: UIViewController, placement: String, customLoadingCompletion: ((Bool) -> Void)?, completion: @escaping (Bool) -> Void) {
        var activityController: SCEPActivityController?
        if customLoadingCompletion == nil {
            activityController = SCEPActivityController.instantiate(bundle: .module)
            viewController.present(activityController!, animated: true)
        }
        loadRewardedAd { ad in
            let showAd = {
                guard let ad else {
                    completion(false)
                    return
                }
                self.showRewardedAd(ad, from: viewController, placement: placement, completion: completion)
            }
            if let customLoadingCompletion {
                customLoadingCompletion(ad != nil)
                showAd()
            } else {
                activityController?.dismiss(animated: true, completion: showAd)
            }
        }
    }
}

extension SCEPAdManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad is GADInterstitialAd {
            interstitial = nil
            loadInterstitialAd()
        } else if ad is GADAppOpenAd {
            appOpenAd = nil
            loadAppOpenAd()
            isShowingAppOpen = false
            NotificationCenter.default.post(Self.appOpenDismissedNotification)
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad is GADInterstitialAd {
            interstitial = nil
            loadInterstitialAd()
        } else if ad is GADAppOpenAd {
            appOpenAd = nil
            loadAppOpenAd()
            isShowingAppOpen = false
            NotificationCenter.default.post(Self.appOpenDismissedNotification)
        } else if ad is GADRewardedAd {
            rewardedAdCompletion?(rewardedAdDidReward)
            rewardedAdCompletion = nil
            rewardedAdDidReward = false
            shownRewardedAd = nil
        }
    }
}
