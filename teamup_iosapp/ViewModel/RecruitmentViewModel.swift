//
//  RecruitmentViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

class RecruitmentViewModel: ObservableObject {
    @Published var id = 0

    /// 招募人数
    @Published var count = 1
    
    /// 招募角色
    @Published var role = RoleViewModel()
    
    /// 招募需求
    @Published var requirements = [String]()
    
    init() { }
    
    init(recruitment: Recruitment) {
        self.id = recruitment.id
        self.count = recruitment.count
        self.role = RoleViewModel(role: recruitment.role)
        self.requirements = recruitment.requirements
    }

    var recruitment: Recruitment {
        return Recruitment(id: id > 0 ? id : nil, role: role.role, count: count, requirements: requirements)
    }
}
