//
//  TeamMemberViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

class TeamMemberViewModel: ObservableObject, Identifiable {
    var id = UUID()

    /// 角色
    @Published var roles = [RoleViewModel]()

    /// 学院
    @Published var faculty = "哲学学院"

    /// 成员描述
    @Published var description = ""

    init() { }

    init(member: TeamMember) {
        self.roles = member.roles!.map { RoleViewModel(role: $0) }
        self.faculty = member.faculty!
        self.description = member.description
    }

    var teamMember: TeamMember {
        return TeamMember(roles: roles.map { $0.role }, faculty: faculty, description: description)
    }
}
