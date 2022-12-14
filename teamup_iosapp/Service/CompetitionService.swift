//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class CompetitionService {
    /// 获取比赛列表
    /// - Returns: 比赛列表
    class func getCompetitionList() async throws -> [Competition] {
        return try await APIRequest().url("/competitions").request()
    }
    
    /// 获取比赛详情
    /// - Parameter id: 比赛ID
    /// - Returns: 比赛详情
    class func getCompetition(id: Int) async throws -> Competition {
        do {
            return try await APIRequest().url("/competitions/\(id)").request()
        } catch APIRequestError.RequestError(let code, let msg) {
            if code == "A0514" {
                throw CompetitionServiceError.CompetitionNotFound
            } else {
                throw APIRequestError.RequestError(code: code, msg: msg)
            }
        }
    }
    
    /// 获取用户订阅比赛列表
    /// - Returns: 比赛列表
    class func getSubsribeCompetitionList() async throws -> [Competition] {
        return try await APIRequest().url("/users/subscriptions/competitions/").request()
    }
    
    /// 用户订阅比赛
    /// - Parameter id: 比赛ID
    /// - Returns: 订阅结果
    class func subscribeCompetition(id: Int) async throws {
        do {
            try await APIRequest().url("/users/subscriptions/competitions/\(id)").method(.post).requestIgnoringResponse()
        } catch APIRequestError.RequestError(let code, let msg) {
            if code == "A0514" {
                throw CompetitionServiceError.CompetitionNotFound
            } else {
                throw APIRequestError.RequestError(code: code, msg: msg)
            }
        }
    }
    /// 用户取消订阅比赛
    /// - Parameter id: 比赛ID
    /// - Returns: 订阅结果
    class func unsubscribeCompetition(id: Int) async throws {
        do {
            try await APIRequest().url("/users/subscriptions/competitions/\(id)").delete()
        } catch APIRequestError.RequestError(let code, let msg) {
            if code == "A0514" {
                throw CompetitionServiceError.CompetitionNotFound
            } else {
                throw APIRequestError.RequestError(code: code, msg: msg)
            }
        }
    }
    
    /// 获取比赛队伍数量历史
    /// - Parameter id: 比赛ID
    /// - Parameter scale: 时间跨度
    /// - Returns: 比赛队伍数量历史
    class func getCompetitionTeamHistory(
        id: Int,
        scale: CompetitionTeamHistory.Scale
    ) async throws -> (history: [CompetitionTeamHistory], delta: Int) {
        do {
            var history: [CompetitionTeamHistory] = try await APIRequest().url("/competitions/\(id)/count/").request()
            // 筛选
            var startDate: Date
            var dateStride: Int
            var result = [CompetitionTeamHistory](repeating: CompetitionTeamHistory(),
                                                  count: scale == .month || scale == .quarter ? 30 : 12)
            switch scale {
            case .month:
                startDate = Date(timeIntervalSinceNow: -30 * 86400)
                dateStride = 1
            case .quarter:
                startDate = Date(timeIntervalSinceNow: -90 * 86400)
                dateStride = 3
            case .halfYear:
                startDate = Date(timeIntervalSinceNow: -180 * 86400)
                dateStride = 15
            case .year:
                startDate = Date(timeIntervalSinceNow: -360 * 86400)
                dateStride = 30
            }
            // 累加
            var delta = 0
            if history.count > 1 {
                if (Date.now - Formatter.getDate(from: history.last!.date, withFormat: "yyyy-MM-dd")!).day == 0 {
                    delta = history.last!.count
                }
                for i in 1..<history.count {
                    history[i].count += history[i - 1].count
                }
            }
            // 取样
            var lastIndex = 0
            var nextDate = Calendar.current.date(byAdding: .day, value: dateStride, to: startDate)!
            result[0].count = 0
            for i in 0..<result.count {
                result[i].date = Formatter.formatDate(date: nextDate, format: scale == .year ? "M" : "M-d")
                while lastIndex < history.count
                        && Formatter.getDate(from: history[lastIndex].date, withFormat: "yyyy-MM-dd")! <= nextDate {
                    lastIndex += 1
                }
                result[i].count = lastIndex >= 1 ? history[lastIndex - 1].count : 0
                nextDate = Calendar.current.date(byAdding: .day, value: dateStride, to: nextDate)!
            }

            return (result, delta)
        } catch APIRequestError.RequestError(let code, let msg) {
            if code == "A0514" {
                throw CompetitionServiceError.CompetitionNotFound
            } else {
                throw APIRequestError.RequestError(code: code, msg: msg)
            }
        }
    }
    
    /// 创建比赛
    /// - Parameter competition: 比赛
    /// - Returns: 新比赛
    class func createCompetition(_ competition: Competition) async throws -> Competition {
        return try await APIRequest().url("/competitions").method(.post).params(competition.toJSON()).request()
    }
}
