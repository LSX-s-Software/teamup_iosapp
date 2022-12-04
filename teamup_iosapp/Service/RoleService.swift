//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class RoleService {
    static var roleList: [Role]?
    
    class func getRoleList(flattened: Bool = false) async throws -> [Role] {
        if roleList == nil {
            roleList = try await APIRequest().url("/teams/roles/").request()
        }
        return flattened ? roleList!.flatMap { $0.children ?? [$0] } : roleList!
    }
}
