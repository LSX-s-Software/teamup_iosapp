//
//  UserView.swift
//  teamup_iosapp
//
//  Created by RTC-13 on 2022/12/7.
//

import SwiftUI
import CachedAsyncImage
import SwiftUIFlow

struct BriefInfoStyle: ViewModifier {
    var width: CGFloat = 100, height: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: width, height: height)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
    }
}

struct UserView: View {
    var userId: Int
    @State var user = User()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // MARK: - 上方信息
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username ?? "未填写用户名")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("\(user.faculty ?? "未填写学院") \(user.grade ?? "未填写年")级")
                            .foregroundColor(.white)
                        if let lastLogin = user.lastLogin, let span = (Date.now - lastLogin).day {
                            Group {
                                if span > 0 {
                                    Text("\(span)天前来过")
                                } else {
                                    Text("今天来过")
                                }
                            }
                            .foregroundColor(.white)
                            .font(.caption)
                        }
                    }
                    Spacer()
                    CachedAsyncImage(url: URL(string: user.avatar ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .background(.white)
                    .cornerRadius(62.5)
                    .shadow(color: Color(white: 0, opacity: 0.1), radius: 15)
                }
                .padding()
                
                VStack {
                    // MARK: - 概要
                    Text("个人简介")
                        .modifier(SectionTitleStyle())
                    HStack(spacing: 0) {
                        if let teamCount = user.teamCount {
                            VStack(spacing: 6) {
                                Text("\(teamCount)")
                                    .font(.largeTitle)
                                    .lineLimit(1)
                                Text("创建的队伍")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .modifier(BriefInfoStyle())
                        }
                        Spacer()
                        if let awardCount = user.awards?.count {
                            VStack(spacing: 6) {
                                Text("\(awardCount)")
                                    .font(.largeTitle)
                                    .lineLimit(1)
                                Text("获奖数")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .modifier(BriefInfoStyle())
                        }
                        Spacer()
                        if let awardCount = user.awards?.count {
                            VStack(spacing: 6) {
                                Text("\(awardCount)")
                                    .font(.largeTitle)
                                    .lineLimit(1)
                                Text("获奖数")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .modifier(BriefInfoStyle())
                        }
                    }
                    .padding([.horizontal, .bottom])
                    
                    // MARK: - 自我介绍
                    Text(nilOrEmpty(user.introduction) ? "这个用户很懒，没有填写自我介绍" : user.introduction!)
                    
                    // MARK: - 获奖信息
                    Spacer()
                        .frame(height: 12)
                    Text("获奖信息")
                        .modifier(SectionTitleStyle())
                    if let awards = user.awards, awards.count > 0 {
                        VStack(alignment: .leading) {
                            ForEach(Array(awards.enumerated()), id: \.offset) { index, award in
                                HStack(spacing: 10) {
                                    if index < 50 {
                                        Image(systemName: "\(index + 1).circle")
                                    } else {
                                        Text("\(index + 1)")
                                    }
                                    Text(award)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(5)
                            }
                        }
                    } else {
                        Spacer()
                            .frame(height: 8)
                        Text("暂无获奖信息")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.background)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
        }
        .navigationTitle("队长信息")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.accentColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            do {
                user = try await UserService.getUserInfo(id: userId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserView(userId: 11, user: PreviewData.leader)
        }
    }
}
