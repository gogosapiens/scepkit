// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SCEPKit",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "SCEPKit", targets: ["SCEPKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.15.0"),
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS", exact: "3.0.0-beta.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.3.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "12.11.0"),
        .package(url: "https://github.com/alexiscreuzot/SwiftyGif", from: "5.4.5"),
    ],
    targets: [
        .target(
            name: "SCEPKit",
            dependencies: [
                .product(name: "Adapty", package: "AdaptySDK-iOS"),
                .product(name: "AdaptyUI", package: "AdaptySDK-iOS"),
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "SwiftyGif", package: "SwiftyGif"),
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
