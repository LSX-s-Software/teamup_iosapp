//
//  MessageListItem.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import Foundation

struct MessageListItem: Codable {
    var id: UInt
    
    /// 用户ID
    var userId: Int
    
    /// 用户名
    var username: String
    
    /// 用户头像
    var userAvatar: String
    
    /// 最新的消息
    var latestMessage: Message
}
