//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class TeamService {
    enum SortMethod: String, CaseIterable {
        case date = "按创建日期从新到旧"
        case dateAsc = "按创建日期从旧到新"
        case popular = "按人气降序"
        case popularAsc = "按人气升序"
    }
    
    /// 获取团队列表
    /// - Parameters:
    ///   - competition: 比赛名
    ///   - role: 角色名
    ///   - page: 页码
    ///   - pageSize: 分页大小
    /// - Returns: 符合条件的团队列表
    class func getTeamList(competition: String? = nil,
                           role: String? = nil,
                           page: Int,
                           pageSize: Int = 20) async throws -> (data: [Team], hasNext: Bool) {
        var params = [String: String]()
        if let competition = competition, !competition.isEmpty {
            params["competition"] = competition
        }
        if let role = role, !role.isEmpty {
            params["role"] = role
        }
        return try await APIRequest().url("/home/teams").params(params).pagedRequest(page: page, pageSize: pageSize)
    }
    
    /// 获取团队详情
    /// - Parameter id: 团队ID
    /// - Returns: 团队详情
    class func getTeamDetail(id: Int) async throws -> Team {
        return try await APIRequest().url("/teams/\(id)").request()
    }
    
    /// 创建团队
    /// - Parameter team: 团队ViewModel
    /// - Returns: 新团队
    class func createTeam(team: TeamViewModel) async throws -> Team {
        return try await APIRequest().url("/teams/").method(.post).params(team.team.toJSON()).request()
    }
}
