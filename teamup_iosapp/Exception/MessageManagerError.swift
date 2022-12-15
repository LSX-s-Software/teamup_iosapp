//
//  MessageManagerError.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/15.
//

import Foundation

enum MessageManagerError: Error {
    case userNotLoggedIn
    case networkError(briefMessage: String, fullMessage: String?)
}

extension MessageManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "用户未登录"
        case .networkError(let briefMessage, let fullMessage):
            return fullMessage ?? briefMessage
        }
    }
}
