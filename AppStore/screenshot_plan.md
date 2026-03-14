# Kinna — App Store Screenshots Plan

## Gereksinimler
- iPhone 6.7" (iPhone 15 Pro Max / 16 Pro Max) — zorunlu
- iPhone 6.1" (iPhone 15 Pro / 16 Pro) — opsiyonel ama önerilen
- Format: 1290 x 2796 px (6.7") veya 1179 x 2556 px (6.1")
- Maksimum 10 screenshot

## Screenshot Sıralaması (6 ekran)

Kural: İlk 3 screenshot App Store arama sonuçlarında görünür — en güçlü değer önerisi önde.

### 1. Value Summary (Onboarding)
**Ekran:** Value Summary step — "Ela 2 ay 13 gün. Şimdi en çok bunlar önemli."
**Caption TR:** Bebeğine özel plan, ilk günden.
**Caption EN:** A plan made for your baby, from day one.
**Neden ilk:** Kişiselleştirme hissi + en etkileyici ekran

### 2. Home
**Ekran:** Home ekranı — milestone kartı, güvenlik kartı, günlük özet
**Caption TR:** Her gün sana özel bir rehber.
**Caption EN:** Daily guidance, made for you.
**Neden:** Ana kullanım deneyimi

### 3. Milestones
**Ekran:** Milestones ekranı — aylık gelişim kartları (sosyal, dil, motor, bilişsel)
**Caption TR:** Gelişim adımlarını bilimsel olarak takip et.
**Caption EN:** Track milestones backed by science.
**Neden:** Temel özellik, WHO güvencesi

### 4. Vaccination
**Ekran:** Aşı takvimi — yaklaşan aşılar, tamamlanan aşılar
**Caption TR:** T.C. aşı takvimi, hatırlatmalarla.
**Caption EN:** TR vaccine schedule with reminders.
**Neden:** Türkiye pazarında güçlü farklılaştırıcı

### 5. Tracking
**Ekran:** Günlük takip — beslenme, uyku, bez, büyüme kaydı
**Caption TR:** Beslenme, uyku, büyüme — tek yerde.
**Caption EN:** Feeding, sleep, growth — all in one place.
**Neden:** Günlük kullanım değeri

### 6. Privacy / Paywall
**Ekran:** Paywall veya Settings privacy bölümü
**Caption TR:** Tüm veriler cihazında. Güvenli.
**Caption EN:** All data stays on your device. Private.
**Neden:** Güven mesajı, rakiplerden farklılaştırıcı (çoğu cloud-based)

## Tasarım Stili
- Frameless rounded screenshot + shadow (Untwist/SPCTools pattern)
- Kinna renk paleti: cream background (#FDF8F4), terracotta accent (#C4725A)
- Caption: üstte veya altta, kinnaDisplay font (veya system serif)
- Basit, temiz — App Store'da hızlı taranabilir

## Üretim Yöntemi
- Simulator screenshot → PIL script ile frame + caption (SPCTools pattern: `AppStore/generate_previews.py`)
- Status bar: `xcrun simctl status_bar override --time "09:41"` ile temizle
- Bebek verisi: test profil (Ela, 2 ay 13 gün, kız)
