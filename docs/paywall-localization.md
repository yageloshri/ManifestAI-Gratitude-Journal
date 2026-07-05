# Paywall Localization — Superwall

This document contains native-quality translations of every string on the "Manifest: Vision Board & 369" Superwall trial paywall, for 20 languages. Placeholders like `{date}`, `{price}`, and `{monthly}` are left untouched — they are filled in at runtime by Superwall/StoreKit and must not be translated or reformatted.

## Setup instructions

**Option A — Superwall's built-in Localization feature (may require a paid plan)**
1. Open the paywall in the Superwall dashboard editor.
2. Go to the **Localization** tab and add each locale you want to support (e.g. `de`, `fr`, `it`...).
3. For each locale, paste the corresponding translated string into its matching text layer, using the numbered lists below as your source of truth.
4. Superwall automatically serves the matching localization based on the device's locale, falling back to the base (English) paywall for unsupported locales. Verify placeholders (`{date}`, `{price}`, `{monthly}`) still render correctly after pasting.

**Option B — Works on every plan (rule-based duplicate paywalls)**
1. Duplicate the existing paywall once per target language (Paywall → Duplicate).
2. In each duplicate, replace the English text layers with the translated strings for that language from the sections below.
3. In Campaigns → Audience/Rules, add a rule per duplicate keyed on device locale, e.g. `device.languageCode == "de"` → German paywall, `device.languageCode == "ja"` → Japanese paywall, etc.
4. Order rules from most-specific to least-specific (e.g. put `zh-Hans` region/script checks before a generic `zh` check if you add more Chinese variants later), and set the original English paywall as the default/fallback rule at the bottom so unmatched locales still see a paywall.
5. Test each rule in Superwall's preview/debug mode by overriding device locale before shipping.

Each language section below lists all 17 strings in the same order as the English source, ready to paste directly into Superwall.

---

## de — Deutsch

1. Starte deine 3-tägige KOSTENLOSE Testversion, um fortzufahren
2. Heute
3. Schalte KI-Insights, unbegrenztes Journaling und tägliche Affirmationen frei.
4. In 2 Tagen
5. Wir erinnern dich rechtzeitig, bevor deine Testphase endet.
6. In 3 Tagen
7. Du wirst am {date} belastet, es sei denn, du kündigst vorher.
8. 3 TAGE KOSTENLOS TESTEN
9. Jährlich
10. Wöchentlich
11. {price} / Jahr abgerechnet
12. Jetzt keine Zahlung fällig
13. Kostenlose 3-Tage-Testversion starten
14. 3 Tage kostenlos, danach {price} pro Jahr ({monthly}/Monat)
15. Datenschutz
16. Wiederherstellen
17. AGB

---

## fr — Français

1. Démarre ton essai GRATUIT de 3 jours pour continuer
2. Aujourd'hui
3. Débloque les analyses IA, un journal illimité et des affirmations quotidiennes.
4. Dans 2 jours
5. Nous t'enverrons un rappel juste avant la fin de ton essai.
6. Dans 3 jours
7. Tu seras débité(e) le {date}, sauf annulation avant cette date.
8. 3 JOURS D'ESSAI GRATUIT
9. Annuel
10. Hebdomadaire
11. Facturé {price} / an
12. Aucun paiement pour l'instant
13. Démarrer mon essai gratuit de 3 jours
14. 3 jours gratuits, puis {price} par an ({monthly}/mois)
15. Confidentialité
16. Restaurer
17. Conditions

---

## it — Italiano

1. Inizia la tua prova GRATUITA di 3 giorni per continuare
2. Oggi
3. Sblocca approfondimenti IA, journaling illimitato e affermazioni quotidiane.
4. Tra 2 giorni
5. Ti invieremo un promemoria prima della fine della prova.
6. Tra 3 giorni
7. Ti verrà addebitato il {date}, salvo disdetta prima di tale data.
8. PROVA GRATUITA DI 3 GIORNI
9. Annuale
10. Settimanale
11. Fatturato {price} / anno
12. Nessun pagamento richiesto ora
13. Inizia la mia prova gratuita di 3 giorni
14. 3 giorni gratis, poi {price} all'anno ({monthly}/mese)
15. Privacy
16. Ripristina
17. Termini

---

## es — Español

1. Comienza tu prueba GRATIS de 3 días para continuar
2. Hoy
3. Desbloquea información de IA, diario ilimitado y afirmaciones diarias.
4. En 2 días
5. Te enviaremos un recordatorio antes de que termine tu prueba.
6. En 3 días
7. Se te cobrará el {date}, a menos que canceles antes.
8. PRUEBA GRATIS DE 3 DÍAS
9. Anual
10. Semanal
11. Se factura {price} / año
12. No se realizará ningún cargo ahora
13. Comenzar mi prueba gratis de 3 días
14. 3 días gratis, luego {price} al año ({monthly}/mes)
15. Privacidad
16. Restaurar
17. Términos

---

## pt-BR — Português (Brasil)

1. Comece seu teste GRÁTIS de 3 dias para continuar
2. Hoje
3. Desbloqueie insights de IA, diário ilimitado e afirmações diárias.
4. Em 2 dias
5. Enviaremos um lembrete pouco antes do fim do seu teste.
6. Em 3 dias
7. Você será cobrado em {date}, a menos que cancele antes.
8. TESTE GRÁTIS DE 3 DIAS
9. Anual
10. Semanal
11. Cobrança de {price} / ano
12. Nenhum pagamento agora
13. Iniciar meu teste grátis de 3 dias
14. 3 dias grátis, depois {price} por ano ({monthly}/mês)
15. Privacidade
16. Restaurar
17. Termos

---

## nl — Nederlands

1. Start je GRATIS proefperiode van 3 dagen om door te gaan
2. Vandaag
3. Ontgrendel AI-inzichten, onbeperkt journalen en dagelijkse affirmaties.
4. Over 2 dagen
5. We sturen je een herinnering vlak voordat je proefperiode afloopt.
6. Over 3 dagen
7. Je wordt op {date} belast, tenzij je daarvoor opzegt.
8. 3 DAGEN GRATIS PROBEREN
9. Jaarlijks
10. Wekelijks
11. {price} / jaar in rekening gebracht
12. Nu geen betaling verschuldigd
13. Start mijn gratis proefperiode van 3 dagen
14. 3 dagen gratis, daarna {price} per jaar ({monthly}/maand)
15. Privacy
16. Herstellen
17. Voorwaarden

---

## pl — Polski

1. Rozpocznij 3-dniowy BEZPŁATNY okres próbny, aby kontynuować
2. Dziś
3. Odblokuj analizy AI, nieograniczony dziennik i codzienne afirmacje.
4. Za 2 dni
5. Wyślemy Ci przypomnienie tuż przed końcem okresu próbnego.
6. Za 3 dni
7. Opłata zostanie pobrana {date}, chyba że anulujesz wcześniej.
8. 3 DNI BEZPŁATNEGO OKRESU PRÓBNEGO
9. Rocznie
10. Tygodniowo
11. Rozliczenie {price} / rok
12. Brak opłaty teraz
13. Rozpocznij mój bezpłatny 3-dniowy okres próbny
14. 3 dni za darmo, potem {price} rocznie ({monthly}/mies.)
15. Prywatność
16. Przywróć
17. Warunki

---

## tr — Türkçe

1. Devam etmek için 3 günlük ÜCRETSİZ deneme sürümünü başlat
2. Bugün
3. Yapay zeka içgörülerinin, sınırsız günlük tutmanın ve günlük olumlamaların kilidini aç.
4. 2 Gün Sonra
5. Deneme süren bitmeden hemen önce sana bir hatırlatma göndereceğiz.
6. 3 Gün Sonra
7. Önceden iptal etmedikçe {date} tarihinde ücretlendirileceksin.
8. 3 GÜNLÜK ÜCRETSİZ DENEME
9. Yıllık
10. Haftalık
11. Yıllık {price} olarak faturalandırılır
12. Şimdi ödeme yok
13. 3 günlük ücretsiz denemeyi başlat
14. 3 gün ücretsiz, ardından yılda {price} (aylık {monthly})
15. Gizlilik
16. Geri Yükle
17. Koşullar

---

## ru — Русский

1. Начни 3-дневный БЕСПЛАТНЫЙ пробный период, чтобы продолжить
2. Сегодня
3. Открой аналитику ИИ, неограниченный дневник и ежедневные аффирмации.
4. Через 2 дня
5. Мы напомним тебе незадолго до окончания пробного периода.
6. Через 3 дня
7. Списание произойдёт {date}, если ты не отменишь подписку раньше.
8. 3 ДНЯ БЕСПЛАТНО
9. Год
10. Неделя
11. Списание {price} / год
12. Сейчас платить не нужно
13. Начать бесплатный пробный период на 3 дня
14. 3 дня бесплатно, затем {price} в год ({monthly}/мес.)
15. Конфиденциальность
16. Восстановить
17. Условия

---

## sv — Svenska

1. Starta din 3-dagars GRATIS provperiod för att fortsätta
2. Idag
3. Lås upp AI-insikter, obegränsad journalföring och dagliga affirmationer.
4. Om 2 dagar
5. Vi skickar en påminnelse strax innan din provperiod tar slut.
6. Om 3 dagar
7. Du debiteras {date} om du inte avbryter innan dess.
8. 3 DAGARS GRATIS PROVPERIOD
9. Årsvis
10. Veckovis
11. Debiteras {price} / år
12. Ingen betalning nu
13. Starta min 3-dagars gratis provperiod
14. 3 dagar gratis, sedan {price} per år ({monthly}/mån)
15. Integritet
16. Återställ
17. Villkor

---

## nb — Norsk bokmål

1. Start din 3-dagers GRATIS prøveperiode for å fortsette
2. I dag
3. Lås opp AI-innsikt, ubegrenset journalføring og daglige bekreftelser.
4. Om 2 dager
5. Vi sender deg en påminnelse like før prøveperioden utløper.
6. Om 3 dager
7. Du blir belastet {date} med mindre du kansellerer før den datoen.
8. 3 DAGERS GRATIS PRØVEPERIODE
9. Årlig
10. Ukentlig
11. Belastes {price} / år
12. Ingen betaling nå
13. Start min 3-dagers gratis prøveperiode
14. 3 dager gratis, deretter {price} per år ({monthly}/mnd)
15. Personvern
16. Gjenopprett
17. Vilkår

---

## da — Dansk

1. Start din 3-dages GRATIS prøveperiode for at fortsætte
2. I dag
3. Lås op for AI-indsigter, ubegrænset journalføring og daglige bekræftelser.
4. Om 2 dage
5. Vi sender dig en påmindelse, lige før din prøveperiode udløber.
6. Om 3 dage
7. Du bliver opkrævet den {date}, medmindre du opsiger inden da.
8. 3 DAGES GRATIS PRØVEPERIODE
9. Årligt
10. Ugentligt
11. Opkræves {price} / år
12. Ingen betaling nu
13. Start min 3-dages gratis prøveperiode
14. 3 dage gratis, derefter {price} om året ({monthly}/md.)
15. Privatliv
16. Gendan
17. Vilkår

---

## fi — Suomi

1. Aloita 3 päivän MAKSUTON kokeilu jatkaaksesi
2. Tänään
3. Avaa tekoälyoivallukset, rajoittamaton päiväkirja ja päivittäiset myönteiset lauseet.
4. 2 päivän kuluttua
5. Lähetämme muistutuksen juuri ennen kokeilun päättymistä.
6. 3 päivän kuluttua
7. Sinulta veloitetaan {date}, ellet peruuta ennen sitä.
8. 3 PÄIVÄN MAKSUTON KOKEILU
9. Vuosittain
10. Viikoittain
11. Veloitus {price} / vuosi
12. Ei maksua nyt
13. Aloita 3 päivän maksuton kokeilu
14. 3 päivää ilmaiseksi, sitten {price} vuodessa ({monthly}/kk)
15. Tietosuoja
16. Palauta
17. Ehdot

---

## ja — 日本語

1. 続けるには3日間の無料トライアルを開始
2. 今日
3. AIインサイト、無制限の日記、毎日のアファメーションを解放しましょう。
4. 2日後
5. トライアル終了間近にリマインダーをお送りします。
6. 3日後
7. {date}に請求されます。それより前にキャンセルすれば請求されません。
8. 3日間無料トライアル
9. 年間プラン
10. 週間プラン
11. {price}/年で請求
12. 今は支払い不要
13. 3日間の無料トライアルを開始
14. 3日間無料、その後は年間{price}（月あたり{monthly}）
15. プライバシー
16. 復元
17. 利用規約

---

## ko — 한국어

1. 계속하려면 3일 무료 체험을 시작하세요
2. 오늘
3. AI 인사이트, 무제한 저널링, 매일의 확언을 잠금 해제하세요.
4. 2일 후
5. 체험 종료 직전에 알림을 보내드릴게요.
6. 3일 후
7. {date}에 결제되며, 그 전에 언제든지 취소할 수 있습니다.
8. 3일 무료 체험
9. 연간
10. 주간
11. 연 {price} 청구
12. 지금은 결제되지 않아요
13. 3일 무료 체험 시작하기
14. 3일 무료, 이후 연 {price} (월 {monthly})
15. 개인정보처리방침
16. 복원
17. 이용약관

---

## zh-Hans — 简体中文

1. 开始你的3天免费试用以继续
2. 今天
3. 解锁AI洞察、无限日记记录和每日肯定语。
4. 2天后
5. 我们会在试用即将结束前提醒你。
6. 3天后
7. 除非你提前取消，否则将于{date}扣款。
8. 3天免费试用
9. 按年
10. 按周
11. 按{price}/年计费
12. 现在无需付款
13. 开始我的3天免费试用
14. 3天免费，之后每年{price}（约{monthly}/月）
15. 隐私政策
16. 恢复购买
17. 服务条款

---

## he — עברית

1. התחל/י תקופת ניסיון חינמית בת 3 ימים כדי להמשיך
2. היום
3. פתח/י תובנות AI, יומן ללא הגבלה ואישורים יומיים.
4. בעוד יומיים
5. נשלח לך תזכורת ממש לפני שתקופת הניסיון מסתיימת.
6. בעוד 3 ימים
7. תחויב/י בתאריך {date} אלא אם תבטל/י לפני כן.
8. 3 ימי ניסיון חינם
9. שנתי
10. שבועי
11. חיוב של {price} לשנה
12. אין תשלום כרגע
13. התחל/י את תקופת הניסיון החינמית בת 3 הימים שלי
14. 3 ימים חינם, ולאחר מכן {price} לשנה ({monthly} לחודש)
15. פרטיות
16. שחזור רכישות
17. תנאי שימוש

---

## ar — العربية

1. ابدأ تجربتك المجانية لمدة 3 أيام للمتابعة
2. اليوم
3. افتح رؤى الذكاء الاصطناعي، وتدوين يوميات غير محدود، وتأكيدات يومية.
4. بعد يومين
5. سنرسل لك تذكيرًا قبل انتهاء فترة تجربتك مباشرة.
6. بعد 3 أيام
7. سيتم خصم الرسوم في {date} ما لم تُلغِ الاشتراك قبل ذلك.
8. تجربة مجانية لمدة 3 أيام
9. سنوي
10. أسبوعي
11. تُفوتر {price} / سنويًا
12. لا يوجد دفع مستحق الآن
13. ابدأ تجربتي المجانية لمدة 3 أيام
14. 3 أيام مجانية، ثم {price} سنويًا ({monthly}/شهريًا)
15. الخصوصية
16. استعادة المشتريات
17. الشروط

---

## id — Bahasa Indonesia

1. Mulai uji coba GRATIS 3 hari untuk melanjutkan
2. Hari ini
3. Buka wawasan AI, jurnal tanpa batas, dan afirmasi harian.
4. 2 Hari Lagi
5. Kami akan mengirimkan pengingat sesaat sebelum masa uji cobamu berakhir.
6. 3 Hari Lagi
7. Kamu akan dikenakan biaya pada {date} kecuali kamu membatalkan sebelum tanggal tersebut.
8. UJI COBA GRATIS 3 HARI
9. Tahunan
10. Mingguan
11. Ditagih {price} / tahun
12. Belum ada pembayaran sekarang
13. Mulai uji coba gratis 3 hari saya
14. Gratis 3 hari, lalu {price} per tahun ({monthly}/bulan)
15. Privasi
16. Pulihkan
17. Ketentuan

---

## vi — Tiếng Việt

1. Bắt đầu dùng thử MIỄN PHÍ 3 ngày để tiếp tục
2. Hôm nay
3. Mở khóa thông tin chi tiết AI, nhật ký không giới hạn và lời khẳng định hằng ngày.
4. Sau 2 ngày
5. Chúng tôi sẽ gửi cho bạn lời nhắc ngay trước khi thời gian dùng thử kết thúc.
6. Sau 3 ngày
7. Bạn sẽ bị tính phí vào ngày {date} trừ khi hủy trước thời điểm đó.
8. DÙNG THỬ MIỄN PHÍ 3 NGÀY
9. Hằng năm
10. Hằng tuần
11. Tính phí {price} / năm
12. Hiện chưa cần thanh toán
13. Bắt đầu dùng thử miễn phí 3 ngày của tôi
14. Miễn phí 3 ngày, sau đó {price} mỗi năm ({monthly}/tháng)
15. Quyền riêng tư
16. Khôi phục
17. Điều khoản
