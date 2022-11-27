//
//  Validator.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/10/7.
//

import Foundation

class Validator {
    /// 验证字符串
    /// - Parameter str: 要验证的字符串
    /// - Parameter regEx: 正则表达式
    /// - Returns: 字符串是否有效
    class func validate(_ str: String, regEx: String) -> Bool {
        if #available(iOS 16.0, *) {
            do {
                let regex = try Regex(regEx)
                return try regex.wholeMatch(in: str) != nil
            } catch {
                return false
            }
        } else {
            return str.range(of: regEx, options: .regularExpression) != nil
        }
    }
    
    /// 验证手机号
    /// - Parameter phone: 手机号
    /// - Returns: 手机号是否有效
    class func validatePhone(phone: String) -> Bool {
        // swiftlint:disable:next line_length
        return validate(phone, regEx: #"1(3[0-9]{3}|5[01235-9][0-9]{2}|8[0-9]{3}|7([0-35-9][0-9]{2}|4(0[0-9]|1[0-2]|9[0-9]))|9[0-35-9][0-9]{2}|6[2567][0-9]{2}|4[579][0-9]{2})[0-9]{6}$"#)
    }
    
    /// 验证邮箱
    /// - Parameter email: 邮箱
    /// - Returns: 邮箱是否有效
    class func validateEmail(email: String) -> Bool {
        return validate(email, regEx: #"^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$"#)
    }
    
    /// 验证QQ号
    /// - Parameter qq: QQ号
    /// - Returns: QQ号是否有效
    class func validateQQ(qq: String) -> Bool {
        return validate(qq, regEx: #"^[1-9][0-9]{4,14}$"#)
    }
}

func nilOrEmpty(_ str: String?) -> Bool {
    return str == nil || str!.isEmpty
}

func nilOrZero(_ num: Int?) -> Bool {
    return num == nil || num! == 0
}
