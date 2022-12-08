//
//  TeamDetailView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/4.
//

import SwiftUI
import CachedAsyncImage

struct SectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.accentColor)
    }
}

struct TeamDetailView: View {
    var teamId: Int
    @State var team = Team()
    // Alert
    @State var alertShown = false
    @State var alertTitle = ""
    @State var alertMsg: String?
    // Sheet
    @State var teamMemberSheetShown = false
    @State var leaderSheetShown = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - 比赛信息
                CompetitionInfoView(competition: team.competition ?? Competition())
                
                // MARK: - 队长信息
                VStack(alignment: .leading) {
                    Text("队长信息")
                        .modifier(SectionTitleStyle())
                    Button {
                        leaderSheetShown.toggle()
                    } label: {
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                CachedAsyncImage(url: URL(string: team.leader?.avatar ?? "")) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(5)
                                Spacer()
                                    .frame(width: 12)
                                VStack(alignment: .leading) {
                                    Text(team.leader?.username ?? "")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                    Text(team.leader?.faculty ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            Text(nilOrEmpty(team.leader?.introduction) ? "这个人很懒，没有写自我介绍" : team.leader!.introduction!)
                                .lineLimit(3)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $leaderSheetShown) {
                        NavigationView {
                            UserView(userId: team.leader!.id, user: team.leader!)
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("关闭") {
                                            leaderSheetShown = false
                                        }
                                        .tint(.white)
                                    }
                                }
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
                
                // MARK: - 队伍介绍
                VStack(alignment: .leading, spacing: 4) {
                    Text("队伍介绍")
                        .modifier(SectionTitleStyle())
                    Text(team.description ?? "")
                }
                
                // MARK: - 队伍成员
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("队伍成员")
                            .modifier(SectionTitleStyle())
                        Spacer()
                        Button {
                            teamMemberSheetShown.toggle()
                        } label: {
                            Text("共\(team.members?.count ?? 0)人")
                                .foregroundColor(.secondary)
                                .font(.callout)
                            Image(systemName: "chevron.right")
                        }
                        .sheet(isPresented: $teamMemberSheetShown) {
                            NavigationView {
                                TeamMemberDetailView(teamMembers: team.members ?? [])
                                    .toolbar {
                                        ToolbarItem(placement: .confirmationAction) {
                                            Button("关闭") {
                                                teamMemberSheetShown = false
                                            }
                                        }
                                    }
                                    .navigationTitle("所有队员")
                            }
                            .presentationDetents([.medium, .large])
                        }
                    }
                    ForEach(Array((team.members ?? []).enumerated()), id: \.offset) { index, member in
                        HStack {
                            Text("队员\(index + 1)")
                                .fontWeight(.medium)
                                .foregroundColor(.accentColor)
                                .lineLimit(1)
                            Text(member.faculty ?? "")
                                .lineLimit(1)
                            Spacer()
                            ForEach(member.roles ?? [], id: \.id) { role in
                                Text(role.name)
                                    .lineLimit(1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 6)
                                    .foregroundColor(.secondary)
                                    .background(Color(UIColor.tertiarySystemBackground))
                                    .cornerRadius(5)
                            }
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                
                // MARK: - 招募信息
                VStack(alignment: .leading, spacing: 12) {
                    Text("招募信息")
                        .modifier(SectionTitleStyle())
                    ForEach(team.recruitments ?? [], id: \.id) { recruitment in
                        RecruitmentInfoView(recruitment: recruitment)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    if team.recruitments == nil || team.recruitments!.isEmpty {
                        Text("该团队暂无招募信息")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(team.name ?? "")
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    
                } label: {
                    Label("点赞", systemImage: "hand.thumbsup")
                }
                Button {
                    
                } label: {
                    Label("收藏", systemImage: "star")
                }
                Spacer()
                    .frame(width: 12)
                Button {
                    
                } label: {
                    Text("立即报名")
                        .fontWeight(.medium)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(VisualEffectView(effect: UIBlurEffect(style: .regular)).ignoresSafeArea(edges: .bottom))
            .cornerRadius(15, corners: [.topLeft, .topRight])
        }
        .alert(isPresented: $alertShown) {
            Alert(title: Text(alertTitle), message: Text(alertMsg ?? ""), dismissButton: .default(Text("确定")))
        }
        .task {
            do {
                team = try await TeamService.getTeamDetail(id: teamId)
            } catch {
                showAlert(title: "团队信息加载失败", msg: error.localizedDescription)
            }
        }
    }
}

extension TeamDetailView {
    func showAlert(title: String, msg: String? = nil) {
        alertTitle = title
        alertMsg = msg
        alertShown = true
    }
}

struct TeamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamDetailView(teamId: 112, team: PreviewData.team)
        }
    }
}
