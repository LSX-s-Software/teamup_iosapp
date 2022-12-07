//
//  TeamInfo.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/1.
//

import SwiftUI
import CachedAsyncImage

struct TeamInfoView: View {
    @State var team: Team
    
    var body: some View {
        NavigationLink {
            TeamDetailView(teamId: team.id, team: team)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(team.name)
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 4) {
                    if let verified = team.competition?.verified, verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.accentColor)
                    }
                    Text(team.competition?.name ?? "")
                        .foregroundColor(.primary)
                }
                
                HStack {
                    CachedAsyncImage(url: URL(string: team.leader?.avatar ?? "")) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .tint(.secondary)
                    }
                    .frame(width: 30, height: 30)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(4)
                    VStack(alignment: .leading) {
                        Text(team.leader?.username ?? "")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        Text(team.leader?.faculty ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("队伍简介：\(team.description ?? "")")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Divider()
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
        }
    }
}

struct TeamInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TeamInfoView(team: PreviewData.team)
    }
}
