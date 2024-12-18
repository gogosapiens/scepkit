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
    var bannerAdViews: Set<SCEPBannerAdView> = []
    
    private let debugInterstitialId = "ca-app-pub-3940256099942544/4411468910"
    private let debugAppOpenId = "ca-app-pub-3940256099942544/5575463023"
    private let debugBannerId = "ca-app-pub-3940256099942544/2435281174"
    private let debudRewardedId = "ca-app-pub-3940256099942544/1712485313"
    
    private var interstitial: GADInterstitialAd?
    private var appOpenAd: GADAppOpenAd?
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationShown), name: SCEPKitInternal.shared.applicationShownNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(premiumStatusUpdated), name: SCEPMonetization.shared.premiumStatusUpdatedNotification, object: nil)
    }
    
    var config: SCEPConfig.Monetization.Ads {
        SCEPKitInternal.shared.config.monetization.ads
    }
    
    var isStartDelayPassed: Bool {
        let startDelay: TimeInterval = config.startDelay ?? 0
        return Date() >= SCEPKitInternal.shared.firstLaunchDate.addingTimeInterval(startDelay)
    }
    
    var canShowAds: Bool {
        return config.isEnabled && !SCEPMonetization.shared.isPremium && isStartDelayPassed
    }
    
    @MainActor private func start() {
        guard canShowAds else { return }
        if !SCEPMonetization.shared.isPremium {
            if config.interstitialId != nil {
                loadInterstitialAd()
            }
            if config.appOpenId != nil {
                isLoadingAppOpen = true
                loadAppOpenAd()
            }
        }
    }
    
    @MainActor @objc func applicationDidBecomeActive() {
        showAppOpenAd()
        start()
    }
    
    @MainActor @objc func applicationShown() {
        if needsToShowAppOpenOnApplicationShown {
            showAppOpenAd()
        }
    }
    
    @MainActor @objc func premiumStatusUpdated() {
        if SCEPMonetization.shared.isPremium {
            for bannerAdView in bannerAdViews {
                bannerAdView.dismissHandler(bannerAdView)
            }
            bannerAdViews.removeAll()
        }
    }
    
    private func loadInterstitialAd() {
        guard config.isEnabled else { return }
        guard interstitial == nil else { return }
        let unitId = isDebug ? debugInterstitialId : config.interstitialId!
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
        guard config.isEnabled else { return }
        guard appOpenAd == nil else { return }
        let unitId = isDebug ? debugAppOpenId : config.appOpenId!
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
        let interstitialInterval: TimeInterval = config.interstitialInterval ?? 60
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
    
    @MainActor func getBannerAdView(placement: String, completion: (SCEPBannerAdView) -> Void, dismissHandler: @escaping (SCEPBannerAdView) -> Void) {
        guard canShowAds else { return }
        let unitId = isDebug ? debugBannerId : config.bannerId!
        let bannerView = SCEPBannerAdView(unitId: unitId, dismissHandler: dismissHandler)
        bannerAdViews.insert(bannerView)
        SCEPKitInternal.shared.trackEvent("[SCEPKit] banner_ad_shown", properties: ["placement": placement])
        completion(bannerView)
    }
    
    @MainActor func loadRewardedAd(id: String? = nil, completion: @escaping (GADRewardedAd?) -> Void) {
        let request = GADRequest()
        let unitId = isDebug ? debudRewardedId : id ?? config.rewardedId!
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
