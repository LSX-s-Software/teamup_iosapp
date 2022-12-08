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
    // Member Sheet
    @State var createMemberViewShown = false
    @State var editingTeamMember = -1
    
    var body: some View {
        NavigationView {
            Form {
                Section("队伍名称") {
                    TextField("队伍名称", text: $teamVM.name)
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
                            createMemberViewShown.toggle()
                        } label: {
                            VStack {
                                HStack {
                                    Text("队员\(index + 1)")
                                        .fontWeight(.medium)
                                        .foregroundColor(.accentColor)
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
                        createMemberViewShown.toggle()
                    }
                    .sheet(isPresented: $createMemberViewShown) {
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
                    }
                }

                Section("招募信息") {
                    ForEach(teamVM.recruitments) { recruitment in
//                        NavigationLink(destination: CreateRecruitmentView(recruitmentVM: recruitment)) {
                            Text(recruitment.role.name)
//                        }
                    }
                    .onDelete { teamVM.recruitments.remove(atOffsets: $0) }
                    .onMove { teamVM.recruitments.move(fromOffsets: $0, toOffset: $1) }
                    Button("添加招募信息") {
                        teamVM.recruitments.append(RecruitmentViewModel())
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
                        print(teamVM.team)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateTeamView_Previews: PreviewProvider {
    static var previews: some View {
//        Rectangle()
//            .fill(.background)
//            .sheet(isPresented: .constant(true)) {
                CreateTeamView()
//            }
    }
}
