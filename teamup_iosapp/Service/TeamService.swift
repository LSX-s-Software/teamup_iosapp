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
        return try await APIRequest().url("/home/teams/").params(params).pagedRequest(page: page, pageSize: pageSize)
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

    // MARK: - 喜欢/收藏
    
    /// 对团队感兴趣
    /// - Parameter id: 团队ID
    class func like(id: Int) async throws {
        try await APIRequest().url("/users/interests/teams/\(id)/").method(.post).requestIgnoringResponse()
    }
    
    /// 取消对团队感兴趣
    /// - Parameter id: 团队ID
    class func cancelLike(id: Int) async throws {
        try await APIRequest().url("/users/interests/teams/\(id)/").method(.delete).requestIgnoringResponse()
    }

    /// 对团队不感兴趣
    /// - Parameter id: 团队ID
    class func dislike(id: Int) async throws {
        try await APIRequest().url("/users/disinterests/teams/\(id)/").method(.post).requestIgnoringResponse()
    }

    /// 取消对团队不感兴趣
    /// - Parameter id: 团队ID
    class func cancelDislike(id: Int) async throws {
        try await APIRequest().url("/users/disinterests/teams/\(id)/").method(.delete).requestIgnoringResponse()
    }

    /// 收藏团队
    /// - Parameter id: 团队ID
    class func favorite(id: Int) async throws {
        try await APIRequest().url("/users/favorites/teams/\(id)/").method(.post).requestIgnoringResponse()
    }

    /// 取消收藏团队
    /// - Parameter id: 团队ID
    class func unfavorite(id: Int) async throws {
        try await APIRequest().url("/users/favorites/teams/\(id)/").delete()
    }
    
    // MARK: - 招募
    
    /// 获取队伍招募
    /// - Parameter id: 队伍ID
    /// - Returns: 队伍招募
    class func getTeamRecruit(id: Int) async throws -> Recruitment {
        return try await APIRequest().url("/teams/\(id)/recruitments/").request()
    }
    
    /// 添加招募
    /// - Parameters:
    ///   - teamId: 团队ID
    ///   - recruitment: 招募ViewModel
    /// - Returns: 新招募
    class func addRecruitment(teamId: Int, recruitment: RecruitmentViewModel) async throws -> Recruitment {
        return try await APIRequest()
            .url("/teams/\(teamId)/recruitments/")
            .method(.post)
            .params(recruitment.recruitment.toJSON())
            .request()
    }

    /// 更新招募
    /// - Parameters:
    ///  - teamId: 团队ID
    ///  - recruitmentId: 招募ID
    ///  - recruitment: 招募ViewModel
    /// - Returns: 更新后的招募
    class func updateRecruitment(teamId: Int, recruitmentId: Int, recruitment: RecruitmentViewModel) async throws -> Recruitment {
        return try await APIRequest()
            .url("/teams/\(teamId)/recruitments/\(recruitmentId)")
            .method(.put)
            .params(recruitment.recruitment.toJSON())
            .request()
    }
    
    /// 删除招募
    /// - Parameters:
    ///   - teamId: 团队ID
    ///   - recruitmentId: 招募ID
    class func removeRecruitment(teamId: Int, recruitmentId: Int) async throws {
        try await APIRequest().url("/teams/\(teamId)/recruitments/\(recruitmentId)").method(.delete).requestIgnoringResponse()
    }
}
