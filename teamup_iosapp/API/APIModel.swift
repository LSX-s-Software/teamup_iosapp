//
//  APIModel.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/5.
//

import Foundation
import HandyJSON

class APIModel<T>: HandyJSON {
    /// 状态码
    var code: String!
    /// 提示信息
    var msg: String!
    /// 数据
    var data: T?
    
    required init() {}
}

class PagedDataModel<T>: HandyJSON {
    var previous: String?
    var next: String?
    var count: Int!
    var results: [T]!
    
    required init() {}
}

class APIEmptyResponseModel: HandyJSON {
    /// 状态码
    var code: String?
    /// 提示信息
    var msg: String?
    
    required init() {}
}

typealias PagedAPIModel<T> = APIModel<PagedDataModel<T>>
