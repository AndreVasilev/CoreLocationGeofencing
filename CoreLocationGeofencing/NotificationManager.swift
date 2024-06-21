//
//  NotificationManager.swift
//  CoreLocationGeofencing
//
//  Created by Andrey Vasilev on 21.06.2024.
//

import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    private init() {

    }

    func sendNotification(title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        let notificationCenter = UNUserNotificationCenter.current()
        Task {
            print("---\n\(title)\n\(subtitle)\n---")
            do {
                try await notificationCenter.add(request)
            } catch {
                print("⚠️ UserNotificationCenter add request failed:\n\(error.localizedDescription)")
            }
        }
    }

    func requestAuthorization() {
        Task {
            do {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                sendNotification(title: "ℹ️ Request authorization", subtitle: "Succeed")
            } catch {
                print("⚠️ UserNotifications authorization failed:\n\(error.localizedDescription)")
            }
        }
    }
}
