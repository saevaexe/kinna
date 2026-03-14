# Kinna — Launch Sonrası Roadmap

Kaynak: Adapty 2026 roadmap + kendi planımız. Launch sonrası, organic çekiş ve kullanıcı verisi toplandıkça sırayla ele alınacak.

## Infrastructure

- [ ] **CI/CD (Fastlane)** — auto build, auto TestFlight upload, auto screenshot
  - Solo dev için MVP'de şart değil, ikinci major update'te değerlendir
- [ ] **Crash monitoring** — TestFlight + Xcode Organizer başlangıç için yeterli
  - Kullanıcı sayısı artarsa Firebase Crashlytics veya Sentry (privacy trade-off değerlendir)

## Analytics & Dashboard

- [ ] **RevenueCat dashboard** — MRR, ARR, LTV, churn zaten built-in
- [ ] **Funnel analizi** — onboarding completion, trial start, trial→paid conversion
  - RevenueCat customer attributes + Apple App Analytics ile başla
- [ ] **Cohort analizi** — haftalık cohort retention
- [ ] **A/B paywall test** — RevenueCat Experiments veya Adapty
  - Minimum 1000 trial user sonrası anlamlı sonuç verir

## Acquisition (Kullanıcı Kazanımı)

- [ ] **Apple Search Ads** — ilk organic çekişi gördükten sonra
  - Hedef keyword: "bebek takip", "aşı takvimi", "baby tracker"
  - Düşük bütçeyle başla ($5-10/gün), CPA izle
- [ ] **Content Marketing** — Instagram/TikTok kısa video
  - "2 aylık bebek ne yapabilir?" tarzı eğitici içerik
  - Anne/baba forumları ve grupları (doğal paylaşım)
- [ ] **Influencer Marketing** — mikro influencer (anne blogger, pediatrist hesaplar)
  - Türkiye'de anne YouTube/Instagram hesapları ile organik işbirliği
- [ ] **Social Media Ads** — Instagram/Facebook anne hedeflemesi
  - Launch sonrası 2-3 ay organic data topla, sonra paid kampanya

## ASO (App Store Optimization)

- [ ] **Icon A/B Testing** — App Store Connect'te product page optimization
- [ ] **Screenshot A/B Testing** — farklı caption/sıralama testleri
- [ ] **Keyword iteration** — ilk 30 gün sonrası keyword performance'a göre güncelle
- [ ] **Ratings & Reviews** — SKStoreReviewController (5+ kayıt sonrası tetikle)
- [ ] **ASO Localization** — TR+EN var, DE/FR/ES eklenebilir (Avrupa pazarı için)

## Retention

- [ ] **Push notification stratejisi** — günlük hatırlatma var, akıllı timing ekle
  - Kullanıcı en aktif olduğu saatte gönder (davranış bazlı)
- [ ] **Win-back kampanyaları** — churn eden kullanıcılara özel teklif
  - RevenueCat promotional offers ile
  - Minimum 3 ay churn verisi toplandıktan sonra
- [ ] **Email automation** — v2 (iCloud sync/hesap sistemi ile birlikte)
- [ ] **Feature adoption tracking** — hangi özellikler kullanılıyor, hangileri keşfedilmemiş

## Conversion Optimization

- [ ] **A/B paywall testleri** — farklı headline, feature sıralaması, fiyat vurgusu
- [ ] **Onboarding A/B** — 5 adım vs 4 adım, value summary varyasyonları
- [ ] **Pricing experiments** — seasonal discount, holiday kampanyaları
- [ ] **Lifetime deal** — düşünülebilir ama recurring revenue'yu öldürür, dikkatli ol

## Growth

- [ ] **Price localization deploy** — ASC'de bölgesel tier ayarları (KARARLANDI, henüz uygulanmadı)
- [ ] **Community building** — Kinna kullanıcı grubu (Telegram/WhatsApp)
- [ ] **Viral loops** — "Bebeğim X aylık, Kinna ile takip ediyorum" paylaşım kartı
- [ ] **Referral program** — v2+ (hesap sistemi gerektirir)
- [ ] **New feature bets** — AI soru-cevap, emzirme zamanlayıcı, uyku analizi

## Öncelik Sırası (Launch Sonrası İlk 90 Gün)

1. **Gün 1-7:** App Store'da yayınla, 2-3 arkadaşa TestFlight → gerçek feedback
2. **Gün 7-14:** İlk organic veriye bak, keyword performance kontrol, rating prompt aktifleştir
3. **Gün 14-30:** RevenueCat dashboard'da trial→paid conversion izle, ilk cohort verisi
4. **Gün 30-60:** Apple Search Ads düşük bütçeyle başla, social media içerik planı
5. **Gün 60-90:** A/B paywall test (yeterli data varsa), win-back kampanya planla
