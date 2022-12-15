//
//  ChatView.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import SwiftUI
import CachedAsyncImage

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var userId: Int
    @State var user: User
    @State var messages = [Message]()
    @ObservedObject var messageManager = MessageManager.shared
    @StateObject var newMessage: MessageViewModel
    @State var userInfoSheetShown = false
    @State var latestMessageId = ""
    
    init(userId: Int, user: User, messages: [Message]? = nil, latestMessageId: String = "") {
        self._userId = State(initialValue: userId)
        self._user = State(initialValue: user)
        if messages != nil {
            self._messages = State(initialValue: messages!)
        }
        self._newMessage = StateObject(wrappedValue: MessageViewModel(content: "", receiver: userId))
        if latestMessageId.isEmpty {
            self._latestMessageId = State(initialValue: latestMessageId)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 用户信息
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .bold()
                }
                .padding(.horizontal, 4)
                
                CachedAsyncImage(url: URL(string: user.avatar ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .cornerRadius(25)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(user.username)
                        .font(.title)
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 10)
                            .foregroundColor(user.status == .Online ? .green : .gray)
                        Group {
                            Text(user.status == .Online ? "在线" : "离线")
                            if user.status == .Offline {
                                Circle()
                                    .frame(width: 5)
                                Text("上次在线：\(Formatter.formatDate(date: user.lastLogin!, compact: true))")
                            }
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .font(.caption)
                }
                Spacer()
                
                Button {
                    userInfoSheetShown.toggle()
                } label: {
                    Image(systemName: "info")
                        .imageScale(.large)
                        .bold()
                        .frame(width: 40, height: 40)
                }
                .background(.white.opacity(0.85))
                .cornerRadius(20)
                .sheet(isPresented: $userInfoSheetShown) {
                    NavigationView {
                        UserView(userId: user.id, user: user)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("关闭") {
                                        userInfoSheetShown = false
                                    }
                                    .tint(.white)
                                }
                            }
                    }
                }
            }
            .padding()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        if messages.isEmpty {
                            Spacer()
                        }
                        ForEach(messages, id: \.id) { message in
                            MessageBubble(message: message).id(message.id)
                        }
                    }
                    .padding(.vertical)
                }
                .background()
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .onChange(of: latestMessageId) { newValue in
                    proxy.scrollTo(newValue, anchor: .bottom)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.NewMessageReceived)) { data in
                    guard let userInfo = data.userInfo, let message = userInfo["message"] as? Message else { return }
                    print(message)
                    if message.sender == userId && message.type == .Chat {
                        messages.append(message)
                        latestMessageId = message.id
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageRead)) { data in
                    guard let userInfo = data.userInfo, let messageId = userInfo["id"] as? String else { return }
                    for i in 0..<messages.count {
                        if messages[i].id == messageId {
                            messages[i].read = true
                        }
                    }
                }
            }
            
            // MARK: - 下方操作区
            VStack {
                HStack {
                    TextField("输入消息内容", text: $newMessage.content)
                    Button {
                        newMessage.createTime = Date.now
                        MessageManager.shared.sendMessage(message: newMessage)
                        messages.append(newMessage.message)
                        latestMessageId = messages.last!.id
                        newMessage.reset()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                    }
                    .cornerRadius(50)
                }
                .padding(6)
                .padding(.leading)
                .background()
                .cornerRadius(50)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
        .background(Color.accentColor)
        .navigationBarBackButtonHidden()
        .onAppear {
            messages = MessageManager.shared.getAllMessage(userId: userId)
            latestMessageId = messages.last?.id ?? ""
        }
        .task {
            do {
                user = try await UserService.getUserInfo(id: userId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatView(userId: PreviewData.leader.id, user: PreviewData.leader, messages: [PreviewData.message1,
                                                                                         PreviewData.message2,
                                                                                         PreviewData.message3,
                                                                                         PreviewData.message4])
        }
    }
}
