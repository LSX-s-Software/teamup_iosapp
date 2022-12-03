//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class RoleService {
    class func getRoleList(flattened: Bool = false) async throws -> [Role] {
        let result: [Role] = try await APIRequest().url("/teams/roles/").request()
        return flattened ? result.flatMap { $0.children ?? [$0] } : result
    }
}
