//
//  NotificationService.swift
//  HanLearn
//
//  Local notification scheduling via UNUserNotificationCenter.
//  No push notifications, no server — everything stays on-device.
//  Gracefully degrades if permission denied.
//

import Foundation
import UserNotifications

public final class NotificationService {
    public static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    private let dailyReminderId = "hanlearn.daily.reminder"
    
    private init() {}
    
    // MARK: - Permission
    
    /// Request notification permission. Returns true if granted.
    /// Never gates core functionality — app is fully usable without notifications.
    public func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("[NotificationService] Permission request failed: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    public func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Daily Reminder
    
    /// Schedule (or reschedule) the daily study reminder.
    ///
    /// - Parameters:
    ///   - hour: Hour component (0–23)
    ///   - minute: Minute component (0–59)
    ///   - reviewCount: Number of SRS reviews due (shown in notification body)
    ///   - streak: Current streak count (shown in notification)
    public func scheduleDailyReminder(
        hour: Int,
        minute: Int,
        reviewCount: Int = 0,
        streak: Int = 0
    ) {
        // Remove existing reminder first
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
        
        let content = UNMutableNotificationContent()
        content.title = "HanLearn · Đến giờ học rồi! 📚"
        
        if reviewCount > 0 && streak > 1 {
            content.body = "Bạn có \(reviewCount) từ vựng cần ôn hôm nay. Chuỗi streak: \(streak) ngày 🔥"
        } else if reviewCount > 0 {
            content.body = "Có \(reviewCount) từ vựng đang chờ bạn ôn tập. Bắt đầu nào! 💪"
        } else if streak > 1 {
            content.body = "Giữ vững chuỗi \(streak) ngày! Hãy hoàn thành bài học hôm nay 🔥"
        } else {
            content.body = "Mỗi ngày một chút, tiếng Trung sẽ tốt hơn từng ngày! 加油！"
        }
        
        content.sound = .default
        content.badge = reviewCount > 0 ? NSNumber(value: reviewCount) : nil
        
        // Trigger daily at the configured time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderId, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("[NotificationService] Failed to schedule reminder: \(error)")
            }
        }
    }
    
    /// Cancel the daily reminder
    public func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }
    
    /// Clear the app badge count
    public func clearBadge() {
        center.setBadgeCount(0) { error in
            if let error = error {
                print("[NotificationService] Failed to clear badge: \(error)")
            }
        }
    }
}
