# Kinna — Product Roadmap — ARŞİV

> **⚠️ Bu dosya artık güncel değil. Tüm post-MVP yapılacaklar [`FEATURES.md`](FEATURES.md) dosyasına taşındı (2026-03-21).**
> Bu dosya stratejik analiz referansı olarak korunmaktadır.

> _Orijinal:_ Son güncelleme: 2026-03-15
> Kaynak: App Store launch hazırlığı, Apple product page kuralları, güncel rakip ürün sayfaları, TR/EN metadata ve creative analizi

---

## Stratejik Özet

Launch hazırlığından çıkan en net sonuç:

1. **Kinna için en güçlü ilk pazar Türkiye.**
2. **TR pazarda fark yaratan şey:** T.C. aşı takvimi + sakin rehberlik + privacy-first + role-aware ebeveyn dili.
3. **EN/global pazarda aynı ürün çıkabilir ama aynı positioning ile çıkmamalı.**
4. **En yüksek kısa vadeli etki AI veya Apple Watch değil; retention ve günlük kullanım döngüsü.**
5. **`0-5 yaş` iddiası dikkatli kullanılmalı.** Bugün en güçlü ve net ürün yüzeyi `ilk yıllar`, özellikle `0-24 ay` core akışlarıdır.

### Yol Haritası İlkesi

- **v1.0.x - v1.2:** TR-first, retention-first
- **v1.3:** EN readiness + country expansion preparation
- **v2.0+:** sync, sharing, deeper intelligence, platform expansion

---

## Şu Anki Ürün Gerçeği

Kinna bugün en güçlü olarak şunları satıyor:

- Home'da günlük rehberlik
- T.C. aşı takvimi ve hatırlatmalar
- Günlük takip (beslenme, uyku, bez, not, büyüme)
- WHO büyüme eğrileri
- Gelişim taşları
- Ek gıda günlüğü
- Anne / baba / bakım veren tonu
- Verilerin cihazda kalması

Zayıf kalan alanlar:

- Ayarlar içinden bebek bilgisi düzenleme yok
- Günlük içerik tekrar etmeye açık
- EN locale ürün sayfası ve uygulama dili TR kadar güçlü değil
- Sync / paylaşım yok
- Watch / widget / AI tarafı henüz erken

---

## v1.0.1 — Post-Launch Stabilization

**Hedef:** Review sonrası hızlı güven artırma ve gerçek kullanım sürtünmesini azaltma

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| Bebek profili düzenleme (Settings) | P0 | S | Ad, doğum tarihi, cinsiyet düzenleme |
| Release warning cleanup | P0 | S | Simulator/runtime gürültüsü, son log temizliği |
| Review / support triage | P0 | S | App Review ve ilk kullanıcı geri bildirimlerine hızlı cevap |
| Metadata / ASO küçük iterasyonlar | P1 | S | Subtitle, promo text, ranking gözlemi |
| Medical category performans takibi | P1 | S | Conversion ve browse görünürlüğü etkisini izle |

**Neden bu sprint ilk sırada:**
- Launch sonrası ilk gerçek kullanıcı sorunu büyük olasılıkla `bebek bilgisi düzenleme`
- En düşük eforla en görünür kalite artışı burada

---

## v1.1 — Retention & Daily Value

**Hedef:** Günlük kullanım sıklığını ve week-1 retention'ı artırmak

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| Günlük içerik genişletme | P0 | M | Motivasyon, günlük rehber ve bildirim varyantlarını ciddi artır |
| Notes / günlük içgörü derinleştirme | P1 | M | Note log'u daha anlamlı günlük rehber bağlamına oturt |
| Uyku özeti v2 | P1 | M | Ortalama + trend + daha iyi haftalık özet dili |
| Home kart rotasyonu optimizasyonu | P1 | S | Tekrar hissini azalt, daha editoryal akış kur |
| Review prompt tuning | P2 | S | Gerçek veriye göre threshold ayarı |

**Neden en yüksek etki burada:**
- Rakipler utility ile kullanıcı alıyor, retention'ı content loop ile koruyor
- Kinna'nın şu an en kolay güçlendirilecek alanı günlük içerik derinliği

---

## v1.2 — Coordination & Stickiness

**Hedef:** Ebeveynler arası koordinasyonu güçlendirmek ve churn'ü azaltmak

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| iCloud sync foundation | P0 | L | Tek cihazdan çok cihaza güvenli veri devamlılığı |
| Partner / caregiver sharing | P0 | L | Anne-baba aynı bebeği takip edebilsin |
| Shareable milestone card | P1 | S | Organik büyüme + kutlama anı |
| Export / doktor özeti | P2 | M | Randevuya götürülebilir basit özet |

**Önemli not:**
- **Multi-baby bu sprintten önce açılmamalı.**
- Önce `sync + sharing`, sonra gerekirse `multi-baby`

---

## v1.3 — EN Readiness & Country Expansion

**Hedef:** EN locale ve daha geniş pazarlara hazırlık

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| EN copy polish | P0 | M | Uygulama içi EN ekranları TR kalitesine çek |
| EN metadata / creative v2 | P0 | M | Global positioning: calm baby tracker + guidance |
| Locale-aware vaccination messaging | P1 | M | EN sayfada TR takvimi mesajını daha doğru konumla |
| Country page strategy | P1 | S | TR-first, EN-secondary, sonra diğer pazarlar |
| Privacy / trust messaging expansion | P2 | S | EN pazarda on-device avantajını daha görünür yap |

**Stratejik karar:**
- Global büyüme, EN localization ve positioning oturmadan zorlanmamalı
- EN pazarda ilk wedge `Turkey schedule` değil, `calm baby tracker + guidance` olmalı

---

## v1.4 — Health Depth

**Hedef:** Premium derinliği artırmak, ama utility çekirdeğini bozmadan

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| Weight-for-length / height | P1 | M | Growth charts genişleme |
| Head circumference tracking | P1 | M | Daha kapsamlı büyüme yüzeyi |
| Breastfeeding v2 | P1 | M | Süre, side, ortalama aralık |
| Sleep insights v3 | P2 | M | Pattern odaklı daha güçlü özet |

**Not:**
- Growth charts zaten iyi bir premium differentiator
- Bu alan, retention ve sync çözüldükten sonra daha yüksek ROI verir

---

## v2.0 — Platform & Intelligence Expansion

**Hedef:** Daha yüksek stickiness ve premium derinlik

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| Widgets (Lock Screen + Home) | P1 | M | Günlük özet + son emzirme / son log |
| Live Activities | P1 | M | Emzirme/uyku timer benzeri canlı durumlar |
| Apple Watch quick-log | P2 | M | Log girdisini hızlandırır ama çekirdek ihtiyaç değil |
| Çoklu çocuk desteği | P1 | M | Sync / sharing sonrası daha mantıklı |
| iPad experience | P2 | M | Growth ve charts için iyi tamamlayıcı |

**Neden burada:**
- Watch / widget özellikleri güzel ama bugün ana büyüme motoru değiller
- Önce çekirdek retention loop, sonra convenience surfaces

---

## v2.x — Intelligence Layer

**Hedef:** Huckleberry benzeri akıllı değer katmanını dikkatli şekilde eklemek

| Özellik | Öncelik | Efor | Detay |
|---|---|---:|---|
| On-device uyku tahmini | P1 | L | "Sonraki şekerleme ne zaman?" |
| Haftalık akıllı özet | P1 | M | Beslenme / uyku / büyüme trendi doğal dilde |
| Pattern-based akıllı bildirimler | P2 | M | "Genelde bu saatte..." tipi öneriler |
| AI destekli ebeveyn soruları | P2 | L | Kural tabanlı + ileride model destekli |

**AI ilkesi:**
- Önce rule-based / on-device
- Sonra gerçekten ihtiyaç varsa model destekli zenginleştirme
- AI, çekirdek product-market-fit oluşmadan ana odak olmamalı

---

## Şimdilik Ertelenmesi Gerekenler

Bu fikirler kötü değil, sadece şu an öncelikli değil:

- Lifetime plan
- Apple Watch first-wave feature push
- Çok erken AI yatırımı
- Çok erken global büyüme
- PDF/reporting ağırlaştırması
- Çoklu çocuk desteğini sync olmadan açmak

---

## Önceliklendirme Matrisi

```
                    Düşük Efor ──────────── Yüksek Efor
                    │                            │
  Yüksek Etki ─────┤  Age settings      iCloud sync
                    │  Warning cleanup   Partner sharing
                    │  Content expansion EN readiness
                    │                            │
  Düşük Etki ──────┤  Review tuning      Apple Watch
                    │  Small exports      iPad app
                    │  Extra badges       Lifetime plan
                    │                            │
```

---

## Rakip Benchmark — Düzeltilmiş Okuma

| Uygulama | Gözlem | Kinna için ders |
|---|---|---|
| Huckleberry | Sleep + expert guidance wedge | AI'ya değil önce guidance loop'a yatırım yap |
| Nara Baby | Calm, privacy, caregiver utility | Sade UI + sync/sharing değerli |
| Cubtale | Care logs + charts + caregivers | Sync ve sharing açıldığında daha güçlü rakip olur |
| Baby Tracker | Basit utility, geniş kullanım | Utility çekirdeği önemli ama içerik fark yaratır |
| Elika | TR ve uzman içerik | TR rakip yoğunluğu düşük, yerel wedge korunmalı |

**Önemli not:**
- Rakip fiyatları ve paketleri storefront / kampanya / ülkeye göre değişebilir
- Bu tablo positioning içindir; mutlak pricing truth olarak kullanılmamalı

---

## Kinna'nın En Güçlü Konumu

Bugün en doğru tek cümle:

**TR için:**  
`Türkiye için sakin ve güvenilir ilk yıllar rehberi`

**EN için:**  
`A calm baby tracker for sleep, feeding, milestones, and growth`

---

## Pazar Notları

- TÜİK'e göre 2024 canlı doğum sayısı `937.559`
- TÜİK çocuk istatistiklerine göre `0-4 yaş` çocuk nüfusu güçlü bir taban sunuyor
- TR App Store'da modern, yerel, calm baby tracker yoğunluğu düşük
- Bu nedenle Kinna'nın ilk hedefi:
  - önce TR'de güven ve review toplamak
  - sonra EN locale'ı gerçekten güçlendirerek dış pazara açılmak

Kaynaklar:
- TÜİK çocuk istatistikleri 2024:
  - https://www.tuik.gov.tr/media/announcements/Turkiye_Cocuk_2024TR.pdf
- Apple product page:
  - https://developer.apple.com/app-store/product-page

---

## Efor Tanımları

- **S (Small):** 1-3 gün
- **M (Medium):** 1-2 hafta
- **L (Large):** 3-4 hafta

## Öncelik Tanımları

- **P0:** Bir sonraki release'te yapılmalı
- **P1:** Yakın plan
- **P2:** Sonraki safhaya ertelenebilir
