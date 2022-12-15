//
//  CompetitionView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/4.
//

import SwiftUI
import CachedAsyncImage

struct CompetitionView: View {
    @State var competitionList = [Competition]()
    @State var subsribeCompetitionList = [Competition]()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    Section {
                        if (subsribeCompetitionList.count == 0) {
                            Text("暂无已订阅的比赛")
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                        ForEach(subsribeCompetitionList, id: \.id) { competition in
                            CompetitionInfoView(competition: competition) {
                                loadData()
                            }
                        }
                        .listStyle(.plain)
                        .padding(.horizontal)
                    } header: {
                        Text("已订阅的比赛")
                            .padding()
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
                    }
                    
                    Section {
                        ForEach(competitionList, id: \.id) { competition in
                            CompetitionInfoView(competition: competition) {
                                loadData()
                            }
                        }
                        .listStyle(.plain)
                        .padding(.horizontal)
                    } header: {
                        Text("全部")
                            .padding()
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
                    }
                }
            }
            .navigationTitle("比赛")
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        Task {
            do {
                competitionList = try await CompetitionService.getCompetitionList()
                subsribeCompetitionList = try await CompetitionService.getSubsribeCompetitionList()
                subsribeCompetitionList.forEach { competition in
                    competitionList.removeAll { $0.id == competition.id}
                }
            } catch {
                
            }
        }
    }
}

struct CompetitionView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionView()
    }
}
