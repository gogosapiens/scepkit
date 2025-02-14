import GoogleMobileAds
import UIKit

class SCEPAdManager: NSObject {
    
    static let shared = SCEPAdManager()
    static let appOpenLoadedNotification = Notification.Name(rawValue: "AdManager.appOpenLoaded")
    static let appOpenDismissedNotification = Notification.Name("SCEPAdManager.appOpenAdDismissed")
    
    var lastInterstitialShowDate: Date = .distantPast
    var needsToShowAppOpenOnApplicationShown: Bool = false
    var isLoadingAppOpen: Bool = false
    private var isShowingAppOpen: Bool = false
    var willShowAppOpen: Bool = false
    var rewardedAdCompletion: ((Bool) -> Void)?
    var rewardedAdDidReward: Bool = false
    var shownRewardedAd: GADRewardedAd?
    var bannerAdViews: Set<SCEPBannerAdView> = []
    var shouldIgnoreApplicationDidBecomeActive: Bool = false
    
    private var interstitial: GADInterstitialAd?
    private var appOpenAd: GADAppOpenAd?
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
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
    
    func load() {
        guard canShowAds else { return }
        guard !SCEPMonetization.shared.isPremium else { return }
        if config.interstitialId != nil {
            loadInterstitialAd()
        }
        if config.appOpenId != nil {
            isLoadingAppOpen = true
            loadAppOpenAd()
            if !SCEPKitInternal.shared.isApplicationShown {
                willShowAppOpen = true
            }
        }
    }
    
    @MainActor @objc func applicationDidBecomeActive() {
        guard !shouldIgnoreApplicationDidBecomeActive else {
            return
        }
        showAppOpenAd()
        if SCEPKitInternal.shared.isApplicationReady {
            NotificationCenter.default.post(SCEPKitInternal.shared.applicationDidBecomeReadyNotification)
        }
    }
    
    @MainActor @objc func applicationWillResignActive() {
        guard !shouldIgnoreApplicationDidBecomeActive else {
            return
        }
        if canShowAds, appOpenAd != nil {
            willShowAppOpen = true
        }
    }
    
    @MainActor @objc func applicationShown() {
        showAppOpenAd()
    }
    
    @MainActor @objc func premiumStatusUpdated() {
        if SCEPMonetization.shared.isPremium {
            for bannerAdView in bannerAdViews {
                bannerAdView.dismissHandler(bannerAdView)
            }
            bannerAdViews.removeAll()
            willShowAppOpen = false
        }
        load()
    }
    
    private func loadInterstitialAd() {
        guard config.isEnabled else { return }
        guard interstitial == nil else { return }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: config.interstitialId!, request: request) { ad, error in
            guard let ad else {
                logger.error("Failed to load interstitial ad with error: \(error?.localizedDescription ?? "none")")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    private func loadAppOpenAd() {
        guard config.isEnabled else { return }
        guard appOpenAd == nil else { return }
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: config.appOpenId!, request: request) { ad, error in
            self.isLoadingAppOpen = false
            if let error = error {
                logger.error("Failed to load app open ad with error: \(error.localizedDescription)")
                NotificationCenter.default.post(name: Self.appOpenLoadedNotification, object: nil)
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            if UIApplication.shared.applicationState != .active {
                self.willShowAppOpen = true
            }
            NotificationCenter.default.post(name: Self.appOpenLoadedNotification, object: nil)
        }
    }
    @MainActor func showInterstitialAd(from viewController: UIViewController? = nil, placement: String?) -> Bool {
        guard canShowAds else { return false }
        let interstitialInterval: TimeInterval = config.interstitialInterval ?? 60
        if let interstitial = interstitial {
            if Date() > lastInterstitialShowDate + interstitialInterval {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak viewController] _ in
                    interstitial.present(fromRootViewController: viewController)
                }
                lastInterstitialShowDate = Date()
                SCEPKitInternal.shared.trackEvent("[SCEPKit] interstitial_ad_shown", properties: ["placement": placement ?? ""])
                return true
            } else {
                logger.info("Interstitial ad skipped due to interval")
                return false
            }
        } else {
            logger.info("Interstitial ad not loaded")
            return false
        }
    }
    
    @MainActor func showAppOpenAd(from viewController: UIViewController? = nil) {
        guard self.canShowAds, SCEPKitInternal.shared.isApplicationShown, !isShowingAppOpen else { return }
        if let appOpenAd = self.appOpenAd {
            isShowingAppOpen = true
            appOpenAd.present(fromRootViewController: viewController)
            SCEPKitInternal.shared.trackEvent("[SCEPKit] app_open_ad_shown")
        } else {
            isShowingAppOpen = false
        }
    }
    
    @MainActor func getBannerAdView(placement: String?, completion: (SCEPBannerAdView) -> Void, dismissHandler: @escaping (SCEPBannerAdView) -> Void) {
        guard canShowAds else { return }
        let bannerView = SCEPBannerAdView(unitId: config.bannerId!, dismissHandler: dismissHandler)
        bannerAdViews.insert(bannerView)
        SCEPKitInternal.shared.trackEvent("[SCEPKit] banner_ad_shown", properties: ["placement": placement ?? ""])
        completion(bannerView)
    }
    
    @MainActor func loadRewardedAd(id: String? = nil, completion: @escaping (GADRewardedAd?) -> Void) {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: id ?? config.rewardedId!, request: request) { ad, error in
            if let error {
                logger.error("Failed to load rewarded ad with error: \(error.localizedDescription)")
            }
            completion(ad)
        }
    }
    
    @MainActor func showRewardedAd(_ ad: GADRewardedAd, from viewController: UIViewController, placement: String?, completion: @escaping (Bool) -> Void) {
        rewardedAdCompletion = completion
        rewardedAdDidReward = false
        shownRewardedAd = ad
        ad.fullScreenContentDelegate = self
        ad.present(fromRootViewController: viewController) {
            self.rewardedAdDidReward = true
        }
        SCEPKitInternal.shared.trackEvent("[SCEPKit] rewarded_ad_shown", properties: ["placement": placement ?? ""])
    }
    
    @MainActor func loadAndShowRewardedAd(from viewController: UIViewController, placement: String?, customLoadingCompletion: ((Bool) -> Void)?, completion: @escaping (Bool) -> Void) {
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
            willShowAppOpen = false
            NotificationCenter.default.post(Self.appOpenDismissedNotification)
            if SCEPKitInternal.shared.isApplicationReady {
                NotificationCenter.default.post(SCEPKitInternal.shared.applicationDidBecomeReadyNotification)
            }
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
            willShowAppOpen = false
            NotificationCenter.default.post(Self.appOpenDismissedNotification)
            if SCEPKitInternal.shared.isApplicationReady {
                NotificationCenter.default.post(SCEPKitInternal.shared.applicationDidBecomeReadyNotification)
            }
        } else if ad is GADRewardedAd {
            rewardedAdCompletion?(rewardedAdDidReward)
            rewardedAdCompletion = nil
            rewardedAdDidReward = false
            shownRewardedAd = nil
        }
    }
}
