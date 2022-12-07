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
                             lastLogin: Date.now,
                             introduction: """
积极参加课外文体活动，各种社会实践活动和兼职工作等，以增加自己的阅历，提高自己的能力。在工作中体会办事方式，锻炼口才和人际交往能力。曾连续两午获得学院暑期社会实践积极分子荣誉称号。在平时学校生活中 ，做过很多兼职。例如：家教、电话访问员、派传单、问卷调查，还到工厂打过暑期工，亲身体会了各种工作的不同运作程序和处事方法 ，锻炼成了吃苦耐劳的精神，并从工作中体会到乐趣，尽心尽力。大学生涯，让我的组织协调能力、管理能力、应变能力等大大提升 ，使我具备良好的心理素质，让我在竞争中拥有更大的优势，让我在人生事业中走得更高更远。获得了优秀大学生的称号。
""",
                             awards: ["中国国际互联网+创新创业大赛国金", "挑战杯国金", "中国高校计算机大赛（微信小程序开发赛）全国三等奖"],
                             teamCount: 10)
    
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
    
    static let recruitment1 = Recruitment(id: 1, role: Role(id: 1, name: "前端"), requirements: ["有项目经历", "吃苦耐闹"])
    
    static let recruitment2 = Recruitment(id: 2, role: Role(id: 3, name: "后端"), requirements: ["有项目经历", "吃苦耐闹"])
    
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
