# Off-site posting guide (English)

Written 2026-08-07. This is the highest-leverage growth action available to us and the
only one Claude cannot execute — Reddit and Quora require a real human account with real
history, and an automated post gets removed, damages the account, and can get the domain
filtered site-wide. Removal is worse than not posting.

## Why this matters more than more content

From `marketing/content-playbook.md` §2.3, the measured signals:

- **Off-site brand mentions correlate 0.664 with AI-engine visibility** — the single
  strongest signal there is.
- Heavy Reddit/Quora mention volume ≈ **4× the odds of being cited**.
- 88% of AI summaries cite 3+ sources, so we only need to be one corroborating source.

And from `website/geo-log.md`, the finding that still holds: **"Nobody cites
ai-manifest.com yet."** That, not content quality, is why ChatGPT doesn't return us in
English. Gemini put us #1 in Hebrew off the back of a single third-party page (Emotiv) —
which is exactly how cheap the threshold is once *someone else* is talking about you.

## Tracking — do not strip these

Every draft's App Store link now carries a campaign token. Apple reports these against
**real installs** in App Store Connect → App Analytics → Acquisition → Campaigns:

| draft | token |
|---|---|
| Quora | `?ct=off-quora` |
| Reddit | `?ct=off-reddit` |
| YouTube | `?ct=off-youtube` |

Keep the `?ct=` on the URL when you paste. Without it we learn nothing about whether this
channel is worth repeating, and the whole point is to find out which market pays.

## Before you post anything

1. **Read the sub's own rules first.** Reddit blocks our crawler, so these drafts were
   written from general norms and the rules were *not* verified against the live sidebar.
   Open each subreddit's rules page yourself and check the self-promotion rule before
   posting. If links are banned, delete the final paragraph — every draft is written so
   the answer stands complete without it.
2. **Account age and karma.** New accounts posting links get auto-removed by AutoModerator
   in most large subs. Use an account with genuine history, or spend a week commenting
   normally first.
3. **Comment, don't post.** Answering an existing thread reads as helpful; a new thread
   with a link reads as an ad. The Reddit draft is written as a reply for this reason.
4. **The 10:1 norm.** Ten genuine contributions for every one that mentions your product.
   This is the norm the communities police hardest.

## Sequence (one action per session, not all at once)

**Week 1 — Quora.** Lowest risk: Quora explicitly allows links and rewards long substantive
answers, and answers keep earning views for years. Target "What is the 369 manifestation
method?" and its near-duplicates. Post `quora-what-is-369-method.md` more or less as-is.

**Week 2 — Reddit warm-up.** No links at all. Answer 5-10 questions in r/lawofattraction,
r/Manifestation, r/NevilleGoddard genuinely, from real experience. This is the deposit that
makes week 3 possible.

**Week 3 — Reddit answer.** Find a live "does the 369 method work / how do I do it" thread
and reply with `reddit-369-method-answer.md`. Lead with the substance; the app mention is
the last paragraph and stays optional.

**Later — YouTube.** `youtube-369-in-3-minutes.md` is a full script with chapters and a
paste-ready description. Highest production cost, but YouTube mentions are the strongest
single correlate with AI Overview citations, and the video keeps working indefinitely.

## Honesty rules (these protect us)

- Every draft already says plainly that there is no scientific evidence the method attracts
  outcomes. **Do not remove that.** It is why the answers read as trustworthy, and it is
  the exact framing (Calm's honest-caveat shape) that AI engines quote.
- Disclose that you built the app. "I build one" / "my app" — every draft does this.
  Undisclosed promotion is what gets accounts banned.
- Never claim results the app doesn't produce.

## Measuring it

Two weeks after the first post, check App Analytics → Campaigns for `off-quora` /
`off-reddit` / `off-youtube`, and re-run the ChatGPT and Gemini probes in English. What we
are testing is not clicks — it is whether *being mentioned somewhere else* moves us into AI
answers. If one channel produces installs, that is the one to repeat.
