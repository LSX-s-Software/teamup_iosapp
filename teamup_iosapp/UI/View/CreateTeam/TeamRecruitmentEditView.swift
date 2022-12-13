//
//  TeamRecruitmentEditView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/13.
//

import SwiftUI

struct TeamRecruitmentEditView: View {
    @Environment (\.modalMode) var modalMode
    @ObservedObject var teamVM: TeamViewModel
    // Recruitment Sheet
    @State var recruitmentViewShown = false
    @State var editingRecruitment = -1
    
    var body: some View {
        Form {
            ForEach(Array(teamVM.recruitments.enumerated()), id: \.offset) { index, recruitment in
                Section("招募信息\(index + 1)") {
                    Button {
                        editingRecruitment = index
                        recruitmentViewShown.toggle()
                    } label: {
                        RecruitmentInfoView(recruitment: recruitment.recruitment)
                            .foregroundColor(.primary)
                    }
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    let target = teamVM.recruitments.remove(at: offset)
                    Task {
                        do {
                            try await TeamService.removeRecruitment(teamId: teamVM.id, recruitmentId: target.id)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            Section {
                Button("添加招募信息") {
                    editingRecruitment = -1
                    recruitmentViewShown.toggle()
                }
                .sheet(isPresented: $recruitmentViewShown) {
                    CreateRecruitmentView(
                        teamId: teamVM.id,
                        recruitmentVM: editingRecruitment >= 0 ? teamVM.recruitments[editingRecruitment] : RecruitmentViewModel(),
                        create: editingRecruitment == -1
                    ) { newRecruitment in
                        if editingRecruitment >= 0 {
                            teamVM.recruitments[editingRecruitment] = newRecruitment
                            editingRecruitment = -1
                        } else {
                            teamVM.recruitments.append(newRecruitment)
                        }
                    }
                    .interactiveDismissDisabled()
                }
            }
        }
        .navigationTitle("填写招募信息")
        .navigationBarBackButtonHidden()
        .toolbar {
            if !teamVM.recruitments.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        modalMode.wrappedValue = false
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("跳过") {
                    modalMode.wrappedValue = false
                }
            }
        }
    }
}

struct EditRecruitmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamRecruitmentEditView(teamVM: TeamViewModel(team: PreviewData.team))
        }
    }
}
