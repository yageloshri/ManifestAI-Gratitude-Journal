# Content Agent Playbook — ai-manifest.com

*Citation-backed operating rules for the recurring SEO/GEO content agents. Every article the agents write MUST pass both checklists below. Compiled 2026-07-28 from deep research.*

---

# SECTION 1 — WRITING AUTHENTICITY: Write So It Doesn't Read (or Flag) as AI

## 1.1 The evidence: AI tells are real and measurable

- The definitive study (Kobak et al., 14.2M PubMed abstracts, 2010–2024) found "delves" appearing at **25x** its expected baseline, "showcasing" 9.2x, "underscores" 9.1x after ChatGPT's release (https://arxiv.org/html/2406.07016v1). A second 27.5M-record analysis found **100 words/phrases** exceeding statistical anomaly thresholds in 2024 (https://www.medrxiv.org/content/10.1101/2024.05.14.24307373v2).
- Two detector concepts explain the structural tells: **perplexity** (predictable word choice reads as AI) and **burstiness** (sentence-length variation — human writing swings ~0.6–1.2 in spread; GPT output clusters at ~0.2–0.4) (https://gptzero.me/news/perplexity-and-burstiness-what-is-it/).

## 1.2 Structural tells (these matter more than vocabulary)

1. **"It's not X — it's Y" / "not just X, but Y" negative parallelism** — the #1 AI tell (https://ruben.substack.com/p/its-not-x-its-y).
2. **Rule-of-three overuse** — three parallel items by default.
3. **Em-dash overuse** — max ~1 per 300 words.
4. **Bolded-lead bullet lists** — every bullet opening with a **Bold Phrase:** is pure ChatGPT markdown.
5. **Uniform sentence and paragraph length** — low burstiness is the core statistical signature.
6. **Empty transitions** ("Moreover," "Furthermore," "Additionally").
7. **Hedging everything** ("may," "can potentially," "it's important to note") — no stance.
8. **The neat-bow conclusion** — restating the whole article, generic profundity.
9. **Vagueness** — no real names, prices, dates, or personal moments.
10. **Over-summarizing / listicle-itis** — fragments instead of sustained argument.

## 1.3 Techniques that read as authentically human

- **Burstiness on purpose.** Follow a fragment ("It works.") with a long, winding sentence. Vary paragraph length: 1-sentence paragraphs next to 6-sentence ones.
- **Concrete specificity** — real dates, numbers, app-screen moments, named books/creators (Nikola Tesla and the 369 method, Rhonda Byrne's *The Secret*, the TikTok #369method wave). Specificity is the strongest anti-AI signal *and* Google's "original information" quality signal.
- **First-person stance and opinion.** "I think the 55×5 method is overkill for beginners" is human; "some practitioners find…" is AI. Take positions.
- **Anecdote** — one first-hand micro-story per article.
- **Deliberate imperfection** — a parenthetical aside, a sentence starting with "And" or "But," a question left open.
- **Voice sample matching** — mirror 300–500 words of genuine human reference writing.
- **Sensory and cultural texture** — concrete imagery raises perplexity naturally.

## 1.4 What Google actually says

- **AI content is not penalized per se.** Google rewards quality "however it is produced"; the violation is automation "with the primary purpose of manipulating ranking" (https://developers.google.com/search/blog/2023/02/google-search-and-ai-content).
- The named spam policy is **"scaled content abuse"** (March 2024): many pages generated primarily to manipulate rankings, not help users — regardless of AI/human/hybrid (https://developers.google.com/search/docs/essentials/spam-policies).
- **E-E-A-T**: Trust is most important; **Experience** (first-hand use) is exactly what raw AI output lacks. Google's **Who/How/Why** framework: visible author, transparency, people-first purpose (https://developers.google.com/search/docs/fundamentals/creating-helpful-content).
- **Goal: not "pass as human" but "be genuinely helpful, experienced, original."** That also defeats detectors.

## 1.5 AI detectors: unreliable — don't optimize for them

- OpenAI retired its own classifier (July 2023) at 26% catch rate / 9% false positives. Stanford (Liang et al. 2023): 61.3% false-positive rate on non-native-English essays. Chasing a "0% AI" score is unwinnable and irrelevant — Google ranks on helpfulness.

## 1.6 WORD/PHRASE BLOCKLIST (apply mechanically — reject or rewrite on match)

**Verbs:** delve, delving, leverage, elevate, empower, unlock, unleash, harness, foster, bolster, amplify, streamline, revolutionize, illuminate, facilitate, cultivate, underscore, resonate, embark, navigate (metaphorical), unravel, elucidate, encompass, discern, supercharge, showcase, transform (as hype)

**Adjectives:** crucial, vital, paramount, integral, profound, nuanced, multifaceted, comprehensive, holistic, inherent, pivotal, robust, transformative, groundbreaking, cutting-edge, seamless, invaluable, unwavering, stark, noteworthy, vibrant, bustling, keen, game-changing

**Nouns:** realm, landscape, tapestry, testament, synergy, interplay, underpinnings, metamorphosis, endeavor, treasure trove, journey (metaphorical), game changer

**Transitions/hedges:** moreover, furthermore, additionally, subsequently, consequently, nonetheless, notably, essentially, ultimately, arguably, indeed, thus, firstly, "it is worth noting that," "one might argue"

**Phrases:** "in today's world," "in today's fast-paced world," "in conclusion," "a testament to," "navigating the landscape of," "the transformative power of," "play a pivotal role," "underscore the importance of," "seamless integration," "rich tapestry," "when it comes to," "the world of," "whether you're a X or a Y," "look no further," "dive into," "at the end of the day"

## 1.7 MECHANICAL CHECKLIST — Writing Authenticity (run on every draft)

**Blockers (fail → rewrite):**
- [ ] Zero hits from the §1.6 blocklist (regex scan; allow only inside quotes)
- [ ] Zero "not just X, it's Y" / "It's not X — it's Y" constructions
- [ ] ≤1 em-dash per 300 words
- [ ] No conclusion that restates the intro; end with a forward action, open question, or specific next step
- [ ] No paragraph opens with Moreover/Furthermore/Additionally/In conclusion
- [ ] ≤1 bulleted list per 500 words; bullets must not all start with a bolded phrase
- [ ] No three-item parallel list more than once per article

**Requirements (must be present):**
- [ ] Sentence-length variance: at least one sentence ≤6 words AND one ≥30 words per ~200 words; std dev of sentence length ≥8 words
- [ ] Paragraph variance: mix of 1–2-sentence and 4+-sentence paragraphs
- [ ] ≥3 concrete specifics (named person/book/creator, exact number, date, price, real place)
- [ ] ≥1 first-person anecdote or observation
- [ ] ≥1 explicit opinion or stance (something a reader could disagree with)
- [ ] Second editing pass that cuts 10–15% of words (AI drafts are padded)
- [ ] Byline with a real author + author bio page

---

# SECTION 2 — SEO + GEO PLAYBOOK (2026)

## 2.1 On-page fundamentals

- **Titles:** 50–60 chars, unique, primary keyword front-loaded.
- **Meta descriptions:** 120–160 chars, unique per page.
- **Headings:** one H1, logical H2/H3 nesting; phrase H2s as real questions — they become the retrieval unit AI engines quote.
- **Internal linking:** 2–5 contextual links per 1,000 words, descriptive anchors, link from high-traffic pages to new pages.
- **Freshness:** ~83% of AI citations come from pages updated within 12 months (https://almcorp.com/blog/answer-engine-optimization-2026/). Schedule refreshes.
- **Topical clusters are the backbone.** Pillar page (3,000–5,000 words) + 10–20 interlinked cluster articles; clustered content drives ~30% more traffic and holds rankings ~2.5x longer (https://searchengineland.com/guide/topic-clusters).

## 2.2 E-E-A-T / helpful content

- Helpful Content System folded into core ranking March 2024 — now a **site-wide** signal: thin content drags down good pages, so prune.
- Manifestation/spirituality is YMYL-adjacent. Trust signals matter disproportionately: real bylines with bios, about/contact pages, conservative claims (never promise outcomes; frame as practice/mindset, cite psychology research on gratitude).

## 2.3 GEO/AEO — getting cited by ChatGPT, Perplexity, AI Overviews, Claude, Copilot

**Proven levers (Princeton GEO paper, ACM KDD 2024, arXiv:2311.09735):**
- **Cited statistics**: up to **+41%** AI-answer visibility.
- **Expert quotations**: second-strongest lever.
- **Citing sources**: +115% relative visibility for pages ranked ~5th.

**Correlation data:**
- 76% of AI-Overview-cited pages ranked top-10 in classic search (Ahrefs) — traditional SEO is the foundation.
- Strongest AI-visibility signals: **off-site brand mentions** (0.664 correlation); heavy Reddit/Quora mention volume ≈ 4x citation odds; YouTube mentions are the strongest AI Overview correlate.
- 88% of AI summaries cite 3+ sources — you only need to be one corroborating source.

**Content-structure tactics:**
- **Answer-first:** each H2 question answered directly in the first 2–3 sentences, then elaborated.
- **Definition up top:** "The 369 method is a manifestation practice where you write a desire 3 times in the morning, 6 in the afternoon, 9 at night." — these get lifted verbatim.
- **Lists and comparison tables** for anything comparative.
- **Off-site:** genuine Reddit (r/lawofattraction, r/NevilleGoddard) + Quora + YouTube presence.
- **llms.txt: low priority.** ~9–10% adoption, no engine confirms using it. Ship one as a hedge; never prioritize. What matters: **don't block GPTBot, PerplexityBot, ClaudeBot, Google-Extended in robots.txt.**

**Schema:**
- FAQ/HowTo rich results are dead but markup aids machine parsing — keep FAQPage on Q&A sections.
- Implement: **Article/BlogPosting** (author → real Person, datePublished, dateModified), **Organization** (sameAs), **BreadcrumbList**.

## 2.4 Programmatic & multilingual SEO

- **URL structure: subdirectories** (`/pt/`, `/es/`) — inherit root authority. Never `?lang=` params.
- **hreflang via XML sitemap;** bidirectional return links mandatory; every version references itself + all others + `x-default`; codes like `pt-BR`, `es-419`. ~75% of implementations have errors — validate after every deploy (https://developers.google.com/search/docs/specialty/international/localized-versions).
- **Fully translate the body, always.** Translated pages are only duplicates if main content stays untranslated.
- **Localize, don't translate:** pt-BR "método 369 / números dos anjos / lei da atração"; es "ley de la atracción / números de ángeles". Raw machine translation at scale = scaled-content-abuse exposure.
- **Angel-number pages are naturally programmatic — fine** if each carries genuinely unique analysis. Template-with-number-swapped = doorway-page penalty.

## 2.5 Prioritized language set

| Tier | Language | Why |
|---|---|---|
| 1 | **English** | Base; ~49% of web, 42% of App Store revenue |
| 1 | **Portuguese (pt-BR)** | The niche's breakout market — LatAm niche revenue 5x'd in 5 years |
| 1 | **Spanish (es-419)** | #2–3 internet language; large "ley de la atracción" audience |
| 2 | **German** | High-ARPU iOS market |
| 2 | **French** | Solid European niche market |
| 2 | **Japanese** | #2 app-revenue country, strong horoscope culture — needs true localization |
| 3 | Korean | High-spend, spiritually engaged Gen Z |
| 3 | Italian | Cheap incremental EU coverage |
| 3 | Indonesian | Volume/SEO play, low ARPU |
| 3 | Hindi | Only with re-created (numerology/ank jyotish) content |

Rule: ship English → pt-BR → es first. Translate a piece only after it proves itself in English — never auto-publish MT stubs.

## 2.6 Pillar-cluster map + article topics

**Pillars:** A) Manifestation complete guide · B) Angel numbers meanings hub · C) Manifestation journaling & prompts · D) Best manifestation apps/tools (money pages).

**Informational (TOFU):**
1. How to do the 369 manifestation method (step-by-step)
2. Angel number 1111 meaning & why you keep seeing it
3. Angel number 444 meaning
4. Angel number 222 meaning
5. Angel number 555 meaning (change)
6. Angel number 369 meaning (love, career, money)
7. What is Lucky Girl Syndrome — and how to actually do it
8. The scripting method for manifestation, explained
9. Law of Attraction for beginners
10. The 55×5 manifestation method
11. How to make a vision board that you'll actually use
12. Does manifestation work? What psychology says (E-E-A-T anchor piece)

**Mixed intent (MOFU → app):**
13. 50 manifestation journal prompts (free template → app CTA)
14. Gratitude journaling: benefits + how to start
15. 5-minute morning manifestation routine
16. Manifestation affirmations for money, love, and confidence

**Commercial (BOFU):**
17. Best manifestation apps in 2026 (ranked — include your own honestly)
18. Best gratitude journal apps
19. Best angel-number apps

**Cadence:** 1–2 quality English cluster pieces per week. Complete one pillar's cluster before starting the next.

## 2.7 MECHANICAL CHECKLIST — SEO/GEO (run on every article)

**On-page:**
- [ ] Title 50–60 chars, keyword front-loaded; meta description 120–160 chars, unique
- [ ] Exactly one H1; H2s phrased as questions where natural
- [ ] Definition of the core term in the first 2 sentences under the H1
- [ ] Each H2 section opens with a direct 2–3 sentence answer
- [ ] ≥1 cited statistic with source link; ≥1 named expert/book quote
- [ ] ≥1 list or comparison table where content is comparative
- [ ] 2–5 internal links per 1,000 words; links up to the pillar + laterally to ≥1 sibling; pillar updated to link back
- [ ] Article/BlogPosting schema (real author Person, datePublished, dateModified); BreadcrumbList; FAQPage on Q&A blocks
- [ ] Byline → author bio page; no outcome guarantees (practice/mindset framing, cite research)

**Site-level (per run):**
- [ ] robots.txt does NOT block GPTBot, PerplexityBot, ClaudeBot, Google-Extended
- [ ] Refresh any article >6 months old targeting a commercial term
- [ ] Prune or merge thin pages
- [ ] One off-site action noted per run (Reddit/Quora/YouTube idea for Yagel)
- [ ] Every new guide added to `website/llms.txt` (one line, en URL) + a run entry appended to `website/geo-log.md` — we maintain both even though llms.txt is a hedge; skipped twice (1111, 444), don't repeat

**Multilingual (per translated page):**
- [ ] Subdirectory URL (`/pt/...`); full main-content translation; localized keywords + examples + CTAs
- [ ] hreflang in sitemap: self + all alternates + x-default, bidirectional; validated post-deploy
- [ ] Never publish raw MT at scale; Tier-1 languages get a real editorial pass

---

**Bottom lines:** (1) Don't chase AI-detector scores — chase specificity, stance, and first-hand experience. (2) Pillar-cluster + answer-first + cited-stats is the one play that compounds classic SEO and AI-engine citations. (3) Spend energy on pt-BR/es localization and off-site Reddit/YouTube mentions, not llms.txt.
