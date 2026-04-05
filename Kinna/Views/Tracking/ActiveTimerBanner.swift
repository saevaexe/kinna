import SwiftUI
import SwiftData

struct ActiveTimerBanner: View {
    let activeTimers: [DailyLog]
    let onStop: (DailyLog) -> Void
    let onCancel: (DailyLog) -> Void

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    var body: some View {
        if !activeTimers.isEmpty {
            VStack(spacing: 8) {
                ForEach(activeTimers) { timer in
                    timerRow(timer)
                }
            }
            .padding(.bottom, 12)
        }
    }

    private func timerRow(_ timer: DailyLog) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let elapsed = ActiveTimerEngine.elapsed(for: timer, referenceDate: context.date)

            HStack(spacing: 12) {
                // Icon
                Text(timerEmoji(timer))
                    .font(.system(size: 20))

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(timerLabel(timer))
                        .font(.kinnaBodyMedium(12))
                        .foregroundStyle(.kChar)

                    Text(timerSubtitle(timer))
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                }

                Spacer()

                // Elapsed time
                Text(ActiveTimerEngine.formattedElapsed(elapsed))
                    .font(.kinnaDisplay(20))
                    .foregroundStyle(.kChar)
                    .monospacedDigit()

                // Stop button
                Button {
                    onStop(timer)
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.kTerra)
                        .clipShape(Circle())
                }

                // Cancel button
                Button {
                    onCancel(timer)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.kLight)
                        .frame(width: 28, height: 28)
                        .background(Color.kPale)
                        .clipShape(Circle())
                }
            }
            .padding(14)
            .background(timerBackground(timer))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(timerBorderColor(timer), lineWidth: 1.5)
            )
        }
    }

    // MARK: - Display Helpers

    private func timerEmoji(_ timer: DailyLog) -> String {
        switch timer.type {
        case .feeding: "🤱"
        case .sleep: "😴"
        default: "⏱️"
        }
    }

    private func timerLabel(_ timer: DailyLog) -> String {
        switch timer.type {
        case .feeding:
            if timer.feedingType == .breast {
                if let side = timer.breastSide {
                    let sideText = side == .left
                        ? (isEN ? "Left" : "Sol")
                        : (isEN ? "Right" : "Sağ")
                    return isEN ? "Breastfeeding (\(sideText))" : "Emzirme (\(sideText))"
                }
                return isEN ? "Breastfeeding" : "Emzirme"
            }
            return isEN ? "Feeding" : "Beslenme"
        case .sleep:
            return isEN ? "Sleep" : "Uyku"
        default:
            return isEN ? "Timer" : "Zamanlayıcı"
        }
    }

    private func timerSubtitle(_ timer: DailyLog) -> String {
        let startTime = timer.timerStartDate?.formatted(date: .omitted, time: .shortened) ?? ""
        return isEN ? "Started at \(startTime)" : "\(startTime) başladı"
    }

    private func timerBackground(_ timer: DailyLog) -> Color {
        switch timer.type {
        case .feeding: Color.kSage.opacity(0.08)
        case .sleep: Color(hex: 0x8BA7C7).opacity(0.08)
        default: .white
        }
    }

    private func timerBorderColor(_ timer: DailyLog) -> Color {
        switch timer.type {
        case .feeding: Color.kSage.opacity(0.3)
        case .sleep: Color(hex: 0x8BA7C7).opacity(0.3)
        default: Color.kPale
        }
    }
}
