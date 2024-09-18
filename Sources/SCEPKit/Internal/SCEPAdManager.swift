import GoogleMobileAds
import UIKit

class SCEPAdManager: NSObject {
    static let shared = SCEPAdManager()
    
    var lastInterstitialShowDate: Date = .distantPast
    
    static let appOpenLoaded = Notification.Name(rawValue: "AdManager.appOpenLoaded")
    
    private var interstitial: GADInterstitialAd?
    private var appOpenAd: GADAppOpenAd?
    
    private override init() {
        super.init()
    }
    
    var isStartDelayPassed: Bool {
        let startDelay: TimeInterval = SCEPKitInternal.shared.config.app.ads.startDelay ?? 0
        return Date() >= SCEPKitInternal.shared.firstLaunchDate.addingTimeInterval(startDelay)
    }
    
    var canShowAds: Bool {
        return !SCEPKitInternal.shared.isAdaptyPremium && isStartDelayPassed
    }
    
    @MainActor func start() {
        guard SCEPKitInternal.shared.config.app.ads.isEnabled else { return }
        if !SCEPKitInternal.shared.isAdaptyPremium {
            if SCEPKitInternal.shared.config.app.ads.interstitialId != nil {
                loadInterstitialAd()
            }
            if SCEPKitInternal.shared.config.app.ads.appOpenId != nil {
                loadAppOpenAd()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @MainActor @objc func applicationDidBecomeActive() {
        if SCEPKitInternal.shared.isOnboardingCompleted {
            showAppOpenAd()
        }
    }
    
    private func loadInterstitialAd() {
        guard SCEPKitInternal.shared.config.app.ads.isEnabled else { return }
        guard interstitial == nil else { return }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/4411468910" : SCEPKitInternal.shared.config.app.ads.interstitialId!
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
        guard SCEPKitInternal.shared.config.app.ads.isEnabled else { return }
        guard appOpenAd == nil else { return }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/5575463023" : SCEPKitInternal.shared.config.app.ads.appOpenId!
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: unitId, request: request) { ad, error in
            if let error = error {
                print("Failed to load app open ad with error: \(error.localizedDescription)")
                NotificationCenter.default.post(name: Self.appOpenLoaded, object: nil)
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            NotificationCenter.default.post(name: Self.appOpenLoaded, object: nil)
        }
    }
    
    @MainActor func showInterstitialAd(from viewController: UIViewController? = nil, placement: String) {
        guard canShowAds else { return }
        let interstitialInterval: TimeInterval = SCEPKitInternal.shared.config.app.ads.interstitialInterval ?? 60
        if let interstitial = interstitial, Date() > lastInterstitialShowDate + interstitialInterval {
            interstitial.present(fromRootViewController: viewController)
            lastInterstitialShowDate = Date()
            SCEPKitInternal.shared.trackEvent("[SCEPKit] interstitial_ad_shown", properties: ["placement": placement])
        }
    }
    
    @MainActor func showAppOpenAd(from viewController: UIViewController? = nil) {
        if SCEPKitInternal.shared.isApplicationShown {
            print("AdManager: app open ad display immediately")
            displayAppOpenAd(delay: 0.66, viewController: viewController)
        } else {
            NotificationCenter.default.addOneTimeObserver(forName: SCEPKitInternal.shared.applicationShownNotification) { _ in
                print("AdManager: app open ad display delayed")
                self.displayAppOpenAd(delay: 0.66, viewController: viewController)
            }
        }
    }
    
    private func displayAppOpenAd(delay: TimeInterval, viewController: UIViewController?) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            guard self.canShowAds else { return }
            if let appOpenAd = self.appOpenAd {
                appOpenAd.present(fromRootViewController: viewController)
                SCEPKitInternal.shared.trackEvent("[SCEPKit] app_open_ad_shown")
            } else {
                NotificationCenter.default.addOneTimeObserver(forName: Self.appOpenLoaded) { _ in
                    self.appOpenAd?.present(fromRootViewController: viewController)
                    SCEPKitInternal.shared.trackEvent("[SCEPKit] app_open_ad_shown")
                }
            }
        }
    }
    
    @MainActor func getBannerAdView(placement: String) -> GADBannerView? {
        guard canShowAds else { return nil }
        let unitId = isDebug ? "ca-app-pub-3940256099942544/2435281174" : SCEPKitInternal.shared.config.app.ads.bannerId!
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        let bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = unitId
        bannerView.load(GADRequest())
        SCEPKitInternal.shared.trackEvent("[SCEPKit] banner_ad_shown", properties: ["placement": placement])
        return bannerView
    }
    
    @MainActor func showRewardedAd(from viewController: UIViewController, placement: String, completion: @escaping (Bool) -> Void) {
        let unitId = isDebug ? "ca-app-pub-3940256099942544/1712485313" : SCEPKitInternal.shared.config.app.ads.rewardedId!
        let activitiController = SCEPActivityController.instantiate(bundle: .module)
        viewController.present(activitiController, animated: true)
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: unitId, request: request) { ad, error in
            activitiController.dismiss(animated: true) {
                guard let ad else {
                    print("Failed to load rewarded ad with error: \(error?.localizedDescription ?? "none")")
                    completion(false)
                    return
                }
                ad.fullScreenContentDelegate = self
                ad.present(fromRootViewController: viewController) {
                    let reward = ad.adReward
                    print("User rewarded with \(reward.amount) \(reward.type)")
                    completion(true)
                }
                SCEPKitInternal.shared.trackEvent("[SCEPKit] rewarded_ad_shown", properties: ["placement": placement])
            }
        }
    }
}

extension SCEPAdManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content with error: \(error.localizedDescription)")
        if ad is GADInterstitialAd {
            interstitial = nil
            loadInterstitialAd()
        } else if ad is GADAppOpenAd {
            appOpenAd = nil
            loadAppOpenAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        if ad is GADInterstitialAd {
            interstitial = nil
            loadInterstitialAd()
        } else if ad is GADAppOpenAd {
            appOpenAd = nil
            loadAppOpenAd()
        }
    }
}
