//
//  NotificationCenter+Async.swift
//
//
//  Created by Lenar Gilyazov on 25.06.2023.
//

import Foundation

extension NotificationCenter {
    @discardableResult
    func observeNotifications(
        from notification: Notification.Name
    ) -> AsyncStream<Any?> {
        AsyncStream { continuation in
            let reference = NotificationCenter.default.addObserver(
                forName: notification,
                object: nil,
                queue: nil
            ) { notification in
                continuation.yield(notification.object)
            }
            
            continuation.onTermination = { @Sendable _ in
                NotificationCenter.default.removeObserver(reference)
            }
        }
    }
}
