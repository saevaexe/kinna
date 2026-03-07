# Kinna MVP Design Decisions

Bu dokuman, [SPEC.md](/Users/osmanseven/Kinna/SPEC.md) ve [CLAUDE.md](/Users/osmanseven/Kinna/CLAUDE.md) kararlarina gore olusturulan UI konseptinin tasarim kurallarini toplar.

## 1) Kapsam

- Faz 1 (MVP) ekranlari: Onboarding, Ana, Gelisim, Takip, Asi, Besin
- Faz 2+ ozellikleri (AI, buyume egrileri, zaman tuneli) konsept disinda tutuldu

## 2) Ton ve Icerik Dili

- Uslup: "sicak pediatrist" (bilimsel ama insani)
- Referans cümlesi UI icinde gorunur:
  - "Iceriklerimiz WHO rehberleri ve T.C. Saglik Bakanligi protokolleri temel alinarak hazirlanmistir."
- Zorunlu saglik uyarisi UI seviyesinde var:
  - "Bu uygulama doktor tavsiyesinin yerini tutmaz."
- Terminoloji: "beyin mimarisi", "noral devreler", "baglanma kaliplari" ekseninde
- Kullanilmayan ifade: "bilincdisi"

## 3) Visual Tokens

- Ana zemin: `#FAF7F2` (cream)
- Card/Surface: `#FFFDF9` (warm-white)
- Primary text: `#2C2C2C` (charcoal)
- Secondary text: `#6B6560` ve `#A09890`
- Accent 1 (uyari/aksiyon): `#C4785A` (terracotta)
- Accent 2 (olumlu/durum): `#7A9E8E` (sage)
- Border soft: `#EDE8E2` (pale)

## 4) Tipografi

- Display/Headline: `Fraunces`
- Body/UI: `DM Sans`
- Hedef: anne odakli yumusak ama premium bir his

## 5) Ana Bilesenler

- `PhoneFrame`: konseptte iOS cihaz cercevesi
- `AgeCard`: ana ekranda buyuk yas bilgisi
- `DailyCard`: ozel icerik, guvenlik, asi hatirlatma kartlari
- `MilestoneItem`: done/pending/warn durumlari
- `TrackingTile`: beslenme/uyku/bez/tarti metrik kutulari
- `VaccineItem`: tamamlanan/yaklasan/gelecek ayrimi
- `AllergyItem`: besin + reaksiyon etiketi
- `BottomTabBar`: 5 sekme (Ana/Gelisim/Takip/Asilar/Besinler)

## 6) Onboarding Kararlari

- Bebek bilgileri: ad, dogum tarihi, cinsiyet
- Ebeveyn rolu secimi: anne/baba (persona kararina uyum)
- Devam CTA net ve tek birincil aksiyon

## 7) Responsiveness ve Motion

- Masaustu: coklu cihaz maketi grid
- Mobil: dar ekran icin padding/gap azaltan media query
- Giris animasyonu: her ekran kartina hafif "float-in" gecisi

## 8) SwiftUI'ya Tasima Notlari

- `KinnaTheme` dosyasi ile renk/font tokenlarini tek yerde topla
- Her ekran icin MVVM ayrimi:
  - `OnboardingViewModel`, `HomeViewModel`, `MilestoneViewModel`, `TrackingViewModel`, `VaccinationViewModel`, `AllergyViewModel`
- Metinleri `Localizable.xcstrings` icinde TR+EN birlikte yonet
- Saglik/disclaimer metinlerini ortak bir reusable `MedicalDisclaimerView` ile sun

