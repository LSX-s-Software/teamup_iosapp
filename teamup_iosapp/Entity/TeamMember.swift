import Foundation
import HandyJSON

/// 队伍成员
struct TeamMember: HandyJSON {
    var id: Int!

    /// 角色
    var roles: [Role]?

    /// 学院
    var faculty: String?

    /// 成员描述
    var description: String!
}
