import Foundation
import HandyJSON

/// 招募
struct Recruitment: HandyJSON {
    var id: Int!

    /// 角色
    var role: Role!

    /// 需求
    var requirements: [Requirement]!
}
