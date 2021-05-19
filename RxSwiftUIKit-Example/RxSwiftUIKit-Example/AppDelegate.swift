//
//  AppDelegate.swift
//  RxSwiftUIKit-Example
//
//  Created by finos.son.le on 18/05/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let vc = ViewController()
        let navi = UINavigationController(rootViewController: vc)
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = navi
        self.window = w
        w.makeKeyAndVisible()
        
        return true
    }

}

