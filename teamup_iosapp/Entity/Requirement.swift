import Foundation
import HandyJSON

/// 需求
struct Requirement: HandyJSON {
    var id: Int!

    /// 所属招募
    var recruitment: Recruitment!

    /// 需求内容
    var content: String!

}
