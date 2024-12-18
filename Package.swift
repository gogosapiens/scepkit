// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SCEPKit",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "SCEPKit",
            targets: ["SCEPKit"]
        ),
    ],
    dependencies: [
        .package(name: "Amplitude-Swift", url: "https://github.com/amplitude/Amplitude-Swift", .exact("1.9.1")),
        .package(name: "Adapty", url: "https://github.com/adaptyteam/AdaptySDK-iOS", .exact("3.0.0-beta.2")),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", .exact("10.23.0")),
        .package(name: "GoogleMobileAds", url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .exact("11.8.0")),
        .package(name: "SwiftyGif", url: "https://github.com/alexiscreuzot/SwiftyGif", .exact("5.4.5"))
    ],
    targets: [
        .target(
            name: "SCEPKit",
            dependencies: [
                .product(name: "AdaptyUI", package: "Adapty"),
                .product(name: "Adapty", package: "Adapty"),
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "FirebaseRemoteConfig", package: "Firebase"),
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "FirebaseAppCheck", package: "Firebase"),
                .product(name: "FirebaseCrashlytics", package: "Firebase"),
                .product(name: "GoogleMobileAds", package: "GoogleMobileAds"),
                .product(name: "SwiftyGif", package: "SwiftyGif")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
