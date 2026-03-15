# Kinna — App Preview Animatic

Last updated: 2026-03-15

Bu dosya, ilk App Preview versiyonu icin **zaman kodlu animatic planidir**.

Amac:
- motion designer / editor'a verilebilecek kadar net siralama
- exact chapter yapisi
- hangi raw capture nerede kullanilacak

## Master Export

- Canvas: `1920 x 886`
- FPS: `30`
- Codec: `H.264`
- Hedef sure: `20 sn`
- Audio: opsiyonel, hafif ambient
- Voice-over: `Yok`

## Global Motion Rules

- chapter girisleri `300–450 ms` ease-out
- text once, phone sonra
- cihazlarda yavas scale-in veya slide-up
- her chapter'da tek ana hareket
- dikkat dagitan hizli cut yok

## Timeline

### 0.0s – 0.8s

Screen:
- cream background
- kucuk kicker pill

Motion:
- background bloom fade-in
- headline ilk satir fade-up

Text:
- `Her gun`

### 0.8s – 2.8s

Screen:
- Chapter 1 / Home

Text:
- `Her gun`
- `neyin onemli`
- `oldugunu gor`
- subline:
  - `Asi, gelisim ve gunluk rehberlik ilk bakista.`

Visual:
- `01_home_tr.png` device icinde
- Home screenshot hafif yukaridan asagi slide

Motion:
- text settle
- phone 96% → 100% scale

### 2.8s – 3.1s

Transition:
- horizontal wipe + terra color carry

### 3.1s – 6.0s

Screen:
- Chapter 2 / Vaccines

Text:
- `Asi takvimi,`
- `hatirlatmalarla`
- subline:
  - `Planlanan dozlari kacirma.`

Visual:
- `02_vaccination_tr.png`
- hero card crop once vurgulanir

Motion:
- phone soldan hafif gelir
- headline once, phone sonra

### 6.0s – 6.3s

Transition:
- cream wipe

### 6.3s – 9.4s

Screen:
- Chapter 3 / Tracking

Text:
- `Beslenme, uyku,`
- `buyume tek yerde`
- subline:
  - `Gunluk rutini hizlica kaydet.`

Visual:
- `03_tracking_tr.png`
- tracking grid ana cihaz
- timeline icin ikinci dar crop opsiyonel

Motion:
- ana cihaz alttan gelir
- timeline crop sagdan fade-slide

### 9.4s – 9.8s

Transition:
- sage fill + soft blur

### 9.8s – 13.6s

Screen:
- Chapter 4 / Growth + Milestones

Text:
- `WHO buyume`
- `egrileri ve`
- `gelisim takibi`
- subline:
  - `Bu ayin gelisimini daha guvenle gor.`

Visual:
- `04_growth_tr.png`
- `05_milestones_tr.png`
- biri ana cihaz, biri offset crop

Motion:
- growth chart once gorunsun
- milestones crop sonra crossfade ile gelsin

### 13.6s – 13.9s

Transition:
- terra-soft card slide

### 13.9s – 17.0s

Screen:
- Chapter 5 / Foods

Text:
- `Yeni besinleri`
- `guvenle takip et`
- subline:
  - `Reaksiyonlari not al, iyi gelenleri gor.`

Visual:
- `06_foods_tr.png`
- sayaclar ve son eklenenler crop

Motion:
- listede yavas push-in
- reaction badge'lerine kisa emphasis glow

### 17.0s – 20.0s

Screen:
- Outro

Text:
- `Kinna`
- `Ilk yillar icin sakin bir rehber`

Badges:
- `Anne · Baba · Bakim Veren`
- `WHO + T.C. Saglik Bakanligi`
- `Verilerin cihazinda kalir`

Motion:
- badges sirayla pop-in
- logo lockup fade-in
- son `400 ms` hafif hold

## Chapter Source Map

1. Chapter 1
   - `raw_tr/01_home_tr.png`
2. Chapter 2
   - `raw_tr/02_vaccination_tr.png`
3. Chapter 3
   - `raw_tr/03_tracking_tr.png`
4. Chapter 4
   - `raw_tr/04_growth_tr.png`
   - `raw_tr/05_milestones_tr.png`
5. Chapter 5
   - `raw_tr/06_foods_tr.png`

## Editor Notes

- screenshot UI'yi kucuk ama okunur tut
- text ile screenshot arasinda yarismaya izin verme
- chapter'larin her biri ayri renkle hissedilsin:
  - 1 cream/sage
  - 2 terra
  - 3 cream
  - 4 sage
  - 5 blush/cream
  - outro charcoal

## First Review Criteria

- ilk 2 saniyede deger net mi
- sessiz izleyince anlasiliyor mu
- text fazla mi
- chapter'lar birbirine cok mu benziyor
- poster frame tek basina guclu mu
