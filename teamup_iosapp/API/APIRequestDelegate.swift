//
//  APIRequestDelegate.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/20.
//

import Foundation

protocol APIRequestDelegate: AnyObject {
    /// 更新上传/下载进度
    /// - Parameter progress: 进度（0.0-1.0）
    func didUpdateProgress(progress: Double)
    func didFinishUploading()
    func didFinishDownloading()
}

extension APIRequestDelegate {
    func didFinishUploading() {}
    func didFinishDownloading() {}
}
