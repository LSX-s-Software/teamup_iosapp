//
//  RecruitmentInfoView.swift
//  teamup_iosapp
//
//  Created by RTC-13 on 2022/12/8.
//

import SwiftUI

struct RecruitmentInfoView: View {
    var recruitment: Recruitment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recruitment.role.name ?? "")
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
                Text("\(recruitment.count ?? 0)人")
            }
            Divider()
            ForEach(Array((recruitment.requirements ?? []).enumerated()), id: \.offset) { index, requirement in
                HStack {
                    if index < 50 {
                        Image(systemName: "\(index + 1).circle")
                    } else {
                        Text("\(index + 1)")
                    }
                    Text(requirement)
                }
            }
        }
    }
}

struct RequirementInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RecruitmentInfoView(recruitment: PreviewData.recruitment1)
    }
}
