import SwiftUI
import SwiftData

struct TimerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \DailyLog.createdAt, order: .reverse) private var logs: [DailyLog]

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    enum Mode {
        case feeding
        case sleep
    }

    let mode: Mode

    // Feeding state
    @State private var feedingType: DailyLog.FeedingType = .breast
    @State private var breastSide: DailyLog.BreastSide = .left
    @State private var bottleAmountText = ""

    // Manual entry fallback
    @State private var showManualEntry = false
    @State private var manualType: DailyLog.LogType = .feeding

    private var babyID: UUID? { babies.first?.id }

    private var hasActiveTimer: Bool {
        let type: DailyLog.LogType = mode == .feeding ? .feeding : .sleep
        return ActiveTimerEngine.activeTimer(ofType: type, in: logs) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHandle

            switch mode {
            case .feeding:
                feedingContent
            case .sleep:
                sleepContent
            }
        }
        .background(Color.kCream.ignoresSafeArea())
        .sheet(isPresented: $showManualEntry) {
            AddLogSheet(initialType: manualType)
                .presentationDetents([.medium])
                .presentationBackground(Color.kCream)
        }
    }

    // MARK: - Sheet Handle

    private var sheetHandle: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.kPale)
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            Text(mode == .feeding
                 ? (isEN ? "Feeding" : "Beslenme")
                 : (isEN ? "Sleep" : "Uyku"))
                .font(.kinnaDisplayItalic(22))
                .foregroundStyle(.kChar)
                .padding(.bottom, 20)
        }
    }

    // MARK: - Feeding Content

    private var feedingContent: some View {
        VStack(spacing: 20) {
            // Feeding type selector
            HStack(spacing: 8) {
                feedingTypeButton(isEN ? "Breast milk" : "Anne sütü", type: .breast, emoji: "🤱")
                feedingTypeButton(isEN ? "Bottle" : "Biberon", type: .bottle, emoji: "🍼")
                feedingTypeButton(isEN ? "Solid food" : "Ek gıda", type: .solid, emoji: "🥣")
            }
            .padding(.horizontal, 24)

            // Type-specific content
            switch feedingType {
            case .breast:
                breastContent
            case .bottle:
                bottleContent
            case .solid:
                solidContent
            }

            manualEntryLink

            Spacer()
        }
    }

    // MARK: - Breast Content

    private var breastContent: some View {
        VStack(spacing: 16) {
            Text(isEN ? "Which side?" : "Hangi taraf?")
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kMid)

            HStack(spacing: 12) {
                breastSideButton(isEN ? "Left" : "Sol", side: .left)
                breastSideButton(isEN ? "Right" : "Sağ", side: .right)
            }
            .padding(.horizontal, 24)

            if let lastSide = lastBreastSide {
                Text(isEN
                     ? "Last feed was on the \(lastSide == .left ? "left" : "right") side"
                     : "Son emzirme \(lastSide == .left ? "sol" : "sağ") taraftaydı")
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kSageDark)
            }

            startButton {
                ActiveTimerEngine.startTimer(
                    type: .feeding,
                    feedingType: .breast,
                    breastSide: breastSide,
                    babyID: babyID,
                    context: modelContext
                )
                dismiss()
            }
        }
    }

    // MARK: - Bottle Content

    private var bottleContent: some View {
        VStack(spacing: 16) {
            Text(isEN ? "Amount (ml)" : "Miktar (ml)")
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kMid)

            TextField(
                "",
                text: $bottleAmountText,
                prompt: Text("ml")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kMid.opacity(0.5))
            )
            .font(.kinnaDisplay(28))
            .foregroundStyle(.kChar)
            .tint(.kTerra)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 120)
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.kPale, lineWidth: 1.5)
            )
            .padding(.horizontal, 24)

            Button {
                saveBottleLog()
                dismiss()
            } label: {
                Text(isEN ? "Save" : "Kaydet")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .disabled(parsedBottleAmount == nil)
            .opacity(parsedBottleAmount == nil ? 0.5 : 1)
        }
    }

    // MARK: - Solid Content

    private var solidContent: some View {
        VStack(spacing: 16) {
            Text(isEN ? "Log solid food feeding" : "Ek gıda kaydı ekle")
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kMid)

            Button {
                saveSolidLog()
                dismiss()
            } label: {
                Text(isEN ? "Save" : "Kaydet")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Sleep Content

    private var sleepContent: some View {
        VStack(spacing: 20) {
            Text("😴")
                .font(.system(size: 48))

            Text(isEN
                 ? "Start tracking sleep"
                 : "Uyku takibini başlat")
                .font(.kinnaBodyMedium(14))
                .foregroundStyle(.kMid)

            if hasActiveTimer {
                Text(isEN
                     ? "A sleep timer is already running."
                     : "Bir uyku zamanlayıcısı zaten çalışıyor.")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kTerraLight)
            }

            startButton {
                ActiveTimerEngine.startTimer(
                    type: .sleep,
                    babyID: babyID,
                    context: modelContext
                )
                dismiss()
            }

            manualEntryLink

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Components

    private func startButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                Text(isEN ? "Start" : "Başlat")
                    .font(.kinnaBodyMedium(15))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.kSageDark)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
        .disabled(hasActiveTimer && mode == .sleep)
        .opacity(hasActiveTimer && mode == .sleep ? 0.5 : 1)
    }

    private var manualEntryLink: some View {
        Button {
            manualType = mode == .feeding ? .feeding : .sleep
            showManualEntry = true
        } label: {
            Text(isEN ? "or add manual entry" : "veya manuel kayıt ekle")
                .font(.kinnaBody(12))
                .foregroundStyle(.kLight)
                .underline()
        }
        .padding(.top, 4)
    }

    private func feedingTypeButton(_ title: String, type: DailyLog.FeedingType, emoji: String) -> some View {
        let isSelected = feedingType == type
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { feedingType = type }
        } label: {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 22))
                Text(title)
                    .font(.kinnaBody(11))
                    .fontWeight(isSelected ? .medium : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.kTerraLight.opacity(0.5) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
        .foregroundStyle(isSelected ? .kTerra : .kMid)
    }

    private func breastSideButton(_ title: String, side: DailyLog.BreastSide) -> some View {
        let isSelected = breastSide == side
        return Button {
            breastSide = side
        } label: {
            Text(title)
                .font(.kinnaBodyMedium(15))
                .foregroundStyle(isSelected ? .white : .kMid)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(isSelected ? Color.kSage : .white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.kSage : Color.kPale, lineWidth: 1.5)
                )
        }
    }

    // MARK: - Helpers

    private var lastBreastSide: DailyLog.BreastSide? {
        logs
            .first { $0.type == .feeding && $0.feedingType == .breast && $0.breastSide != nil }?
            .breastSide
    }

    private var parsedBottleAmount: Double? {
        let normalized = bottleAmountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }

    private func saveBottleLog() {
        let log = DailyLog(date: .now, type: .feeding, babyID: babyID)
        log.feedingType = .bottle
        log.feedingAmountML = parsedBottleAmount
        modelContext.insert(log)
    }

    private func saveSolidLog() {
        let log = DailyLog(date: .now, type: .feeding, babyID: babyID)
        log.feedingType = .solid
        modelContext.insert(log)
    }
}
