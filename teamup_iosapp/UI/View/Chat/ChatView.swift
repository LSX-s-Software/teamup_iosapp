//
//  ChatView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import SwiftUI

struct ChatView: View {
    @State var user: User
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(user: PreviewData.leader)
    }
}
