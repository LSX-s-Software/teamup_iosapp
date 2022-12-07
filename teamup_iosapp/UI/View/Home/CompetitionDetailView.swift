//
//  CompetitionDetailView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/7.
//

import SwiftUI
import CachedAsyncImage
import Charts

struct CompetitionDetailView: View {
    var competitionId: Int
    @State var competition = Competition()
    @State var teams = [Team]()
    @StateObject var pagedListVM = PagedListViewModel()
    // Filter
    @State var sortMethod: TeamService.SortMethod = .date
    
    var body: some View {
        ScrollView {
            ZStack {
                Color.accentColor
            
                VStack {
                    Spacer()
                        .frame(height: 150)
                    VStack(spacing: 12) {
                        // MARK: - 基本信息
                        Text(competition.name ?? "")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        HStack {
                            if let startTime = competition.startTime {
                                Text("\(Formatter.formatDate(date: startTime, format: "yyyy-MM-dd"))")
                                    .lineLimit(1)
                                    .foregroundColor(.primary)
                            }
                            Image(systemName: "arrowshape.right")
                                .foregroundColor(.primary)
                            if let endTime = competition.endTime {
                                Text("\(Formatter.formatDate(date: endTime, format: "yyyy-MM-dd"))")
                                    .lineLimit(1)
                                    .foregroundColor(.primary)
                            }
                        }
                        Text(competition.description ?? "")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // MARK: - 组队情况
                        Text("组队情况")
                            .modifier(SectionTitleStyle())
                        Chart(Array(PreviewData.teamCountHistory.enumerated()), id: \.offset) { index, element in
                            BarMark(x: .value("index", index), y: .value("count", element))
                        }
                        .chartYAxisLabel("队伍数量")
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        HStack(spacing: 4) {
                            Text("队伍总数：\(competition.teamCount ?? 0)")
                            Spacer()
                                .frame(width: 10)
                            Group {
                                Image(systemName: "arrow.up")
                                    .fontWeight(.heavy)
                                Text("10 (较昨日)")
                            }
                            .foregroundColor(.green)
                        }
                        Divider()
                        
                        // MARK: - 队伍
                        LazyVStack(spacing: 0) {
                            HStack(spacing: -8) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(.accentColor)
                                Picker("排序方法", selection: $sortMethod) {
                                    ForEach(TeamService.SortMethod.allCases, id: \.self) { method in
                                        Text(method.rawValue)
                                    }
                                }
                                Spacer()
                            }
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
                                Text(pagedListVM.hasNextPage ? "正在加载中..." : "没有更多队伍了")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .padding(.top, 75)
                    .frame(maxWidth: .infinity)
                    .background(.background)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    // MARK: - logo
                    VStack {
                        Spacer()
                            .frame(height: 75)
                        CachedAsyncImage(url: URL(string: competition.logo ?? "")) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .background()
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                        .overlay(alignment: .bottomTrailing) {
                            if competition.verified {
                                Image(systemName: "checkmark.seal.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.accentColor)
                                    .frame(width: 40, height: 40)
                                    .offset(x: 14, y: 14)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.accentColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            loadTeamList()
        }
        .task {
            do {
                competition = try await CompetitionService.getCompetition(id: competitionId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension CompetitionDetailView {
    func loadTeamList() {
        if pagedListVM.loading || !pagedListVM.hasNextPage { return }
        pagedListVM.loading = true
        Task {
            do {
                let response = try await TeamService.getTeamList(competition: competition.name,
                                                                 page: pagedListVM.currentPage + 1,
                                                                 pageSize: 10)
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

struct CompetitionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompetitionDetailView(competitionId: 13, competition: PreviewData.competition)
        }
    }
}
