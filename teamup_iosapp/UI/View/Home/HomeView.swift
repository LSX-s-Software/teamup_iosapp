//
//  HomeView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import SwiftUI
import iPages

struct HomeView: View {
    @Environment(\.tabBarSelection) var tabbarSelection
    // Banner
    @State var currentPage = 0
    let bannerTimer = Timer.publish(every: 7.5, on: .main, in: .common).autoconnect()
    @State var bannerItems = [Color.red, Color.yellow, Color.blue, Color.green]
    // 角色
    @State var teamRoles = ["全部角色"]
    @State var selectedRole = 0
    @State var roleViewShown = false
    @State var roleViewSelction = Role(id: 0)
    // 比赛
    @State var competitions = ["全部"]
    @State var selectedCompetition = 0
    // 组队信息
    @StateObject var pagedListVM = PagedListViewModel()
    @State var teams = [Team]()
    @State var createTeamSheetShown = false
    // Alert
    @State var alertShown = false
    @State var alertTitle = ""
    @State var alertMsg: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    // MARK: - banner
                    iPages(selection: $currentPage) {
                        ForEach(bannerItems, id: \.hashValue) { item in
                            item
                        }
                    }
                    .wraps(true)
                    .animated(true)
                    .frame(height: 250)
                    .onReceive(bannerTimer) { _ in
                        currentPage = (currentPage + 1) % bannerItems.count
                    }
                    
                    Section {
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
                            }
                            Text(pagedListVM.hasNextPage ? "正在加载中..." : "没有更多内容了")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                    } header: {
                        // MARK: - tab
                        VStack {
                            HStack(spacing: 0) {
                                TabMenu(items: competitions, selection: $selectedCompetition)
                                Button {
                                    tabbarSelection.wrappedValue = Tab.competition
                                } label: {
                                    Image(systemName: "arrow.up.forward.circle")
                                        .imageScale(.large)
                                }
                                .padding(.horizontal, 10)
                            }
                            .onChange(of: selectedCompetition) { _ in
                                loadTeamList(reload: true)
                            }
                            HStack(spacing: 0) {
                                TabMenu(items: teamRoles, selection: $selectedRole)
                                Button {
                                    roleViewShown.toggle()
                                } label: {
                                    Image(systemName: "line.3.horizontal.circle")
                                        .imageScale(.large)
                                }
                                .padding(.horizontal, 10)
                            }
                            .onChange(of: selectedRole) { _ in
                                loadTeamList(reload: true)
                            }
                            .sheet(isPresented: $roleViewShown) {
                                RoleView { newRole in
                                    roleViewSelction = newRole
                                }
                            }
                            .onChange(of: roleViewSelction) { newSelection in
                                if let name = newSelection.name {
                                    selectedRole = teamRoles.firstIndex(of: name) ?? 0
                                }
                            }
                        }
                        .background(.regularMaterial)
                    }
                }
            }
            .navigationTitle("组队")
            .toolbar {
                ToolbarItem {
                    Button {
                        createTeamSheetShown.toggle()
                    } label: {
                        Label("创建队伍", systemImage: "plus")
                    }
                    .sheet(isPresented: $createTeamSheetShown) {
                        CreateTeamView()
                            .environment(\.modalMode, $createTeamSheetShown)
                    }
                }
            }
            .alert(isPresented: $alertShown) {
                Alert(title: Text(alertTitle), message: Text(alertMsg ?? ""), dismissButton: .default(Text("确定")))
            }
            .task {
                if competitions.count > 1 { return }
                do {
                    let rawTeamRoles = try await RoleService.getRoleList(flattened: true)
                    teamRoles.append(contentsOf: rawTeamRoles.map { $0.name! })
                } catch {
                    print(error.localizedDescription)
                }
            }
            .task {
                if teamRoles.count > 1 { return }
                do {
                    let rawCompetitions = try await CompetitionService.getCompetitionList()
                    competitions.append(contentsOf: rawCompetitions.map { $0.abbreviation ?? $0.name })
                } catch {
                    print(error.localizedDescription)
                }
            }
            .onAppear {
                loadTeamList()
            }
        }
    }
}

extension HomeView {
    func showAlert(title: String, msg: String? = nil) {
        alertTitle = title
        alertMsg = msg
        alertShown = true
    }
    
    func loadTeamList(reload: Bool = false) {
        if pagedListVM.loading || !reload && !pagedListVM.hasNextPage { return }
        if reload {
            pagedListVM.currentPage = 0
            pagedListVM.hasNextPage = true
            teams.removeAll()
        }
        pagedListVM.loading = true
        let targetCompetition = selectedCompetition > 0 ? competitions[selectedCompetition] : nil
        let targetRole = selectedRole > 0 ? teamRoles[selectedRole] : nil
        Task {
            do {
                let response = try await TeamService.getTeamList(competition: targetCompetition,
                                                                 role: targetRole,
                                                                 page: pagedListVM.currentPage + 1)
                teams.append(contentsOf: response.data)
                pagedListVM.currentPage += 1
                pagedListVM.hasNextPage = response.hasNext
            } catch {
                showAlert(title: "加载队伍列表失败", msg: error.localizedDescription)
            }
            pagedListVM.loading = false
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("组队", systemImage: "flag.2.crossed")
                }
        }
    }
}
