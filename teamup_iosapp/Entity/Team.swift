import Foundation
import HandyJSON

/// 队伍
struct Team: HandyJSON {
    var id: Int!

    /// 名称
    var name: String!

    /// 竞赛
    var competition: Competition?

    /// 队长
    var leader: User?

    /// 队伍描述
    var description: String?

    /// 点赞数
    var likeCount: Int!

    /// 队伍成员
    var members: [TeamMember]?

    /// 招募信息
    var recruitments: [Recruitment]?

    /// 标签
    var tags: [TeamTag]?

    /// 是否招募中
    var recruiting: Bool!
}
