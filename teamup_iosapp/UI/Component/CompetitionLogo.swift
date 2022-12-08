//
//  CompetitionLogo.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/8.
//

import SwiftUI
import CachedAsyncImage

struct CompetitionLogo: View {
    var logo: String?
    var abbreviation: String
    var size: CGFloat = 60
    
    var body: some View {
        if nilOrEmpty(logo) {
            Text(abbreviation)
                .font(.system(size: size / 3))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(width: size, height: size)
                .background(Color(UIColor.random))
                .cornerRadius(size / 10)
        } else {
            CachedAsyncImage(url: URL(string: logo!)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
                    .tint(.secondary)
            }
            .frame(width: size, height: size)
            .cornerRadius(size / 10)
        }
    }
}

struct CompetitionLogo_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CompetitionLogo(abbreviation: "互联网+")
            CompetitionLogo(abbreviation: "挑战杯大学生")
            CompetitionLogo(abbreviation: "挑战杯大学生", size: 150)
        }
    }
}
