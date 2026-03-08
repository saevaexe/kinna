import SwiftUI
import SwiftData

struct VaccinationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VaccinationRecord.scheduledDate) private var records: [VaccinationRecord]
    @Query private var babies: [Baby]
    @State private var showAddSheet = false

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    // TR mode: auto-generated schedule records
    private var scheduleRecords: [VaccinationRecord] {
        records.filter { !$0.isManual }
    }

    // Manual entries (both TR and EN users can add these)
    private var manualRecords: [VaccinationRecord] {
        records.filter { $0.isManual }
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

    private var nextVaccine: VaccinationRecord? {
        scheduleRecords.first { !$0.isCompleted }
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
            if let next = nextVaccine {
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
                    let isNext = record.id == nextVaccine?.id
                    vaccineRow(record, status: isNext ? .next : .upcoming)
                }
            }

            if !futureRecords.isEmpty {
                sectionHeader("GELECEK")
                ForEach(futureRecords) { record in
                    vaccineRow(record, status: .future)
                }
            }

            if scheduleRecords.isEmpty {
                VStack(spacing: 12) {
                    Text("💉")
                        .font(.system(size: 40))
                    Text("Aşı takvimi oluşturmak için bebek profili ekleyin")
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kMid)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }

            // Manual entries for TR too
            if !manualRecords.isEmpty {
                sectionHeader("MANUEL KAYITLAR")
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
                .foregroundStyle(.kLight)
                .frame(maxWidth: .infinity)
                .padding(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.kPale, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                )
        }
        .padding(.top, 8)
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

            Text(record.vaccineName)
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
                    if !record.doctorName.isEmpty {
                        Text("·")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kPale)
                        Text(record.doctorName)
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

    private func heroCard(_ record: VaccinationRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SIRADAKİ AŞI")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1.5)

            Text(record.vaccineName)
                .font(.kinnaDisplay(20))
                .foregroundStyle(.white)

            Text(record.scheduledDate, format: .dateTime.day().month(.wide).year())
                .font(.kinnaBody(12))
                .foregroundStyle(.white.opacity(0.7))

            Text("📍 Randevu al")
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
                        case .next, .upcoming:
                            Text("→")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.kTerra)
                        case .future:
                            EmptyView()
                        }
                    }
            }

            // Name
            Text(record.vaccineName)
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
    }

    private func statusBadgeBg(_ status: VaccineStatus) -> Color {
        switch status {
        case .done: .kSageLight
        case .next, .upcoming: .kTerraLight
        case .future: .kPale
        }
    }
}

// MARK: - Add Vaccine Sheet

struct AddVaccineSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var vaccineName = ""
    @State private var administeredDate = Date()
    @State private var hasNextDose = false
    @State private var nextDoseDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var doctorName = ""
    @State private var lotNumber = ""
    @State private var note = ""

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

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
                        TextField(isEN ? "e.g., DTaP 2nd dose" : "örnek: DTaP 2. doz", text: $vaccineName)
                            .font(.kinnaBody(14))
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
                        DatePicker("", selection: $administeredDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Next dose toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $hasNextDose) {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.kTerra)
                                Text(isEN ? "Set next dose reminder" : "Sonraki doz hatırlatıcısı")
                                    .font(.kinnaBody(13))
                                    .foregroundStyle(.kChar)
                            }
                        }
                        .tint(.kSage)

                        if hasNextDose {
                            DatePicker(
                                isEN ? "Next dose date" : "Sonraki doz tarihi",
                                selection: $nextDoseDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .font(.kinnaBody(13))
                            .foregroundStyle(.kChar)
                        }
                    }

                    // Doctor name (optional)
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "DOCTOR (OPTIONAL)" : "DOKTOR (OPSİYONEL)")
                        TextField(isEN ? "Dr. Smith" : "Dr. Yılmaz", text: $doctorName)
                            .font(.kinnaBody(14))
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
                        TextField(isEN ? "Any reactions, lot number, etc." : "Reaksiyon, lot numarası vb.", text: $note)
                            .font(.kinnaBody(14))
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
        if hasNextDose {
            NotificationManager.shared.scheduleVaccinationReminder(
                vaccineName: name,
                date: nextDoseDate
            )
        }

        dismiss()
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1)
    }
}

#Preview {
    NavigationStack {
        VaccinationView()
    }
    .modelContainer(for: [VaccinationRecord.self, Baby.self], inMemory: true)
}
