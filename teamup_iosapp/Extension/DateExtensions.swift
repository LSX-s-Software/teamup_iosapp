//
//  DateExtensions.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/11.
//

import Foundation
import HandyJSON

extension Date {
    
    /// 日期间隔
    public struct DateInterval {
        var year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?
        
        init(year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
            self.year = year
            self.month = month
            self.day = day
            self.hour = hour
            self.minute = minute
            self.second = second
        }
    }
    
    /// 计算日期差
    /// - Parameters:
    ///   - recent: 日期1
    ///   - previous: 日期2
    /// - Returns: 日期1-日期2
    static func - (recent: Date, previous: Date) -> DateInterval {
        let year = Calendar.current.dateComponents([.year], from: previous, to: recent).year
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return DateInterval(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }

}

extension Date: HandyJSONCustomTransformable {

    public static func _transform(from object: Any) -> Date? {
        if let dateStr = object as? String {
            return Formatter.iso8601.date(from: dateStr) ?? Formatter.iso8601withFracSec.date(from: dateStr)
        } else if let timestamp = object as? Int {
            return Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        } else {
            return nil
        }
    }
    
    public func _plainValue() -> Any? {
        return self.ISO8601Format()
    }

}
