import SwiftUI
import SwiftData

struct VaccinationView: View {
    @Query(sort: \VaccinationRecord.scheduledDate) private var records: [VaccinationRecord]
    @Query private var babies: [Baby]

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var completedRecords: [VaccinationRecord] {
        records.filter { $0.isCompleted }
    }

    private var upcomingRecords: [VaccinationRecord] {
        records.filter { !$0.isCompleted && $0.scheduledDate <= Calendar.current.date(byAdding: .month, value: 2, to: .now)! }
    }

    private var futureRecords: [VaccinationRecord] {
        records.filter { !$0.isCompleted && $0.scheduledDate > Calendar.current.date(byAdding: .month, value: 2, to: .now)! }
    }

    private var nextVaccine: VaccinationRecord? {
        records.first { !$0.isCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "MINISTRY OF HEALTH PROTOCOL" : "T.C. SAĞLIK BAKANLIĞI PROTOKOLÜ")
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    (
                        Text(isEN ? "Vaccine " : "Aşı ")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text(isEN ? "schedule" : "planı")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Next vaccine hero card
                if let next = nextVaccine {
                    heroCard(next)
                        .padding(.bottom, 16)
                }

                // Grouped lists
                if !completedRecords.isEmpty {
                    sectionHeader(isEN ? "COMPLETED" : "TAMAMLANANLAR")
                    ForEach(completedRecords) { record in
                        vaccineRow(record, status: .done)
                    }
                }

                if !upcomingRecords.isEmpty {
                    sectionHeader(isEN ? "UPCOMING" : "YAKLAŞAN")
                    ForEach(upcomingRecords) { record in
                        let isNext = record.id == nextVaccine?.id
                        vaccineRow(record, status: isNext ? .next : .upcoming)
                    }
                }

                if !futureRecords.isEmpty {
                    sectionHeader(isEN ? "FUTURE" : "GELECEK")
                    ForEach(futureRecords) { record in
                        vaccineRow(record, status: .future)
                    }
                }

                if records.isEmpty {
                    VStack(spacing: 12) {
                        Text("💉")
                            .font(.system(size: 40))
                        Text(isEN ? "Add baby profile to generate vaccination schedule" : "Aşı takvimi oluşturmak için bebek profili ekleyin")
                            .font(.kinnaBody(14))
                            .foregroundStyle(.kMid)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero Card

    private func heroCard(_ record: VaccinationRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isEN ? "NEXT VACCINE" : "SIRADAKİ AŞI")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1.5)

            Text(record.vaccineName)
                .font(.kinnaDisplay(20))
                .foregroundStyle(.white)

            Text(record.scheduledDate, format: .dateTime.day().month(.wide).year())
                .font(.kinnaBody(12))
                .foregroundStyle(.white.opacity(0.7))

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

    // MARK: - Vaccine Row

    private enum VaccineStatus {
        case done, next, upcoming, future
    }

    private func vaccineRow(_ record: VaccinationRecord, status: VaccineStatus) -> some View {
        HStack(spacing: 12) {
            // Status badge
            RoundedRectangle(cornerRadius: 10)
                .fill(statusBadgeBg(status))
                .frame(width: 28, height: 28)
                .overlay {
                    switch status {
                    case .done:
                        Text("✓")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    case .next:
                        Text("→")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.kTerra)
                    case .upcoming:
                        Text("→")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.kTerra)
                    case .future:
                        EmptyView()
                    }
                }

            // Name
            Text(record.vaccineName)
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kChar)
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

#Preview {
    NavigationStack {
        VaccinationView()
    }
    .modelContainer(for: [VaccinationRecord.self, Baby.self], inMemory: true)
}
