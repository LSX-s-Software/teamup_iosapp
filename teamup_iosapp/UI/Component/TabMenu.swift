//
//  TabMenu.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/1.
//

import SwiftUI

struct TabMenu: View {
    var items: [String]
    @Binding var selection: Int
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .fontWeight(selection == index ? .medium : .regular)
                        .foregroundColor(selection == index ? .accentColor : .secondary)
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation {
                                selection = index
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

struct TabMenu_Previews: PreviewProvider {
    static var previews: some View {
        TabMenu(items: ["全部角色", "前端开发", "后端开发"], selection: Binding.constant(1))
    }
}
