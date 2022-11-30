//
//  UserServiceError.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/1.
//

import Foundation

enum UserServiceError: Error {
    case UserNotLoggedin
    case UsernameEmpty
    case RealNameEmpty
    case PhoneInvalid
    case StudentIdInvalid
    case FacultyEmpty
    case GradeInvalid
}

extension UserServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .UserNotLoggedin:
            return NSLocalizedString("用户未登录", comment: "")
        case .UsernameEmpty:
            return NSLocalizedString("用户名不能为空", comment: "")
        case .RealNameEmpty:
            return NSLocalizedString("真实姓名不能为空", comment: "")
        case .PhoneInvalid:
            return NSLocalizedString("手机号码格式不正确", comment: "")
        case .StudentIdInvalid:
            return NSLocalizedString("学号格式不正确", comment: "")
        case .FacultyEmpty:
            return NSLocalizedString("学院不能为空", comment: "")
        case .GradeInvalid:
            return NSLocalizedString("年级格式不正确", comment: "")
        }
    }
}
