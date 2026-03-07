# Kinna MVP Design Decisions v2

Bu dosya, [CLAUDE.md](/Users/osmanseven/Kinna/CLAUDE.md) ve [SPEC.md](/Users/osmanseven/Kinna/SPEC.md) kararlarina gore tasarlanan v2 konseptin ozetidir.

## Karar Uyumu

- Kapsam: sadece Faz 1 / MVP ekranlari (Onboarding, Ana, Gelisim, Takip, Asi, Besin)
- Mimari yansima: ekranlar MVVM'e uygun sekilde moduler bilesen mantigiyla kurgulandi
- Veri ve gizlilik: UI'da "veri cihazda" vurgusu var (SwiftData + privacy-first)
- Lokalizasyon: metinler TR odakli, `Localizable.xcstrings` ile TR+EN'e tasinabilir
- Monetizasyon karariyla uyum: paywall veya premium Faz 2 ozellikleri v2 konsepte eklenmedi

## Icerik ve Ton

- Ton: sicak pediatrist dili, empatik ama net
- Terminoloji: "beyin mimarisi", "noral devreler", "baglanma kaliplari" kullanildi
- Yasak ifade: "bilincdisi" kullanilmadi
- Referans cumlesi gorunur: WHO + T.C. Saglik Bakanligi protokolleri
- Disclaimer gorunur: "Bu uygulama doktor tavsiyesinin yerini tutmaz"

## Gorsel Dil

- v2, v1'den farkli olarak editorial bir tipografi dili kullanir:
  - Display: `Cormorant Garamond`
  - UI text: `Manrope`
- Renk yaklasimi:
  - Sicak paper/cream zemin
  - Terracotta + Sage vurgu
  - Yuksek okunurluklu koyu metin
- Arka plan: gradient + ince pattern katmani (duz renk degil)

## Motion ve Responsive

- Grid ekranlar icin kademeli giris animasyonu (`rise`)
- Aktif sekmede yumuşak `pulse` noktasi
- `1180px` altinda 2 kolon, `760px` altinda 1 kolon responsive duzen

## SwiftUI'ya Donusum Notu

- `KinnaTheme` (renk + tipografi tokenlari)
- Reusable bilesenler:
  - `KinnaCard`, `KinnaChip`, `MetricTile`, `TimelineRow`, `BottomTabBar`
- Ekran bazli ViewModel ayrimi:
  - `OnboardingViewModel`, `HomeViewModel`, `MilestoneViewModel`, `TrackingViewModel`, `VaccinationViewModel`, `AllergyViewModel`

