import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext

    @State private var babyName = ""
    @State private var birthDate = Date()
    @State private var selectedGender: Baby.Gender? = nil

    private let totalSteps = 4
    private let currentStep = 2

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(i < currentStep ? Color.kTerra : Color.kPale)
                        .frame(width: i < currentStep ? 32 : 20, height: 3)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 32)

            // Baby icon
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.kTerraLight)
                .frame(width: 72, height: 72)
                .overlay {
                    Text("👶")
                        .font(.system(size: 32))
                }
                .padding(.bottom, 32)

            // Title
            Text("Bebeğinle tanışalım")
                .font(.kinnaDisplay(28))
                .foregroundStyle(.kChar)
                .padding(.bottom, 12)

            Text("Kinna'yı bebeğine özel hale getirelim")
                .font(.kinnaBody(14))
                .foregroundStyle(.kMid)
                .padding(.bottom, 40)

            // Form fields
            VStack(spacing: 12) {
                // Name field
                formField(label: "BEBEK ADI") {
                    TextField("Ela", text: $babyName)
                        .font(.kinnaBody(15))
                        .foregroundStyle(.kChar)
                }

                // Birth date field
                formField(label: "DOĞUM TARİHİ") {
                    DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Gender selection
                VStack(alignment: .leading, spacing: 4) {
                    Text("CİNSİYET")
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kLight)
                        .tracking(1)

                    HStack(spacing: 10) {
                        genderButton("Kız", gender: .female)
                        genderButton("Erkek", gender: .male)
                        genderButton("Belirtmek istemiyorum", gender: .other)
                    }
                }
            }
            .padding(.horizontal, 4)

            Spacer()

            // Continue button
            Button {
                saveBaby()
            } label: {
                Text("Devam")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.kChar)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(babyName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(babyName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
        .background(Color.kCream.ignoresSafeArea())
    }

    // MARK: - Components

    private func formField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1)

            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.kPale, lineWidth: 1.5)
                )
        }
    }

    private func genderButton(_ title: String, gender: Baby.Gender) -> some View {
        let isSelected = selectedGender == gender
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedGender = gender
            }
        } label: {
            Text(title)
                .font(.kinnaBody(13))
                .foregroundStyle(isSelected ? .kTerra : .kMid)
                .fontWeight(isSelected ? .medium : .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.kTerraLight : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
                )
        }
    }

    // MARK: - Save

    private func saveBaby() {
        let name = babyName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let baby = Baby(
            name: name,
            birthDate: birthDate,
            gender: selectedGender ?? .other
        )
        modelContext.insert(baby)

        // Generate vaccination schedule
        let schedule = VaccinationEngine.schedule(birthDate: birthDate)
        for item in schedule {
            let record = VaccinationRecord(
                vaccineName: item.nameTR,
                scheduledDate: VaccinationEngine.scheduledDate(birthDate: birthDate, monthAge: item.monthAge)
            )
            modelContext.insert(record)
        }

        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Baby.self, VaccinationRecord.self], inMemory: true)
}
