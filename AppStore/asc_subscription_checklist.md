# Kinna — App Store Connect Subscription Setup Checklist

## Subscription Group
- [ ] Group name: `Kinna Premium`
- [ ] Group reference name (internal): `kinna_premium`

## Products

### Monthly
- [ ] Product ID: `kinna_premium_monthly` (RevenueCat'te de aynı)
- [ ] Reference name: Kinna Premium Monthly
- [ ] Duration: 1 Month
- [ ] Price: $4.99 (Tier 5) — base US
- [ ] Free trial: 7 days
- [ ] Subscription group: Kinna Premium
- [ ] Review information: "Unlocks full tracking history, all milestone months, vaccine reminders, unlimited food logs, and all Home guidance cards."

### Yearly
- [ ] Product ID: `kinna_premium_yearly` (RevenueCat'te de aynı)
- [ ] Reference name: Kinna Premium Yearly
- [ ] Duration: 1 Year
- [ ] Price: $39.99 (Tier 39) — base US
- [ ] Free trial: 7 days
- [ ] Subscription group: Kinna Premium
- [ ] Review information: Same as monthly

## Bölgesel Fiyatlandırma

ASC'de "Subscription Prices" → "Manage Prices" → ülke bazlı override.

**Karar:** Exact tier numaraları ASC'deki güncel matris ile doğrulanacak. Aşağıdakiler hedef endeksler:

| Bölge | Endeks | Monthly hedef | Yearly hedef |
|---|---|---|---|
| US (base) | 1.0x | $4.99 | $39.99 |
| Turkey | 0.7x | En yakın TL tier (~₺149.99?) | En yakın TL tier |
| EU (DE, FR, IT, ES, UK) | 1.2x | ~€5.99 / £5.49 tier | ~€47.99 / £42.99 tier |
| India, Indonesia | 0.6x | ~₹249-349 tier | ~₹1999-2499 tier |

**NOT:** Apple tier matrisi zaman zaman güncellenir. Tier numarasını uygulamadan önce ASC'de güncel fiyat tablosunu kontrol et.

## RevenueCat Bağlantısı
- [ ] RevenueCat dashboard'da app oluştur (iOS, bundle ID: com.osmanseven.kinna)
- [ ] Public API key'i `SubscriptionManager.swift`'e ekle
- [ ] Product ID'leri RevenueCat'te tanımla:
  - `kinna_premium_monthly` → Monthly offering
  - `kinna_premium_yearly` → Annual offering
- [ ] Entitlement: `pro` (mevcut kodda bu isimle kullanılıyor)
- [ ] Offering: `default` — içinde monthly + yearly package

## App Store Review Notları
- [ ] Subscription description: Her iki ürün için açıklama ekle
- [ ] Terms of Use URL: https://saevaexe.github.io/kinna/terms.html
- [ ] Privacy Policy URL: https://saevaexe.github.io/kinna/privacy.html
- [ ] Support URL: https://saevaexe.github.io/kinna/support.html
- [ ] Demo account: Gerekmiyor (subscription test için sandbox kullanılır)
- [ ] Review notes: "Premium features can be tested with a sandbox account. The app uses RevenueCat for subscription management. All baby data is stored on-device only."

## Test Checklist
- [ ] Sandbox hesap oluştur (US region)
- [ ] Monthly purchase → entitlement aktif mi?
- [ ] Yearly purchase → entitlement aktif mi?
- [ ] Restore purchases → çalışıyor mu?
- [ ] Trial başlat → 7 gün boyunca premium erişim var mı?
- [ ] Trial bitişi → premium gate aktif mi?
- [ ] Paywall doğru fiyat gösteriyor mu? (sandbox'ta USD gösterecek — normal)
