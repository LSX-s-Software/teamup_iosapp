//
// Created by 林思行 on 2022/12/1.
//

import Foundation

class CompetitionService {
    class func getCompetitionList() async throws -> [Competition] {
        return try await APIRequest().url("/competitions").request()
    }
    
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
}
