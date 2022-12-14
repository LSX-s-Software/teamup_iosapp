//
//  MessageViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import Foundation

class MessageViewModel: ObservableObject, Identifiable {
    var id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()

    /// 消息类型
    var type: MessageType

    /// 消息内容
    @Published var content: String

    /// 发送者ID
    var receiver: Int
    
    var createTime: Date

    var jsonString: String {
        """
        {
            "id": "\(id)",
            "type": "\(type.rawValue)",
            "content": "\(content)",
            "receiver": \(receiver)
        }
        """
    }
    
    var message: Message {
        Message(id: id, type: type, content: content, sender: UserService.userId, receiver: receiver, createTime: createTime)
    }

    init(type: MessageType = .Chat, content: String, receiver: Int) {
        self.type = type
        self.content = content
        self.receiver = receiver
        self.createTime = Date.now
    }
    
    func reset() {
        id = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        content = ""
    }
}
