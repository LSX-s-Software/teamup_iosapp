//
//  CompetitionServiceError.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

enum CompetitionServiceError: Error {
    case CompetitionNotFound
    case CompetitionEnded
}


extension CompetitionServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .CompetitionNotFound:
            return "比赛不存在"
        case .CompetitionEnded:
            return "比赛已结束"
        }
    }
}
