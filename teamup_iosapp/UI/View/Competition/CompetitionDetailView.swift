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
    // 团队数量历史
    @State var teamCountHistory = [CompetitionTeamHistory]()
    @State var teamCountScale = CompetitionTeamHistory.Scale.quarter
    @State var teamCountDelta = 0
    var xAxisMarkInterval: Int {
        var interval: Int
        switch teamCountScale {
        case .month:
            interval = 5
        case .quarter:
            interval = 5
        case .halfYear:
            interval = 2
        case .year:
            interval = 1
        }
        return interval
    }
    // 团队
    @State var teams = [Team]()
    @StateObject var pagedListVM = PagedListViewModel()
    // Filter
    @State var sortMethod: TeamService.SortMethod = .date
    
    var callback: (()->Void)?
    
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
                        if let abbreviation = competition.abbreviation {
                            Text("“\(abbreviation)”")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
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
                        
                        Button(competition.subscribed ? "取消订阅" : "订阅") {
                            if (!competition.subscribed) {
                                Task {
                                    do {
                                        try await CompetitionService.subscribeCompetition(id: competitionId)
                                        callback?()
                                    } catch {
                                        
                                    }
                                }
                                competition.subscribed = true
                            } else {
                                Task {
                                    do {
                                        try await CompetitionService.unsubscribeCompetition(id: competitionId)
                                        callback?()
                                    } catch {
                                        
                                    }
                                }
                                competition.subscribed = false
                            }
                        }.buttonStyle(.borderedProminent)
                        

                        Text(competition.description ?? "")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // MARK: - 组队情况
                        Text("组队情况")
                            .modifier(SectionTitleStyle())
                        VStack {
                            Picker("时间跨度", selection: $teamCountScale) {
                                ForEach(CompetitionTeamHistory.Scale.allCases, id: \.self) { scale in
                                    Text(scale.rawValue).tag(scale)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: teamCountScale) { _ in
                                loadHistory()
                            }
                            Chart(teamCountHistory, id: \.date) { element in
                                BarMark(x: .value("日期", element.date), y: .value("数量", element.count))
                            }
                            .chartYAxisLabel("队伍数量")
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisTick()
                                    if value.index % xAxisMarkInterval == 0 {
                                        AxisGridLine()
                                        AxisValueLabel(collisionResolution: .greedy)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        HStack(spacing: 4) {
                            Text("队伍总数：\(competition.teamCount ?? 0)")
                            Spacer()
                                .frame(width: 10)
                            if teamCountDelta > 0 {
                                Group {
                                    Image(systemName: "arrow.up")
                                        .fontWeight(.heavy)
                                    Text("\(teamCountDelta) (较昨日)")
                                }
                                .foregroundColor(.green)
                            } else {
                                Group {
                                    Image(systemName: "minus")
                                        .fontWeight(.heavy)
                                    Text("\(teamCountDelta) (较昨日)")
                                }
                                .foregroundColor(.secondary)
                            }
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
                        CompetitionLogo(logo: competition.logo, abbreviation: competition.abbreviation, size: 150)
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
            loadHistory()
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
    
    func loadHistory() {
        Task {
            do {
                let result = try await CompetitionService.getCompetitionTeamHistory(id: competitionId, scale: teamCountScale)
                withAnimation {
                    teamCountHistory = result.history
                    teamCountDelta = result.delta
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct CompetitionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompetitionDetailView(competitionId: 14, competition: PreviewData.competition)
        }
    }
}
