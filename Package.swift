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
        .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS", .exact("8.18.3")),
        .package(name: "Adapty", url: "https://github.com/adaptyteam/AdaptySDK-iOS", .exact("3.0.0-beta.2")),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", .exact("10.23.0"))        
    ],
    targets: [
        .target(
            name: "SCEPKit",
            dependencies: [
                .product(name: "AdaptyUI", package: "Adapty", condition: .when(platforms: [.iOS])),
                .product(name: "Adapty", package: "Adapty", condition: .when(platforms: [.iOS])),
                "Amplitude",
                .product(name: "FirebaseRemoteConfig", package: "Firebase", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseAnalytics", package: "Firebase", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseAppCheck", package: "Firebase", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseCrashlytics", package: "Firebase")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
