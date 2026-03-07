import Foundation
import UserNotifications
import UIKit

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private(set) var isAuthorized = false
    private(set) var isDenied = false

    private init() {
        Task { await checkAuthorization() }
    }

    func requestPermission() async -> Bool {
        if isDenied {
            await openSettings()
            return false
        }

        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
                isDenied = !granted
            }
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
            isDenied = settings.authorizationStatus == .denied
        }
    }

    @MainActor
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notif_daily_title", defaultValue: "Good morning!")
        content.body = String(localized: "notif_daily_body", defaultValue: "Check today's tip for your baby's development.")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        center.add(request)
    }

    func scheduleVaccinationReminder(vaccineName: String, date: Date) {
        let center = UNUserNotificationCenter.current()
        let identifier = "vaccination_\(vaccineName.replacingOccurrences(of: " ", with: "_"))"

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notif_vaccine_title", defaultValue: "Vaccine Reminder")
        content.body = "It's time for \(vaccineName). Don't forget to schedule the appointment!"
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
}
