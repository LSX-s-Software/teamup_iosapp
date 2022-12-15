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
                VStack(alignment: .leading,spacing: 16) {
                    Section {
                        if (subsribeCompetitionList.count == 0) {
                            Text("暂无订阅比赛").padding(.horizontal)
                        }
                        ForEach(subsribeCompetitionList, id: \.id) { competition in
                            CompetitionInfoView(competition: competition){
                                Task {
                                    do {
                                        subsribeCompetitionList = try await CompetitionService.getSubsribeCompetitionList()
                                    }
                                    catch {}
                                }
                            }
                        }
                        .listStyle(.plain)
                        .padding(.horizontal)
                    } header: {
                        Text("订阅").padding().fontWeight(.medium)
                    }
                    
                    Section {
                        ForEach(competitionList, id: \.id) { competition in
                                CompetitionInfoView(competition: competition){
                                    Task {
                                        do {
                                            subsribeCompetitionList = try await CompetitionService.getSubsribeCompetitionList()
                                        }
                                        catch {}
                                    }
                                }
                        }
                        .listStyle(.plain)
                        .padding(.horizontal)
                    } header: {
                        Text("全部").padding().fontWeight(.medium)
                    }
                }
            }
            .navigationTitle("比赛")
        }
        .task {
            do {
                competitionList = try await CompetitionService.getCompetitionList()
                subsribeCompetitionList = try await CompetitionService.getSubsribeCompetitionList()
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
