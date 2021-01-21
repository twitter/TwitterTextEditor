//
//  AppDelegate.swift
//  Example
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation
import KeyboardGuide
import TwitterTextEditor
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        KeyboardGuide.shared.activate()

        // For Objective-C implementation, you can use `TwitterTextEditorBridgeConfiguration`.
        // See `TwitterTextEditorBridgeConfiguration.swift`.
        let configuration = TwitterTextEditor.Configuration.shared
        configuration.logger = OSDefaultLogger()
        configuration.tracer = OSDefaultTracer()
        configuration.attributeNamesDescribedForAttributedStringShortDescription = [
            .font,
            .foregroundColor,
            .backgroundColor,
            .suffixedAttachment
        ]

        let window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
