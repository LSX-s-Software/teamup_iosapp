//
//  CreateTeamView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import SwiftUI
import SwiftUIFlow

struct CreateTeamView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var teamVM = TeamViewModel()
    @State var competitions = [Competition]()
    // Member Sheet
    @State var memberViewShown = false
    @State var editingTeamMember = -1
    // Recruitment Sheet
    @State var recruitmentViewShown = false
    @State var editingRecruitment = -1
    
    var body: some View {
        NavigationView {
            Form {
                Section("队伍名称") {
                    TextField("队伍名称", text: $teamVM.name)
                }
                
                Section {
                    Picker("比赛", selection: $teamVM.competitionId) {
                        Text("未选择比赛").tag(0)
                        ForEach(competitions, id: \.id) { competition in
                            Text(competition.name).tag(competition.id!)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("参加的比赛")
                } footer: {
                    Text("选择该团队参加的比赛，如果需要参加多场比赛，请分别在每个比赛下创建团队")
                }

                Section {
                    TextEditor(text: $teamVM.description)
                } header: {
                    Text("队伍描述")
                } footer: {
                    Text("可以从项目介绍、项目进展、团队成员、指导老师等方面描述你的队伍")
                }

                Section("队伍已有成员") {
                    ForEach(Array(teamVM.members.enumerated()), id: \.offset) { index, member in
                        Button {
                            editingTeamMember = index
                            memberViewShown.toggle()
                        } label: {
                            VStack {
                                HStack {
                                    Text("队员\(index + 1)")
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(member.faculty)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                VFlow(alignment: .leading) {
                                    ForEach(member.roles, id: \.id) { role in
                                        Text(role.name)
                                            .lineLimit(1)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 6)
                                            .foregroundColor(.secondary)
                                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                                            .cornerRadius(5)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete { teamVM.members.remove(atOffsets: $0) }
                    .onMove { teamVM.members.move(fromOffsets: $0, toOffset: $1) }
                    Button("添加队员") {
                        editingTeamMember = -1
                        memberViewShown.toggle()
                    }
                    .sheet(isPresented: $memberViewShown) {
                        CreateTeamMemberView(
                            memberVM: editingTeamMember >= 0 ? teamVM.members[editingTeamMember] : TeamMemberViewModel(),
                            create: editingTeamMember == -1
                        ) { newTeamMember in
                            if editingTeamMember >= 0 {
                                teamVM.members[editingTeamMember] = newTeamMember
                                editingTeamMember = -1
                            } else {
                                teamVM.members.append(newTeamMember)
                            }
                        }
                        .interactiveDismissDisabled()
                    }
                }

                Section("招募信息") {
                    ForEach(Array(teamVM.recruitments.enumerated()), id: \.offset) { index, recruitment in
                        Button {
                            editingRecruitment = index
                            recruitmentViewShown.toggle()
                        } label: {
                            RecruitmentInfoView(recruitment: recruitment.recruitment)
                                .foregroundColor(.primary)
                        }
                    }
                    .onDelete { teamVM.recruitments.remove(atOffsets: $0) }
                    .onMove { teamVM.recruitments.move(fromOffsets: $0, toOffset: $1) }
                    Button("添加招募信息") {
                        editingRecruitment = -1
                        recruitmentViewShown.toggle()
                    }
                    .sheet(isPresented: $recruitmentViewShown) {
                        CreateRecruitmentView(
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

                Section {
                    Toggle("允许报名", isOn: $teamVM.recruiting)
                } header: {
                    Text("是否招募中")
                } footer: {
                    Text("不允许报名的队伍将不会显示在队伍列表中")
                }
            }
            .navigationBarTitle("创建队伍")
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        submit()
                    }
                    .disabled(!formValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .task {
                do {
                    competitions = try await CompetitionService.getCompetitionList()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension CreateTeamView {
    var formValid: Bool {
        return !(teamVM.name.isEmpty || teamVM.description.isEmpty || teamVM.competitionId == 0 || teamVM.recruitments.isEmpty)
    }
    
    func submit() {
        Task {
            do {
                try await TeamService.createTeam(team: teamVM)
                dismiss()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct CreateTeamView_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(.background)
            .sheet(isPresented: .constant(true)) {
                CreateTeamView()
            }
    }
}
