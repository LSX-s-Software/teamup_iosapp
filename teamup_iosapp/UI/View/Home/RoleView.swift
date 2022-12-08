//
//  RoleView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/4.
//

import SwiftUI

struct RoleView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var innerSelection = Role(id: 0, name: "全部角色")
    @State var roles = [Role(id: 0, name: "全部角色")]
    @State var leftSelection = Role(children: [Role]())
    @State var allRole = Role(id: 0, name: "全部角色", children: [Role]())
    
    var didUpdate: ((Role) -> Void)?
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(roles, id: \.id) { role in
                            Text(role.name)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(leftSelection == role ? .accentColor : .primary)
                                .background(leftSelection == role ? Color.accentColor.opacity(0.1) : Color.clear)
                                .onTapGesture {
                                    leftSelection = role
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))

                ScrollView {
                    VStack(spacing: 0) {
                        Group {
                            if leftSelection == allRole {
                                Text("全部角色")
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(innerSelection == allRole ? .accentColor : .primary)
                                    .background(innerSelection == allRole ? Color.accentColor.opacity(0.1) : Color.clear)
                                    .onTapGesture {
                                        innerSelection = allRole
                                    }
                            }
                            ForEach(leftSelection.children, id: \.id) { role in
                                Text(role.name)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(innerSelection == role ? .accentColor : .primary)
                                    .background(innerSelection == role ? Color.accentColor.opacity(0.1) : Color.clear)
                                    .onTapGesture {
                                        innerSelection = role
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("选择角色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        didUpdate?(innerSelection)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .task {
            do {
                let result = try await RoleService.getRoleList()
                allRole.children = result.flatMap { $0.children ?? [$0] }
                roles[0] = allRole
                roles.append(contentsOf: result)
                leftSelection = allRole
                innerSelection = allRole
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct RoleView_Previews: PreviewProvider {
    static var previews: some View {
        RoleView()
    }
}
