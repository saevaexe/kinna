# Kinna — App Store Preview Strategy

Last updated: 2026-03-15

Bu dosya, Kinna'nin App Store screenshot setinden ayri olarak **App Preview** videosu icin yaratıcı format kararini kilitler.

## Official Constraints

Resmi Apple kaynaklarina gore:

- App Preview opsiyoneldir ama product page'de screenshot'lardan once gelir.
- iOS icin portrait veya landscape olabilir.
- Sure:
  - minimum `15 sn`
  - maksimum `30 sn`
- Maksimum dosya boyutu `500 MB`
- Maksimum frame rate `30 fps`
- Poster frame product page'de kritik; ayrica autoplay kapaliysa yalnizca poster frame gorunur.
- iPhone 6.9" / 6.3" / 6.1" iPhone sınıflari icin kabul edilen landscape preview cozunurlugu `1920 x 886`.

Kaynaklar:
- Apple App Preview specifications:
  https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/
- Apple Upload app previews and screenshots:
  https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/
- Apple Creating your product page:
  https://developer.apple.com/app-store/product-page
- Apple App Previews:
  https://developer.apple.com/app-store/app-previews/

## What the reference creatives are doing

Kullanici referanslarindan ortak pattern:

1. **Landscape strip**
   - tek bir vertical phone screenshot yerine yatay bir sahne
   - 4–5 bolum yan yana ilerliyor

2. **One idea per panel**
   - her panel tek bir fayda satiyor
   - headline kisa ve buyuk

3. **Big typography first**
   - video sessiz autoplay varsayimi
   - ilk 1–2 saniyede metin deger satmali

4. **Phones as props, not the whole story**
   - ekran goruntusu tek basina yeterli degil
   - cihaz + arka plan + sekil + sticker/ikon ile destekleniyor

5. **Strong color fields**
   - her panelin net bir renk kimligi var
   - text ve UI bundan ayrisiyor

6. **Fast chapter rhythm**
   - sabit uzun demo kayit degil
   - chapter-based, motion graphic mantigi

7. **Campaign framing**
   - headline once gelir
   - cihaz proof olarak ikinci katmanda durur
   - her frame poster gibi tek bir faydayi satar

## Recommendation for Kinna

Kinna icin preview, screenshot'lardan farkli bir format kullanmali.

### Do not do

- 20 saniye boyunca tek bir app walkthrough
- her tab'i birer birer gosteren recording
- cok fazla kucuk metin
- sadece vertical ekran capture'larini art arda kesmek

### Do this instead

- landscape master canvas
- chapter-based preview
- her chapter bir fayda satar
- raw app capture'lar device frame veya crop icinde kullanilir
- typographic storytelling on planda olur

## Launch format

### Orientation

- **Landscape**

Sebep:
- referanslardaki chapter diliyle daha uyumlu
- buyuk tipografi icin daha fazla yatay alan var
- birden fazla cihaz/crop ayni sahnede gosterilebilir
- screenshot setinden ayri bir creative karakter kazandirir

### Master resolution

- `1920 x 886`
- `30 fps`
- H.264

### Length

- hedef: `18–22 sn`

Bu, Apple limitleri icinde kalir ve launch icin fazla uzamaz.

## Kinna preview structure

### Overall structure

5 chapter + outro

1. Home / daily guidance
2. Vaccines / reminders
3. Tracking / daily routine
4. Growth + milestones
5. Foods + privacy close

### Why not 6 separate chapters?

- 6 chapter cok katalog hissi verir
- growth + milestones ayni "development confidence" chapter'inda birlesebilir
- foods + privacy ayni kapanis chapter'inda birlesebilir

## Recommended chapter sequence

### Chapter 1 — Daily guidance

Goal:
- Kinna'nin ana degeri ne?

Headline:
- TR: `Her gun neyin onemli oldugunu gor`
- EN: `See what matters today`

Visual:
- Home screenshot crop
- "Bu ay icin" cards
- yumusak cream + sage background

Duration:
- `3.0 sn`

### Chapter 2 — Vaccines

Goal:
- TR pazarindaki en guclu utility

Headline:
- TR: `Asi takvimi, hatirlatmalarla`
- EN: `Vaccine tracking with reminders`

Visual:
- hero vaccine card
- timeline / list crop
- terra accent

Duration:
- `3.5 sn`

### Chapter 3 — Tracking

Goal:
- her gun kullanilan degeri satmak

Headline:
- TR: `Beslenme, uyku, buyume tek yerde`
- EN: `Feeding, sleep, growth in one place`

Visual:
- Tracking grid
- quick actions
- one or two timeline crops

Duration:
- `3.5 sn`

### Chapter 4 — Development confidence

Goal:
- premium depth + scientific trust

Headline:
- TR: `WHO buyume egrileri ve gelisim takibi`
- EN: `WHO growth charts and milestones`

Visual:
- growth charts crop
- milestones progress ring + list crop

Duration:
- `4.0 sn`

### Chapter 5 — Foods + privacy close

Goal:
- practical parenting use case + trust close

Headline:
- TR: `Yeni besinleri takip et, verilerin cihazinda kalsin`
- EN: `Track foods, keep data on device`

Visual:
- foods screen
- reaction badges
- short privacy closing badge

Duration:
- `3.5 sn`

### Outro / CTA

Goal:
- clean brand finish

Headline:
- TR: `Kinna`
- Subline: `Ilk yillar icin sakin bir rehber`
- EN: `A calm guide for the early years`

Duration:
- `2.0–3.0 sn`

## Motion language

### Allowed motion

- slow horizontal pan
- soft scale-in on phones
- chapter card slide
- pill/badge pop
- quote fade

### Avoid

- hyper-fast zooms
- gamer-like transitions
- too many floating particles
- tiny UI pointer demos

## Visual system

### Background palette

- cream
- blush / terra
- sage
- occasional charcoal

### Typography

- strong sans headline
- clean sans body
- gerekirse ufak editorial italic vurgu
- max 2 ana text boyutu per panel

### Device use

- 1 large phone per chapter
- optional second crop or offset phone
- hafif acili / offset yerlestirme kullanilabilir
- avoid showing 4 full phones in every panel

## Poster frame strategy

Poster frame kritik.

Secim:
- Chapter 1 veya Chapter 2'den bir frame
- buyuk headline + temiz device + net fayda

En iyi aday:
- `Her gun neyin onemli oldugunu gor`
  veya
- `Asi takvimi, hatirlatmalarla`

Poster frame'de:
- buyuk metin
- tek dominant cihaz
- az kalabalik

## Raw capture usage

Halihazirda mevcut TR raw set:

- `01_home_tr`
- `02_vaccination_tr`
- `03_tracking_tr`
- `04_growth_tr`
- `05_milestones_tr`
- `06_foods_tr`

Bu set preview icin yeterli base malzeme veriyor.

Preview, bu raw'lari:
- tam ekran degil
- crop / zoom / masked device olarak
kullanacak.

## Production plan

### Phase 1

- preview chapter storyboard kilitle
- her chapter icin exact line copy kilitle

### Phase 2

- `preview.html` bu yeni landscape chapter sistemine gore yenilenir
- static board olarak once review edilir

### Phase 3

- video animatic:
  - still board + simple transitions
  - no full editing polish yet

### Phase 4

- final export:
  - `1920 x 886`
  - H.264
  - `18–22 sn`

## Recommendation summary

Kinna icin App Preview:

- **screenshot mantigi ile degil**
- **landscape chapter trailer** mantigiyla yapilmali

En dogru format:
- 5 chapter
- 18–22 sn
- big headline first
- app UI as supporting proof
- screenshot setiyle ayni fayda sirasini koruyan ama daha sinematik bir layout
