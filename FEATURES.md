# Kinna — Feature Backlog (Post-MVP)

Son güncelleme: 2026-03-21

## Durum Özeti

- **MVP:** v1.0 yayında (build 5 review'da)
- **Mevcut:** Onboarding (5 adım + Value Summary), milestones (0-24 ay), aşı takvimi (18 kayıt, TR hibrit), günlük takip (beslenme/uyku/bez/not), güvenlik uyarıları, ek gıda günlüğü, WHO büyüme eğrileri, emzirme aralık sayacı, uyku analizi özeti, role-aware baba modu, custom paywall (7 gün trial, $4.99/mo + $39.99/yr), premium gating (7/7), TR+EN lokalizasyon, 27 test
- **External blocker:** App Store Connect subscription approval

---

## v1.0.x — Hardening & Quick Wins

Sprint 8 kalan + launch sonrası ilk stabilizasyon.

| # | Özellik | Öncelik | Efor | Kaynak |
|---|---|---|---|---|
| 1 | `.gitignore`'a `build/` ve `design/` eklenmesi | P0 | S | BACKLOG Sprint 8 |
| 2 | Release-risk warning cleanup (simulator/runtime gürültüsü) | P0 | S | BACKLOG Sprint 8 |
| 3 | MVVM alignment — Home, Tracking için ViewModel çıkarma | P1 | M | BACKLOG Sprint 8 |
| 4 | Bebek profili düzenleme (Settings'ten ad, doğum tarihi, cinsiyet) | P0 | S | ROADMAP v1.0.1 |
| 5 | Metadata / ASO küçük iterasyonlar (subtitle, promo text) | P1 | S | ROADMAP v1.0.1 |
| 6 | Medical category performans takibi | P1 | S | ROADMAP v1.0.1 |

---

## v1.1 — Günlük Kullanım Modülleri

Timer'lar ve içerik derinliği — retention için kritik. Rakip analizi: 3/3 rakipte (HappyKids, Baby+, Huckleberry) timer mevcut.

| # | Özellik | Öncelik | Efor | Detay |
|---|---|---|---|---|
| 1 | Emzirme timer v2 (sol/sağ meme, süre, start/stop) | P0 | M | Mevcut aralık sayacı → gerçek timer'a yükseltme |
| 2 | Biberon takibi (miktar loglama) | P0 | M | 3/3 rakipte var |
| 3 | Uyku takibi (başlat/durdur timer) | P0 | M | 3/3 rakipte var |
| 4 | Bez takibi gelişmiş (pee/poo/mixed) | P1 | S | Mevcut basit log → detaylı |
| 5 | Süt sağma (pumping) tracker | P1 | M | 3/3 rakipte var |
| 6 | Dark mode | P0 | M | Gece emzirme için kritik |
| 7 | Günlük içerik genişletme (Sprint 11) | P0 | M | Motivasyon 3→10/rol, rehber 4→12/rol (yaş bazlı), bildirim 3→6/rol |
| 8 | Home kart rotasyonu optimizasyonu | P1 | S | Tekrar hissini azalt |
| 9 | Notes / günlük içgörü derinleştirme | P1 | M | Note log'u yaş bazlı rehber bağlamına oturt |
| 10 | Uyku özeti v2 (ortalama + trend + haftalık özet) | P1 | M | Mevcut kompakt kart → daha derin |
| 11 | Review prompt tuning (gerçek veriye göre) | P2 | S | — |

---

## v1.2 — Sağlık & Büyüme Genişlemesi

Premium derinliği artırma — retention ve sync çözüldükten sonra daha yüksek ROI.

| # | Özellik | Öncelik | Efor | Detay |
|---|---|---|---|---|
| 1 | Baş çevresi ölçümü (WHO persentil) | P1 | M | Baby+, HappyKids'te var |
| 2 | Ateş / sıcaklık takibi | P1 | M | 3/3 rakipte var |
| 3 | İlaç / doz takibi | P1 | M | 3/3 rakipte var |
| 4 | Diş takibi (hangi diş çıktı, referans chart) | P2 | M | Baby+ |
| 5 | Hastalık kaydı | P2 | M | Baby+, HappyKids |
| 6 | Doktor randevu takibi | P2 | M | Baby+, HappyKids |
| 7 | Weight-for-length / height genişleme | P1 | M | Growth charts derinleştirme |
| 8 | Breastfeeding v2 (süre, side, ortalama aralık) | P1 | M | v1.1 timer'ın analiz katmanı |
| 9 | Sleep insights v3 (pattern odaklı özet) | P2 | M | — |
| 10 | Doktora PDF rapor / basit özet | P2 | M | Randevuya götürülebilir özet |

---

## v1.3 — Platform Entegrasyonları

Sync, paylaşım ve convenience yüzeyleri. **Önemli:** Multi-baby, sync olmadan açılmamalı.

| # | Özellik | Öncelik | Efor | Detay |
|---|---|---|---|---|
| 1 | ~~iCloud sync foundation~~ | ✅ | — | CloudKit + SwiftData automatic sync |
| 2 | Partner / bakıcı sharing | P0 | L | Anne-baba aynı bebeği takip edebilsin |
| 3 | Çoklu çocuk profili | P1 | M | Sync sonrası, 3/3 rakipte var |
| 4 | iOS Widget (son beslenme/uyku/bez + günlük özet) | P1 | M | Huckleberry |
| 5 | Live Activities (kilit ekranı timer) | P1 | M | Huckleberry |
| 6 | Apple Watch quick-log | P2 | M | Çekirdek ihtiyaç değil ama convenience |
| 7 | Veri export (CSV/PDF doktor için) | P2 | M | Baby+, Huckleberry |
| 8 | Shareable milestone card (organik büyüme) | P1 | S | Kutlama anı, viral potansiyel |
| 9 | iPad experience | P2 | M | Growth ve charts için iyi tamamlayıcı |

---

## v1.4 — İçerik & Engagement + EN Readiness

| # | Özellik | Öncelik | Efor | Detay |
|---|---|---|---|---|
| 1 | Beyaz gürültü / ninni player | P1 | M | Baby+, HappyKids — düşük maliyet, yüksek engagement |
| 2 | Blog / makale içerikleri (yaşa göre) | P1 | M | Baby+, HappyKids |
| 3 | Bebek yemek tarifleri | P2 | M | HappyKids |
| 4 | Günlük / diary (serbest metin) | P2 | M | Baby+, HappyKids |
| 5 | Fotoğraf anıları / Face-A-Day zaman tüneli | P2 | M | Baby+, viral potansiyel |
| 6 | EN copy polish (uygulama içi TR kalitesine çek) | P0 | M | Global büyüme hazırlığı |
| 7 | EN metadata / creative v2 | P0 | M | "Calm baby tracker + guidance" positioning |
| 8 | Locale-aware vaccination messaging (EN) | P1 | M | EN sayfada TR takvimi mesajını doğru konumla |
| 9 | ASO localization — DE/FR/ES metadata | P2 | S | Avrupa pazarı için |

---

## v2.0 — Gelişmiş Özellikler & Intelligence Layer

AI ilkesi: Önce rule-based/on-device, sonra gerçekten ihtiyaç varsa model destekli.

| # | Özellik | Öncelik | Efor | Detay |
|---|---|---|---|---|
| 1 | On-device uyku tahmini ("Sonraki şekerleme ne zaman?") | P1 | L | Huckleberry SweetSpot benzeri |
| 2 | Haftalık akıllı özet (doğal dilde) | P1 | M | Beslenme/uyku/büyüme trendi |
| 3 | Pattern-based akıllı bildirimler | P2 | M | "Genelde bu saatte..." öneriler |
| 4 | AI destekli ebeveyn soruları (chatbot) | P2 | L | HappyKids, Huckleberry — kural tabanlı → model |
| 5 | Bebek ağlama analizi (ses tabanlı) | P2 | L | HappyKids |
| 6 | Doğal dil ile log girişi | P2 | M | Huckleberry |
| 7 | Siri Shortcuts | P2 | M | Huckleberry |
| 8 | Live Activities (emzirme/uyku timer) | P1 | M | — |
| 9 | Premature bebek düzeltilmiş yaş | P2 | S | Huckleberry |
| 10 | Kırmızı bayrak semptom kontrolü | P2 | M | SPEC Faz 2 |
| 11 | Beyin gelişimi katmanı (Harvard/WHO) | P2 | M | SPEC Faz 2 |
| 12 | Doğru bilinen yanlışlar serisi | P1 | M | SPEC Faz 2 — büyükanne vs bilim |

---

## Growth & Marketing

Kaynak: post_launch_roadmap.md + ROADMAP.md analizi.

### Launch Sonrası İlk 90 Gün

1. **Gün 1-7:** Yayınla, 2-3 kişiye TestFlight, gerçek feedback
2. **Gün 7-14:** Organic veriye bak, keyword performance, rating prompt
3. **Gün 14-30:** RevenueCat dashboard — trial→paid conversion, ilk cohort
4. **Gün 30-60:** Apple Search Ads düşük bütçe ($5-10/gün), social media içerik planı
5. **Gün 60-90:** A/B paywall test (yeterli data varsa), win-back kampanya planla

### ASO

- [ ] Icon A/B Testing (App Store Connect product page optimization)
- [ ] Screenshot A/B Testing
- [ ] Keyword iteration (ilk 30 gün sonrası)
- [ ] ASO Localization — DE/FR/ES (Avrupa pazarı)

### Acquisition

- [ ] Apple Search Ads — hedef: "bebek takip", "aşı takvimi", "baby tracker"
- [ ] Content Marketing — Instagram/TikTok kısa eğitici video
- [ ] Mikro influencer — anne blogger, pediatrist hesaplar
- [ ] Social Media Ads — organic data toplandıktan sonra (2-3 ay)

### Retention & Conversion

- [ ] Push notification akıllı timing (davranış bazlı)
- [ ] Win-back kampanyaları (RevenueCat promotional offers, 3 ay churn verisi sonrası)
- [ ] A/B paywall testleri (headline, feature sıralaması, fiyat vurgusu)
- [ ] Onboarding A/B (adım sayısı, value summary varyasyonları)
- [ ] Feature adoption tracking
- [ ] Viral loops — "Bebeğim X aylık, Kinna ile takip ediyorum" paylaşım kartı

### Altyapı

- [ ] CI/CD (Fastlane) — ikinci major update'te değerlendir
- [ ] Crash monitoring — TestFlight + Xcode Organizer başlangıç, sonra Sentry (privacy trade-off)
- [ ] Funnel analizi — RevenueCat customer attributes + Apple App Analytics
- [ ] Cohort analizi — haftalık retention

---

## Rekabet Avantajları (Korumalı)

Kinna'nın rakiplerde olmayan veya zayıf olan güçlü yönleri:

| Avantaj | Detay |
|---|---|
| WHO tabanlı milestone kartları | Huckleberry'de milestone yok |
| T.C. Sağlık Bakanlığı aşı takvimi | TR pazarında rakip yok |
| Alerji / ek gıda reaksiyon takibi | Derinlikli, rakiplerden ayrışıyor |
| Tam cihaz içi gizlilik | Hesap gerektirmez, sunucuya veri gitmez |
| TR + EN çift dil | Büyük rakipler Türkçe sunmuyor |
| Agresif fiyat | $4.99/mo vs Huckleberry $9.99/mo |
| Anne / baba / bakıcı role-aware ton | Kişiselleştirilmiş deneyim |

---

## Açık Kararlar

- [ ] App Store kategori kesinleştirme: Health & Fitness vs Medical
- [ ] AI provider (v2): on-device rule-based vs cloud (Claude API)
- [ ] AI günlük free limit
- [ ] İlk beta tester: kız kardeş (anne persona)
- [ ] Fotoğraflı zaman tüneli — PhotoKit entegrasyonu kapsamı
- [ ] Daily notes content strategy: yaş bazlı mı, persona bazlı mı, editorial mı?
- [ ] Lifetime plan — recurring revenue'yu öldürür, dikkatli değerlendir
- [ ] Topluluk forumu zamanlaması

---

## Efor & Öncelik Tanımları

| Efor | Süre |
|---|---|
| S (Small) | 1-3 gün |
| M (Medium) | 1-2 hafta |
| L (Large) | 3-4 hafta |

| Öncelik | Anlamı |
|---|---|
| P0 | Bir sonraki release'te yapılmalı |
| P1 | Yakın plan |
| P2 | Sonraki safhaya ertelenebilir |
