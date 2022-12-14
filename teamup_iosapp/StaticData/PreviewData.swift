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
                             status: .Online,
                             lastLogin: Date.now,
                             introduction: """
积极参加课外文体活动，各种社会实践活动和兼职工作等，以增加自己的阅历，提高自己的能力。在工作中体会办事方式，锻炼口才和人际交往能力。曾连续两午获得学院暑期社会实践积极分子荣誉称号。
在平时学校生活中 ，做过很多兼职。例如：家教、电话访问员、派传单、问卷调查，还到工厂打过暑期工，亲身体会了各种工作的不同运作程序和处事方法，锻炼成了吃苦耐劳的精神，并从工作中体会到乐趣，尽心尽力。
大学生涯，让我的组织协调能力、管理能力、应变能力等大大提升，使我具备良好的心理素质，让我在竞争中拥有更大的优势，让我在人生事业中走得更高更远。获得了优秀大学生的称号。
""",
                             awards: ["中国国际互联网+创新创业大赛国金", "挑战杯国金", "中国高校计算机大赛（微信小程序开发赛）全国三等奖"],
                             teamCount: 10)
    
    static let competition = Competition(id: 14,
                                         name: "中国“互联网+”大学生创新创业大赛",
                                         abbreviation: "互联网+",
                                         description: """
中国“互联网+”大学生创新创业大赛，由教育部与政府、各高校共同主办的一项技能大赛。大赛旨在深化高等教育综合改革，激发大学生的创造力，培养造就“大众创业、万众创新”的主力军；
推动赛事成果转化，促进“互联网+”新业态形成，服务经济提质增效升级；以创新引领创业、创业带动就业，推动高校毕业生更高质量创业就业。
""",
                                         verified: true,
                                         logo: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/competition/hulianwang.png",
                                         startTime: Date.now,
                                         endTime: Date.now,
                                         finish: false,
                                         teamCount: 230)
    
    static let teamMember1 = TeamMember(id: 1,
                                        roles: [Role(id: 2, name: "传媒")],
                                        faculty: "新闻传播学院",
                                        description: "string")
    
    static let teamMember2 = TeamMember(id: 2,
                                        roles: [Role(id: 1, name: "前端"), Role(id: 3, name: "后端")],
                                        faculty: "计算机学院",
                                        description: "123123")
    
    static let recruitment1 = Recruitment(id: 1, role: Role(id: 1, name: "前端"), count: 2, requirements: ["有项目经历", "吃苦耐闹"])
    
    static let recruitment2 = Recruitment(id: 2, role: Role(id: 3, name: "后端"), count: 4, requirements: ["有项目经历", "吃苦耐闹"])
    
    static let team = Team(id: 113,
                           name: "互联网+队伍招队友",
                           competition: competition,
                           leader: leader,
                           description: "Lorem, ipsum dolor sit amet consectetur adipisicing elit. Vitae rem quibusdam nihil…",
                           likeCount: 0,
                           members: [teamMember1, teamMember2],
                           recruitments: [recruitment1, recruitment2],
                           recruiting: true,
                           favorite: false,
                           interested: false,
                           uninterested: false)
    
    static let teamCountHistory = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 175, 200, 220, 230]

    static let message1 = Message(id: "123", type: .Chat, content: "你好", sender: 13, createTime: Date.now)
    static let message2 = Message(id: "124", type: .System, content: "简历", sender: 0, createTime: Date.now)
    static let message3 = Message(id: "125", type: .Chat, content: "这是我的简历", sender: 13, createTime: Date.now, read: true)
    static let message4 = Message(id: "125",
                                  type: .Chat,
                                  content: "这是我的简历我的简历我的简历我的简历我的简历我的简历我的简历我的简历我的简历",
                                  sender: 13,
                                  createTime: Date.now,
                                  read: true)

    static let userMessageList = [MessageListItem(id: 1,
                                                  userId: 11,
                                                  username: "VIP USER3",
                                                  userAvatar: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/avatar/202212081814072796.png",
                                                  latestMessage: message1),
                                  MessageListItem(id: 2,
                                                  userId: 12,
                                                  username: "VIP USER4",
                                                  userAvatar: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/avatar/202212081814072796.png",
                                                  latestMessage: message2),
                                  MessageListItem(id: 3,
                                                  userId: 13,
                                                  username: "VIP USER5",
                                                  userAvatar: "https://zq-teamup.oss-cn-hangzhou.aliyuncs.com/media/avatar/202212081814072796.png",
                                                  latestMessage: message3)]
}
