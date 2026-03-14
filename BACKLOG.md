# Kinna Backlog

This file consolidates product roadmap items from `SPEC.md`, implementation constraints from `CLAUDE.md`, and release risks found during code inspection and local verification.

## Current State

Last sync: 2026-03-14

- Build succeeds for iOS Simulator.
- Sprint 1 ✅, Sprint 2 ✅, Sprint 3 ✅, Sprint 4 ✅, Sprint 5 ✅, Sprint 6 ✅, Sprint 7 ✅.
- Sprint 8 kısmen tamamlandı, Sprint 9a, 9b, 9c ve 9d tamamlandı.
- Tüm ticari kararlar (Adapty raporu) koda yansıtıldı.
- Paywall v2 tamamlandı: auto-renewal disclosure, "Bugün ücret alınmaz", feature sıralaması, Premium/Pro tutarlılığı, abone state ayrımı.
- GitHub Pages canlı: https://saevaexe.github.io/kinna/
- Sprint 9a, 9b, 9c ve 9d local durumda tamamlandı; commit/push bekliyor.

### Feature Status Snapshot

| Özellik | Durum | Not |
|---|---|---|
| Onboarding | ✅ 5 step (rework) | Welcome → Role → Family Info → Safety Note → Value Summary → Paywall |
| Milestones (0-24 ay) | ✅ | Content review ✅ (WHO, CDC, T.C. Sağlık Bakanlığı) |
| Aşı Takvimi (18 kayıt) | ✅ Hibrit (TR auto + EN manual) | Otomatik hatırlatma trigger ✅ |
| Günlük Takip | ✅ Beslenme, uyku, bez, not | — |
| Güvenlik Uyarıları | ✅ JSON + engine + Home guidance card | Ayrı safety ekranı yok (yeterli MVP için) |
| Ek Gıda Günlüğü | ✅ | 5 gıda free limiti ✅ |
| GrowthRecord | ✅ Model + input + tracking tile + timeline + WHO eğrileri | Premium gated growth charts eklendi |
| Paywall | ✅ Custom SwiftUI, 7 gün trial | Onboarding soft paywall ✅, per-day price ✅, tasarruf oranı ✅, legal linkler ✅, auto-renewal disclosure ✅, "Bugün ücret alınmaz" ✅, abone state UI ✅ |
| Premium Gating | ✅ 7/7 implement | Tüm kurallar kodda |
| Lokalizasyon (TR+EN) | ✅ | — |
| RevenueCat | ✅ | Sandbox verified, ASC approval pending |
| Parent Role | ✅ Persist + role-aware Home + notification tonu | Sprint 9c derinleştirmesi tamamlandı |
| Restore Purchases | ✅ Fix uygulandı | SubscriptionManager'a delegated |
| Settings Subscription UI | ✅ | Pro→Premium isimlendirme, NavigationLink→PaywallView(navigation), abone/non-abone state |
| Tests | ✅ 25 test | Data integrity + policy enforcement + growth chart engine + sleep insights + review prompt logic |
| Legal (Terms + Privacy) | ✅ In-app views + GitHub Pages | SFSafariViewController, AppConstants.Legal URLs |
| Paywall Optimizasyonu | ✅ v2 | Dinamik per-day price, %tasarruf, aylık karşılık, subscription terms, auto-renewal disclosure, "Bugün ücret alınmaz", feature sıralaması (aşı üste), Pro→Premium tutarlılığı, abone/non-abone state ayrımı |
| GitHub Pages | ✅ | saevaexe.github.io/kinna/ (privacy, terms, support, landing) |

### Gating Implementation — TAMAMLANDI

| Gating Kuralı | Kodda | Dosya |
|---|---|---|
| Milestone kaydetme (5 limit) | ✅ | MonetizationPolicy + MilestonesView |
| Home kartı (1/gün) | ✅ | MonetizationPolicy + HomeView |
| Günlük takip (7 gün geçmiş) | ✅ | MonetizationPolicy + TrackingView |
| Bu ay milestone sınırı | ✅ | MonetizationPolicy + MilestonesView |
| Ek gıda (5 limit) | ✅ | MonetizationPolicy + AllergyView |
| Aşı hatırlatma (premium) | ✅ | MonetizationPolicy + VaccinationView |
| Safety alerts (Home card) | ✅ | SafetyAlertEngine + HomeView |

### Remaining Open Issues

1. ~~Aşı otomatik hatırlatma trigger'ı~~ ✅ Sprint 6b' de tamamlandı
2. ~~Multi-baby model~~ ✅ Sprint 6a: MVP = single-baby olarak kilitlendi
3. ~~Onboarding "I have account"~~ → Sprint 5'te çözüldü ✅
4. ~~Baba persona bildirim stratejisi~~ ✅ Sprint 7b temel ton/copy katmanı tamamlandı
5. ~~WHO persentil grafikleri~~ ✅ Sprint 9a tamamlandı
6. ~~Milestone content review~~ ✅
7. **App Store Connect subscription approval** — external blocker
8. ~~Codex uncommitted changes~~ ✅ (`d337885` + `4ab7e6d`)

## Recommended Priority Order

### Tier 0 — ✅ TAMAMLANDI

1. ~~Fix SwiftData migration for `VaccinationRecord`.~~ ✅
2. ~~Configure RevenueCat with a real public app API key.~~ ✅
3. ~~Define the free vs premium comparison clearly.~~ ✅ (Adapty raporu, bkz. P1 Commercial Decisions)
4. ~~Add real premium gating.~~ ✅ (7/7 gating kuralı kodda)

### Tier 1 — ✅ TAMAMLANDI

5. ~~Expand MVP data coverage.~~ ✅ (milestones 0-24 ay, vaccinations 18 kayıt, safety_alerts 6 uyarı)
6. ~~Review milestone content month by month.~~ ✅ (WHO, CDC, Sağlık Bakanlığı kaynaklarından doğrulandı)
7. ~~Fix bundled font loading.~~ ✅

### Tier 2 — ✅ TAMAMLANDI

8. ~~Introduce GrowthRecord SwiftData model.~~ ✅ (model + input + tile + timeline)
9. ~~Define single-baby vs multi-baby model explicitly.~~ ✅ (MVP = single-baby)
10. ~~Complete vaccination reminder behavior.~~ ✅ (auto-trigger + backfill)

### Tier 3 — ✅ Büyük ölçüde TAMAMLANDI

11. ~~Improve daily notes.~~ ⚠️ (note log tipi eklendi, content strategy açık)
12. ~~Rework the Home "This month" section.~~ ✅
13. ~~Persist and use parent role from onboarding.~~ ✅ (role-aware copy)
14. ~~Define father persona behavior more explicitly.~~ ✅ (presentation layer)

### Tier 4 — ⚠️ Kısmen TAMAMLANDI

15. ~~Harden onboarding flow.~~ → Sprint 5 Onboarding Rework (KARARLANDI)
16. ~~Add meaningful tests for product logic.~~ ✅ (7 test eklendi)
17. Reduce release-risk logs. **← AÇIK**
18. Align implementation with the stated MVVM architecture. **← AÇIK**

## Priority Order For Your Latest 6 Notes

1. ~~Free vs premium comparison decision~~ ✅
2. ~~GrowthRecord model for weight / height~~ ✅
3. ~~Review milestone features month by month~~ ✅
4. ~~Improve daily notes~~ ⚠️ (note tipi var, content strategy açık)
5. ~~Rework the Home "This month" section~~ ✅
6. ~~Define father persona notifications and changes~~ ✅

## Sprint Plan

### Sprint 1 — Release Foundations ✅ TAMAMLANDI

Tamamlanan: SwiftData migration, RevenueCat config, premium gating (7/7), font loading, trial 7 gün, onboarding paywall, parent role persist, restore fix.

Kalan external blocker: App Store Connect subscription approval.

### Sprint 2 — Core Content Correctness ✅ TAMAMLANDI

Tamamlanan: milestones 0-24 ay, vaccinations 18 kayıt (TR hibrit), safety_alerts.json + Home guidance card, note log tipi.

Kalan: aşı otomatik hatırlatma trigger.
~~Milestone content medikal review~~ ✅ — resmi kaynaklardan (WHO, CDC, T.C. Sağlık Bakanlığı) araştırılıp doğrulandı.

### Sprint 3 — Data Model And Tracking Foundations ✅ TAMAMLANDI

Tamamlanan: GrowthRecord model + input + tile + timeline, placeholder metrics kaldırıldı, WHO büyüme eğrileri premium gated olarak eklendi, test kapsamı genişletildi.

### Sprint 4 — Home Experience And Persona Differentiation ✅ TAMAMLANDI

Tamamlanan: parent role persist, role-aware Home copy, Home "This month" rework, father persona tone/copy katmanı, note log tipi.

### Sprint 5 — Onboarding Rework — ✅ TAMAMLANDI (2026-03-14)

Kaynak: Adapty raporu + onboarding completion rate optimizasyonu.

**Karar: 7 adım → 5 adım + Value Summary + soft paywall**
**Build ✅, Test ✅ (8/8), Görsel tur ✅**

Mevcut flow (7 adım): Welcome → Role → User Name → Baby Info → Child Order → Disclaimer (4 kart) → Notification → Paywall
Yeni flow (5 adım): Welcome → Role → Family Info → Safety Note → Value Summary → Paywall

#### Adım adım spec:

**Step 0 — Welcome**
- Mevcut tasarım korunur
- "I have an account, sign in" placeholder KALDIRILıR (OnboardingView.swift:136)
- Yerine: "Restore purchases" linki veya tamamen sil

**Step 1 — Role**
- Mevcut haliyle kalır (anne/baba/bakıcı)

**Step 2 — Family Info** (merge: eski Step 2 + Step 3)
- Ebeveyn adı + bebek adı + doğum tarihi + cinsiyet TEK ADIMDA
- ScrollView ile (çok alan var)
- Privacy info box korunur

**Step 3 — Safety Note** (compact: eski Step 5)
- 4 kart → TEK compact disclaimer kartı
- Checkbox korunur: "Kinna'nın bilgilendirme amaçlı olduğunu anlıyorum"
- Detaylı disclaimer Settings'te zaten mevcut (LegalDisclaimerView)

**Step 4 — Value Summary** ← YENİ (paywall'dan hemen önce)
- Kişiselleştirilmiş: "{BabyName} {age} aylık. Bu ay seni neler bekliyor:"
- 1x milestone odağı (milestones.json'dan bebek yaşına göre)
- 1x yaklaşan aşı (VaccinationEngine'den hesaplanmış)
- 1x kısa rehber/hatırlatma (safety_alerts veya home content'ten)
- Bildirim izni BURADA istenir (notification previews ile)
- "İzin ver" + "Şimdi değil" butonları

**Sonra → Soft Paywall** (mevcut PaywallView, entryPoint: .onboarding)

#### Kaldırılanlar:
- **Child Order step** (OnboardingView.swift:425) — onboarding'den çıkar
- `childOrder` @AppStorage ve veri modeli KORunur — sadece UI'dan kaldırılır
- İleride Settings'e "Kaçıncı çocuğunuz?" olarak taşınabilir

#### Neden:
- 7 → 5 adım = daha yüksek onboarding completion rate
- Child order şu an gerçek personalizasyon farkı yaratmıyor
- Compact disclaimer = "yasal belge" hissi azalır
- Value Summary = paywall'dan önce "bu sana özel" hissi → trial conversion artışı
- Adapty: Gün 0'da %44.5 satın alma piki, kişiselleştirilmiş onboarding bunu maximize eder

#### Codex implementation notu:
- `totalSteps = 7` → `totalSteps = 5`
- progressBar `1...6` → `1...4`
- Step tag'leri yeniden numaralandırılacak
- `childOrderStep` view'ı kaldırılacak (kod silinebilir)
- `userNameStep` + `babyInfoStep` → tek `familyInfoStep`'e merge
- `disclaimerStep` → compact `safetyNoteStep`
- Yeni `valueSummaryStep` eklenir (milestone/aşı/rehber hesaplamaları)
- `notificationStep` kaldırılır — bildirim izni valueSummaryStep içine taşınır

### Sprint 6 — Single-Baby Lock + Auto Vaccine Reminders — KARARLANDI (2026-03-14)

#### 6a. Single-Baby Lock
**Karar:** MVP = tek bebek. Multi-baby v2'ye ertelenir (iCloud sync + partner paylaşımı ile birlikte).

**Mevcut durum:**
- `babies.first` ile tek bebek varsayılıyor ✅
- `DailyLog` ve `GrowthRecord`'da `babyID` var
- `VaccinationRecord` ve `AllergyLog`'da baby ilişkisi YOK

**Codex implementation:**
- UI'da "bebek ekle" seçeneği eklenmeyecek
- Mevcut `babies.first` pattern'i korunacak
- İlişki eksikliği (VaccinationRecord, AllergyLog) v2'de düzeltilecek — şimdi dokunma
- Settings'te bebek bilgisi düzenleme yeterli (yeni bebek ekleme yok)

#### 6b. Auto Vaccine Reminders
**Karar:** Yaklaşan aşılar için otomatik local notification schedule.

**Spec:**
- Her aşı için 2 notification: **3 gün önce** + **aşı günü sabahı (09:00)**
- 18 aşı × 2 = 36 notification → iOS 64 pending limit içinde ✅
- Premium gate: `MonetizationPolicy.canUseVaccineReminders` — free kullanıcıya hatırlatma gitmez
- Identifier format: `vaccine-{vaccineName}-{3d|0d}` (stabil, reschedule-safe)

**Schedule tetikleme noktaları:**
1. Onboarding'de bebek kaydedildiğinde (ilk schedule)
2. Premium açılınca (gate kalkınca backfill)
3. Restore purchases sonrası (backfill)
4. Bebek profili güncellenince (tarih değişirse reschedule)

**Önemli:** Reschedule öncesi eski pending request'ler `removeAllPendingNotificationRequests(withIdentifiers:)` ile temizlenmeli. NotificationManager'a `scheduleVaccineReminders(birthDate:)` ve `removeVaccineReminders()` methodları eklenmeli.

### Sprint 7 — Home Rework + Father Persona — KARARLANDI (2026-03-14)

#### 7a. Home "This Month" Rework
**Karar:** Placeholder'dan çıkar, 3 editorial modül.

**Modüller:**
1. **Milestone odağı kartı** — Bu ayın öne çıkan gelişim noktası (milestones.json'dan bebek yaşına göre)
2. **Yaklaşan aşı kartı** — Varsa tarihiyle, yoksa "Bu ay aşı yok ✓"
3. **Günün rehberi** — Yaşa göre rotate eden mikro-doz içerik (güvenlik, beslenme, oyun, uyku)

**Premium gate:** Free → 1 kart/gün, Premium → tüm kartlar (mevcut MonetizationPolicy kuralı korunur).

**Referans:** HomeView.swift:317 — mevcut placeholder modülleri bu yapıyla değiştirilecek.

#### 7b. Father Persona Tone/Copy
**Karar:** Presentation layer farkı — veri şeması değişmez, aynı milestone/veri, farklı destekleyici copy.

**Yaklaşım:** MVP'de `motherTip`/`fatherTip` JSON field'ı EKLENMEZ. Bunun yerine:
- Role'a göre notification body ve Home copy değişir (presentation layer)
- Anne → emzirme/beslenme odaklı aksiyon önerisi
- Baba → ten tene temas, oyun, bağlanma odaklı aksiyon önerisi
- Copy farkları `Localizable.xcstrings`'te `_mother` / `_father` suffix'li key'ler ile

**Implementasyon:** HomeView ve NotificationManager'da `parentRole` kontrolü, role-aware string seçimi.

### Sprint 8 — Hardening — KISMEN TAMAMLANDI (2026-03-14)

Tamamlanan:
- Test genişletme (Home vaccine planner, reminder scheduling, policy regressions)
- Genel UI consistency pass
- Subscription logging temizliği
- Notification permission edge-case fix

Kalan:
- `.gitignore`'a `build/` ve `design/` eklenmesi (bağımsız, küçük iş)
- Release-risk warning cleanup (simulator / runtime gürültüsü)
- MVVM alignment — ağır ekranlar için ViewModel çıkarma (özellikle Home, Tracking)

### Sprint 9 — Insight Layer + Post-MVP Polish — KISMEN TAMAMLANDI (2026-03-14)

#### 9a. Büyüme Eğrisi (WHO persentil) — ✅ TAMAMLANDI
**Durum:** Premium gated growth charts eklendi.

**Tamamlanan scope:**
- WHO weight-for-age / length-for-age referans eğrileri
- `GrowthRecord` verisini chart üstünde gösterim
- Yaşa ve cinsiyete göre doğru dataset seçimi
- Premium gating
- `Takip` içinde gizlenebilir kart + `Ayarlar`dan görünürlük toggle'ı
- Mobilde sadeleştirilmiş grafik: alt sınır / orta çizgi / üst sınır + kullanıcı noktaları

#### 9b. Uyku Analizi Özeti — ✅ TAMAMLANDI
**Durum:** Tracking içinde kompakt uyku özeti kartı eklendi.

**Tamamlanan scope:**
- Son 7 gün içindeki takip edilen uyku kayıtlarından ortalama süre
- Basit trend özeti (artan / azalan / stabil / veri yetersiz)
- Tracking içinde kompakt özet kartı + mini günlük bar görünümü
- Veri az olduğunda daha dürüst copy (`1 gün`, `birkaç gün daha ekle`)
- Medikal claim yok, sadece gözlemsel içgörü

#### 9c. Baba Modu Derinleştirme — ✅ TAMAMLANDI
**Durum:** Home ve bildirim katmanında role-aware copy derinleştirildi.

**Tamamlanan scope:**
- Notification title/body varyantları (günlük reminder + aşı reminder)
- Home guidance action satırlarında role-aware farkların genişletilmesi
- Motivasyon alıntıları, yaş kartı alt metni, `Bu ay için` intro ve premium CTA'nın role-aware hale getirilmesi
- `Ayarlar`dan rol değişince Home ve bekleyen bildirimlerin yeni role göre yeniden senkronlanması
- Veri modeli değiştirilmedi; presentation layer yaklaşımı korundu

#### 9d. Subscription Polish — ✅ TAMAMLANDI
**Karar:** RevenueCat kenar durumları ve App Store review prompt davranışı tamamlanır.

**Tamamlanan scope:**
- Paywall tarafında no-offering / missing-plan / network hata guard'ları
- Aktif abonelikte gereksiz offering yükleme denemesinin kaldırılması
- Home üzerinde veri bazlı App Store review prompt mantığı
- Prompt için tek-seferlik / versiyon-bazlı / cooldown'lı koruma
- İlk değer döngüsü için minimum engaged day + meaningful action eşiği

#### 9e. Emzirme Zamanlayıcı
**Karar:** Hemen implement edilmez; önce net product spec gerekir.

**Önce cevaplanacaklar:**
- Sadece son emzirme üzerinden sayaç mı?
- Reminder mı, timer mı, yoksa analiz yüzeyi mi?
- Tek aksiyon mu, sol/sağ göğüs ayrımı var mı?

**Not:** Scope netleşmeden implementasyona geçilmez.

## Sprint Skill Matrix

Rule:

- Start each sprint by naming the primary skill in the prompt.
- Add a supporting skill only when the task clearly crosses both domains.

### Sprint 1 — Release Foundations

Primary skills:

- `kinna-release-hardening`
- `kinna-monetization`

Supporting skills:

- `kinna-swiftui-design-system` if runtime fixes touch visible UI or theme tokens

Suggested prompts:

- `kinna-release-hardening ile Sprint 1 blocker'larini temizleyelim`
- `kinna-monetization ile free premium matrisini netlestirelim`

### Sprint 2 — Core Content Correctness

Primary skills:

- `kinna-content-data-ops`

Supporting skills:

- `kinna-persona-localization` if content wording must vary by mother / father / caregiver
- `kinna-home-content` if reviewed content needs a new Home module or Home card structure

Suggested prompts:

- `kinna-content-data-ops ile milestone ve vaccination verilerini MVP kapsamına tamamlayalım`
- `kinna-content-data-ops ile aylik milestone iceriklerini tek tek gozden gecirelim`

### Sprint 3 — Data Model And Tracking Foundations

Primary skills:

- `kinna-growth-tracking`

Supporting skills:

- `kinna-release-hardening` if model changes create migration risk
- `kinna-swiftui-design-system` if tracking UI needs component or token cleanup

Suggested prompts:

- `kinna-growth-tracking ile GrowthRecord modelini implement edelim`
- `kinna-growth-tracking ile tracking ekranindaki placeholder metricleri kaldiralim`

### Sprint 4 — Home Experience And Persona Differentiation

Primary skills:

- `kinna-home-content`
- `kinna-persona-localization`

Supporting skills:

- `kinna-swiftui-design-system` for Home redesign, card hierarchy, and component polish
- `kinna-monetization` if premium placement is changed on Home

Suggested prompts:

- `kinna-home-content ile Bu ay icin bolumunu yeniden tasarlayalim`
- `kinna-persona-localization ile baba persona davranisini ve copy farklarini implement edelim`

### Sprint 5 — Hardening

Primary skills:

- `kinna-release-hardening`

Supporting skills:

- `kinna-swiftui-design-system` for final UI consistency passes
- `kinna-persona-localization` for string cleanup before broader testing
- `kinna-content-data-ops` if late content fixes are still entering the build

Suggested prompts:

- `kinna-release-hardening ile Sprint 5 hardening turunu yapalim`
- `kinna-release-hardening ile release oncesi kontrol listesini calistiralim`

## P0 Release Blockers

- ~~Fix SwiftData migration for `VaccinationRecord`.~~ ✅ Done (Sprint 1).

- ~~Configure RevenueCat with a real public app API key.~~ ✅ Done (Sprint 1). Sandbox verified, ASC approval pending.

- ~~Add real premium gating.~~ ✅ Done. 7/7 gating kuralı kodda (MonetizationPolicy.swift).

- ~~Fix bundled font loading.~~ ✅ Done (Sprint 1).

- ~~Expand MVP data coverage to match the product promise.~~ ✅ Büyük ölçüde tamamlandı.
  - `milestones.json`: 0-24 ay kapsanıyor (SPEC 0-60 ay diyor, ileride genişletilecek).
  - `vaccinations.json`: 18 kayıt, TR takvimi kapsamlı.
  - `safety_alerts.json`: 6 uyarı var, Home guidance card'larında gösteriliyor.

- ~~Restore purchases bug.~~ ✅ Done. SubscriptionManager'a delegated, error handling eklendi.

- ~~Trial copy alignment.~~ ✅ Done. Paywall 7 gün gösteriyor (MonetizationPolicy.trialLengthDays = 7).

## P1 Product Gaps

- ~~Introduce a `GrowthRecord` SwiftData model for weight / height tracking.~~ ✅ Done.
  - Model, input UI, tracking tile, timeline ve WHO büyüme eğrileri mevcut.

- ~~Persist and use parent role from onboarding.~~ ✅ Done.
  - `@AppStorage("parentRole")` ile persist ediliyor.
  - HomeView role-aware copy kullanıyor (mother/father/caregiver).

- ~~Define single-baby vs multi-baby model explicitly.~~ → KARARLANDI: MVP = single-baby.
  - `babies.first` pattern korunur, "bebek ekle" UI eklenmez.
  - DailyLog/GrowthRecord'da babyID var, VaccinationRecord/AllergyLog'da yok — v2'de düzeltilecek.
  - Detay: Sprint 6a.

- ~~Complete vaccination reminder behavior.~~ ✅ Done.
  - 3 gün önce + aşı günü sabahı, premium gate, 4 tetikleme noktası, stabil identifier.

- ~~Replace placeholder metrics in tracking.~~ ⚠️ Kısmen tamamlandı.
  - GrowthRecord modeli + input + tracking tile + timeline entegrasyonu yapıldı.
  - WHO persentil grafikleri Faz 2'de.

- ~~Improve daily notes.~~ ⚠️ Kısmen tamamlandı.
  - Bağımsız note log tipi eklendi (DailyLog.swift:11).
  - Hâlâ content strategy kararı lazım: age-based, persona-based, rotating editorial?

- ~~Review milestone content month by month.~~ ✅ Done.
  - WHO, CDC, T.C. Sağlık Bakanlığı kaynaklarından doğrulandı.
  - 0-24 ay, 8 band, social/language/cognitive/motor kategorileri.

- ~~Rework the Home "This month" section.~~ ✅ Done.
  - Milestone odağı + yaklaşan aşı + dönen rehber kartı.

- ~~Harden onboarding flow.~~ → Sprint 5 Onboarding Rework olarak yeniden tanımlandı.
  - 7 → 5 adım, "I have account" kaldırılıyor, Value Summary ekleniyor.
  - Detaylı spec: Sprint 5 bölümüne bkz.

- ~~Define father persona behavior more explicitly.~~ ✅ Done.
  - Presentation layer farkı, role-aware Home / notification tone.

- Align implementation with the stated MVVM architecture.
  - Current code is mostly view-centric with lightweight engines and managers.
  - If MVVM remains a requirement, introduce view models gradually for state-heavy screens.

## P1 Quality

- ~~Add meaningful tests for product logic.~~ ✅ 19 test mevcut.
  - Milestone data coverage (0-24 ay band check)
  - GrowthRecord persistence
  - DailyLog note type
  - Vaccination data (18 kayıt, TR schedule)
  - Safety alert data (6+ alert)
  - MonetizationPolicy rules (trial, limits, gates)
  - Free history cutoff (7 gün window)

- Reduce release-risk logs. **← AÇIK**
  - ~~RevenueCat invalid-key logs.~~ ✅ Done (DEBUG guard).
  - Font loading warnings — durumu doğrulanmalı.
  - Simulator launch warnings.

## P1 Commercial Decisions — KARARLANDI (2026-03-13)

Kaynak: Adapty "State of In-App Subscriptions 2026" raporu (16K app, $3B veri).

### Trial Süresi

- 3 gün → **7 gün** olarak değiştirildi.
- Neden: Health & Fitness'te Gün 4-7'de ikinci satın alma piki var, bebek uygulamasında 3 günde değer hissedilmiyor (veri birikimi lazım).
- Aksiyon: RevenueCat product config + App Store Connect'te trial süresini 7 güne çek.

### Paywall Stratejisi — Hibrit 3 Katmanlı

- Katman 1: **Onboarding sonu** — kişiselleştirilmiş değer özeti ekranı + "7 gün ücretsiz dene" butonu + "Önce keşfedeyim" skip linki (soft paywall).
- Katman 2: **İlk premium aksiyonda** — soft paywall tekrar tetiklenir (6. milestone save, 2. home card vs.).
- Katman 3: **Trial sonrası** — hard gate (premium özellikler kilitli).
- Neden: Hard paywall %21 daha yüksek LTV ama %50 daha düşük conversion. Hibrit ikisini birleştiriyor. Gün 0'da %44.5 satın alma piki var, onboarding paywall bunu yakalar.

### Bölgesel Fiyatlandırma

- Türkiye: 0.7x endeks (~₺79.99/mo tier veya uygun Apple tier).
- Avrupa (UK, FR, DE, IT, ES): 1.2x endeks ($5.99 tier'a çıkarılabilir).
- ABD: $4.99/mo base.
- Hindistan, Endonezya: 0.6-0.7x endeks (~$2.99-3.49).
- Aksiyon: App Store Connect'te subscription pricing bölgesel tier ayarı. RevenueCat otomatik çeker.
- Neden: Yerelleştirme testleri %62.3 LTV kazanı gösteriyor (en yüksek A/B test kategorisi).

### Haftalık Plan

- **Eklenmeyecek.**
- Neden: Sektörde %55.6 gelir payı ama bu Utilities/AI apps tarafından sürükleniyor. Health & Fitness'te yıllık plan büyüyor. Bebek uygulaması uzun süreli (0-5 yaş), haftalık plan güven kırıcı.

### Free vs Premium Özellik Matrisi

Strateji: "Progressive depth" — free tier tattırır ve trial başlatır, premium derinlik sağlar. Sınırlar Gün 4-7 ikinci satın alma pikini tetikleyecek şekilde tasarlandı.

#### Free — "Tattır" Katmanı

| Özellik | Sınır | Neden free? |
|---|---|---|
| Onboarding + bebek profili | Sınırsız | Giriş noktası |
| Günlük takip (beslenme, uyku, bez) | Son 7 gün geçmiş | Gün 0'da değer görmesi lazım, geçmiş veri premium motivasyonu yaratır |
| Aylık gelişim kartları | Sadece bu ay | Bu ayki milestone'ları görsün, geçmiş/gelecek aylar premium |
| Aşı takvimi | Görüntüleme free | Sağlık bilgisi kilitlemek güven kırar |
| Ek gıda günlüğü | İlk 5 gıda | Tattırsın, devamı premium |
| Home kartları | 1 kart/gün | Günlük değer hissi, fazlası premium |

#### Premium — "Derinlik" Katmanı

| Özellik | Açıklama |
|---|---|
| Günlük takip tam geçmiş | 7 gün sınırı kalkar, tüm loglar erişilebilir |
| Tüm ayların gelişim kartları | Geçmiş ve gelecek aylar açılır |
| Aşı hatırlatmaları | Push notification ile aşı reminder'ları |
| Ek gıda günlüğü sınırsız | 5 gıda limiti kalkar |
| Tüm home kartları | Günlük 1 kart sınırı kalkar |
| Güvenlik uyarıları | Yaşa göre push alert'ler (tamamı premium) |
| Milestone kaydetme sınırsız | Mevcut 5 limit kalkar |
| Büyüme eğrileri (Faz 2) | WHO persentil grafikleri |
| AI soru-cevap (Faz 2) | Limitli free olabilir |

#### Kullanıcı Yolculuğu

```
Gün 0: Onboarding → bebeğin bu ayı, bugünkü kart, ilk log
       → Onboarding sonu paywall → trial başlat veya skip
Gün 1-3: Logları giriyor, 1 kart/gün, milestone keşfediyor
         → Değer birikiyor
Gün 4-7: "Geçen haftaki loglarıma bakayım" → 7 gün sınırı
         "Gelecek ay ne olacak?" → Bu ay sınırı
         "Aşı hatırlatması gelmiyor" → Premium
         → İkinci satın alma piki tetiklenir
Gün 7: Trial bitiyor → Hard gate → Karar anı
```

#### Kritik Kural

Aşı takvimi görüntüleme her zaman free kalmalı. Sağlık bilgisini kilitlemek "çocuğumun sağlığını paraya çeviriyor" algısı yaratır. Hatırlatma (push) premium olabilir — bu bir kolaylık özelliği.

### Güncel Plan Özeti

| Plan | Fiyat | Trial |
|---|---|---|
| Aylık | $4.99/mo (bölgesel ayarlı) | 7 gün |
| Yıllık | $39.99/yr (bölgesel ayarlı) | 7 gün |

## P2 Roadmap Alignment

These are already present in `SPEC.md`, but not required before MVP release:

- Finalize App Store category: Health & Fitness vs Medical.
- Finalize naming, domain, and trademark checks.
- Decide AI provider and free usage limit.
- Decide long-term iCloud sync scope.
- Define first beta tester loop.
- Scope PhotoKit-based timeline feature.

## Suggested Next Steps

1. ~~Fix persistence and packaging risks.~~ ✅
2. ~~Define commercial behavior.~~ ✅
3. ~~Close MVP scope mismatches.~~ ✅
4. ~~Paywall v2 (auto-renewal, bugün ücret alınmaz, feature sıralaması, Pro→Premium).~~ ✅
5. ~~Codex değişikliklerini commit et.~~ ✅ (`d337885` + `4ab7e6d`)
6. ~~Sprint 5: Onboarding rework~~ ✅ — 7→5 adım + Value Summary
7. ~~Sprint 6a: Single-baby lock~~ ✅
8. ~~Sprint 6b: Auto vaccine reminders~~ ✅
9. ~~Sprint 7a: Home "This month" rework~~ ✅
10. ~~Sprint 7b: Father persona tone/copy~~ ✅
11. ~~Sprint 9a: Growth charts~~ ✅
12. ~~Sprint 9b: Sleep summary~~ ✅
13. **Sprint 8 remaining** — `.gitignore`, warning cleanup, MVVM alignment
14. **Sprint 9 remaining** — emzirme zamanlayıcı spec
15. **App Store Connect — Release Checklist:**

### ASC Release Checklist

| # | Adım | Durum |
|---|---|---|
| 1 | App oluştur (com.osmanseven.kinna) | ✅ |
| 2 | Subscription group + 2 product (monthly + yearly, 7-day trial) | ✅ |
| 3 | RevenueCat dashboard: app + products + entitlement (`pro`) + offering (`default`) | ✅ |
| 4 | RevenueCat public API key → `SubscriptionManager.swift` | ✅ |
| 5 | Sandbox test: purchase + restore + trial + expiry | ✅ |
| 6 | Bölgesel fiyat tier ayarı (TR 0.55x, EU 1.2x, IN 0.6x) | ✅ |
| 7 | Privacy nutrition label (Purchases only) | ✅ |
| 8 | Metadata gir: title, subtitle, description, keywords | [ ] |
| 9 | URLs gir: privacy, terms, support, marketing | [ ] |
| 10 | Age rating: 4+ | [ ] |
| 11 | Screenshots üret (6 ekran, 6.7" iPhone) | [ ] |
| 12 | App Review notes yaz | [ ] |
| 13 | Archive + Upload (Xcode → ASC) | [ ] |
| 14 | Submit for Review | [ ] |

## Done Definition For MVP

MVP should be considered ready only when:

- ~~App launches cleanly on a fresh install and on an upgraded install.~~ ✅
- ~~Fonts load correctly in runtime builds.~~ ✅
- ~~RevenueCat configuration works with real offerings.~~ ✅ (ASC approval pending)
- ~~At least one premium behavior is actually enforced.~~ ✅ (7/7 gating)
- ~~Milestone, vaccination, and safety datasets match the announced MVP scope.~~ ✅ (0-24 ay)
- ~~Parent persona copy no longer contradicts selected onboarding role.~~ ✅
- ~~Tracking, vaccination, and food records are stored in a model that matches the intended user scope.~~ ✅ (MVP = single-baby)
- ~~Critical flows are covered by basic automated tests.~~ ✅ (7 test)
- App Store Connect subscription approval completed. **← AÇIK**
- Bölgesel fiyat tier'ları ayarlandı (TR, EU, Hindistan). **← AÇIK**
- ~~Milestone content medikal doğruluk kontrolü geçti.~~ ✅
