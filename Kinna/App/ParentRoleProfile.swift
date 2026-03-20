import Foundation

enum ParentRoleProfile: String {
    case mother
    case father
    case caregiver

    init(storedValue: String) {
        self = ParentRoleProfile(rawValue: storedValue.lowercased()) ?? .mother
    }

    func possessiveLabel(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother: return "mother"
            case .father: return "father"
            case .caregiver: return "caregiver"
            }
        }

        switch self {
        case .mother: return "annesi"
        case .father: return "babası"
        case .caregiver: return "bakım vereni"
        }
    }

    func homeLead(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother:
                return "Today, closeness, rhythm, and tiny cues will carry the most value."
            case .father:
                return "Today, play, eye contact, and repeated sounds will build the bond."
            case .caregiver:
                return "Today, calm transitions and a steady routine will make the day easier."
            }
        }

        switch self {
        case .mother:
            return "Bugün yakınlık, ritim ve küçük işaretler en çok işe yarar."
        case .father:
            return "Bugün oyun, göz teması ve tekrar eden sesler bağı güçlendirir."
        case .caregiver:
            return "Bugün sakin geçişler ve düzenli rutin günü kolaylaştırır."
        }
    }

    func milestoneAction(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother:
                return "Notice this especially during feeding and cuddle moments."
            case .father:
                return "Try to catch this during play and eye-contact moments."
            case .caregiver:
                return "Watch for this in the daily routine and pass a short note to the family."
            }
        }

        switch self {
        case .mother:
            return "Beslerken ve kucağındayken bu işareti özellikle izle."
        case .father:
            return "Oyunda ve göz temasında bu tepkiyi yakalamaya çalış."
        case .caregiver:
            return "Günlük rutinde bunu gözleyip aileye kısa bir not geç."
        }
    }

    func vaccineAction(isEnglish: Bool, hasUpcomingThisMonth: Bool) -> String {
        if isEnglish {
            switch (self, hasUpcomingThisMonth) {
            case (.mother, true):
                return "Pick a calm hour now so the day feels easier."
            case (.mother, false):
                return "This month is lighter, so you can focus on rhythm and recovery."
            case (.father, true):
                return "Drop it in your calendar now and take care of the logistics."
            case (.father, false):
                return "The calendar is lighter this month. Make room for play and routine."
            case (.caregiver, true):
                return "Confirm the date with the family and prepare the day ahead of time."
            case (.caregiver, false):
                return "This month is quieter. Keeping the routine steady is enough."
            }
        }

        switch (self, hasUpcomingThisMonth) {
        case (.mother, true):
            return "Randevu için sakin bir saat seçmek günü kolaylaştırır."
        case (.mother, false):
            return "Bu ay daha sakin. Ritme ve yakınlığa biraz daha alan açabilirsin."
        case (.father, true):
            return "Takvimine şimdi ekle; lojistiği sen toparlayabilirsin."
        case (.father, false):
            return "Bu ay takvim rahat. Oyuna ve rutine daha çok yer açabilirsin."
        case (.caregiver, true):
            return "Aileyle tarihi netleştirip günü önceden hazırlayın."
        case (.caregiver, false):
            return "Bu ay daha sakin. Düzenli bakım akışını korumak yeterli."
        }
    }

    func dailyGuideTemplate(isEnglish: Bool, rotationIndex: Int) -> (title: String, body: String, action: String) {
        let index = rotationIndex % 4

        if isEnglish {
            switch self {
            case .mother:
                switch index {
                case 0:
                    return (
                        "Closeness and rhythm",
                        "Feeding, holding, and a soft voice help your baby settle this month.",
                        "Try a calm two-minute cuddle after one feed today."
                    )
                case 1:
                    return (
                        "Sleep cues",
                        "Eye rubbing, zoning out, and fussiness often open a small sleep window.",
                        "When the first cue appears, soften the room and slow the pace."
                    )
                case 2:
                    return (
                        "Face-to-face chat",
                        "Seeing your face and hearing your voice supports early social smiles.",
                        "Add one minute of face-to-face talking today."
                    )
                default:
                    return (
                        "Tiny log, big clarity",
                        "A short note after feeding can make the rhythm easier to notice.",
                        "Log just one small pattern you notice today."
                    )
                }
            case .father:
                switch index {
                case 0:
                    return (
                        "Bond through play",
                        "Short face-to-face play and imitation help attachment grow this month.",
                        "Try a two-minute eye-contact game today."
                    )
                case 1:
                    return (
                        "Skin-to-skin time",
                        "Calm holding and close contact can help your baby regulate more easily.",
                        "Put the phone away and give them a quiet contact moment."
                    )
                case 2:
                    return (
                        "They know your voice",
                        "Your repeated tone and rhythm can become a strong source of safety.",
                        "Repeat the same short phrase a few times today."
                    )
                default:
                    return (
                        "Take one routine",
                        "Owning a small part of the evening routine builds confidence for both of you.",
                        "Take over one pre-sleep step tonight."
                    )
                }
            case .caregiver:
                switch index {
                case 0:
                    return (
                        "Keep the routine steady",
                        "Predictable care patterns help babies feel the day more safely.",
                        "Keep the same feeding or sleep order today if you can."
                    )
                case 1:
                    return (
                        "Watch for cues early",
                        "Catching hunger, sleep, or fussiness early often makes the whole day smoother.",
                        "Write down one signal you noticed a little earlier today."
                    )
                case 2:
                    return (
                        "Gentle transitions",
                        "Soft transitions between care moments support regulation and calm.",
                        "Use a short spoken cue before each transition today."
                    )
                default:
                    return (
                        "One note to the family",
                        "Small observations help everyone stay consistent in the baby's care.",
                        "Send the family one short end-of-day summary today."
                    )
                }
            }
        }

        switch self {
        case .mother:
            switch index {
            case 0:
                return (
                    "Yakınlık ve ritim",
                    "Beslenme, kucak ve yumuşak ses tonu bu ay bebeğinin sakinleşmesine yardım eder.",
                    "Bugün bir beslenmeden sonra iki dakikalık sakin temas dene."
                )
            case 1:
                return (
                    "Uyku işaretleri",
                    "Göz ovuşturma, dalma ve huzursuzluk kısa bir uyku penceresi açabilir.",
                    "İlk işarette ortamı yavaşlatıp sakinleştirmeyi dene."
                )
            case 2:
                return (
                    "Yüz yüze konuşma",
                    "Yüzünü görmek ve sesini duymak sosyal gülümsemeyi destekler.",
                    "Bugün bir dakikalık yüz yüze konuşma ekle."
                )
            default:
                return (
                    "Minik not, büyük fark",
                    "Kısa notlar günün ritmini fark etmeyi kolaylaştırır.",
                    "Bugün sadece tek bir küçük düzeni not et."
                )
            }
        case .father:
            switch index {
            case 0:
                return (
                    "Oyunla bağ kur",
                    "Kısa yüz yüze oyunlar ve taklitler bu ay bağlanmayı büyütür.",
                    "Bugün iki dakikalık göz teması oyunu dene."
                )
            case 1:
                return (
                    "Ten tene temas",
                    "Sakin kucak ve yakın temas bebeğinin regülasyonuna yardım edebilir.",
                    "Bugün telefonu bırakıp sadece temas ettiğin kısa bir an yarat."
                )
            case 2:
                return (
                    "Sesini tanıyor",
                    "Babanın sesi ve ritmi tekrarlandıkça güven duygusu pekişir.",
                    "Bugün aynı kısa cümleyi birkaç kez tekrar et."
                )
            default:
                return (
                    "Bir rutini devral",
                    "Akşamın küçük bir bölümünü üstlenmek ikiniz için de bağı güçlendirir.",
                    "Bu akşam uyku öncesi tek bir adımı sen üstlen."
                )
            }
        case .caregiver:
            switch index {
            case 0:
                return (
                    "Ritmi koru",
                    "Tutarlı bakım sıraları bebeğin günü daha güvenli hissetmesine yardım eder.",
                    "Bugün mümkünse aynı beslenme ya da uyku sırasını koru."
                )
            case 1:
                return (
                    "İşaretleri erken yakala",
                    "Açlık, uyku ve huzursuzluk işaretlerini erken görmek günü kolaylaştırır.",
                    "Bugün biraz daha erken fark ettiğin tek bir işareti not et."
                )
            case 2:
                return (
                    "Sakin geçişler",
                    "Bakım anları arasında yumuşak geçişler bebeğin sakin kalmasına yardım eder.",
                    "Bugün her geçişten önce kısa bir sözlü uyarı kullan."
                )
            default:
                return (
                    "Aileye kısa özet",
                    "Küçük gözlemler paylaşılınca bakım dili daha tutarlı olur.",
                    "Bugün aileye gün sonu için tek cümlelik bir özet gönder."
                )
            }
        }
    }

    func dailyReminderTitle(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother: return "Today's gentle note"
            case .father: return "Today's bonding note"
            case .caregiver: return "Today's care note"
            }
        }

        switch self {
        case .mother: return "Günün küçük notu"
        case .father: return "Bugün bağ kurma zamanı"
        case .caregiver: return "Günün bakım notu"
        }
    }

    func dailyReminderBody(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother:
                return "Open Kinna for one calm suggestion that supports your baby's rhythm today."
            case .father:
                return "Open Kinna for one short play or connection idea for today."
            case .caregiver:
                return "Open Kinna for one practical cue to support today's care routine."
            }
        }

        switch self {
        case .mother:
            return "Bugün bebeğinin ritmine iyi gelecek tek bir sakin öneri seni bekliyor."
        case .father:
            return "Bugün için kısa bir oyun ya da bağ kurma önerisi seni bekliyor."
        case .caregiver:
            return "Bugünkü bakım rutinini destekleyecek pratik bir öneri hazır."
        }
    }

    // MARK: - Sprint 9c — Role-Aware Home & Notification Copy

    func motivationQuotes(isEnglish: Bool) -> [String] {
        if isEnglish {
            switch self {
            case .mother:
                return [
                    "\u{201C}Every bond you build with your baby shapes their brain architecture.\u{201D}",
                    "\u{201C}The feeding rhythm you create strengthens lasting neural circuits.\u{201D}",
                    "\u{201C}Small moments of closeness form deep attachment patterns.\u{201D}",
                ]
            case .father:
                return [
                    "\u{201C}Every playful moment builds new neural circuits in your baby\u{2019}s brain.\u{201D}",
                    "\u{201C}Skin-to-skin contact shapes your baby\u{2019}s brain architecture from day one.\u{201D}",
                    "\u{201C}Repeating sounds and words strengthens attachment patterns through your voice.\u{201D}",
                ]
            case .caregiver:
                return [
                    "\u{201C}A consistent routine builds the brain architecture your baby relies on.\u{201D}",
                    "\u{201C}Every careful observation strengthens the neural circuits of trust.\u{201D}",
                    "\u{201C}A safe, steady rhythm forms secure attachment patterns.\u{201D}",
                ]
            }
        }

        switch self {
        case .mother:
            return [
                "\u{201C}Her gün bebeğinle kurduğun bağ, onun beyin mimarisini şekillendiriyor.\u{201D}",
                "\u{201C}Beslenme ritmin, kalıcı nöral devreleri güçlendiriyor.\u{201D}",
                "\u{201C}Küçük yakınlık anları, derin bağlanma kalıpları oluşturur.\u{201D}",
            ]
        case .father:
            return [
                "\u{201C}Her oyun anı, bebeğinin beyninde yeni nöral devreler kuruyor.\u{201D}",
                "\u{201C}Ten tene temas, bebeğinin beyin mimarisini ilk günden şekillendiriyor.\u{201D}",
                "\u{201C}Tekrar eden sesler ve kelimeler, sesinle bağlanma kalıplarını güçlendiriyor.\u{201D}",
            ]
        case .caregiver:
            return [
                "\u{201C}Tutarlı bir rutin, bebeğin güvendiği beyin mimarisini kurar.\u{201D}",
                "\u{201C}Her dikkatli gözlem, güven nöral devrelerini güçlendirir.\u{201D}",
                "\u{201C}Güvenli ve düzenli bir ritim, sağlam bağlanma kalıpları oluşturur.\u{201D}",
            ]
        }
    }

    func ageCardDescription(babyAgeInDays: Int, isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother: return "\(babyAgeInDays) days of closeness and growing together"
            case .father: return "\(babyAgeInDays) days of growing together"
            case .caregiver: return "\(babyAgeInDays) days of care and growth"
            }
        }

        switch self {
        case .mother: return "\(babyAgeInDays) gündür yakınlık kuruyorsun"
        case .father: return "\(babyAgeInDays) gündür birlikte büyüyorsunuz"
        case .caregiver: return "\(babyAgeInDays) gündür bakımla büyüyor"
        }
    }

    func thisMonthSectionIntro(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother:
                return "This month\u{2019}s rhythm: feeding cues, developmental closeness, and one calm suggestion each day."
            case .father:
                return "Play ideas, bonding activities, and what to watch for this month."
            case .caregiver:
                return "Routine structure, observation points, and family coordination tips for this month."
            }
        }

        switch self {
        case .mother:
            return "Bu ayın ritmi: beslenme ipuçları, gelişimsel yakınlık ve her gün sakin bir öneri."
        case .father:
            return "Bu ay için oyun fikirleri, bağ kurma aktiviteleri ve nelere dikkat etmeli."
        case .caregiver:
            return "Bu ay için rutin yapısı, gözlem noktaları ve aile koordinasyonu."
        }
    }

    func premiumUnlockCTA(isEnglish: Bool) -> (title: String, body: String) {
        if isEnglish {
            switch self {
            case .mother:
                return (
                    "Unlock the full monthly plan",
                    "See all cards, track feeding rhythm and closeness patterns with Kinna Premium."
                )
            case .father:
                return (
                    "Unlock daily bonding ideas",
                    "Open daily connection ideas and save unlimited milestones with Kinna Premium."
                )
            case .caregiver:
                return (
                    "Unlock the full care plan",
                    "Access the full care plan and share detailed observations with Kinna Premium."
                )
            }
        }

        switch self {
        case .mother:
            return (
                "Bu ayın tam planını aç",
                "Tüm kartları gör, emzirme ve yakınlık ritmini Kinna Premium ile takip et."
            )
        case .father:
            return (
                "Günlük bağ kurma fikirlerini aç",
                "Günlük bağ kurma önerilerini gör ve sınırsız kilometre taşı kaydet."
            )
        case .caregiver:
            return (
                "Tam bakım planına eriş",
                "Detaylı bakım planını gör ve gözlemleri aileyle paylaş."
            )
        }
    }

    // swiftlint:disable:next function_body_length
    func dailyReminderBody(isEnglish: Bool, rotationIndex: Int) -> String {
        let index = rotationIndex % 7

        if isEnglish {
            switch self {
            case .mother:
                return [
                    "Try a two-minute cuddle after one feed today — it strengthens your baby's rhythm.",
                    "When you see the first sleep cue, dim the room and slow down — the window closes fast.",
                    "Spend one minute face-to-face today — it supports early social smiles.",
                    "Let your baby grip your finger for a minute — it builds the trust reflex.",
                    "Hum a short melody during a diaper change — routine sounds calm the nervous system.",
                    "Place a safe toy just out of reach today — it sparks early motor planning.",
                    "Take one slow deep breath before picking your baby up — your calm transfers instantly."
                ][index]
            case .father:
                return [
                    "Try one minute of slow rocking today — it calms the nervous system faster than words.",
                    "Hold your baby skin-to-skin for two minutes after a feed — oxytocin works both ways.",
                    "Repeat one short sound near your baby today — early sound patterns build recognition.",
                    "Carry your baby facing outward for a minute — new visual angles spark curiosity.",
                    "Gently tap a rhythm on your baby's back — it builds early pattern awareness.",
                    "Read one sentence aloud in a calm voice — your tone matters more than the words.",
                    "Lie next to your baby on the floor for a minute — eye-level contact deepens the bond."
                ][index]
            case .caregiver:
                return [
                    "Check one routine detail this morning — small consistency builds big trust.",
                    "Write a quick observation note about today's mood — parents notice patterns you catch.",
                    "Prepare a short end-of-day summary for the family — it strengthens the care loop.",
                    "Note one new thing the baby responded to today — small firsts add up fast.",
                    "Check the nap timing against yesterday — rhythm shifts are easier to catch early.",
                    "Observe how the baby reacts to a familiar sound — it reveals hearing development.",
                    "Share one positive moment from today with the parents — good news builds partnership."
                ][index]
            }
        }

        switch self {
        case .mother:
            return [
                "Bugün bir beslenmeden sonra iki dakika kucak teması dene — bebeğin ritmi güçlenir.",
                "İlk uyku işaretinde ortamı karart ve sesi azalt — uyku penceresi hızla kapanır.",
                "Bugün bir dakika yüz yüze konuş — erken sosyal gülümsemeyi destekler.",
                "Bebeğin parmağını tutsun bir dakika — güven refleksini inşa eder.",
                "Alt değiştirirken kısa bir melodi mırıldan — rutin sesler sinir sistemini sakinleştirir.",
                "Güvenli bir oyuncağı erişim sınırına koy — erken motor planlamayı tetikler.",
                "Bebeğini kucağa almadan önce bir derin nefes al — sakinliğin anında geçer."
            ][index]
        case .father:
            return [
                "Bugün bir dakika yavaş sallanma dene — sinir sistemini kelimelerden hızlı sakinleştirir.",
                "Beslenmeden sonra iki dakika ten tene temas yap — oksitosin iki yönlü çalışır.",
                "Bugün bebeğinin yanında kısa bir ses tekrarla — erken ses kalıpları tanımayı güçlendirir.",
                "Bebeğini bir dakika dışa bakacak şekilde taşı — yeni görsel açılar merakı tetikler.",
                "Bebeğin sırtına hafif bir ritim vur — erken örüntü farkındalığını geliştirir.",
                "Sakin bir sesle bir cümle oku — tonun kelimelerden daha çok önemli.",
                "Bebeğinin yanına yere uzan bir dakika — göz hizası temas bağı derinleştirir."
            ][index]
        case .caregiver:
            return [
                "Bu sabah bir rutin detayını kontrol et — küçük tutarlılık büyük güven inşa eder.",
                "Bugünkü ruh hali hakkında kısa bir gözlem notu yaz — senin fark ettiğin kalıpları ebeveynler değerlendirir.",
                "Aile için kısa bir gün sonu özeti hazırla — bakım döngüsünü güçlendirir.",
                "Bugün bebeğin yeni tepki verdiği bir şeyi not et — küçük ilkler hızla birikir.",
                "Uyku zamanını dünle karşılaştır — ritim kaymaları erken fark edilirse kolay düzelir.",
                "Bebeğin tanıdık bir sese nasıl tepki verdiğini gözlemle — işitme gelişimini gösterir.",
                "Bugünden bir olumlu anı ebeveynlerle paylaş — iyi haber ortaklığı güçlendirir."
            ][index]
        }
    }

    func vaccineReminderTitle(isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother: return "Vaccine Reminder"
            case .father: return "Vaccine Plan Reminder"
            case .caregiver: return "Vaccine Coordination Note"
            }
        }

        switch self {
        case .mother: return "Aşı Hatırlatması"
        case .father: return "Aşı Planı Hatırlatması"
        case .caregiver: return "Aşı Koordinasyon Notu"
        }
    }

    func vaccineReminderBody(vaccineName: String, leadDays: Int, isEnglish: Bool) -> String {
        if isEnglish {
            switch self {
            case .mother:
                return leadDays == 0
                    ? "Today is \(vaccineName) day. Prepare the visit calmly and keep the rest of the day light."
                    : "\(vaccineName) is in \(leadDays) days. Choosing a calm appointment slot now may help."
            case .father:
                return leadDays == 0
                    ? "Today is \(vaccineName) day. Double-check the plan and take care of the logistics."
                    : "\(vaccineName) is in \(leadDays) days. Put it on your calendar and handle the setup early."
            case .caregiver:
                return leadDays == 0
                    ? "Today is \(vaccineName) day. Confirm the timing with the family and get ready."
                    : "\(vaccineName) is in \(leadDays) days. It may help to confirm the date with the family now."
            }
        }

        switch self {
        case .mother:
            return leadDays == 0
                ? "Bugün \(vaccineName) günü. Hazırlığı sakin sakin yapıp günü hafif tutabilirsin."
                : "\(vaccineName) için \(leadDays) gün kaldı. Randevu için sakin bir saat seçmek iyi gelebilir."
        case .father:
            return leadDays == 0
                ? "Bugün \(vaccineName) günü. Planı ve lojistiği bir kez daha kontrol et."
                : "\(vaccineName) için \(leadDays) gün kaldı. Takvimine ekleyip hazırlığı erkenden toparlayabilirsin."
        case .caregiver:
            return leadDays == 0
                ? "Bugün \(vaccineName) günü. Aileyle saati netleştirip hazırlığı tamamla."
                : "\(vaccineName) için \(leadDays) gün kaldı. Aileyle tarihi şimdi netleştirmek iyi olabilir."
        }
    }
}
