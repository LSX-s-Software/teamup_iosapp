//
//  CreateRecruitmentView.swift
//  teamup_iosapp
//
//  Created by RTC-13 on 2022/12/8.
//

import SwiftUI

struct CreateRecruitmentView: View {
    @Environment(\.dismiss) var dismiss

    var teamId: Int
    @ObservedObject var recruitmentVM: RecruitmentViewModel
    @State var roleViewShown = false
    @State var editingRequirement = false
    @State var newRequirement = ""
    @State var editingRequirementIndex = -1
    @State var submitting = false
    
    /// 新建操作
    var create = true
    var didUpdate: (RecruitmentViewModel) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("招募角色") {
                    Button(recruitmentVM.role.id == 0 ? "选择角色" : recruitmentVM.role.name) {
                        roleViewShown.toggle()
                    }
                }
                .sheet(isPresented: $roleViewShown) {
                    RoleView { newRole in
                        recruitmentVM.role = RoleViewModel(role: newRole)
                    }
                    .presentationDetents([.medium, .large])
                }
                
                Section("招募人数") {
                    Stepper("\(recruitmentVM.count)人", value: $recruitmentVM.count, in: 1...50)
                }
                
                Section {
                    ForEach(Array(recruitmentVM.requirements.enumerated()), id: \.offset) { index, requirement in
                        Button {
                            editingRequirementIndex = index
                            newRequirement = requirement
                            editingRequirement = true
                        } label: {
                            HStack {
                                Image(systemName: "\(index + 1).circle")
                                Text(requirement)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .onDelete { recruitmentVM.requirements.remove(atOffsets: $0) }
                    .onMove { recruitmentVM.requirements.move(fromOffsets: $0, toOffset: $1) }
                    if recruitmentVM.requirements.count < 50 {
                        Button("添加需求") {
                            editingRequirementIndex = -1
                            newRequirement = ""
                            editingRequirement = true
                        }
                    }
                } header: {
                    Text("招募需求")
                } footer: {
                    Text("你可以添加一些招募需求来筛选报名表，例如：有项目经历、有商赛获奖经历等")
                }
                .alert("编辑需求内容", isPresented: $editingRequirement, actions: {
                    TextField("请输入需求内容", text: $newRequirement)
                    Button("确定", action: {
                        if editingRequirementIndex == -1 {
                            recruitmentVM.requirements.append(newRequirement)
                        } else {
                            recruitmentVM.requirements[editingRequirementIndex] = newRequirement
                        }
                    })
                    Button("取消", role: .cancel, action: {})
                }, message: {
                    Text("请用简短的一句话描述这条需求")
                })
            }
            .navigationBarTitle(create ? "添加招募信息" : "修改招募信息")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if submitting {
                        ProgressView()
                    } else {
                        Button(create ? "添加" : "修改") {
                            submit()
                        }
                        .disabled(recruitmentVM.role.id == 0 || recruitmentVM.requirements.isEmpty)
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

extension CreateRecruitmentView {
    func submit() {
        submitting = true
        Task {
            do {
                if create {
                    let result = try await TeamService.addRecruitment(teamId: teamId, recruitment: recruitmentVM)
                    recruitmentVM.id = result.id
                } else {
                    _ = try await TeamService.updateRecruitment(teamId: teamId,
                                                                recruitmentId: recruitmentVM.id,
                                                                recruitment: recruitmentVM)
                }
                didUpdate(recruitmentVM)
                submitting = false
                dismiss()
            } catch {
                submitting = false
                print(error.localizedDescription)
            }
        }
    }
}

struct CreateRecruitmentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecruitmentView(teamId: PreviewData.team.id, recruitmentVM: RecruitmentViewModel()) { _ in }
    }
}
