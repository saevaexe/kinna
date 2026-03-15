# Kinna — App Store Capture Checklist

Last updated: 2026-03-14

Bu dosya raw screenshot capture operasyonu icindir.

Amaç:
- her screenshot icin exact veri hazirligi
- exact scroll pozisyonu
- exact state
- capture sirasinda hata cikmasini azaltmak

## Global Capture Rules

### Device / Simulator

- Tek bir primary portrait iPhone simulator kullan
- Tum raw capture'lari ayni cihazdan al
- Gerekirse sonradan 6.1 preview readability icin ikinci kontrol yap

Helper script:
- [capture_commands.sh](/Users/osmanseven/Kinna/AppStore/capture_commands.sh)

Ornek akış:

```bash
./AppStore/capture_commands.sh "iPhone 17 Pro Max" boot
./AppStore/capture_commands.sh "iPhone 17 Pro Max" status-on
./AppStore/capture_commands.sh "iPhone 17 Pro Max" capture /Users/osmanseven/Kinna/design/AppStore_20260314/raw_tr/01_home_tr.png
./AppStore/capture_commands.sh "iPhone 17 Pro Max" status-off
```

Premium screenshot state gerekiyorsa:

```bash
KINNA_SCREENSHOT_PREMIUM=1 ./AppStore/capture_commands.sh "iPhone 17 Pro Max" boot
```

Not:
- Bu override sadece `DEBUG` build'de calisir.
- Release davranisini etkilemez.

### Status bar

Capture oncesi:

```bash
xcrun simctl status_bar booted override \
  --time 09:41 \
  --dataNetwork wifi \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100
```

Capture sonrasi reset:

```bash
xcrun simctl status_bar booted clear
```

### Language sets

Iki set:
- TR
- EN

Kural:
- once TR tum capture
- sonra EN tum capture

### Demo identity

Primary profile:
- Bebek: `Ela`
- Yas: `2 ay 13 gun`
- Cinsiyet: `Kiz`
- Rol:
  - TR set: `Anne`
  - EN set: `Mother`

## Shared Demo Data Baseline

Tum set oncesi ortak veri:

- Home kartlari dolu
- Asi planinda:
  - tamamlanan dozlar
  - yaklasan dozlar
- Tracking'te:
  - beslenme
  - uyku
  - bez
  - not
  - tarti ve boy
- Milestones'ta:
  - bu ay icin birkac tamamlanmis tas
- Growth charts'ta:
  - en az `2` olcum noktasi
- Settings'te:
  - bildirim toggle acik
  - legal satirlari temiz

## Screenshot 1 — Home

### Target screen

- `Home`

### Required state

- Premium aktif
- `Bu ay icin` bolumu `3/3 acik`
- Kartlar:
  - Asi plani
  - Gelisim odagi
  - Gunun rehberi
- Greeting dogal
- Ust yas karti tam gorunsun

### Scroll position

- Ust yas kartinin alt kismi + yesil quote karti + `Bu ay icin` ve ilk `3` kart ayni ekranda

### Must hide / avoid

- debugging state
- paywall / upsell
- yarim kesilmis kart
- bos state

### Final capture check

- `3/3 acik` label okunuyor
- `Bu ay icin` bolumu asıl kahraman
- quote karti ekrani boğmuyor

## Screenshot 2 — Vaccination

### Target screen

- `Aşı Planı`

### Required state

- Hero kartta `Sıradaki doz`
- Tarih dolu
- `Tamamlananlar` altında en az `3` satir
- `Yaklaşan` altında en az `2` satir
- `Gelecek` gorunmek zorunda degil

### Scroll position

- Hero kart
- tamamlananlar basligi ve listesi
- yaklasan bolumunun en az `2` satiri

### Must hide / avoid

- acik modal
- ertele action state
- fazla uzun manuel kayit listesi

### Final capture check

- Hero kart net
- Asi mantigi hemen anlasiliyor
- Tarihler okunur ama kalabalik degil

## Screenshot 3 — Tracking

### Target screen

- `Takip`

### Required state

- Kart grid dolu:
  - Emzirme
  - Uyku
  - Bez
  - Son Tarti
  - Son Boy
  - Notlar
- Emzirme kartinda alt satir olabilir ama dikkat dagitmamali
- Alt timeline'in ilk satirlari gorunsun

### Scroll position

- Ust grid tam
- hizli aksiyon butonlari tam
- timeline'in ilk `2-3` satiri gorunsun

### Must hide / avoid

- buyume egrisi karti default capture'a girmesin
- bos kartlar
- modal sheet

### Final capture check

- tracking utility bir bakista anlasiliyor
- ekran ne cok bos ne cok kalabalik

## Screenshot 4 — Growth Charts

### Target screen

- `Büyüme Eğrisi`

### Required state

- `Tartı` secili
- `Son ölçüm` karti gorunur
- Grafik:
  - alt sinir
  - orta cizgi
  - ust sinir
  - kullanici noktasi / noktalari
- Y-axis ve X-axis okunur

### Scroll position

- Ust segment
- son olcum karti
- grafiğin tamami
- legend tam

### Must hide / avoid

- fazla bos alan
- kesik/yarim legend
- gereksiz ekstra aciklama

### Final capture check

- grafik tek bakista anlatıyor mu
- `Beklenen aralıkta` metni gorunur mu

## Screenshot 5 — Milestones

### Target screen

- `Gelişim Taşları`

### Required state

- Premium aktif
- bu ay secili
- progress ring dolu
- en az `4-5` milestone satiri gorunur
- category badges gorunsun

### Scroll position

- screen top
- progress ring + ay chips
- ilk milestone satirlari

### Must hide / avoid

- free upsell karti
- paywall
- kilitli ay secimi

### Final capture check

- progress net
- kategori cesitliligi gorunuyor
- ekran "gelisim rehberi" hissi veriyor

## Screenshot 6 — Foods / Reactions

### Target screen

- `Besin Takibi`

### Required state

- `Denenen / Sorunsuz / Dikkat` sayaclari gorunsun
- `Son eklenenler` listesinde en az 5 item olsun
- Reaksiyon badge'lerinde cesitlilik olsun:
  - `Iyi`
  - `Hafif`
  - `Ciddi`

### Scroll position

- liste ve alt CTA tek ekranda gorunsun

### Must hide / avoid

- modal sheet
- cok bos liste
- tekrar eden tek tip besinler

### Final capture check

- liste okunur mu
- reaksiyon takibi degeri tek bakista anlasiliyor mu

## Optional Screenshot 7 — Value Summary

### Target screen

- Onboarding `Value Summary`

### Required state

- milestone card
- aşı card
- kısa rehber
- bildirim preview kartlari

### Scroll position

- ekran tam
- CTA gorunebilir ama asiri dominant olmamali

### Use rule

- sadece 7. screenshot kullanmaya karar verirsek capture al

## TR Capture Run Order

1. Home
2. Vaccination
3. Tracking
4. Growth Charts
5. Milestones
6. Foods
7. Optional Value Summary

## EN Capture Run Order

TR ile ayni sira

## Post-Capture QA

Her raw capture sonrasi:

- dosya adini hemen yeniden adlandir
- duplicate / eski shot ile karismasin
- exact screen order'a gore klasorle

Suggested filenames:

- `01_home_tr.png`
- `02_vaccination_tr.png`
- `03_tracking_tr.png`
- `04_growth_tr.png`
- `05_milestones_tr.png`
- `06_settings_tr.png`

- `01_home_en.png`
- `02_vaccination_en.png`
- `03_tracking_en.png`
- `04_growth_en.png`
- `05_milestones_en.png`
- `06_settings_en.png`

## Final Rule

Capture phase'de amacimiz "en iyi screenshot" degil:
- dogru raw screen'i almak
- temiz state'i yakalamak

Asil tasarim / polish bir sonraki composite asamasinda yapilacak.
