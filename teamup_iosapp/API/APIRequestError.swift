//
//  APIRequestError.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/18.
//

import Foundation

enum APIRequestError: Error {
    case DeserializationFailed
    case ServerError
    case NetworkError
    case TokenInvalid
    case RequestError(code: String, msg: String)
}

extension APIRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .DeserializationFailed:
            return NSLocalizedString("用户未登录", comment: "")
        case .ServerError:
            return NSLocalizedString("服务器内部错误", comment: "")
        case .NetworkError:
            return NSLocalizedString("网络错误", comment: "")
        case .TokenInvalid:
            return NSLocalizedString("登录已过期", comment: "")
        case .RequestError(code: _, msg: let msg):
            return msg
        }
    }
}
