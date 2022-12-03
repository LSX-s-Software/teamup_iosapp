//
//  MainView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("组队", systemImage: "flag.2.crossed")
                }
            
            ChatListView()
                .tabItem {
                    Label("聊天", systemImage: "bubble.left.and.bubble.right")
                }
            
            MeView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
