import Foundation
import HandyJSON

/// 角色
struct Role: HandyJSON, Equatable, Hashable {
    var id: Int!

    /// 名称
    var name: String!

    /// 描述
    var description: String?

    /// 等级
    var level: Int?

    /// 父角色ID
    var pid: Int?

    /// 子角色
    var children: [Role]!
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Role, rhs: Role) -> Bool {
        return lhs.id == rhs.id
    }
}
