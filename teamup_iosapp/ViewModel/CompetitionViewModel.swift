//
// Created by 林思行 on 2022/12/8.
//

import Foundation

class CompetitionViewModel: ObservableObject {
    /// 名称
    @Published var name = ""

    /// 简称
    @Published var abbreviation = ""

    /// 描述
    @Published var description = ""

    /// 开始时间
    @Published var startTime = Date.now

    /// 结束时间
    @Published var endTime = Date.now

    init() { }

    init(competition: Competition) {
        name = competition.name
        abbreviation = competition.abbreviation
        description = competition.description
        startTime = competition.startTime ?? Date.now
        endTime = competition.endTime ?? Date.now
    }

    var competition: Competition {
        Competition(
            name: name,
            abbreviation: abbreviation,
            description: description,
            startTime: startTime,
            endTime: endTime
        )
    }
}
