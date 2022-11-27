//
//  APIRequest.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/5.
//

import Foundation
import Alamofire
import HandyJSON

class APIRequest {
    
    static let BASE_URL = "https://api.teamup.nagico.cn"
    
    private weak var delegate: APIRequestDelegate?
    
    private var method: HTTPMethod? // 请求类型
    private var url: String? // URL
    private var params: [String: Any]? // 参数
    private var httpRequest: Request?
    private var noAuth: Bool? = false
    private var file: Data?
    private var fileName: String?
    private var fileId: Int?
    
    /// headers设置
    private var headers: HTTPHeaders?
}

// MARK: - APIRequest属性的设置
extension APIRequest {
    /// 设置url
    func url(_ url: String?) -> Self {
        self.url = url
        return self
    }
    
    /// 设置requestType
    func method(_ type: HTTPMethod) -> Self {
        self.method = type
        return self
    }
    
    /// 设置参数
    func params(_ params: [String: Any]?) -> Self {
        self.params = params
        return self
    }
    
    /// 设置headers
    func headers(_ headers: HTTPHeaders?) -> Self {
        self.headers = headers
        return self
    }
    
    /// 不附带token
    func noAuth(_ noAuth: Bool = true) -> Self {
        self.noAuth = noAuth
        return self
    }
    
    /// 设置文件内容
    func file(_ fileData: Data) -> Self {
        self.file = fileData
        return self
    }
    
    /// 设置文件ID（下载时使用）
    func fileId(_ id: Int) -> Self {
        self.fileId = id
        return self
    }
    
    /// 设置文件名
    func fileName(_ name: String) -> Self {
        self.fileName = name
        return self
    }
    
    /// 设置上传/下载进度代理
    func delegate(_ delegate: APIRequestDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}

// MARK: - APIRequest请求相关
extension APIRequest {
    
    /// 发起普通请求
    func afRequest<T: HandyJSON>() async throws -> T {
        // headers处理
        var requestHeaders = HTTPHeaders()
        if let header = headers {
            requestHeaders = header
        }
        if noAuth == nil || !noAuth! {
            let token = await AuthService.getToken()
            if token != nil {
                requestHeaders.add(name: "Authorization", value: "Bearer " + token!)
            }
        }
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
        // 发起网络请求
        return try await withUnsafeThrowingContinuation { continuation in
            httpRequest = AF.request(Self.BASE_URL + url!,
                                     method: method ?? .get,
                                     parameters: params,
                                     encoding: method == .post || method == .patch ? JSONEncoding.default : URLEncoding.default,
                                     headers: requestHeaders)
                .responseString { response in
                    if let err = response.error {
                        print("请求出错：", response, err.localizedDescription)
                        continuation.resume(throwing: err)
                        return
                    }
                    let statusCode = response.response!.statusCode
                    if statusCode >= 500 {
                        continuation.resume(throwing: APIRequestError.ServerError)
                        return
                    } else if statusCode >= 400 {
                        print("请求状态码异常：", response)
                    } else if statusCode == 204 {
                        continuation.resume(returning: T())
                        return
                    }
                    if let data = response.data {
                        if let model = T.deserialize(from: String(data: data, encoding: .utf8)) {
                            continuation.resume(returning: model)
                        } else {
                            continuation.resume(throwing: APIRequestError.DeserializationFailed)
                        }
                        return
                    }
                    fatalError()
                }
        }
    }
    
    /// 发起文件上传请求
    func afUpload<T: HandyJSON>(formFileName: String = "file") async throws -> T {
        // headers处理
        var requestHeaders = HTTPHeaders()
        if let header = headers {
            requestHeaders = header
        }
        if (noAuth == nil || !noAuth!) {
            let token = await AuthService.getToken()
            if (token != nil) {
                requestHeaders.add(name: "Authorization", value: "Bearer " + token!)
            }
        }
        return try await withUnsafeThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multiPart in
                var mimeType: String?
                if formFileName == "file", let fileName = self.fileName {
                    multiPart.append(fileName.data(using: .utf8)!, withName: "name")
                    mimeType = fileName.suffix(4) == ".pdf" ? "application/pdf" : nil
                }
                multiPart.append(self.file!, withName: formFileName, fileName: self.fileName, mimeType: mimeType)
                // 处理参数列表
                if let params = self.params {
                    self.processParamToMultipartData(params: params, multiPart: multiPart)
                }
            }, to: Self.BASE_URL + url!, method: method ?? .post, headers: requestHeaders)
            .uploadProgress(queue: .main, closure: { progress in
                self.delegate?.didUpdateProgress(progress: progress.fractionCompleted)
                if progress.isFinished {
                    self.delegate?.didFinishUploading()
                }
            })
            .responseString { response in
                if let err = response.error {
                    continuation.resume(throwing: err)
                    return
                }
                let statusCode = response.response!.statusCode
                if statusCode >= 500 {
                    continuation.resume(throwing: APIRequestError.ServerError)
                    return
                } else if statusCode >= 400 {
                    print("请求状态码异常：", response)
                }
                if let data = response.data {
                    if let model = T.deserialize(from: String(data: data, encoding: .utf8)) {
                        continuation.resume(returning: model)
                    } else {
                        continuation.resume(throwing: APIRequestError.DeserializationFailed)
                    }
                    return
                }
                fatalError()
            }
        }
    }
    
    /// 发起下载请求
    func download() async throws -> URL {
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = UserService.userFileDirectory!
                .appendingPathComponent("\(self.fileId!)")
                .appendingPathComponent(self.fileName!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return try await withUnsafeThrowingContinuation { continuation in
            AF.download(url!, to: destination)
                .downloadProgress(queue: .main, closure: { progress in
                    self.delegate?.didUpdateProgress(progress: progress.fractionCompleted)
                    if progress.isFinished {
                        self.delegate?.didFinishDownloading()
                    }
                })
                .response { response in
                    if let err = response.error {
                        continuation.resume(throwing: err)
                        return
                    }
                    if let url = response.fileURL {
                        continuation.resume(returning: url)
                        return
                    }
                    continuation.resume(throwing: APIRequestError.NetworkError)
                }
        }
    }
    
    /// 检查响应
    func checkResponse(code: String, msg: String) throws {
        if code == "00000" {
            return
        } else if code == "A0221" {
            AuthService.accessToken = nil
            throw APIRequestError.TokenInvalid
        } else {
            throw APIRequestError.RequestError(code: code, msg: msg)
        }
    }
    
    /// 请求
    func request<T>() async throws -> T {
        let response: APIModel<T> = try await afRequest()
        try checkResponse(code: response.code, msg: response.msg)
        return response.data!
    }
    
    /// 发送不处理响应的请求
    func requestIgnoringResponse() async throws {
        let response: APIEmptyResponseModel = try await afRequest()
        if let code = response.code, code != "00000" {
            throw APIRequestError.RequestError(code: code, msg: response.msg ?? "未知错误")
        }
        return
    }
    
    /// 上传
    func upload<T>(formFileName: String = "file") async throws -> T {
        let response: APIModel<T> = try await afUpload(formFileName: formFileName)
        try checkResponse(code: response.code, msg: response.msg)
        return response.data!
    }
    
    /// 发送DELETE请求
    func delete() async throws {
        method = .delete
        try await requestIgnoringResponse()
    }
    
    /// 发送分页请求
    func pagedRequest<T>(page: Int, pageSize: Int = 10) async throws -> (data: [T], hasNext: Bool) {
        if self.params != nil {
            self.params!["page"] = page
            self.params!["page_size"] = pageSize
        } else {
            self.params = ["page": page, "page_size": pageSize]
        }
        let response: PagedAPIModel<T> = try await afRequest()
        try checkResponse(code: response.code, msg: response.msg)
        return (data: response.data!.results, hasNext: response.data!.next != nil)
    }
    
    /// 取消请求
    func cancel() {
        httpRequest?.cancel()
    }
    
    func processParamToMultipartData(params: [String: Any], multiPart: MultipartFormData) {
        for (key, value) in params {
            if let temp = value as? String {
                multiPart.append(temp.data(using: .utf8)!, withName: key)
            }
            if let temp = value as? Int {
                multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
            }
            if let temp = value as? NSArray {
                temp.forEach({ element in
                    let keyObj = key + "[]"
                    if let string = element as? String {
                        multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                    } else
                    if let num = element as? Int {
                        let value = "\(num)"
                        multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                    }
                })
            }
        }
    }
}
