import SwiftUI
import SwiftData

struct VaccinationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query(sort: \VaccinationRecord.scheduledDate) private var records: [VaccinationRecord]
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @State private var showAddSheet = false
    @State private var showPaywall = false
    @State private var showAllFutureRecords = false
    @State private var recordPendingReschedule: VaccinationRecord?
    @State private var rescheduledDate = Date()

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private func displayName(_ record: VaccinationRecord) -> String {
        VaccinationEngine.localizedName(record.vaccineName, isEnglish: isEN)
    }

    // TR mode: auto-generated schedule records
    private var scheduleRecords: [VaccinationRecord] {
        records.filter { $0.isManual != true }
    }

    // Manual entries (both TR and EN users can add these)
    private var manualRecords: [VaccinationRecord] {
        records.filter { $0.isManual == true }
    }

    // Schedule groupings (TR mode)
    private var completedRecords: [VaccinationRecord] {
        scheduleRecords.filter { $0.isCompleted }
    }

    private var upcomingRecords: [VaccinationRecord] {
        scheduleRecords.filter { !$0.isCompleted && $0.scheduledDate <= Calendar.current.date(byAdding: .month, value: 2, to: .now)! }
    }

    private var futureRecords: [VaccinationRecord] {
        scheduleRecords.filter { !$0.isCompleted && $0.scheduledDate > Calendar.current.date(byAdding: .month, value: 2, to: .now)! }
    }

    private var visibleFutureRecords: [VaccinationRecord] {
        showAllFutureRecords ? futureRecords : Array(futureRecords.prefix(2))
    }

    private var nextVaccine: VaccinationRecord? {
        scheduleRecords.first { !$0.isCompleted }
    }

    private var nextHeroEntry: (name: String, date: Date, isManualDose: Bool)? {
        let scheduleCandidate = nextVaccine.map { (name: displayName($0), date: $0.scheduledDate, isManualDose: false) }
        let manualCandidate = upcomingManual.first.flatMap { record in
            record.nextDoseDate.map { (name: displayName(record), date: $0, isManualDose: true) }
        }

        return [scheduleCandidate, manualCandidate]
            .compactMap { $0 }
            .sorted { $0.date < $1.date }
            .first
    }

    // Manual groupings (EN mode / both modes)
    private var upcomingManual: [VaccinationRecord] {
        manualRecords.filter { record in
            if let nextDose = record.nextDoseDate, nextDose > .now {
                return true
            }
            return false
        }.sorted { ($0.nextDoseDate ?? .distantFuture) < ($1.nextDoseDate ?? .distantFuture) }
    }

    private var completedManual: [VaccinationRecord] {
        manualRecords.filter { record in
            record.nextDoseDate == nil || (record.nextDoseDate ?? .distantFuture) <= .now
        }.sorted { ($0.administeredDate ?? $0.scheduledDate) > ($1.administeredDate ?? $1.scheduledDate) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    if isEN {
                        Text("VACCINATION TRACKER")
                            .font(.kinnaBody(9))
                            .foregroundStyle(.kMuted)
                            .tracking(1.5)

                        (
                            Text("Vaccine ")
                                .font(.kinnaDisplay(26))
                                .foregroundStyle(.kChar)
                            +
                            Text("tracker")
                                .font(.kinnaDisplayItalic(26))
                                .foregroundStyle(.kTerra)
                        )

                        Text("Log your baby's vaccinations and set reminders.")
                            .font(.kinnaBody(12, weight: .light))
                            .foregroundStyle(.kMid)
                    } else {
                        Text("T.C. SAĞLIK BAKANLIĞI PROTOKOLÜ")
                            .font(.kinnaBody(9))
                            .foregroundStyle(.kMuted)
                            .tracking(1.5)

                        (
                            Text("Aşı ")
                                .font(.kinnaDisplay(26))
                                .foregroundStyle(.kChar)
                            +
                            Text("planı")
                                .font(.kinnaDisplayItalic(26))
                                .foregroundStyle(.kTerra)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                if !subscriptionManager.hasFullAccess {
                    reminderUpgradeCard
                        .padding(.bottom, 16)
                }

                if isEN {
                    // EN MODE: Manual tracker
                    manualTrackerContent
                } else {
                    // TR MODE: Auto schedule + manual section
                    scheduleContent
                }

                // Disclaimer banner
                HStack(alignment: .top, spacing: 8) {
                    Text("⚕️")
                        .font(.system(size: 12))
                    Text(isEN
                        ? "This is a personal tracker only. Always confirm vaccination schedules with your pediatrician."
                        : "Tarihler tahminidir. Her zaman aile hekiminizle teyit edin.")
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                        .lineSpacing(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.kSage.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.kSage.opacity(0.2), lineWidth: 1)
                )
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddSheet) {
            AddVaccineSheet()
                .presentationDetents([.medium, .large])
                .environment(subscriptionManager)
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
            .environment(subscriptionManager)
        }
        .sheet(isPresented: Binding(
            get: { recordPendingReschedule != nil },
            set: { newValue in
                if !newValue {
                    recordPendingReschedule = nil
                }
            }
        )) {
            NavigationStack {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(recordPendingReschedule?.vaccineName ?? "")
                            .font(.kinnaBodyMedium(16))
                            .foregroundStyle(.kChar)

                        Text(isEN
                             ? "Move this vaccine to a new date instead of removing it from the plan."
                             : "Bu aşıyı plandan silmek yerine yeni bir tarihe taşı.")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    DatePicker(
                        "",
                        selection: $rescheduledDate,
                        in: Date()...Date.distantFuture,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                    Button(isEN ? "Save new date" : "Yeni tarihi kaydet") {
                        saveReschedule()
                    }
                    .font(.kinnaBodyMedium(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.kChar)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(20)
                }
                .background(Color.kCream.ignoresSafeArea())
                .navigationTitle(isEN ? "Reschedule" : "Ertele")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(isEN ? "Cancel" : "Vazgeç") {
                            recordPendingReschedule = nil
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - EN Mode: Manual Tracker

    private var manualTrackerContent: some View {
        VStack(spacing: 0) {
            // Stats
            HStack(spacing: 10) {
                statCard(value: "\(manualRecords.count)", label: "LOGGED", valueColor: .kChar)
                statCard(value: "\(upcomingManual.count)", label: "UPCOMING", valueColor: .kTerra)
            }
            .padding(.bottom, 16)

            // Upcoming reminders
            if !upcomingManual.isEmpty {
                // Next dose hero
                if let next = upcomingManual.first {
                    nextDoseHeroCard(next)
                        .padding(.bottom, 12)
                }

                if upcomingManual.count > 1 {
                    sectionHeader("UPCOMING DOSES")
                    ForEach(upcomingManual.dropFirst()) { record in
                        manualVaccineRow(record)
                    }
                }
            }

            // Completed / logged
            if !completedManual.isEmpty {
                sectionHeader(isEN ? "VACCINATION LOG" : "AŞI KAYDI")
                ForEach(completedManual) { record in
                    manualVaccineRow(record)
                }
            }

            // Empty state
            if manualRecords.isEmpty {
                VStack(spacing: 12) {
                    Text("💉")
                        .font(.system(size: 40))
                    Text("Start logging your baby's vaccinations")
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kMid)
                        .multilineTextAlignment(.center)
                    Text("Keep a record of each vaccine and set reminders for next doses.")
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kLight)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.bottom, 16)
            }

            // Add vaccine button
            addVaccineButton
        }
    }

    // MARK: - TR Mode: Schedule + Manual

    private var scheduleContent: some View {
        VStack(spacing: 0) {
            // Next vaccine hero card
            if let next = nextHeroEntry {
                heroCard(next)
                    .padding(.bottom, 16)
            }

            // Grouped lists
            if !completedRecords.isEmpty {
                sectionHeader("TAMAMLANANLAR")
                ForEach(completedRecords) { record in
                    vaccineRow(record, status: .done)
                }
            }

            if !upcomingRecords.isEmpty {
                sectionHeader("YAKLAŞAN")
                ForEach(upcomingRecords) { record in
                    let isNext = record.id == nextVaccine?.id && nextHeroEntry?.isManualDose != true
                    vaccineRow(record, status: isNext ? .next : .upcoming)
                }
            }

            if !futureRecords.isEmpty {
                sectionHeader("GELECEK")
                ForEach(visibleFutureRecords) { record in
                    vaccineRow(record, status: .future)
                }

                if futureRecords.count > visibleFutureRecords.count {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAllFutureRecords = true
                        }
                    } label: {
                        Text(isEN ? "Show more" : "Daha fazla göster")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kTerra)
                            .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if futureRecords.count > 2 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAllFutureRecords = false
                        }
                    } label: {
                        Text(isEN ? "Show less" : "Daha az göster")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kMid)
                            .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if scheduleRecords.isEmpty {
                VStack(spacing: 12) {
                    Text("💉")
                        .font(.system(size: 40))
                    Text(isEN ? "Add a baby profile to create a vaccine schedule" : "Aşı takvimi oluşturmak için bebek profili ekleyin")
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kMid)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }

            // Manual entries for TR too
            if !manualRecords.isEmpty {
                sectionHeader(isEN ? "MANUAL RECORDS" : "MANUEL KAYITLAR")
                ForEach(manualRecords.sorted { ($0.administeredDate ?? $0.scheduledDate) > ($1.administeredDate ?? $1.scheduledDate) }) { record in
                    manualVaccineRow(record)
                }
            }

            // Add vaccine button
            addVaccineButton
                .padding(.top, 12)
        }
    }

    // MARK: - Add Vaccine Button

    private var addVaccineButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Text(isEN ? "+ Log a vaccine" : "+ Aşı kaydı ekle")
                .font(.kinnaBody(13))
                .foregroundStyle(.kChar)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.kWarm.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.kPale.opacity(0.9), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                )
        }
        .padding(.top, 8)
    }

    private var reminderUpgradeCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 12))
                .foregroundStyle(.kTerra)

            Text(isEN
                 ? "Vaccine reminders are part of Kinna Premium. Free can log vaccines, Premium can schedule next-dose reminders."
                 : "Aşı hatırlatıcıları Kinna Premium'a dahildir. Ücretsiz planda aşı kaydı tutulur, Premium'da sonraki doz hatırlatıcısı eklenir.")
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
                .lineSpacing(2)

            Spacer(minLength: 8)

            Button(isEN ? "Premium" : "Premium") {
                showPaywall = true
            }
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kTerra)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Stat Card

    private func statCard(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.kinnaDisplay(28, weight: .light))
                .foregroundStyle(valueColor)

            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Next Dose Hero (EN)

    private func nextDoseHeroCard(_ record: VaccinationRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NEXT DOSE")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1.5)

            Text(displayName(record))
                .font(.kinnaDisplay(20))
                .foregroundStyle(.white)

            if let nextDose = record.nextDoseDate {
                Text(nextDose, format: .dateTime.day().month(.wide).year())
                    .font(.kinnaBody(12))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Text(isEN ? "📍 Book appointment" : "📍 Randevu al")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.kSageDark)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Manual Vaccine Row

    private func manualVaccineRow(_ record: VaccinationRecord) -> some View {
        HStack(spacing: 12) {
            // Status badge
            RoundedRectangle(cornerRadius: 10)
                .fill(record.nextDoseDate != nil && (record.nextDoseDate ?? .distantPast) > .now
                      ? Color.kTerraLight : Color.kSageLight)
                .frame(width: 28, height: 28)
                .overlay {
                    if record.nextDoseDate != nil && (record.nextDoseDate ?? .distantPast) > .now {
                        Text("→")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.kTerra)
                    } else {
                        Text("✓")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(record.vaccineName)
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)

                HStack(spacing: 4) {
                    if let administered = record.administeredDate {
                        Text(administered, format: .dateTime.day().month(.abbreviated).year())
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kLight)
                    }
                    if let doctorName = record.doctorName, !doctorName.isEmpty {
                        Text("·")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kPale)
                        Text(doctorName)
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kLight)
                    }
                }
            }

            Spacer()

            // Next dose indicator
            if let nextDose = record.nextDoseDate, nextDose > .now {
                VStack(alignment: .trailing, spacing: 1) {
                    Text(isEN ? "Next" : "Sonraki")
                        .font(.kinnaBody(8))
                        .foregroundStyle(.kMuted)
                    Text(nextDose, format: .dateTime.day().month(.abbreviated))
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kTerra)
                }
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.kPale)
                .frame(height: 1)
        }
    }

    // MARK: - Schedule Hero Card (TR)

    private func heroCard(_ entry: (name: String, date: Date, isManualDose: Bool)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isEN ? (entry.isManualDose ? "NEXT DOSE" : "NEXT VACCINE") : (entry.isManualDose ? "SIRADAKİ DOZ" : "SIRADAKİ AŞI"))
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1.5)

            Text(entry.name)
                .font(.kinnaDisplay(20))
                .foregroundStyle(.white)

            Text(entry.date, format: .dateTime.day().month(.wide).year())
                .font(.kinnaBody(12))
                .foregroundStyle(.white.opacity(0.7))

            Text(isEN ? (entry.isManualDose ? "📍 Schedule next dose" : "📍 Book appointment") : (entry.isManualDose ? "📍 Sonraki dozu planla" : "📍 Randevu al"))
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.kSageDark)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    // MARK: - Schedule Vaccine Row (TR)

    private enum VaccineStatus {
        case done, next, upcoming, future
    }

    private func vaccineRow(_ record: VaccinationRecord, status: VaccineStatus) -> some View {
        HStack(spacing: 12) {
            // Toggle button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    record.isCompleted.toggle()
                    record.administeredDate = record.isCompleted ? .now : nil
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(statusBadgeBg(status))
                    .frame(width: 28, height: 28)
                    .overlay {
                        switch status {
                        case .done:
                            Text("✓")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        case .next, .upcoming, .future:
                            Text("→")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.kTerra)
                        }
                    }
            }

            // Name
            Text(displayName(record))
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(record.isCompleted ? .kLight : .kChar)
                .strikethrough(record.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Date
            Text(record.scheduledDate, format: .dateTime.month(.abbreviated).year())
                .font(.kinnaBody(11))
                .foregroundStyle(.kLight)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.kPale)
                .frame(height: 1)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if status != .done {
                Button {
                    startRescheduling(record)
                } label: {
                    Label(isEN ? "Reschedule" : "Ertele", systemImage: "calendar.badge.clock")
                }
                .tint(.kTerra)
            }
        }
        .contextMenu {
            if status != .done {
                Button {
                    startRescheduling(record)
                } label: {
                    Label(isEN ? "Reschedule" : "Ertele", systemImage: "calendar.badge.clock")
                }
            }
        }
    }

    private func statusBadgeBg(_ status: VaccineStatus) -> Color {
        switch status {
        case .done: .kSageLight
        case .next, .upcoming, .future: .kTerraLight
        }
    }

    private func startRescheduling(_ record: VaccinationRecord) {
        rescheduledDate = max(record.scheduledDate, Calendar.current.startOfDay(for: .now))
        recordPendingReschedule = record
    }

    private func saveReschedule() {
        guard let record = recordPendingReschedule else { return }

        record.scheduledDate = rescheduledDate
        recordPendingReschedule = nil

        Task {
            await NotificationManager.shared.syncVaccineReminders(
                birthDate: baby?.birthDate,
                scheduledRecords: scheduleRecords,
                hasFullAccess: subscriptionManager.hasFullAccess
            )
        }
    }
}

// MARK: - Add Vaccine Sheet

struct AddVaccineSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var vaccineName = ""
    @State private var administeredDate = Date()
    @State private var hasNextDose = false
    @State private var nextDoseDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var doctorName = ""
    @State private var lotNumber = ""
    @State private var note = ""
    @State private var showPaywall = false
    @State private var activeDatePicker: ActiveDatePicker?

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }
    private var canUseReminder: Bool { MonetizationPolicy.canUseVaccineReminders(hasFullAccess: subscriptionManager.hasFullAccess) }
    private var placeholderColor: Color { .kMid.opacity(0.8) }

    private enum ActiveDatePicker: Identifiable {
        case administered
        case nextDose

        var id: Int {
            switch self {
            case .administered: return 0
            case .nextDose: return 1
            }
        }
    }

    private let commonVaccines: [(en: String, tr: String)] = [
        ("Hepatitis B", "Hepatit B"),
        ("BCG", "BCG"),
        ("DTaP / Whooping Cough", "DTaP / Boğmaca"),
        ("IPV / Polio", "IPV / Polio"),
        ("Hib", "Hib"),
        ("PCV / Pneumococcal", "KPA / Pnömokok"),
        ("Rotavirus", "Rotavirüs"),
        ("MMR / Measles", "KKK / Kızamık"),
        ("Varicella / Chickenpox", "Suçiçeği"),
        ("Hepatitis A", "Hepatit A"),
        ("Influenza / Flu", "İnfluenza / Grip"),
        ("HPV", "HPV"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Vaccine name
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "VACCINE NAME" : "AŞI ADI")
                        TextField(
                            "",
                            text: $vaccineName,
                            prompt: Text(isEN ? "e.g., DTaP 2nd dose" : "örnek: DTaP 2. doz")
                                .foregroundStyle(placeholderColor)
                        )
                            .font(.kinnaBody(14))
                            .foregroundColor(.kChar)
                            .tint(.kTerra)
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )
                    }

                    // Quick picks
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel(isEN ? "COMMON VACCINES" : "SIK KULLANILAN AŞILAR")
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(commonVaccines, id: \.en) { vaccine in
                                let name = isEN ? vaccine.en : vaccine.tr
                                Button {
                                    vaccineName = name
                                } label: {
                                    Text(name)
                                        .font(.kinnaBody(11))
                                        .foregroundStyle(vaccineName == name ? .kTerra : .kMid)
                                        .fontWeight(vaccineName == name ? .medium : .regular)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(vaccineName == name ? Color.kTerraLight.opacity(0.5) : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(vaccineName == name ? Color.kTerra : Color.kPale, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    // Administered date
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "DATE ADMINISTERED" : "YAPILDIĞI TARİH")
                        Button {
                            activeDatePicker = .administered
                        } label: {
                            HStack {
                                Text(administeredDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.kinnaBody(14))
                                    .foregroundStyle(.kChar)
                                Spacer()
                                Image(systemName: "calendar")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.kTerra)
                            }
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Next dose toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            handleReminderToggle()
                        } label: {
                            HStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(canUseReminder ? .kTerra : .kLight)
                                    Text(isEN ? "Set next dose reminder" : "Sonraki doz hatırlatıcısı")
                                        .font(.kinnaBody(13))
                                        .foregroundStyle(canUseReminder ? .kChar : .kMid)
                                }

                                Spacer()

                                reminderToggle
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if hasNextDose {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(isEN ? "Next dose date" : "Sonraki doz tarihi")
                                    .font(.kinnaBody(12))
                                    .foregroundStyle(.kMid)

                                Button {
                                    activeDatePicker = .nextDose
                                } label: {
                                    HStack {
                                        Text(nextDoseDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.kinnaBody(14))
                                            .foregroundStyle(.kChar)
                                        Spacer()
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(.kTerra)
                                    }
                                    .padding(12)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.kPale, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        } else if !canUseReminder {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(isEN
                                         ? "Unlock reminders with Kinna Premium"
                                         : "Hatırlatıcıları Kinna Premium ile aç")
                                        .font(.kinnaBodyMedium(11))
                                }
                                .foregroundStyle(.kTerra)
                            }
                        }
                    }

                    // Doctor name (optional)
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "DOCTOR (OPTIONAL)" : "DOKTOR (OPSİYONEL)")
                        TextField(
                            "",
                            text: $doctorName,
                            prompt: Text("Dr. Seven")
                                .foregroundStyle(placeholderColor)
                        )
                            .font(.kinnaBody(14))
                            .foregroundColor(.kChar)
                            .tint(.kTerra)
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )
                    }

                    // Note (optional)
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "NOTE (OPTIONAL)" : "NOT (OPSİYONEL)")
                        TextField(
                            "",
                            text: $note,
                            prompt: Text(isEN ? "Any reactions, lot number, etc." : "Reaksiyon, lot numarası vb.")
                                .foregroundStyle(placeholderColor)
                        )
                            .font(.kinnaBody(14))
                            .foregroundColor(.kChar)
                            .tint(.kTerra)
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color.kCream.ignoresSafeArea())
            .navigationTitle(isEN ? "Log Vaccine" : "Aşı Kaydı")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                NavigationStack {
                    PaywallView()
                }
                .environment(subscriptionManager)
            }
            .sheet(item: $activeDatePicker) { picker in
                NavigationStack {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            DatePicker(
                                "",
                                selection: dateBinding(for: picker),
                                in: dateRange(for: picker),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        Button(isEN ? "Done" : "Tamam") {
                            activeDatePicker = nil
                        }
                        .font(.kinnaBodyMedium(14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.kChar)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(20)
                    }
                    .background(Color.kCream.ignoresSafeArea())
                    .navigationTitle(datePickerTitle(for: picker))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(isEN ? "Done" : "Tamam") {
                                activeDatePicker = nil
                            }
                        }
                    }
                }
                .preferredColorScheme(.light)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEN ? "Cancel" : "Vazgeç") { dismiss() }
                        .foregroundStyle(.kMid)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEN ? "Save" : "Kaydet") { saveVaccine() }
                        .fontWeight(.semibold)
                        .foregroundStyle(.kTerra)
                        .disabled(vaccineName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveVaccine() {
        let name = vaccineName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let record = VaccinationRecord(
            vaccineName: name,
            administeredDate: administeredDate,
            nextDoseDate: hasNextDose ? nextDoseDate : nil,
            note: note.trimmingCharacters(in: .whitespaces),
            doctorName: doctorName.trimmingCharacters(in: .whitespaces),
            lotNumber: lotNumber.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(record)

        // Schedule reminder for next dose
        if hasNextDose && canUseReminder {
            NotificationManager.shared.scheduleVaccinationReminder(
                vaccineName: name,
                date: nextDoseDate
            )
        }

        dismiss()
    }

    private func handleReminderToggle() {
        guard !hasNextDose else {
            hasNextDose = false
            return
        }

        guard canUseReminder else {
            showPaywall = true
            return
        }

        hasNextDose = true
    }

    private func dateBinding(for picker: ActiveDatePicker) -> Binding<Date> {
        switch picker {
        case .administered:
            return $administeredDate
        case .nextDose:
            return $nextDoseDate
        }
    }

    private func dateRange(for picker: ActiveDatePicker) -> ClosedRange<Date> {
        switch picker {
        case .administered:
            return Date.distantPast...Date()
        case .nextDose:
            return Date()...Date.distantFuture
        }
    }

    private func datePickerTitle(for picker: ActiveDatePicker) -> String {
        switch picker {
        case .administered:
            return isEN ? "Date administered" : "Yapıldığı tarih"
        case .nextDose:
            return isEN ? "Next dose date" : "Sonraki doz tarihi"
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1)
    }

    private var reminderToggle: some View {
        ZStack(alignment: hasNextDose ? .trailing : .leading) {
            Capsule()
                .fill(toggleTrackColor)
                .overlay(
                    Capsule()
                        .stroke(toggleBorderColor, lineWidth: 1)
                )

            Circle()
                .fill(.white)
                .frame(width: 26, height: 26)
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                .padding(3)
        }
        .frame(width: 54, height: 32)
        .animation(.easeInOut(duration: 0.18), value: hasNextDose)
        .accessibilityHidden(true)
    }

    private var toggleTrackColor: Color {
        if hasNextDose { return .kSage }
        return canUseReminder ? .kPale : .kTerraPale
    }

    private var toggleBorderColor: Color {
        if hasNextDose { return .kSage }
        return canUseReminder ? .kMuted.opacity(0.35) : .kTerraLight
    }
}

#Preview {
    NavigationStack {
        VaccinationView()
    }
    .modelContainer(for: [VaccinationRecord.self, Baby.self], inMemory: true)
    .environment(SubscriptionManager.shared)
}
