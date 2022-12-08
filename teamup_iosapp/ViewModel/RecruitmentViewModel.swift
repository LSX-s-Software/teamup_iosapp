//
//  RecruitmentViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

class RecruitmentViewModel: ObservableObject, Identifiable {
    var id = UUID()

    /// 招募人数
    @Published var count = 1
    
    /// 招募角色
    @Published var role = RoleViewModel()
    
    /// 招募需求
    @Published var requirements = [String]()
    
    init() { }
    
    init(recruitment: Recruitment) {
        self.count = recruitment.count
        self.role = RoleViewModel(role: recruitment.role)
        self.requirements = recruitment.requirements
    }

    var recruitment: Recruitment {
        return Recruitment(role: role.role, count: count, requirements: requirements)
    }
}
