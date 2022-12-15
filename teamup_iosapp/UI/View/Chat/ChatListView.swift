//
//  ChatListView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/11/28.
//

import SwiftUI
import CachedAsyncImage

struct ChatListView: View {
    @State var messageList = [MessageListItem]()
    @State var status: UserStatus = MessageManager.shared.connected ? .Online : .Offline
    
    var body: some View {
        NavigationStack {
            Group {
                if messageList.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 44)
                            .foregroundColor(.accentColor)
                        Text("还没有聊天记录")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(Array(messageList.enumerated()), id: \.offset) { index, message in
                        NavigationLink(value: index) {
                            HStack {
                                CachedAsyncImage(url: URL(string: message.userAvatar)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(25)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text(message.username)
                                            .font(.title3)
                                        Spacer()
                                        Text(Formatter.formatDate(date: message.latestMessage.createTime, compact: true))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack(spacing: 4) {
                                        Text("[\(message.latestMessage.read ? "已读" : "未读")]")
                                            .foregroundColor(message.latestMessage.read ? .secondary : .accentColor)
                                        if message.latestMessage.type == .System {
                                            Text("[模板消息]")
                                        }
                                        Text(message.latestMessage.content)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                        .navigationDestination(for: Int.self) { index in
                            ChatView(userId: messageList[index].userId, user: User(username: messageList[index].username,
                                                                                   avatar: messageList[index].userAvatar))
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("消息")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        status = MessageManager.shared.connected ? .Online : .Offline
                    } label: {
                        HStack {
                            Circle()
                                .frame(width: 10)
                            Text(status == .Online ? "在线" : "离线")
                        }
                        .foregroundColor(status == .Online ? .green : .gray)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageManagerConnected)) { _ in
                status = .Online
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageManagerDisconnected)) { _ in
                status = .Offline
            }
            .onAppear {
                status = MessageManager.shared.connected ? .Online : .Offline
            }
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ChatListView(messageList: PreviewData.userMessageList)
                .tabItem {
                    Label("消息", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(Tab.chat)
        }
    }
}
