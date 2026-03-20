import Foundation
import UserNotifications
import UIKit

struct VaccineReminderRequest: Equatable {
    let identifier: String
    let vaccineName: String
    let scheduledAt: Date
    let leadDays: Int
}

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

        // Remove legacy single-notification identifier and all weekday identifiers
        var idsToRemove = ["dailyReminder"]
        for weekday in 1...7 {
            idsToRemove.append("dailyReminder_\(weekday)")
        }
        center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

        let isEnglish = Locale.current.language.languageCode?.identifier != "tr"
        let roleProfile = ParentRoleProfile(
            storedValue: UserDefaults.standard.string(forKey: "parentRole") ?? ParentRoleProfile.mother.rawValue
        )

        // Schedule one notification per weekday (Sun=1 ... Sat=7) with unique body text
        for weekday in 1...7 {
            let content = UNMutableNotificationContent()
            content.title = roleProfile.dailyReminderTitle(isEnglish: isEnglish)
            content.body = roleProfile.dailyReminderBody(isEnglish: isEnglish, rotationIndex: weekday - 1)
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = weekday

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "dailyReminder_\(weekday)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    func scheduleVaccinationReminder(vaccineName: String, date: Date) {
        let center = UNUserNotificationCenter.current()
        let identifier = "vaccination_\(vaccineName.replacingOccurrences(of: " ", with: "_"))"
        let isEnglish = Locale.current.language.languageCode?.identifier != "tr"
        let roleProfile = ParentRoleProfile(
            storedValue: UserDefaults.standard.string(forKey: "parentRole") ?? ParentRoleProfile.mother.rawValue
        )

        let content = UNMutableNotificationContent()
        content.title = roleProfile.vaccineReminderTitle(isEnglish: isEnglish)
        content.body = roleProfile.vaccineReminderBody(
            vaccineName: vaccineName,
            leadDays: 0,
            isEnglish: isEnglish
        )
        content.sound = .default

        let reminderDate = Self.scheduledReminderDate(from: date, calendar: .current)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request)
    }

    func syncVaccineReminders(
        birthDate: Date?,
        scheduledRecords: [VaccinationRecord] = [],
        hasFullAccess: Bool
    ) async {
        await checkAuthorization()

        guard hasFullAccess, isAuthorized else {
            removeVaccineReminders()
            return
        }

        removeVaccineReminders()

        let center = UNUserNotificationCenter.current()
        let isEnglish = Locale.current.language.languageCode?.identifier != "tr"
        let autoScheduleRecords = scheduledRecords
            .filter { $0.isManual != true && !$0.isCompleted }
            .sorted { $0.scheduledDate < $1.scheduledDate }

        let reminderRequests: [VaccineReminderRequest]
        if !autoScheduleRecords.isEmpty {
            reminderRequests = Self.vaccineReminderRequests(
                scheduledRecords: autoScheduleRecords,
                referenceDate: .now,
                calendar: .current,
                isEnglish: isEnglish
            )
        } else if let birthDate {
            reminderRequests = Self.vaccineReminderRequests(
                birthDate: birthDate,
                referenceDate: .now,
                calendar: .current,
                isEnglish: isEnglish
            )
        } else {
            reminderRequests = []
        }

        for request in reminderRequests {
            let content = UNMutableNotificationContent()
            content.title = Self.vaccineReminderTitle(isEnglish: isEnglish)
            content.body = Self.vaccineReminderBody(
                vaccineName: request.vaccineName,
                leadDays: request.leadDays,
                isEnglish: isEnglish
            )
            content.sound = .default

            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: request.scheduledAt
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let notificationRequest = UNNotificationRequest(
                identifier: request.identifier,
                content: content,
                trigger: trigger
            )

            try? await center.add(notificationRequest)
        }
    }

    func removeVaccineReminders() {
        let identifiers = Self.allVaccineReminderIdentifiers()
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func cancelDailyReminder() {
        var ids = ["dailyReminder"]
        for weekday in 1...7 {
            ids.append("dailyReminder_\(weekday)")
        }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func vaccineReminderRequests(
        birthDate: Date,
        referenceDate: Date = .now,
        calendar: Calendar = .current,
        isEnglish: Bool,
        items: [VaccinationItem] = VaccinationEngine.allItems()
    ) -> [VaccineReminderRequest] {
        return items.flatMap { item -> [VaccineReminderRequest] in
            let vaccineDate = VaccinationEngine.scheduledDate(birthDate: birthDate, monthAge: item.monthAge)
            let vaccineName = isEnglish ? item.nameEN : item.nameTR
            return reminderRequests(
                vaccineName: vaccineName,
                identifierSeed: item.nameTR,
                scheduledDate: vaccineDate,
                referenceDate: referenceDate,
                calendar: calendar
            )
        }
    }

    static func vaccineReminderRequests(
        scheduledRecords: [VaccinationRecord],
        referenceDate: Date = .now,
        calendar: Calendar = .current,
        isEnglish: Bool
    ) -> [VaccineReminderRequest] {
        scheduledRecords.flatMap { record in
            reminderRequests(
                vaccineName: record.vaccineName,
                identifierSeed: record.vaccineName,
                scheduledDate: record.scheduledDate,
                referenceDate: referenceDate,
                calendar: calendar
            )
        }
    }

    static func allVaccineReminderIdentifiers(items: [VaccinationItem] = VaccinationEngine.allItems()) -> [String] {
        items.flatMap { item in
            [
                vaccineReminderIdentifier(vaccineName: item.nameTR, suffix: "3d"),
                vaccineReminderIdentifier(vaccineName: item.nameTR, suffix: "0d")
            ]
        }
    }

    private static func vaccineReminderTitle(isEnglish: Bool) -> String {
        let roleProfile = ParentRoleProfile(
            storedValue: UserDefaults.standard.string(forKey: "parentRole") ?? ParentRoleProfile.mother.rawValue
        )
        return roleProfile.vaccineReminderTitle(isEnglish: isEnglish)
    }

    private static func vaccineReminderBody(vaccineName: String, leadDays: Int, isEnglish: Bool) -> String {
        let roleProfile = ParentRoleProfile(
            storedValue: UserDefaults.standard.string(forKey: "parentRole") ?? ParentRoleProfile.mother.rawValue
        )
        return roleProfile.vaccineReminderBody(
            vaccineName: vaccineName,
            leadDays: leadDays,
            isEnglish: isEnglish
        )
    }

    private static func scheduledReminderDate(from date: Date, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
    }

    private static func reminderRequests(
        vaccineName: String,
        identifierSeed: String,
        scheduledDate: Date,
        referenceDate: Date,
        calendar: Calendar
    ) -> [VaccineReminderRequest] {
        let reminderMoments: [(suffix: String, leadDays: Int, date: Date)] = [
            (
                "3d",
                3,
                scheduledReminderDate(
                    from: calendar.date(byAdding: .day, value: -3, to: scheduledDate) ?? scheduledDate,
                    calendar: calendar
                )
            ),
            (
                "0d",
                0,
                scheduledReminderDate(from: scheduledDate, calendar: calendar)
            )
        ]

        return reminderMoments.compactMap { reminder in
            guard reminder.date > referenceDate else { return nil }

            return VaccineReminderRequest(
                identifier: vaccineReminderIdentifier(vaccineName: identifierSeed, suffix: reminder.suffix),
                vaccineName: vaccineName,
                scheduledAt: reminder.date,
                leadDays: reminder.leadDays
            )
        }
    }

    private static func vaccineReminderIdentifier(vaccineName: String, suffix: String) -> String {
        "vaccine-\(identifierSlug(from: vaccineName))-\(suffix)"
    }

    private static func identifierSlug(from text: String) -> String {
        let normalized = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ß", with: "ss")

        let allowed = CharacterSet.alphanumerics
        let scalars = normalized.unicodeScalars.map { scalar -> String in
            allowed.contains(scalar) ? String(scalar) : "_"
        }

        return scalars
            .joined()
            .split(separator: "_")
            .joined(separator: "_")
    }
}
