// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluesnapSDK",
    defaultLocalization: LanguageTag("en"),
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BluesnapSDK",
            type: .dynamic,
            targets: ["BluesnapSDK", "KountWrapper"]
        ),
        .library(
            name: "KountWrapper",
            type: .static,
            targets: ["KountWrapper"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        //.package(url: "https://github.com/Kount/kount-ios-swift-package", from: "4.1.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BluesnapSDK",
            dependencies: [
                "CardinalMobile",
                "KountWrapper"
                //.product(name: "KountDataCollectorPackage", package: "kount-ios-swift-package")
            ],
            resources: [
                .copy("Resources/credentials.plist"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "KountWrapper",
            dependencies: [
                "KountDataCollector"
            ],
            path: "KountWrapper/KountWrapper"
        ),
        .testTarget(
            name: "BluesnapSDKTests",
            dependencies: ["BluesnapSDK"]
        ),
        .testTarget(
            name: "BluesnapSDKIntegrationTests",
            dependencies: ["BluesnapSDK"]
        ),
        .binaryTarget(name: "CardinalMobile", path: "Frameworks/XCFrameworks/CardinalMobile.xcframework"),
        .binaryTarget(name: "KountDataCollector", path: "Frameworks/XCFrameworks/KountDataCollector.xcframework")
    ]
)
