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

    /// 已激活
    var active: Bool?

    /// 上次在线时间
    var lastLogin: Date?
    
    /// 自我介绍
    var introduction: String?
}

/// 用户
class UserViewModel: ObservableObject {
    /// 用户名
    @Published var username: String
    /// 真名
    @Published var realName: String
    /// 学号
    @Published var studentId: String
    /// 学院
    @Published var faculty: String
    /// 年级
    @Published var grade: String
    /// 电话
    @Published var phone: String
    /// 头像
    @Published var avatar: String

    var jsonDict: [String: Any] {
        [
            "username": username,
            "realName": realName,
            "studentId": studentId,
            "faculty": faculty,
            "grade": grade,
            "phone": phone,
            "avatar": avatar
        ]
    }

    init?() {
        if let userInfo = UserService.userInfo {
            username = userInfo.username
            realName = userInfo.realName
            studentId = userInfo.studentId ?? ""
            faculty = userInfo.faculty ?? ""
            grade = userInfo.grade ?? ""
            phone = userInfo.phone
            avatar = userInfo.avatar ?? ""
        } else {
            return nil
        }
    }

    init(username: String, realName: String, studentId: String, faculty: String, grade: String, phone: String, avatar: String) {
        self.username = username
        self.realName = realName
        self.studentId = studentId
        self.faculty = faculty
        self.grade = grade
        self.phone = phone
        self.avatar = avatar
    }

    func update(using: User) {
        username = using.username
        realName = using.realName
        studentId = using.studentId ?? ""
        faculty = using.faculty ?? ""
        grade = using.grade ?? ""
        phone = using.phone
        avatar = using.avatar ?? ""
    }

    func reset() {
        if let userInfo = UserService.userInfo {
            update(using: userInfo)
        }
    }
}
