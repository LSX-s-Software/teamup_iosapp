import Foundation
import HandyJSON

/// 角色
struct Role: HandyJSON {
    var id: Int!

    /// 名称
    var name: String!

    /// 描述
    var description: String?

    /// 等级
    var level: Int?

    /// 父角色ID
    var pid: Int?
}
