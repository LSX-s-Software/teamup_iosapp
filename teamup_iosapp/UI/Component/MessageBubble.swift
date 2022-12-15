//
//  MessageBubble.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/14.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    var isMyMessage: Bool {
        message.sender == 0 || UserService.userId != nil && UserService.userId! == message.sender
    }
    @State var showTime = false
    
    var body: some View {
        VStack(alignment: isMyMessage ? .trailing : .leading) {
            HStack(alignment: .bottom) {
                if isMyMessage && showTime {
                    Text(Formatter.formatDate(date: message.createTime, compact: true))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                Text(message.content)
                    .padding()
                    .foregroundColor(isMyMessage ? .white : .primary)
                    .background(isMyMessage ? Color.accentColor.opacity(0.8) : Color(UIColor.secondarySystemFill))
                    .cornerRadius(15, corners: [.topLeft, .topRight, isMyMessage ? .bottomLeft : .bottomRight])
                if !isMyMessage && showTime {
                    Text(Formatter.formatDate(date: message.createTime, compact: true))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
            }
            .frame(maxWidth: showTime ? 340 : 300, alignment: isMyMessage ? .trailing : .leading)
            .onTapGesture {
                withAnimation {
                    showTime.toggle()
                }
            }
            
            if isMyMessage {
                Text(message.read ? "已读" : "未读")
                    .foregroundColor(message.read ? .secondary : .accentColor)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: isMyMessage ? .trailing : .leading)
        .onAppear {
            if !isMyMessage && !message.read {
                MessageManager.shared.setRead(id: message.id, userId: message.sender)
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubble(message: PreviewData.message1)
            MessageBubble(message: PreviewData.message3)
            MessageBubble(message: PreviewData.message2)
            MessageBubble(message: PreviewData.message4)
        }
    }
}
