//
//  PreviewData.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/7.
//

import Foundation

class PreviewData {
    static let leader = User(id: 1,
                             username: "user1",
                             realName: "张三",
                             faculty: "计算机学院",
                             grade: "2020",
                             avatar: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/avatar/default.jpg",
                             introduction: nil)
    
    static let competition = Competition(id: 14,
                                         name: "测试",
                                         description: "123123",
                                         verified: true,
                                         logo: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/avatar/default.jpg",
                                         startTime: Date.now,
                                         endTime: Date.now,
                                         finish: false)
    
    static let teamMember1 = TeamMember(id: 1,
                                        roles: [Role(id: 2, name: "传媒")],
                                        faculty: "新闻传播学院",
                                        description: "string")
    
    static let teamMember2 = TeamMember(id: 2,
                                        roles: [Role(id: 1, name: "前端"), Role(id: 3, name: "后端")],
                                        faculty: "计算机学院",
                                        description: "123123")
    
    static let recruitment1 = Recruitment(id: 1,
                                          role: Role(id: 1, name: "前端"),
                                          requirements: [Requirement(content: "有项目经历"), Requirement(content: "吃苦耐闹")])
    
    static let recruitment2 = Recruitment(id: 2,
                                          role: Role(id: 3, name: "后端"),
                                          requirements: [Requirement(content: "有项目经历"), Requirement(content: "吃苦耐闹")])
    
    static let team = Team(id: 113,
                           name: "互联网+队伍招队友",
                           competition: competition,
                           leader: leader,
                           description: "Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae rem quibusdam nihil…",
                           likeCount: 0,
                           members: [teamMember1, teamMember2],
                           recruitments: [recruitment1, recruitment2],
                           recruiting: true)
}
