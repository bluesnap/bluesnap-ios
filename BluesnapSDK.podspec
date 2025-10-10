Pod::Spec.new do |spec|
    spec.name         = "BluesnapSDK"
    spec.version      = "2.1.2"
    spec.source       = { :git => "https://github.com/bluesnap/bluesnap-ios.git", :tag => "v2.1.2" }
    spec.summary      = "An iOS SDK for Bluesnap "
    spec.description  = <<-DESC
    Integrate payment methods into your iOS native apps quickly and easily.
    Bluesnap iOS SDK supports credit card and Apple Pay, currency conversions and more.
                       DESC
    spec.homepage     = "http://www.bluesnap.com"
    spec.license      = { :type => "MIT", :file => "LICENSE.md" }
    spec.author       = { "snpori" => "oribsnap@gmail.com" }
    spec.platform     = :ios
    spec.ios.deployment_target = '12.0'
    spec.swift_version = '5.0'
    spec.pod_target_xcconfig = { "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES" }
    spec.source_files = ["Sources/**/*.{h,m,swift}", "KountWrapper/**/*.{h,m,c,swift}", "Frameworks/XCFrameworks/KountDataCollector.xcframework/ios-arm64/Headers/KDataCollector.h", "Frameworks/XCFrameworks/KountDataCollector.xcframework/ios-arm64/Headers/KountAnalyticsViewController.h"]
    spec.public_header_files = ["Frameworks/XCFrameworks/KountDataCollector.xcframework/ios-arm64/Headers/KDataCollector.h", "Frameworks/XCFrameworks/KountDataCollector.xcframework/ios-arm64/Headers/KountAnalyticsViewController.h"]
    spec.ios.vendored_frameworks = ["Frameworks/XCFrameworks/CardinalMobile.xcframework", "Frameworks/XCFrameworks/KountDataCollector.xcframework"]
    #spec.ios.vendored_libraries = ["Frameworks/XCFrameworks/KountDataCollector.xcframework/ios-arm64_x86_64-simulator/libKountDataCollector.a"]
    spec.exclude_files = ["Tests/**/*.*", "Frameworks/XCFrameworks/CardinalMobile.SDK runs properly on ios 18 /**/Headers/**"]
    spec.resource_bundles = {
        'BluesnapUI' => [
            'Sources/**/*.xib',
            'Sources/**/*.storyboard',
            'Sources/**/Media.xcassets',
            'Sources/**/*.strings',
            'Sources/**/PrivacyInfo.xcprivacy'
        ]
    }

end

