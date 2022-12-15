//
//  MessageManager.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/15.
//

import Foundation
import StompClientLib

class MessageManager: StompClientLibDelegate, ObservableObject {
    // Instance
    static let shared = MessageManager()
    
    // Config
    let serverURL = URL(string: "ws://42.193.50.174:8085/ws")! // "wss://api.teamup.nagico.cn/ws")!
    let topicPublic = "/topic/public"
    let topicPrivate = "/user/topic/private"
    let messageHeaders = ["content-type": "application/json"]
    
    var messages = [Message]()
    
    // Published state
    @Published private(set) var connected = false
    @Published var messageList = [MessageListItem]()
    var unreadCount: Int {
        var count = 0
        messages.forEach { message in
            if !message.read {
                count += 1
            }
        }
        return count
    }

    private var stompClient = StompClientLib()

    private init() { }

    func connect() {
        Task {
            guard var token = await AuthService.getToken() else {
                throw MessageManagerError.userNotLoggedIn
            }
            token = "Bearer " + token
            let request = NSMutableURLRequest(url: serverURL)
            request.setValue(token, forHTTPHeaderField: "Authorization")

            stompClient.openSocketWithURLRequest(request: request, delegate: self, connectionHeaders: ["Authorization": token])
        }
    }

    func disconnect() {
        stompClient.disconnect()
    }

    func sendMessage(message: MessageViewModel) {
        stompClient.sendMessage(message: message.jsonString,
                                toDestination: "/app/send",
                                withHeaders: messageHeaders,
                                withReceipt: nil)
        if message.type == .Chat {
            Task {
                await addMessage(message: message.message)
            }
        }
    }
    
    func getLatestMessage(userId: Int) -> Message? {
        return messages.last { $0.receiver == userId }
    }
    
    func getAllMessage(userId: Int) -> [Message] {
        return messages.filter { $0.sender == userId }
    }
    
    func fetchRemoteMessage() {
        if !AuthService.registered { return }
        Task {
            do {
                let result: [Message] = try await APIRequest().url("/messages/offline/").request()
                for i in 0..<result.count {
                    if result[i].type == .Chat {
                        await addMessage(message: result[i])
                    } else if result[i].type == .Ack {
                        for j in 0..<messages.count {
                            if messages[j].id == result[i].content {
                                messages[j].read = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addMessage(message: Message) async {
        if messages.contains(where: { $0.id == message.id }) { return }
        messages.append(message)
        if message.sender == UserService.userId { return }
        if let index = messageList.firstIndex(where: { $0.userId == message.sender }) {
            DispatchQueue.main.async {
                self.messageList[index].latestMessage = message
            }
        } else {
            do {
                let user = try await UserService.getUserInfo(id: message.sender)
                DispatchQueue.main.async {
                    self.messageList.append(MessageListItem(id: (self.messageList.last?.id ?? 0) + 1,
                                                            userId: message.sender,
                                                            username: user.username,
                                                            userAvatar: user.avatar ?? "",
                                                            latestMessage: message))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setRead(id: String, userId: Int) {
        print("Ack sent:", id)
        sendMessage(message: MessageViewModel(type: .Ack, content: id, receiver: userId))
    }
}

// MARK: - 事件处理
extension MessageManager {
    func stompClient(client: StompClientLib!,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?,
                     withHeader header: [String: String]?,
                     withDestination destination: String) {
        print("JSON BODY: \(String(describing: jsonBody))")
        
        guard let jsonDict = jsonBody as? NSDictionary, let message = Message.deserialize(from: jsonDict) else { return }
        if message.type == .Chat {
            Task {
                await addMessage(message: message)
            }
            NotificationCenter.default.post(name: NSNotification.NewMessageReceived, object: nil, userInfo: ["message": message])
        } else if message.type == .Ack {
            NotificationCenter.default.post(name: NSNotification.MessageRead, object: nil, userInfo: ["id": message.content ?? ""])
            if let index = messages.firstIndex(where: { $0.id == message.content }) {
                messages[index].read = true
            }
        }
    }

    func stompClientDidDisconnect(client: StompClientLib!) {
        print("Stomp Disconnected")
        NotificationCenter.default.post(name: NSNotification.MessageManagerDisconnected, object: nil)
        connected = false
    }

    func stompClientDidConnect(client: StompClientLib!) {
        stompClient.subscribe(destination: topicPublic)
        stompClient.subscribe(destination: topicPrivate)
        print("Stomp Connected")
        NotificationCenter.default.post(name: NSNotification.MessageManagerConnected, object: nil)
        connected = true
    }

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) { }

    func serverDidSendError(client: StompClientLib!,
                            withErrorMessage description: String,
                            detailedErrorMessage message: String?) {
        print(description, message ?? "")
    }

    func serverDidSendPing() { }
}

extension NSNotification {
    static let MessageManagerConnected = Notification.Name("MessageManagerConnected")
    static let MessageManagerDisconnected = Notification.Name("MessageManagerDisconnected")
    static let NewMessageReceived = Notification.Name("NewMessageReceived")
    static let MessageRead = Notification.Name("MessageRead")
}
