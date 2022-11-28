//
//  TokenService.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/5.
//

import Foundation
import JWTDecode
import HandyJSON

class AuthService {
    static var accessToken: String? {
        didSet {
            if accessToken != oldValue {
                if accessToken != nil {
                    UserDefaults.standard.set(accessToken!, forKey: "accessToken")
                } else {
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                }
            }
        }
    }
    
    static var refreshToken: String? {
        didSet {
            if refreshToken != oldValue {
                if refreshToken != nil {
                    UserDefaults.standard.set(refreshToken!, forKey: "refreshToken")
                } else {
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                }
            }
        }
    }
    
    static var registered = UserDefaults.standard.bool(forKey: "registered") {
        didSet {
            if registered != oldValue {
                UserDefaults.standard.set(registered, forKey: "registered")
            }
        }
    }

    struct TokenResponse: HandyJSON {
        var id: Int!
        var access: String!
        var refresh: String?
    }
    
    class func register(phone: String, verifyCode: String, password: String) async throws {
        if !Validator.validatePhone(phone: phone) {
            throw AuthServiceError.PhoneInvalid
        }
        if verifyCode.count != 6 {
            throw AuthServiceError.VerifyCodeInvalid
        }
        if password.isEmpty {
            throw AuthServiceError.PasswordInvalid
        }
        let data: TokenResponse = try await APIRequest()
            .url("/users/")
            .method(.post)
            .params(["phone": phone, "verifyCode": verifyCode, "password": password])
            .noAuth()
            .request()
        if data.id != nil {
            UserService.userId = data.id
            registered = true
        }
        if data.access != nil {
            accessToken = data.access!
        }
        if data.refresh != nil {
            refreshToken = data.refresh!
        }
    }

    class func login(phone: String, password: String) async throws {
        if !Validator.validatePhone(phone: phone) {
            throw AuthServiceError.PhoneInvalid
        }
        if password.isEmpty {
            throw AuthServiceError.PasswordInvalid
        }
        let data: TokenResponse = try await APIRequest()
            .url("/auth/login/")
            .method(.post)
            .params(["phone": phone, "password": password])
            .noAuth()
            .request()
        if data.id != nil {
            UserService.userId = data.id
            registered = true
        }
        if data.access != nil {
            accessToken = data.access!
        }
        if data.refresh != nil {
            refreshToken = data.refresh!
        }
    }

    class func refresh() async throws {
        if refreshToken == nil {
            let storedRefreshToken = UserDefaults.standard.string(forKey: "refreshToken")
            if storedRefreshToken == nil {
                throw AuthServiceError.RefreshTokenInvalid
            } else {
                if let jwt = try? decode(jwt: storedRefreshToken!), !jwt.expired {
                    refreshToken = storedRefreshToken
                } else {
                    throw AuthServiceError.RefreshTokenExpired
                }
            }
        }
        do {
            let data: TokenResponse = try await APIRequest()
                .url("/auth/refresh/")
                .method(.post)
                .params(["refresh": refreshToken!])
                .noAuth()
                .request()
            if data.access != nil {
                accessToken = data.access!
            } else {
                refreshToken = nil
                throw AuthServiceError.RefreshTokenInvalid
            }
        } catch APIRequestError.TokenInvalid {
            refreshToken = nil
            throw AuthServiceError.RefreshTokenInvalid
        }
    }

    class func getToken() async -> String? {
        if accessToken == nil {
            let storedAccessToken = UserDefaults.standard.string(forKey: "accessToken")
            if let storedAccessToken = storedAccessToken,
               storedAccessToken != "",
               let jwt = try? decode(jwt: storedAccessToken),
               !jwt.expired {
                accessToken = storedAccessToken
            } else {
                print("AccessToken过期")
                do {
                    try await refresh()
                } catch AuthServiceError.RefreshTokenExpired, AuthServiceError.RefreshTokenInvalid {
                    print("RefreshToken过期")
//                    do {
//                        try await login()
//                    } catch {
//                        print("登录失败:\(error.localizedDescription)")
                        return nil
//                    }
                } catch {
                    print("刷新失败:\(error.localizedDescription)")
                    return nil
                }
            }
        }
        return accessToken
    }
    
    class func getVerifyCode(phone: String) async throws {
        if !Validator.validatePhone(phone: phone) {
            throw AuthServiceError.PhoneInvalid
        }
        try await APIRequest().url("/sms/verifyCodes/").params(["phone": phone]).noAuth().requestIgnoringResponse()
    }
    
    class func clearToken() {
        accessToken = nil
        refreshToken = nil
        registered = false
    }
}

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
