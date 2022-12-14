//
//  TeamViewModel.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import Foundation

class TeamViewModel: ObservableObject {
    var id = 0
    
    /// 名称
    @Published var name = ""

    /// 竞赛
    @Published var competitionId = 0

    /// 队伍描述
    @Published var description = ""

    /// 队伍成员
    @Published var members = [TeamMemberViewModel]()

    /// 招募信息
    @Published var recruitments = [RecruitmentViewModel]()

    /// 是否招募中
    @Published var recruiting = true

    init() { }

    init(team: Team) {
        self.id = team.id
        self.name = team.name
        self.competitionId = team.competition!.id
        self.description = team.description!
        self.members = team.members!.map { TeamMemberViewModel(member: $0) }
        self.recruitments = team.recruitments!.map { RecruitmentViewModel(recruitment: $0) }
        self.recruiting = team.recruiting
    }

    var team: Team {
        return Team(
            name: name,
            competition: Competition(id: competitionId),
            description: description,
            members: members.map { $0.teamMember },
            recruitments: recruitments.map { $0.recruitment },
            recruiting: recruiting
        )
    }
}
