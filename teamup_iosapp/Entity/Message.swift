import Foundation
import HandyJSON

struct Message: HandyJSON {
    var id: String!

    /// 消息类型
    var type: MessageType!

    /// 消息内容
    var content: String!

    /// 发送者ID
    var sender: Int!

    /// 时间
    var createTime: Date!
}

enum MessageType: String, HandyJSONEnum {
    /// 系统消息
    case System
    /// 普通文字消息
    case Chat
    /// 已读回执
    case Ack
    /// 正在输入
    case Typing
    /// 输入结束
    case UnTyping
}
