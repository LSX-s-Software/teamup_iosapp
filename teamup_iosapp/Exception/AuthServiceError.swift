//
//  AuthServiceError.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/1.
//

import Foundation

enum AuthServiceError: Error {
    case AccessTokenInvalid
    case AccessTokenExpired
    case RefreshTokenInvalid
    case RefreshTokenExpired
    case NotLoggedIn
    
    case PhoneInvalid
    case PasswordInvalid
    case VerifyCodeInvalid
}

extension AuthServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .AccessTokenInvalid:
            return NSLocalizedString("AccessToken无效", comment: "")
        case .AccessTokenExpired:
            return NSLocalizedString("AccessToken已过期", comment: "")
        case .RefreshTokenInvalid:
            return NSLocalizedString("RefreshToken无效", comment: "")
        case .RefreshTokenExpired:
            return NSLocalizedString("RefreshToken已过期", comment: "")
        case .NotLoggedIn:
            return NSLocalizedString("用户未登录", comment: "")
        case .PhoneInvalid:
            return NSLocalizedString("手机号格式错误", comment: "")
        case .PasswordInvalid:
            return NSLocalizedString("密码不能为空", comment: "")
        case .VerifyCodeInvalid:
            return NSLocalizedString("验证码格式错误", comment: "")
        }
    }
}
