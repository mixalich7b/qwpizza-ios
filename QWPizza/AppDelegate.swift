//
//  AppDelegate.swift
//  QWPizza
//
//  Created by Тупицин Константин on 15.11.16.
//  Copyright © 2016 Qiwi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: NSNotification.Name("status"), object: Optional.none)
        print(url.absoluteString)
        return true
    }

}

