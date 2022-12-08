//
//  CreateTeamMemberView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import SwiftUI

struct CreateTeamMemberView: View {
    @Environment(\.dismiss) var dismiss
    
    let academyList: [Academy] = loadJSON("academies")
    @ObservedObject var memberVM: TeamMemberViewModel
    @State var roleViewShown = false
    
    /// 新建操作
    var create = true
    var didUpdate: (TeamMemberViewModel) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("队员学院") {
                    Picker("学院", selection: $memberVM.faculty, content: {
                        ForEach(academyList, id: \.name) { section in
                            ForEach(section.children!, id: \.name) { item in
                                Text(item.name).tag(item.name)
                            }
                        }
                    })
                }
                
                Section("队员角色") {
                    ForEach(memberVM.roles) { role in
                        Text(role.name)
                    }
                    .onDelete { memberVM.roles.remove(atOffsets: $0) }
                    .onMove { memberVM.roles.move(fromOffsets: $0, toOffset: $1) }
                    Button("新建角色") {
                        roleViewShown.toggle()
                    }
                }
                .sheet(isPresented: $roleViewShown) {
                    RoleView { newRole in
                        memberVM.roles.append(RoleViewModel(role: newRole))
                    }
                    .presentationDetents([.medium, .large])
                }
                
                Section {
                    TextEditor(text: $memberVM.description)
                } header: {
                    Text("队员介绍")
                } footer: {
                    Text("填写队员的个人介绍、项目经历、获奖经历等信息，让大家更了解你的队员吧！")
                }
            }
            .navigationBarTitle(create ? "添加队员" : "修改队员信息")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(create ? "添加" : "修改") {
                        didUpdate(memberVM)
                        dismiss()
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

struct CreateTeamMemberView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTeamMemberView(memberVM: TeamMemberViewModel()) {_ in }
    }
}
