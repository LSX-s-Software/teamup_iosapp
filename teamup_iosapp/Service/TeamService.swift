//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class TeamService {
    class func getTeamList(page: Int, pageSize: Int = 20) async throws -> (data: [Team], hasNext: Bool) {
        try await APIRequest().url("/home/teams").pagedRequest(page: page, pageSize: pageSize)
    }

    class func getTeamDetail(id: Int) async throws -> Team {
        try await APIRequest().url("/teams/\(id)").request()
    }
}
