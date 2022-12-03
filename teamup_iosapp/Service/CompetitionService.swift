//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class CompetitionService {
    class func getCompetitionList() async throws -> [Competition] {
        try await APIRequest().url("/competitions").request()
    }
}
