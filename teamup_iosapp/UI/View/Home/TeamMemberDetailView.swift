//
//  TeamMemberDetailView.swift
//  teamup_iosapp
//
//  Created by RTC-13 on 2022/12/7.
//

import SwiftUI
import SwiftUIFlow

struct TeamMemberDetailView: View {
    var teamMembers: [TeamMember]
    
    var body: some View {
        List(Array(teamMembers.enumerated()), id: \.offset) { index, member in
            Section {
                HStack {
                    Text("学院")
                    Spacer()
                    Text(member.faculty ?? "")
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
                Text(member.description ?? "")
            } header: {
                HStack {
                    Text("队员\(index + 1)")
                        .font(.system(size: 17))
                    ForEach(member.roles ?? [], id: \.id) { role in
                        Text(role.name)
                            .lineLimit(1)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 6)
                            .foregroundColor(.secondary)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct TeamMemberDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamMemberDetailView(teamMembers: [PreviewData.teamMember1, PreviewData.teamMember2])
        }
    }
}
