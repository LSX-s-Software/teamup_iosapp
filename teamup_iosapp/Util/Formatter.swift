//
//  Formatter.swift
//  zq_recruitment_iosapp
//
//  Created by 林思行 on 2022/9/7.
//

import Foundation

extension Formatter {
    
    /// 格式化日期
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 格式
    ///   - compact: 如果年份与今年相同的话去除年份，且隐藏秒
    /// - Returns: 格式化后的日期字符串
    static func formatDate(date: Date, format: String = "yyyy-MM-dd HH:mm:ss", compact: Bool = false) -> String {
        let df = DateFormatter()
        if compact {
            let calendar = Calendar.current
            let targetYear = calendar.dateComponents([.year], from: date).year
            let currentYear = calendar.dateComponents([.year], from: Date()).year
            if targetYear == currentYear {
                df.dateFormat = "MM-dd HH:mm"
            } else {
                df.dateFormat = format
            }
        } else {
            df.dateFormat = format
        }
        return df.string(from: date)
    }
    
    static func getDate(from: String?, withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        guard let from = from else { return nil }
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: from)
    }
    
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let iso8601withFracSec: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
