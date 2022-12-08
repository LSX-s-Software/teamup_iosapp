//
//  CompetitionInfoView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/5.
//

import SwiftUI
import CachedAsyncImage

struct CompetitionInfoView: View {
    let competition: Competition
    
    var body: some View {
        NavigationLink {
            CompetitionDetailView(competitionId: competition.id, competition: competition)
        } label: {
            HStack(spacing: 0) {
                CompetitionLogo(logo: competition.logo, abbreviation: competition.abbreviation)
                Spacer()
                    .frame(width: 12)
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(competition.name.count < 10 ? competition.name : competition.abbreviation)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        if let verified = competition.verified, verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    HStack {
                        if let startTime = competition.startTime {
                            Text("\(Formatter.formatDate(date: startTime, format: "yyyy-MM-dd"))")
                                .lineLimit(1)
                                .foregroundColor(.primary)
                        }
                        Image(systemName: "arrowshape.right")
                            .foregroundColor(.primary)
                        if let endTime = competition.endTime {
                            Text("\(Formatter.formatDate(date: endTime, format: "yyyy-MM-dd"))")
                                .lineLimit(1)
                                .foregroundColor(.primary)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct CompetitionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionInfoView(competition: PreviewData.competition)
    }
}
