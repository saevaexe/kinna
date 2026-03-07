# Kinna — Product Specification

> Bilimi annelik diline çeviren günlük mikro-doz rehber.
> "Her gün bir bilgi. 10 kitaba gerek yok."

## 1. Genel Bakış

| Alan | Değer |
|---|---|
| **Uygulama adı** | Kinna |
| **İsim kökeni** | Kin (aile) + na (anne); Galce "greatest champion" |
| **Platform** | iOS (SwiftUI) |
| **Minimum iOS** | 17.0 |
| **Mimari** | SwiftUI + MVVM + SwiftData + @Observable |
| **Dil desteği** | TR + EN (Localizable.xcstrings) |
| **Bundle ID** | com.osmanseven.kinna |
| **Yaş kapsamı** | 0–5 yaş |
| **Hedef kitle** | Genç ebeveynler (20–30 yaş) — birincil: anne, ikincil: baba |
| **Ton** | Sıcak pediatrist — bilimsel ama insani |
| **Kategori** | Health & Fitness veya Medical (TBD) |

## 2. Problem

1. Genç anneler güvenilir bilgiye ulaşamıyor — Google çelişkili, kendi anneleri güncel değil, doktor ayda 1 kez
2. Kitap okuyacak vakitleri yok (2 aylık bebeğe bakıyorlar)
3. Türkçe pazarda güvenilir, sade, kişiselleştirilmiş uygulama yok

## 3. Pazar Fırsatı

- Global ebeveynlik app pazarı: $1.69B (2024) → $6B (2035), %12 CAGR
- Millennial ebeveynlerin %75+'ı dijital platform kullanıyor
- TR boşluk: Bakanlık uygulaması statik, Elika dar kapsamlı, global oyuncular TR'ye gelmiyor

## 4. Rakip Analizi

| Rakip | Güçlü | Zayıf |
|---|---|---|
| Sağlık Bakanlığı "Annelik Yolculuğu" | Ücretsiz, güvenilir | Statik, AI yok, 2 yaşta bitiyor |
| Elika Bebek | Uzman onaylı, 3D görseller | 0–3 yaş sınırlı, AI yok |
| Huckleberry | Uyku takibi güçlü | Sadece uyku, TR yok |
| BabyCenter | 400M+ kullanıcı | Eski UI, TR'ye özel yok |
| Cocoon | Aktivite + uzman | 0–12 ay sınırlı, TR yok |

### Hiçbir rakipte olmayan 3 fark:
1. **Beyin gelişimi / psikolojik katman** — Harvard, WHO, ACE destekli
2. **Doğru bilinen yanlışlar serisi** — büyükanne vs bilim
3. **Hem anne hem baba persona desteği**

## 5. Kullanıcı Personaları

### 5.1 Anne Persona
- **Bildirim:** Motivasyon + takdir ("Zor günleri geçtin, harikasın")
- **Güven:** Doktor figürü
- **İçerik:** Doğru bilinen yanlışlar + haftalık aktiviteler
- **Ana ekran:** Bebeğin yaşı büyük ve net ("2 ay 3 gün")

### 5.2 Baba Persona
- **Bildirim:** Pratik durum ("Minik kahraman beslendi")
- **Güven:** Eşine güveniyor → paylaşım özelliği şart
- **İçerik:** Sağlık verileri, ölçülebilir
- **Ana ekran:** Eski fotoğraf karşılaştırma (zaman tüneli — viral potansiyel)

## 6. Özellikler

### 6.1 MVP (Faz 1 — v1.0)

| # | Özellik | Açıklama |
|---|---|---|
| 1 | **Onboarding** | Bebek profili oluşturma (ad, doğum tarihi, cinsiyet), ebeveyn rolü (anne/baba) |
| 2 | **Aylık Gelişim Kartları** | Milestone listesi + "Bu ay ne bekle" bilgi kartları (0–60 ay) |
| 3 | **Aşı Takvimi** | T.C. Sağlık Bakanlığı takvimi + push hatırlatma |
| 4 | **Günlük Takip** | Beslenme, uyku, bez — basit log (SwiftData) |
| 5 | **Güvenlik Uyarıları** | Yaşa göre push notification (yüzüstü uyutma, küçük parçalar vb.) |
| 6 | **Alerji / Ek Gıda Günlüğü** | Yeni gıda tanıtım logu + reaksiyon takibi |

### 6.2 Premium (Faz 2 — v1.1+)

| # | Özellik | Tier |
|---|---|---|
| 1 | **AI Soru-Cevap** | Limitli free (3/gün?), sınırsız premium |
| 2 | **Büyüme Eğrileri** | WHO persentil grafikleri (boy, kilo, baş çevresi) |
| 3 | **Doktora PDF Rapor** | Takip verilerinden otomatik rapor oluşturma |
| 4 | **Kırmızı Bayrak Kontrolü** | Semptom checker — acil mi değil mi? |
| 5 | **Beyin Gelişimi Katmanı** | Harvard/WHO destekli nöral gelişim içerikleri |
| 6 | **Fotoğraflı Zaman Tüneli** | Aylık fotoğraf karşılaştırma (viral potansiyel) |
| 7 | **Doğru Bilinen Yanlışlar** | Büyükanne vs bilim serisi |

## 7. Monetizasyon

| Plan | Fiyat | Trial |
|---|---|---|
| Aylık | $4.99/mo | 3 gün ücretsiz deneme |
| Yıllık | $39.99/yr (~$3.33/mo) | 3 gün ücretsiz deneme |

- **SDK:** RevenueCat
- **Paywall:** Custom SwiftUI (RevenueCat PaywallView değil, SPCTools/Untwist tarzı)
- **Free tier:** Onboarding, gelişim kartları (özet), aşı takvimi, günlük takip (temel)
- **Premium:** Tüm Faz 2 özellikleri + sınırsız günlük takip geçmişi

## 8. Bilimsel Temel

### Kaynaklar (kamu belgesi, legal)
- WHO rehberleri (büyüme eğrileri, beslenme, gelişim)
- Harvard Center on the Developing Child (beyin mimarisi)
- CDC ACE çalışması (erken deneyimlerin uzun vadeli etkisi)
- T.C. Sağlık Bakanlığı Bebek-Çocuk İzlem Protokolleri (2008, rev. 2015, 2018)

### Temel Veriler
- 0–5 yaş: beynin %90'ı gelişiyor (Zero to Three)
- Saniyede 1M+ yeni sinaptik bağlantı (Harvard)
- 2 yaşında yetişkinden 2x fazla sinaps
- ACE çalışması: çocukluk olumsuz deneyimleri → yetişkinlikte 4–12x risk artışı

### Terminoloji Kuralları
- "Bilinçdışı" DEĞİL → "beyin mimarisi", "nöral devreler", "bağlanma kalıpları"
- Referans cümlesi: *"İçeriklerimiz WHO rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır."*

## 9. Teknik Mimari

```
Kinna/
├── App/
│   ├── KinnaApp.swift
│   └── AppState.swift
├── Models/
│   ├── Baby.swift              # SwiftData — ad, doğum tarihi, cinsiyet
│   ├── DailyLog.swift          # SwiftData — beslenme, uyku, bez
│   ├── Vaccination.swift       # SwiftData — aşı kaydı
│   ├── AllergyLog.swift        # SwiftData — ek gıda + reaksiyon
│   └── Milestone.swift         # Gelişim kilometre taşları
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── TrackingViewModel.swift
│   ├── VaccinationViewModel.swift
│   └── MilestoneViewModel.swift
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   ├── Tracking/
│   ├── Milestones/
│   ├── Vaccination/
│   ├── Allergy/
│   ├── Settings/
│   └── Subscription/
├── Engine/
│   ├── MilestoneEngine.swift   # Yaşa göre milestone hesaplama
│   ├── VaccinationEngine.swift # Aşı takvimi + hatırlatma
│   └── GrowthEngine.swift      # WHO persentil (Faz 2)
├── Utilities/
│   ├── NotificationManager.swift
│   └── AnalyticsManager.swift
├── Resources/
│   ├── Localizable.xcstrings
│   ├── Assets.xcassets
│   └── Data/
│       ├── milestones.json     # 0-60 ay milestone veritabanı
│       ├── vaccinations.json   # TR aşı takvimi
│       └── safety_alerts.json  # Yaşa göre güvenlik uyarıları
└── project.yml                 # XcodeGen
```

### Veri Katmanı
- **Persistence:** SwiftData (tüm veri cihazda)
- **İçerik:** JSON bundle (milestones, aşı takvimi, güvenlik uyarıları)
- **Sync:** iCloud yok (MVP), Faz 3'te değerlendirilecek

### Bağımlılıklar
| Paket | Kullanım |
|---|---|
| RevenueCat | Subscription yönetimi |
| — | Diğer 3rd party SDK yok (gizlilik öncelikli) |

## 10. Gizlilik ve Uyumluluk

- **Veri depolama:** Tamamı cihaz üzerinde (SwiftData)
- **3rd party SDK:** Sadece RevenueCat (ödeme)
- **Analytics:** Apple Analytics only (3rd party analytics SDK yok)
- **KVKK uyumu:** Çocuk verisi hassas — açık rıza, minimal veri toplama
- **Disclaimer:** "Bu uygulama doktor tavsiyesinin yerini tutmaz. Sağlık endişeleriniz için doktorunuza danışın."
- **Apple Review:** Health & Fitness kategorisi — sağlık içerik doğrulaması gerekebilir

## 11. Dikkat Noktaları

1. Pediatrist "content reviewer" danışmanlığı — baştan içerik üretmesine gerek yok, review yeterli
2. AI maliyet yönetimi: sık sorulan sorulara hazır içerik, AI sadece premium + günlük limit
3. Apple sağlık içerik review süreci uzun olabilir — erken submit
4. Ebeveynlerin %40'ı çocuk verisi paylaşmaktan çekiniyor — gizlilik ön planda
5. İsim trademark kontrolü yapılmalı (domain + App Store)

## 12. Açık Kararlar

- [ ] App Store kategori: Health & Fitness vs Medical
- [ ] İsim kesinleştirme — domain/trademark kontrol
- [ ] AI provider (Faz 2): on-device vs cloud (Claude API vs rule-based)
- [ ] AI günlük free limit (3/gün önerisi)
- [ ] iCloud sync (Faz 3?)
- [ ] İlk beta tester: kız kardeş (anne persona)
- [ ] Fotoğraflı zaman tüneli — PhotoKit entegrasyonu kapsamı

## 13. Yol Haritası

```
Faz 1 (MVP — v1.0)
├── Onboarding + bebek profili
├── Aylık gelişim kartları (0-60 ay)
├── Aşı takvimi + hatırlatma
├── Günlük takip (beslenme, uyku, bez)
├── Yaşa göre güvenlik uyarıları
├── Alerji / ek gıda günlüğü
└── RevenueCat paywall (boş premium, coming soon)

Faz 2 (Premium — v1.1)
├── WHO büyüme eğrileri
├── AI soru-cevap
├── Doktora PDF rapor
├── Kırmızı bayrak semptom kontrolü
├── Beyin gelişimi katmanı
└── Doğru bilinen yanlışlar serisi

Faz 3 (Growth — v2.0)
├── Fotoğraflı zaman tüneli
├── iCloud sync
├── Baba persona UI varyantları
├── Widget (bugünün bilgisi)
└── Apple Watch komplikasyon
```
