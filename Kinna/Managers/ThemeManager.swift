import SwiftUI

// MARK: - Kinna Color Palette (Sonnet v3)

extension Color {
    // Background
    static let kCream = Color(hex: 0xFAF7F2)
    static let kBlush = Color(hex: 0xF2E8DF)
    static let kWarm = Color(hex: 0xFFFDF9)

    // Primary — Terracotta
    static let kTerra = Color(hex: 0xC4785A)
    static let kTerraLight = Color(hex: 0xE8C4B0)
    static let kTerraPale = Color(hex: 0xF7EDE6)

    // Secondary — Sage
    static let kSage = Color(hex: 0x7A9E8E)
    static let kSageDark = Color(hex: 0x4A7A68)
    static let kSageLight = Color(hex: 0xB8D4C8)

    // Text
    static let kChar = Color(hex: 0x2C2C2C)
    static let kMid = Color(hex: 0x6B6560)
    static let kMuted = Color(hex: 0x9E9590)
    static let kLight = Color(hex: 0xA09890)
    static let kPale = Color(hex: 0xEDE8E2)

    // MARK: - Hex Initializer

    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - ShapeStyle Convenience (enables .kTerra in .foregroundStyle etc.)

extension ShapeStyle where Self == Color {
    static var kCream: Color { Color(hex: 0xFAF7F2) }
    static var kBlush: Color { Color(hex: 0xF2E8DF) }
    static var kWarm: Color { Color(hex: 0xFFFDF9) }

    static var kTerra: Color { Color(hex: 0xC4785A) }
    static var kTerraLight: Color { Color(hex: 0xE8C4B0) }
    static var kTerraPale: Color { Color(hex: 0xF7EDE6) }

    static var kSage: Color { Color(hex: 0x7A9E8E) }
    static var kSageDark: Color { Color(hex: 0x4A7A68) }
    static var kSageLight: Color { Color(hex: 0xB8D4C8) }

    static var kChar: Color { Color(hex: 0x2C2C2C) }
    static var kMid: Color { Color(hex: 0x6B6560) }
    static var kMuted: Color { Color(hex: 0x9E9590) }
    static var kLight: Color { Color(hex: 0xA09890) }
    static var kPale: Color { Color(hex: 0xEDE8E2) }
}

// MARK: - Font Helpers

extension Font {
    /// Display font — Fraunces variable
    static func kinnaDisplay(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Fraunces", size: size, relativeTo: .title)
            .weight(weight)
    }

    /// Display font — Fraunces italic
    static func kinnaDisplayItalic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Fraunces", size: size, relativeTo: .title)
            .weight(weight)
            .italic()
    }

    /// Body font — DM Sans variable
    static func kinnaBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: size, relativeTo: .body)
            .weight(weight)
    }

    /// Body font medium
    static func kinnaBodyMedium(_ size: CGFloat) -> Font {
        .custom("DM Sans", size: size, relativeTo: .body)
            .weight(.medium)
    }
}

// MARK: - Reusable Sheet Header

/// Custom sheet header that replaces NavigationStack toolbar to avoid UIKit rendering delay.
func sheetHeader(
    title: String,
    cancelLabel: String,
    saveLabel: String,
    onCancel: @escaping () -> Void,
    onSave: @escaping () -> Void,
    saveDisabled: Bool = false
) -> some View {
    HStack {
        Button(cancelLabel, action: onCancel)
            .font(.kinnaBody(15))
            .foregroundStyle(.kMid)
        Spacer()
        Text(title)
            .font(.kinnaBodyMedium(16))
            .foregroundStyle(.kChar)
        Spacer()
        Button(saveLabel, action: onSave)
            .font(.kinnaBodyMedium(15))
            .foregroundStyle(.kTerra)
            .opacity(saveDisabled ? 0.4 : 1)
            .disabled(saveDisabled)
    }
    .padding(.horizontal, 20)
    .padding(.top, 18)
    .padding(.bottom, 12)
}
