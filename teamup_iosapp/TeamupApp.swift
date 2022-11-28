//
//  TeamupApp.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/27.
//

import SwiftUI

@main
struct TeamupApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .tint(.accentColor)
        }
    }
}
