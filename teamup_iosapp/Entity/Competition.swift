import Foundation
import HandyJSON

/// 比赛
struct Competition: HandyJSON {
    var id: Int!

    /// 名称
    var name: String!

    /// 描述
    var description: String!

    /// 是否通过审核
    var verified: Bool!

    /// logo
    var logo: String!

    /// 开始时间
    var startTime: Date?

    /// 结束时间
    var endTime: Date?

    /// 是否结束
    var finish: Bool!

    /// 比赛评分
    var score: Int?

    /// 队伍数量
    var teamCount: Int!
}
