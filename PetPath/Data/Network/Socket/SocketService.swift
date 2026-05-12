//
//  SocketService.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Foundation
import SocketIO

struct NewChatEventDTO: Decodable {
    let roomId: Int
    let lastChatContent: String
    let lastChatAt: String
    let unreadMessage: Int
}

final class SocketService {
    static let shared = SocketService()
    private let socketQueue = DispatchQueue(label: "\(UrlManager.baseUrl.urlString)")
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    private init() {}

    func establishConnection() {
        guard let token = KeychainWorker.shared.read(key: .access),
              let url = URL(string: UrlManager.baseUrl.urlString) else { return }

        socketQueue.async {
            self.manager = SocketManager(socketURL: url, config: [
                .log(true),
                .compress,
                .path("/socket"),
                .forceWebsockets(true),
                .extraHeaders(["auth": token])
            ])
            self.socket = self.manager?.defaultSocket
            self.registerDefaultHandlers()
            self.socket?.connect()
        }
    }

    private func registerDefaultHandlers() {
        socket?.on(clientEvent: .connect) { _, _ in
            print("✅ Socket connected")
            NotificationCenter.default.post(name: .socketConnected, object: nil)
        }

        socket?.on(clientEvent: .disconnect) { data, _ in
            print("❌ Socket disconnected: \(data)")
        }

        socket?.on(clientEvent: .error) { data, _ in
            print("⚠️ Socket error: \(data)")
        }

        socket?.on("NewChatEvent") { data, _ in
            guard let raw = data.first,
                  let json = try? JSONSerialization.data(withJSONObject: raw, options: []),
                  let event = try? JSONDecoder().decode(NewChatEventDTO.self, from: json) else {
                print("❌ NewChatEvent 파싱 실패: \(data)")
                return
            }

            print("📨 NewChatEvent 수신: \(event)")
            NotificationCenter.default.post(name: .newChatEventReceived, object: nil, userInfo: ["event": event])
        }

        socket?.on("RecieveChatEvent") { data, _ in
            print("💬 RecieveChatEvent 수신: \(data)")
        }

        socket?.on("ChatReadEvent") { data, _ in
            print("📖 ChatReadEvent 수신: \(data)")
        }

        socket?.on("_error") { data, _ in
            print("🛑 서버 에러 수신: \(data)")
        }
    }

    func emitRead(chatIndex: Int) {
        print("📤 emit ChatReadMessage with index: \(chatIndex)")
        socket?.emit("ChatReadMessage", ["chatIndex": chatIndex])
    }

    func emitListenWalk(walkId: Int) {
        socketQueue.async {
            print("📤 emit ListenWalkMessage with walkId: \(walkId)")
            self.socket?.emit("ListenWalkMessage", ["walk": walkId])
        }
    }

    func registerWalkStatusEvent(handler: @escaping (_ walkId: Int, _ status: String) -> Void) {
        socket?.on("WalkStatusEvent") { data, _ in
            guard let raw = data.first as? [String: Any],
                  let walkId = raw["walk"] as? Int,
                  let status = raw["status"] as? String else {
                print("❌ WalkStatusEvent 파싱 실패: \(data)")
                return
            }
            print("📥 WalkStatusEvent 수신: walk=\(walkId), status=\(status)")
            handler(walkId, status)
        }
    }

    func closeConnection() {
        socket?.disconnect()
    }
}

extension Notification.Name {
    static let newChatEventReceived = Notification.Name("newChatEventReceived")
    static let socketConnected = Notification.Name("socketConnected")
}
