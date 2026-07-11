# GEO Log — ai-manifest.com

Running log of AI-answer-engine landscape probes, on-site GEO changes, and outreach. Owned by the geo-expert agent. Append dated entries; never rewrite history.

---

## 2026-07-11 — Round 1 (first GEO round; site is 1 day old)

### AI-answer landscape probe

| Query | Who gets cited today | Winning content format | Our gap / angle |
|---|---|---|---|
| "best manifestation app" | Competitor-owned listicles dominate: manifestive.app, loa-lawofattraction.co, mindfulsuite.com, manifestvision.ai (cited twice), quantumleapapp.com, calmsage.com, appshive.co | "Top 5/10 apps, tested/compared" listicles with per-app verdicts ("best for X") — almost all self-published by competing apps | We have NO comparison/listicle asset and aren't in anyone else's. Angle: an honest "best manifestation apps" comparison page naming real competitors with a fair per-use-case table (we win "369 method + vision board + numerology in one"). Also: competitors get cited for *their own* roundups — the format works even when self-interested. |
| "369 method app" | Google Play listings (369 Manifest: Tesla Method, Tesla 369, 369 Manifest), App Store listing (369 Manifestation & Meditation), manifestapp.xyz blog, manifestyourlifeapp.com (Myla), a Quora thread ("can you do 369 in your notes app?") | App-store listing pages + one competitor blog post; a Quora Q&A surfaces | High-intent query, weak editorial competition. Our two 369 guides should own this. The Quora "notes app vs journal" question is a perfect outreach target (drafted this round). Angle: our guides answer *method + app* together; competitors' listings answer only "app". |
| "how to do the 369 manifestation method" | themanifestationcollective.co, refinery29.com, calm.com blog, theuniverseunveiled.com, cathclaire.com, blog.gratefulness.me, bloomandmanifest.com | Step-by-step articles: numbered steps, an example affirmation, "33 days", honest "no scientific proof but useful for intention-setting" caveat (Calm's framing gets lifted) | Big publishers (Calm, Refinery29) win on authority; niche blogs win on structure. Our how-to guide already has steps + table; hardened this round with answer-first opening, quick-answer box, HowTo JSON-LD, visible Updated date. Calm's honest-caveat framing is what engines quote — we already carry that tone ("strip away the cosmology..."). |
| "369 method examples what to write" | themanifestationcollective.co, theuniverseunveiled.com, hellomyyoga.com, thegodmessage.com, calm.com, soniamotwani.com | Formula + concrete example affirmations ("gratitude + emotion + 'into my life'"), categorized by love/money/success, present-tense rules | Winners give a *formula* plus many categorized examples. Our 369-method-examples.html (25+ affirmations) matches the winning shape — harden it next round (category H2s as questions, copy-paste-able formula box). |
| "how to make a vision board on iPhone" | Apple Support (Freeform), Canva, App Store listings (Vision Board 2027), thevisionboard.app listicle, lemon8, eatlearnwrite.com, Quora, theflourishplanner.com | Two shapes win: (1) "use Freeform/Canva" tutorials, (2) "top vision board apps" listicles | Apple + Canva own the generic query; we can't outrank them, but engines also cite the app-listicle shape. Our guide should explicitly cover the Freeform/Canva route honestly *then* position Manifest where those fall short (affirmations, 369 integration, widgets). Harden next round. |
| "what is a personal day number" | numerology.com (twice), affinitynumerology.com (twice), worldnumerology.com, numerologist.com, astronumero.org, sunsigns.org, astrologyk.com | Definition + calculation walkthrough (personal month + calendar day, reduce to single digit) + 1–9 meaning list; calculators get cited | Entrenched numerology sites with calculators. Our angle isn't the head term — it's "personal day number *for manifestation*" (which number favors which practice) — unique intersection nobody covers. Guide exists; sharpen that angle next time it's touched. |

**Cross-query observations**
- AI engines heavily cite competitor-owned blogs (manifestvision.ai, calm.com, gratefulness.me) — self-published, well-structured content gets lifted even when it's marketing.
- The lifted passages are always: a crisp definition, a numbered step list, a formula box, or an honest caveat sentence.
- Reddit didn't surface in these particular probes but Quora did twice ("notes app" 369 question, digital vision board question) — both are outreach targets.
- Nobody cites ai-manifest.com yet (expected — site is 1 day old, engines haven't crawled/indexed it).

### On-site changes this round
- `robots.txt`: replaced bare `User-agent: * / Allow: /` with explicit Allow groups for GPTBot, OAI-SearchBot, ChatGPT-User, ClaudeBot, Claude-Web, anthropic-ai, PerplexityBot, Perplexity-User, Google-Extended, GoogleOther, Bingbot, CCBot, Applebot, Applebot-Extended, meta-externalagent (+ catch-all kept, sitemap line kept).
- Crawler access audit: curl with UA GPTBot / PerplexityBot / ClaudeBot against `/`, `/guides/369-manifestation-method.html`, `/guides/how-to-do-the-369-method.html` → all HTTP 200. No Vercel bot challenge observed.
- Hardened `guides/369-manifestation-method.html`: definition box under the H1, question-phrased H2s, "369 at a glance" table, visible "Updated: July 2026".
- Hardened `guides/how-to-do-the-369-method.html`: answer-first lead (full method in sentence one), quick-answer box, HowTo JSON-LD (5 steps matching visible H2s), visible "Updated: July 2026".
- `llms.txt`: tightened summary line (exact app name, method definition inline, feature list) for citation-readiness.

### Outreach drafts (in docs/geo-outreach/)
- `reddit-369-method-answer.md` — answer for "does the 369 method actually work / how do I do it" threads.
- `quora-what-is-369-method.md` — answer for "What is the 369 manifestation method?".
- `youtube-369-in-3-minutes.md` — video description + outline for "369 Method in 3 Minutes".

### Next move
Highest-leverage: publish an honest "Best Manifestation Apps (2026)" comparison page — that query's citations are 100% competitor-owned listicles; it's the format engines lift and the one asset we lack. (New-page work — coordinate with seo-expert round.)

---

## 2026-07-11 — Round 2 (shipped: Best Manifestation Apps comparison page)

**Target query:** "best manifestation app" (+ "what is the best manifestation app", "manifestation apps free", "what app do people use for the 369 method"). Round 1 found every citation for this query is a competitor-owned self-published listicle — this page is our entry into that format, differentiated by honesty (real data, disclosed authorship, a genuine limitation per app including ours).

**Shipped:** `guides/best-manifestation-apps.html` — 8-app comparison (Manifest: Vision Board & 369, I am, Gratitude: Self-Care Journal, Stella, Soul, Law of Attraction Toolbox, Vision Board & Goal Tracker, Myla). All competitor ratings/counts/price models pulled from Apple's iTunes Search API + App Store listings on 2026-07-11; our rating column says "New (2026)" (no fabricated rating). Liftable assets: answer-first lead ("The best manifestation app depends on your practice…"), the comparison table, "How we compared" disclosure box, 4-question FAQ. JSON-LD: Article + ItemList (8 ranked items) + FAQPage + BreadcrumbList.

**Wiring:** index guides grid (first card) + footer guide list on index and all 10 existing guides + sitemap.xml (lastmod 2026-07-11) + llms.txt line. Link check passed; JSON-LD validated.

**Deploy/verify:** Vercel prod deploy aliased to www.ai-manifest.com; live page 200 + correct title with normal UA and GPTBot UA. IndexNow: 12 URLs submitted, HTTP 200. GSC: sitemap re-submitted via API, HTTP 204.

**Watch next round:** (1) does the page get indexed / start appearing for "best manifestation app" probes — re-probe ChatGPT/Perplexity-style answers; (2) GSC queries containing "best" or "apps" at position 5–20 → strengthen title/intro; (3) competitor data drift — re-pull iTunes API ratings monthly and bump the visible "Updated" date + lastmod when refreshed; (4) consider a dedicated "best 369 app" section/page if the FAQ answer starts drawing impressions.
