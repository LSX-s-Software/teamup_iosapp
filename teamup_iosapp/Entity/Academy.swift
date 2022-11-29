//
//  Academy.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/5.
//

import Foundation
import HandyJSON

struct Academy: Codable, Hashable, Equatable {
    var id: Int
    /// 名称
    var name: String
    /// 下属学院
    var children: [Academy]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Academy, rhs: Academy) -> Bool {
        return lhs.name == rhs.name
    }
}
