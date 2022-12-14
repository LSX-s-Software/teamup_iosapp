//
//  CreateTeamView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import SwiftUI
import SwiftUIFlow

struct CreateTeamView: View {
    enum Status {
        case initial
        case submitting
        case success
        case fail
    }
    
    @Environment(\.dismiss) var dismiss

    @StateObject var teamVM = TeamViewModel()
    @State var competitions = [Competition]()
    // Member Sheet
    @State var memberViewShown = false
    @State var editingTeamMember = -1
    // Competition Sheet
    @State var competitionAppViewShown = false
    // Submission state
    @State var pageStatus = Status.initial
    @State var errorMsg: String?
    // Callback
    var didCreateTeam: ((Team) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                if pageStatus == .fail {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 36)
                            .foregroundColor(.red)
                        Text(errorMsg ?? "发生未知错误")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                
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
                    Button("建议新比赛") {
                        competitionAppViewShown.toggle()
                    }
                    .sheet(isPresented: $competitionAppViewShown) {
                        CompetitionApplicationView { newCompetition in
                            competitions.append(newCompetition)
                            teamVM.competitionId = newCompetition.id!
                        }
                    }
                } header: {
                    Text("参加的比赛")
                } footer: {
                    Text("选择该团队参加的比赛，如果需要参加多场比赛，请分别在每个比赛下创建团队。如果想参加的比赛不在列表中，可以点击“建议新比赛”按钮向我们提交新比赛的建议")
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
                    switch pageStatus {
                    case .initial, .fail:
                        Button(pageStatus == .initial ? "创建" : "重试") {
                            submit()
                        }
                        .disabled(!formValid)
                    case .submitting:
                        ProgressView()
                    case .success:
                        NavigationLink("下一步", isActive: .constant(pageStatus == .success)) {
                            TeamRecruitmentEditView(teamVM: teamVM)
                        }
                    }
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
        return !(teamVM.name.isEmpty || teamVM.description.isEmpty || teamVM.competitionId == 0)
    }
    
    func submit() {
        pageStatus = .submitting
        Task {
            do {
                let newTeam = try await TeamService.createTeam(team: teamVM)
                teamVM.id = newTeam.id
                didCreateTeam?(newTeam)
                withAnimation {
                    pageStatus = .success
                }
            } catch {
                withAnimation {
                    pageStatus = .fail
                    errorMsg = error.localizedDescription
                }
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
