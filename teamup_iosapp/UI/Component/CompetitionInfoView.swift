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
            
        } label: {
            HStack(spacing: 0) {
                CachedAsyncImage(url: URL(string: competition.logo ?? "")) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                        .tint(.secondary)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(5)
                Spacer()
                    .frame(width: 12)
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(competition.name ?? "")
                            .font(.title2)
                            .foregroundColor(.primary)
                        if let verified = competition.verified, verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    HStack {
                        if let startTime = competition.startTime {
                            Text("\(Formatter.formatDate(date: startTime, compact: true))")
                                .lineLimit(1)
                                .foregroundColor(.primary)
                        }
                        Image(systemName: "arrowshape.right")
                            .foregroundColor(.primary)
                        if let endTime = competition.endTime {
                            Text("\(Formatter.formatDate(date: endTime, compact: true))")
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