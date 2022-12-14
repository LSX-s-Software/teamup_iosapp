//
//  MessageViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import Foundation

class MessageViewModel: ObservableObject {
    var id: String = ""

    /// 消息类型
    var type: MessageType = .Chat

    /// 消息内容
    var content: String = ""

    /// 发送者ID
    var sender: Int = UserService.userId ?? 0

    init() { }

    init(message: Message) {
        id = message.id
        type = message.type
        content = message.content
        sender = message.sender
    }

    init(id: String, type: MessageType, content: String, sender: Int) {
        self.id = id
        self.type = type
        self.content = content
        self.sender = sender
    }
}
