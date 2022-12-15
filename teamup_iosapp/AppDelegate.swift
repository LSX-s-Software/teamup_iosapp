//
//  AppDelegate.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import UIKit
#if DEBUG
    import Atlantis
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 启用网络调试
#if DEBUG
        Atlantis.start()
#endif
        
        print("Application directory: \(NSHomeDirectory())")
        
        return true
    }
    
}
