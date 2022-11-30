//
//  UserService.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/14.
//

import Foundation
import HandyJSON

class UserService {
    private static var _userId: Int?
    static var userId: Int? {
        get {
            if _userId != nil {
                return _userId
            }
            _userId = UserDefaults.standard.integer(forKey: "userId")
            return _userId
        }
        set {
            _userId = newValue
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "userId")
            } else {
                UserDefaults.standard.removeObject(forKey: "userId")
            }
        }
    }
    
    private static var _userInfo: User?
    static var userInfo: User? {
        get {
            if _userInfo != nil {
                return _userInfo
            }
            if let data = UserDefaults.standard.object(forKey: "userInfo") as? Data {
                let info = try? JSONDecoder().decode(User.self, from: data)
                _userInfo = info
                return info
            }
            return nil
        }
        set {
            _userInfo = newValue
            if newValue != nil {
                if let encoded = try? JSONEncoder().encode(newValue!) {
                    UserDefaults.standard.set(encoded, forKey: "userInfo")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "userInfo")
            }
        }
    }
    
    static var userFileDirectory: URL? {
        if !AuthService.registered || userId == nil {
            return nil
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileDirURL = documentsURL.appendingPathComponent("UserFiles")
        let userFileDir = fileDirURL.appendingPathComponent("user_\(userId!)")
        if !FileManager.default.fileExists(atPath: userFileDir.path) {
            if ((try? FileManager.default.createDirectory(at: userFileDir, withIntermediateDirectories: true)) != nil) {
                return userFileDir
            }
        }
        return nil
    }
    
    /// 从服务器获取用户信息
    /// - Returns: 用户信息
    class func getUserInfoFromServer() async throws -> User {
        if !AuthService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        userInfo = try await APIRequest().url("/users/").request()
        return userInfo!
    }
    
    /// 修改用户信息
    /// - Parameter newInfo: 新用户信息
    class func editUserInfo(newInfo: UserViewModel) async throws {
        if !AuthService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        // 验证信息
        if newInfo.username.isEmpty {
            throw UserServiceError.UsernameEmpty
        }
        if newInfo.realName.isEmpty {
            throw UserServiceError.RealNameEmpty
        }
        if !Validator.validatePhone(phone: newInfo.phone) {
            throw UserServiceError.PhoneInvalid
        }
        if newInfo.studentId.count != 13 {
            throw UserServiceError.StudentIdInvalid
        }
        if newInfo.faculty.isEmpty {
            throw UserServiceError.FacultyEmpty
        }
        if newInfo.grade.count != 4 {
            throw UserServiceError.GradeInvalid
        }
        // 发送请求
        userInfo = try await APIRequest().url("/users/").method(.put).params(newInfo.jsonDict).request()
        NotificationCenter.default.post(name: NSNotification.UserInfoUpdated, object: nil)
    }
    
    class func uploadAvatar(data: Data) async throws {
        if !AuthService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        let newUserInfo: User = try await APIRequest()
            .url("/users/students/\(userId!)/")
            .file(data)
            .fileName("avatar.jpg")
            .method(.patch)
            .upload(formFileName: "avatar")
        userInfo?.avatar = newUserInfo.avatar
    }
    
    /*
    /// 删除文件
    /// - Parameter id: 文件ID
    class func deleteFile(id: Int) async throws {
        if !TokenService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        try await APIRequest().url("/users/students/\(userId!)/files/\(id)/").delete()
        // 删除本地文件
        let fileDir = userFileDirectory!.appendingPathComponent("\(id)")
        try? FileManager.default.removeItem(at: fileDir)
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - file: 文件数据
    ///   - filename: 文件名
    ///   - type: 文件类型（简历/作品）
    ///   - delegate: 上传进度代理
    /// - Returns: 文件对象
    class func uploadFile(file: Data,
                           filename: String,
                           type: UserFileType,
                           delegate: APIRequestDelegate? = nil) async throws -> UserFile {
        if !TokenService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        return try await APIRequest()
            .url("/users/students/\(userId!)/files/\(type.rawValue)s/")
            .file(file)
            .fileName(filename)
            .delegate(delegate)
            .upload()
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - file: 文件数据
    ///   - filename: 文件名
    ///   - type: 文件类型（简历/作品）
    ///   - callback: 上传进度回调
    /// - Returns: 文件对象
    class func uploadFile(file: Data,
                           filename: String,
                           type: UserFileType,
                           callback: @escaping (Double) -> Void) async throws -> UserFile {
        return try await uploadFile(file: file, filename: filename, type: type, delegate: NetworkProgressHandler(callback: callback))
    }
    
    /// 重命名文件
    /// - Parameters:
    ///   - id: 文件ID
    ///   - filename: 文件名
    /// - Returns: 文件对象
    class func renameFile(file old: UserFile, newName: String) async throws -> UserFile {
        if !TokenService.registered || userId == nil {
            throw UserServiceError.UserNotLoggedin
        }
        let newFile: UserFile = try await APIRequest()
            .url("/users/students/\(userId!)/files/\(old.id!)/")
            .method(.patch)
            .params(["name": newName])
            .request()
        if fileExist(file: old) {
            // 本地文件改名
            try? FileManager.default.moveItem(at: localFileURL(of: old)!, to: localFileURL(of: newFile)!)
        }
        return newFile
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - file: 文件对象
    ///   - delegate: 下载进度代理
    /// - Returns: 文件URL
    class func downloadFile(file: UserFile, delegate: APIRequestDelegate? = nil) async throws -> URL {
        return try await APIRequest()
            .url(file.file)
            .fileName("\(file.name!).\(file.ext!)")
            .fileId(file.id)
            .delegate(delegate)
            .download()
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - file: 文件对象
    ///   - callback: 下载进度回调
    /// - Returns: 文件URL
    class func downloadFile(file: UserFile, callback: @escaping (Double) -> Void) async throws -> URL {
        return try await downloadFile(file: file, delegate: NetworkProgressHandler(callback: callback))
    }
    
    class func localFileURL(of file: UserFile) -> URL? {
        if !TokenService.registered || userId == nil {
            return nil
        }
        return userFileDirectory!
            .appendingPathComponent("\(file.id!)")
            .appendingPathComponent("\(file.name!).\(file.ext!)")
    }
    
    /// 检查用户文件是否存在
    /// - Parameter file: 文件对象
    /// - Returns: 是否存在（未登录返回false）
    class func fileExist(file: UserFile) -> Bool {
        if file.id == nil {
            return false
        }
        if let url = localFileURL(of: file) {
            return FileManager.default.fileExists(atPath: url.path)
        }
        return false
    }
     */
    
    /// 退出登录
    class func logout() {
        if FileManager.default.fileExists(atPath: userFileDirectory!.path) {
            try? FileManager.default.removeItem(at: userFileDirectory!)
        }
        userId = nil
        userInfo = nil
        AuthService.clearToken()
        NotificationCenter.default.post(name: NSNotification.UserLogout, object: nil)
    }
}

class NetworkProgressHandler: APIRequestDelegate {
    private var callback: (Double) -> Void
    
    init(callback: @escaping (Double) -> Void) {
        self.callback = callback
    }
    
    func didUpdateProgress(progress: Double) {
        callback(progress)
    }
}

extension NSNotification {
    static let UserLogout = Notification.Name("UserLogout")
    static let UserInfoUpdated = Notification.Name("UserInfoUpdated")
}
