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

    class func getTeamDetail(id: Int) async throws -> Team {
        return try await APIRequest().url("/teams/\(id)").request()
    }
}
