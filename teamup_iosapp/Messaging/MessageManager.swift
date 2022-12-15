//
//  MessageManager.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/15.
//

import Foundation
import StompClientLib

class MessageManager: StompClientLibDelegate {
    // Instance
    static let shared = MessageManager()

    // Config
    let serverURL = URL(string: "ws://42.193.50.174:8085/ws")! // "wss://api.teamup.nagico.cn/ws")!
    let topicPublic = "/topic/public"
    let topicPrivate = "/user/topic/private"
    let messageHeaders = ["content-type": "application/json"]

    private(set) var connected = false

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
                                withReceipt: message.id)
    }

    func stompClient(client: StompClientLib!,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?,
                     withHeader header: [String: String]?,
                     withDestination destination: String) {
        print("DESTINATION: \(destination)")
        print("JSON BODY: \(String(describing: jsonBody))")
        print("STRING BODY: \(stringBody ?? "nil")")
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

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("Stomp Receipt Received:", receiptId)
    }

    func serverDidSendError(client: StompClientLib!,
                            withErrorMessage description: String,
                            detailedErrorMessage message: String?) {
        print(description, message ?? "")
    }

    func serverDidSendPing() {
        print("Server did send ping")
    }
}

extension NSNotification {
    static let MessageManagerConnected = Notification.Name("MessageManagerConnected")
    static let MessageManagerDisconnected = Notification.Name("MessageManagerDisconnected")
}
