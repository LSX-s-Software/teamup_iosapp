//
//  RoleViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

class RoleViewModel: ObservableObject, Identifiable {
    @Published var id = 0
    
    /// 角色名称
    @Published var name = ""
    
    init() { }
    
    init(role: Role) {
        self.id = role.id
        self.name = role.name
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    var role: Role {
        return Role(id: id, name: name)
    }
}
