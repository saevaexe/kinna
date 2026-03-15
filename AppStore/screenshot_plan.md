# Kinna — App Store Creatives Plan

Last updated: 2026-03-14

## Executive Decision

Kinna icin ilk yayin setini iki parcaya ayiriyoruz:

1. Launch-critical set: `6` portrait screenshots
2. Optional phase-2 asset: `1` portrait app preview video

Neden:
- Apple, app preview'leri urun sayfasinda screenshot'lardan once gosteriyor.
- Zayif bir preview, guclu screenshot setini golgeleyebilir.
- Kinna'nin su an en guclu tarafi net ekranlar ve sakin bilgi mimarisi; bunu once screenshot setiyle satmak daha guvenli.

Sonuc:
- v1 submission icin screenshot-first ilerliyoruz.
- App preview videosunu ancak tek bir guclu `18-22 sn` cut hazirsa ekliyoruz.

## Research Summary

Apple'in guncel kurallarindan cikan ana noktalar:

- `1-10` screenshot yuklenebilir.
- iPhone icin sadece en yuksek gerekli boyutu vermek yeterli; App Store daha kucuk boyutlara otomatik scale eder.
- `Up to 3` app preview yuklenebilir.
- App preview suresi `15-30 sn`.
- App previews urun sayfasinda screenshot'lardan once gorunur.
- Preview autoplay ve muted oynar; ilk saniyeler gorsel olarak kendi kendini anlatmak zorunda.
- Poster frame onemli; autoplay olmayan yerlerde ilk gorunen kare odur.

Kaynaklar:
- Apple Developer — Creating Your Product Page:
  - https://developer.apple.com/app-store/product-page
- Apple Developer — Upload App Previews and Screenshots:
  - https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/
- Apple Developer — Screenshot Specifications:
  - https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- Apple Developer — App Preview Specifications:
  - https://developer.apple.com/help/app-store-connect/reference/app-preview-specifications
- Apple Developer — Show More with App Previews:
  - https://developer.apple.com/app-store/app-previews/
- CDC / WHO chart context:
  - https://www.cdc.gov/growthcharts/who-charts.html
  - https://www.who.int/tools/child-growth-standards/standards

Secondary market research:
- App Store Tracker:
  - https://www.appstoretracker.com/

Not:
- Apple kaynaklari spec ve review dogrulugu icin birincil kaynaktir.
- App Store Tracker'i teknik kural kaynagi olarak degil, rakip screenshot siralamasi, kategori hareketi ve pazar gozlemi icin kullanacagiz.

## Product Page Strategy

### What the first 3 assets must say

Ilk 3 yaratıcı su uc soruya cevap vermeli:

1. `Bu uygulama ne?`
2. `Bana ne sagliyor?`
3. `Neden simdi indirmeliyim?`

Kinna icin bu cevaplar:

1. Bebege ozel rehberlik
2. Asi, takip ve gelisim tek yerde
3. Bilimsel ama sakin, mahremiyet-oncelikli deneyim

## Competitive Research Workflow

App Store Tracker'i su isler icin kullan:

1. Health & Fitness / Lifestyle benzeri uygulamalarda ilk `3` creative'in ne anlattigini gozlemle
2. Rakiplerin:
   - ilk screenshot'ta hangi benefit'i sattigini
   - asi / tracking / growth benzeri utility app'lerde hangi ekranlari one koydugunu
   - screenshot basliklarinda kac kelime kullandigini
3. TR pazarina yakin utility / parenting / tracker uygulamalarini watchlist'e ekle
4. Launch sonrasi kategori hareketlerini izle

Kullanmayacagimiz sey:
- App Store Tracker verisini dogrudan tasarim karari yerine tek kaynak yapmak

Bizim karar hiyerarsimiz:
1. Apple kurallari
2. Kinna'nin urun gercegi
3. Pazar gozuyle rakip pattern'leri

### Creative tone

Kinna App Store seti icin hedef ton:

- sakin
- premium ama yumusak
- tibbi degil, guven verici
- bilgi yogun ama hizli taranabilir

Yapmayacagimiz seyler:

- kucuk ve paragraf gibi uzun copy
- cok fazla badge, chip, kalabalik overlay
- tutorial gibi adim adim UI gostermek
- ayni mesaji iki ekranda tekrar etmek

## Recommendation: Screenshots First

Launch'ta once screenshot setini bitiriyoruz.

App preview videosu icin kalite esigi:

- ilk `3-5 sn` sesi kapali izleyiciye deger onerisini anlatmali
- poster frame tek basina guclu olmali
- video, screenshot'lardan daha iyi satmiyorsa yayinlamiyoruz

Bu nedenle:

- `Default product page`: screenshot-first
- `Phase 2`: 1 portrait preview video

## Device Plan

### Screenshot capture

Primary target:
- iPhone `6.9"` / `6.7"` class
- Apple'in kabul ettigi portrait boyutlardan biri

Pratik karar:
- tek bir yuksek cozumluklu iPhone portrait seti capture edip App Store'un scale etmesine izin verecegiz
- ancak kopya 6.1 inch'te fazla kuculurse ikinci export seti uretebiliriz

### Preview capture

Eger video yaparsak:
- portrait
- accepted preview resolution
- `18-22 sn` hedef
- sessiz izlemeye uygun buyuk copy

## Current Asset Inventory

Eldeki ilgili dosyalar:

- [preview.html](/Users/osmanseven/Kinna/AppStore/preview.html)
- [metadata.md](/Users/osmanseven/Kinna/AppStore/metadata.md)
- design screenshot klasorleri:
  - `/Users/osmanseven/Kinna/design/08032026_Screenshot`
  - `/Users/osmanseven/Kinna/design/08032026_EN`

Karar:
- `preview.html` final template degil
- moodboard / visual direction olarak kullanilabilir
- final store assets daha az copy, daha buyuk baslik, daha sert hiyerarsiyle uretilmeli

## Final Screenshot Set

### Set size

Default set: `6` screenshots

Gerekirse `7.` screenshot eklenebilir ama default hedef `6`.

### Order

#### 1. Home / Daily Guidance
Screen:
- Home, `Bu ay icin` bolumu acik
- role-aware greeting gorunebilir ama ana vurgu Home kartlari olmali

Headline TR:
- `Her gun sana ozel rehber`

Headline EN:
- `Daily guidance for your baby`

Why #1:
- app'in gunluk degerini tek bakista anlatir
- onboarding degil, asil urun deneyimini satar

#### 2. Vaccination
Screen:
- Asi plani hero kart + yaklasan dozlar

Headline TR:
- `Asi takvimi, hatirlatmalarla`

Headline EN:
- `Vaccine tracking with reminders`

Why #2:
- TR icin cok guclu farklilastirici
- somut ve yuksek niyetli kullanim degeri

#### 3. Tracking
Screen:
- Takip ekrani
- beslenme, uyku, bez, notlar, tarti/boy kartlari gorunsun

Headline TR:
- `Beslenme, uyku, buyume tek yerde`

Headline EN:
- `Feeding, sleep, growth in one place`

Why #3:
- gunluk kullanim frekansini gosterir
- search sonucunda gorulen ilk 3 ekran icinde temel utility tamamlanir

#### 4. Growth Charts
Screen:
- Buyume Egrisi
- tarti veya boy grafik ekraninin temiz hali

Headline TR:
- `WHO buyume egrileri`

Headline EN:
- `WHO growth charts`

Subline:
- `Kilo ve boy olcumlerini beklenen aralikla gor`

Why:
- premium farklilastirici
- yeni ve guclu ozellik

#### 5. Milestones
Screen:
- Gelisim Taslari
- aylik milestone listesi ve progress ring

Headline TR:
- `Gelisim adimlarini takip et`

Headline EN:
- `Track milestones with confidence`

Why:
- ebeveyn rehberligi hissini guclendirir

#### 6. Foods / Reactions
Screen:
- Besin Takibi
- sayaclar + son eklenenler + reaksiyon badge'leri

Headline TR:
- `Yeni besinleri guvenle takip et`

Headline EN:
- `Track new foods with confidence`

Subline:
- `Reaksiyonlari not al, iyi gelenleri kolayca gor`

Why:
- launch setine gunluk parenting degeri ekler
- privacy ekranindan daha guclu utility satar

## Optional 7th Screenshot

Eger 7 ekran istersek:

#### 7. Personalized Summary
Screen:
- Onboarding Value Summary

Headline TR:
- `Bebegine ozel plan, ilk gunden`

Headline EN:
- `A plan made for your baby`

Not:
- Bunu ilk 3'e almak yerine 7. ekrana koymak bilincli karar.
- Neden: App Store'da asıl urun deneyimini once gostermek daha guvenli.

## Copy Rules

Her screenshot icin:

- `1` ana benefit
- headline en fazla `3-6` kelime
- subline en fazla `1` kisa satir
- body paragraph yok

TR copy ilkesi:
- daha duygusal ama net
- "bilimsel" ve "gizlilik" tonunu kaybetmeden

EN copy ilkesi:
- kelime sayisi daha da kisa
- utility-first

## Visual System

### Layout

Tek format kullan:

- frameless screenshot veya cok hafif rounded framing
- ayni background family
- ayni headline treatment
- ayni caption placement

### Recommended composition

- Ustte buyuk headline
- Ortada gercek app screenshot
- Altta kisa destek satiri veya hicbir sey yok

### Palette

- cream base
- terra accent
- sage trust / science accent
- koyu charcoal metin

### Typography

- headline: Kinna'nin serif dili
- supporting copy: sade sans
- caption text arm's length test'ini gecmeli

## What to avoid

- her ekranda farkli renk dunyasi
- screenshot ustunde paragraflar
- UI icinde zaten yazan seyi bir daha headline'da tekrar etmek
- cok fazla cihazi ayni anda gosterme
- uygulamada olmayan animasyon / fake feature izlenimi

## App Preview Video Plan

### Recommendation

If we ship a video, ship only `1`.

Sebep:
- ilk yayin icin 3 farkli preview gereksiz
- tek bir guclu portrait preview yeterli

### Length

- hedef: `18-22 sn`

### Structure

#### 0-3 sn
- Home / daily guidance
- buyuk text:
  - `Bebegine ozel rehberlik`

#### 3-7 sn
- Vaccination hero
- text:
  - `Asi takvimini unutma`

#### 7-11 sn
- Tracking
- text:
  - `Beslenme ve uykuyu kaydet`

#### 11-15 sn
- Growth charts
- text:
  - `WHO buyume egrileri`

#### 15-19 sn
- Milestones / father mode / privacy beat
- text:
  - `Bilimsel. Sakin. Mahremiyet oncelikli.`

### Video rules

- voiceover zorunlu degil
- ses kapali izlendiginde de anlasilmali
- buyuk text
- basit dissolve / fade
- fake gesture yok
- poster frame olarak en guclu Home veya Vaccination karelerinden biri secilmeli

## Production Workflow

### Phase 1 — Capture

1. Test veri setini sabitle
   - Ela
   - 2 ay 13 gun
   - kiz
   - milestone progress, asi kayitlari, tracking, growth chart verileri hazir
2. Status bar `09:41`
3. Tek dil TR capture
4. Sonra EN duplicate set

### Phase 2 — Compose

1. Raw screenshot export
2. Final canvas ustune tasima
3. Headline / subline ekleme
4. Search-result kucuk onizleme testi

### Phase 3 — Validate

Checklist:
- ilk 3 ekran tek basina urunun hikayesini anlatiyor mu
- 6.1 inch'te kopya okunuyor mu
- her ekranda tek bir benefit var mi
- TR ve EN ayni sirayi koruyor mu
- privacy ve medical claims review-friendly mi

## Search Result Priority Rule

Ilk 3 asset icin kural:

- login yok
- settings yok
- paywall yok
- legal ekran yok
- sadece deger ve cekirdek urun

Bu nedenle paywall / privacy ekranini ilk 3'e sokmuyoruz.

## Post-Launch Optimization Plan

App yayinlandiktan sonra:

1. Product Page Optimization test
2. Test variable:
   - screenshot order
   - 1. screenshot headline
   - 2. screenshot Vaccination vs Growth Charts
3. Once kazanan ilk 3 kombinasyonu sabitle

Apple PPO kaynaklari:
- https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization
- https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/create-a-test

## Immediate Next Steps

1. Bu plani kilitle
2. `preview.html`i final template yerine moodboard olarak yeniden degerlendir
3. TR screenshot setinin `6` final sahnesini sec
4. Simulator capture checklist hazirla
5. Sonra ilk composited screenshot batch'ini uret
