//
//  UserTeamView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import SwiftUI

struct UserTeamView: View {
    enum ViewType {
        case myTeam
        case favorite
    }
    
    let type: ViewType
    @StateObject var pagedListVM = PagedListViewModel()
    @State var teams = [Team]()
    @State var createTeamSheetShown = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(teams, id: \.id) { team in
                    TeamInfoView(team: team)
                        .onAppear {
                            if !teams.isEmpty && team.id == teams.last!.id {
                                loadTeamList()
                            }
                        }
                }
                
                HStack(spacing: 4) {
                    if pagedListVM.loading {
                        ProgressView()
                        Text("正在加载中...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    } else {
                        if teams.isEmpty {
                            VStack(spacing: 16) {
                                if type == .myTeam {
                                    Image("Team2")
                                        .resizable()
                                        .scaledToFit()
                                    Text("还没有创建队伍，快去创建一个吧")
                                    Button("创建队伍") {
                                        createTeamSheetShown.toggle()
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Image(systemName: "star")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48)
                                        .foregroundColor(.yellow)
                                    Text("点击团队卡片右上角的星号\n即可快速收藏队伍")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                        } else {
                            Text(pagedListVM.hasNextPage ? "正在加载中..." : "没有更多内容了")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $createTeamSheetShown) {
            CreateTeamView(teamVM: TeamViewModel()) { newTeam in
                teams.append(newTeam)
            }
            .environment(\.modalMode, $createTeamSheetShown)
        }
        .onAppear {
            loadTeamList()
        }
        .navigationTitle(type == .myTeam ? "我的队伍" : "我的收藏")
        .toolbar {
            if type == .myTeam {
                ToolbarItem {
                    Button {
                        createTeamSheetShown.toggle()
                    } label: {
                        Label("创建队伍", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    func loadTeamList() {
        if pagedListVM.loading || !pagedListVM.hasNextPage { return }
        pagedListVM.loading = true
        Task {
            do {
                let response: (data: [Team], hasNext: Bool)
                if type == .myTeam {
                    response = try await UserService.getUserTeam(page: pagedListVM.currentPage + 1)
                } else {
                    response = try await UserService.getUserFavoriteTeam(page: pagedListVM.currentPage + 1)
                }
                teams.append(contentsOf: response.data)
                pagedListVM.currentPage += 1
                pagedListVM.hasNextPage = response.hasNext
            } catch {
                print(error.localizedDescription)
            }
            pagedListVM.loading = false
        }
    }
}

struct UserTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserTeamView(type: .myTeam)
        }
        .previewDisplayName("我的队伍")
        
        NavigationView {
            UserTeamView(type: .favorite)
        }
        .previewDisplayName("我的收藏")
    }
}
