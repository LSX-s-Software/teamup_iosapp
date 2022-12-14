//
//  User.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/5.
//

import Foundation
import HandyJSON

/// 用户
struct User: HandyJSON, Codable {
    var id: Int!

    /// 用户名
    var username: String!

    /// 真名
    var realName: String!

    /// 学号
    var studentId: String?

    /// 学院
    var faculty: String?

    /// 年级
    var grade: String?

    /// 电话
    var phone: String!

    /// 头像
    var avatar: String?
    
    /// 是否在线
    var status: UserStatus!

    /// 上次在线时间
    var lastLogin: Date?
    
    /// 自我介绍
    var introduction: String?
    
    /// 获奖记录
    var awards: [String]?
    
    /// 团队数量
    var teamCount: Int?
}

enum UserStatus: String, HandyJSONEnum, Codable {
    case Offline
    case Online
}
