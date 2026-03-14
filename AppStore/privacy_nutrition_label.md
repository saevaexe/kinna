# Kinna — App Privacy (Nutrition Label)

ASC'de "App Privacy" bölümüne girilecek deklarasyon.

## Veri Toplama Özeti

Kinna'nın kendisi kullanıcı verisini sunucuya GÖNDERMEZ. Ancak RevenueCat (subscription yönetimi) ve Apple (App Store işlemleri) transaction verisi işler.

## ASC Deklarasyonu

### 1. Contact Info
- **Toplanmıyor.** Email sadece support sayfasında — uygulama içinden otomatik toplanmıyor.

### 2. Health & Fitness
- **Toplanmıyor.** Bebek sağlık verileri (boy, kilo, aşı, beslenme) tamamen cihazda kalır, sunucuya gönderilmez.

### 3. Financial Info
- **Toplanmıyor.** Ödeme Apple tarafından işlenir. Uygulama kredi kartı veya banka bilgisi görmez.

### 4. Location
- **Toplanmıyor.** Konum izni istenmez.

### 5. Sensitive Info
- **Toplanmıyor.**

### 6. Contacts
- **Toplanmıyor.**

### 7. User Content
- **Toplanmıyor.** Notlar ve loglar cihazda kalır.

### 8. Browsing History
- **Toplanmıyor.**

### 9. Search History
- **Toplanmıyor.**

### 10. Identifiers
- **Toplanmıyor.** Reklam ID'si (IDFA) istenmez. RevenueCat anonim app user ID kullanır.

### 11. Purchases
- **Toplanan:** Purchase history (RevenueCat + Apple)
- **Kullanım amacı:** App functionality (subscription entitlement doğrulama)
- **Kullanıcıya bağlı mı:** Evet (Apple ID üzerinden)
- **Tracking için mi:** Hayır

### 12. Usage Data
- **Toplanmıyor.** 3rd party analytics SDK yok. Apple'ın kendi App Analytics'i cihaz ayarlarına bağlı.

### 13. Diagnostics
- **Toplanmıyor.** Crash log'lar Apple tarafından toplanır (kullanıcı ayarına bağlı).

## ASC'de Seçilecekler

**"Does your app collect data?"** → YES (sadece Purchases — RevenueCat)

**Data Types:**
- [x] Purchases → Purchase History
  - Used for: App Functionality
  - Linked to User: Yes
  - Used for Tracking: No

**Diğer tüm kategoriler:** Not Collected

## Notlar
- RevenueCat privacy policy: revenuecat.com/privacy/
- Apple processes subscription transactions under Apple's own terms
- "Data Not Collected" label'ı ALAMAYIZ çünkü RevenueCat purchase data işliyor
- Doğru label: "Data Used to Track You: No" + "Data Linked to You: Purchase History"
