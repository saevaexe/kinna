# Kinna — Ebeveynlik Rehber Uygulaması

## Proje
- 0–5 yaş ebeveynlik rehberi, bilimi annelik diline çeviren mikro-doz içerik
- SwiftUI + MVVM + SwiftData + @Observable, iOS 17+, TR + EN
- Bundle ID: `com.osmanseven.kinna`
- XcodeGen ile proje yönetimi (`project.yml`)

## Mimari Kurallar
- **MVVM:** View → ViewModel (@Observable) → Model (SwiftData)
- **SwiftData:** Tüm veri cihazda, cloud sync yok (MVP)
- **İçerik verileri:** JSON bundle (`Resources/Data/`) — milestones, aşı takvimi, güvenlik uyarıları
- **Lokalizasyon:** `Localizable.xcstrings` — her yeni string TR + EN birlikte eklenmeli
- **Subscription:** RevenueCat — custom SwiftUI paywall (RevenueCat PaywallView KULLANMA)
- **Analytics:** Apple Analytics only — 3rd party analytics SDK ekleme

## Fiyatlandırma
- $4.99/mo, $39.99/yr, 3 gün trial

## Ton ve İçerik
- Sıcak pediatrist tonu — bilimsel ama insani
- Terminoloji: "beyin mimarisi", "nöral devreler", "bağlanma kalıpları" KULLAN
- "Bilinçdışı" KULLANMA
- Referans: "İçeriklerimiz WHO rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır."

## Gizlilik
- Tüm veri cihazda (SwiftData), sunucuya veri gönderme
- Disclaimer zorunlu: "Bu uygulama doktor tavsiyesinin yerini tutmaz."
- KVKK uyumu — çocuk verisi hassas, minimal veri toplama

## Do NOT
- RevenueCat PaywallView kullanma — custom SwiftUI paywall yaz
- 3rd party analytics SDK ekleme (PostHog, Firebase vb.) — gizlilik vaadini bozar
- Tıbbi teşhis/tedavi önerisi verme — sadece bilgilendirme
- "Bilinçdışı" kelimesini kullanma
- iCloud sync ekleme (MVP scope dışı)

## Known Gotchas
- `.fullScreenCover` / `.sheet` parent `.environment()` miras almaz — açıkça geçir
- RevenueCat paywall simulator'da yüklenmez — gerçek cihazda test et
- `UILaunchScreen` key Info.plist'te olmalı (boş `<dict/>` bile olsa) — yoksa siyah barlar
- Sandbox purchase simulator'da çalışmaz — TestFlight veya gerçek cihaz kullan
- Sandbox hesap bölgesi cihaz App Store bölgesiyle eşleşmeli
