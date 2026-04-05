import SwiftUI
import SwiftData

struct EditBabyProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var baby: Baby

    @State private var name: String
    @State private var birthDate: Date
    @State private var gender: Baby.Gender

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    init(baby: Baby) {
        self.baby = baby
        _name = State(initialValue: baby.name)
        _birthDate = State(initialValue: baby.birthDate)
        _gender = State(initialValue: baby.gender)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.kPale)
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            Text(isEN ? "Edit Profile" : "Profili Düzenle")
                .font(.kinnaDisplayItalic(22))
                .foregroundStyle(.kChar)
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text(isEN ? "Baby's Name" : "Bebeğin Adı")
                        .font(.kinnaBodyMedium(12))
                        .foregroundStyle(.kMid)

                    TextField("", text: $name)
                        .font(.kinnaBody(15))
                        .foregroundStyle(.kChar)
                        .tint(.kTerra)
                        .padding(14)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.kPale, lineWidth: 1.5)
                        )
                }

                // Birth date
                VStack(alignment: .leading, spacing: 6) {
                    Text(isEN ? "Date of Birth" : "Doğum Tarihi")
                        .font(.kinnaBodyMedium(12))
                        .foregroundStyle(.kMid)

                    DatePicker(
                        "",
                        selection: $birthDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(.kTerra)
                }

                // Gender
                VStack(alignment: .leading, spacing: 6) {
                    Text(isEN ? "Gender" : "Cinsiyet")
                        .font(.kinnaBodyMedium(12))
                        .foregroundStyle(.kMid)

                    HStack(spacing: 8) {
                        genderButton(isEN ? "Boy" : "Erkek", value: .male, emoji: "👦")
                        genderButton(isEN ? "Girl" : "Kız", value: .female, emoji: "👧")
                        genderButton(isEN ? "Other" : "Diğer", value: .other, emoji: "👶")
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Save button
            Button {
                save()
                dismiss()
            } label: {
                Text(isEN ? "Save" : "Kaydet")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.kPale : Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }

    private func genderButton(_ title: String, value: Baby.Gender, emoji: String) -> some View {
        let isSelected = gender == value
        return Button { gender = value } label: {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 20))
                Text(title)
                    .font(.kinnaBody(11))
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.kTerraLight.opacity(0.5) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
        .foregroundStyle(isSelected ? .kTerra : .kMid)
    }

    private func save() {
        baby.name = name.trimmingCharacters(in: .whitespaces)
        baby.birthDate = birthDate
        baby.gender = gender
    }
}
