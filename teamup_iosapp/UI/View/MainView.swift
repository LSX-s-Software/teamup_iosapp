//
//  MainView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import SwiftUI

enum Tab: Int {
    case home
    case competition
    case chat
    case me
}

struct MainView: View {
    @State var tabSelection = Tab.home.rawValue
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView(tabbarSelection: $tabSelection)
                .tabItem {
                    Label("组队", systemImage: "person.2")
                }
                .tag(Tab.home.rawValue)
            
            CompetitionView()
                .tabItem {
                    Label("比赛", systemImage: "flag.2.crossed")
                }
                .tag(Tab.competition.rawValue)
            
            ChatListView()
                .tabItem {
                    Label("消息", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(Tab.chat.rawValue)
            
            MeView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(Tab.me.rawValue)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
