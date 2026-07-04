# ManifestAI — Marketing Website

A single-page, no-build-step marketing site for **ManifestAI: Gratitude Journal** (iOS).
Plain HTML/CSS/JS — no frameworks, no bundler, no npm install required.

## Structure

```
website/
├── index.html          # main marketing page
├── privacy.html         # placeholder privacy policy
├── terms.html           # placeholder terms of service
├── robots.txt
├── sitemap.xml
├── css/styles.css       # design system + all animations
├── js/main.js           # starfield canvas, scroll reveals, parallax, tilt, nav, FAQ
└── assets/img/          # owl mascot art, app screenshots, hero nebula, OG image
```

## Preview locally

No build tools needed. Any static file server works:

```bash
cd website
python3 -m http.server 8080
# then open http://localhost:8080
```

Or, with Node installed:

```bash
npx serve website
```

Opening `index.html` directly via `file://` also works, but a local server is recommended so
relative asset paths and fonts behave exactly as they will in production.

## Deploy

### Vercel

```bash
cd website
npx vercel deploy --prod
```

Or connect the repo in the Vercel dashboard and set the **Root Directory** to `website/`
with no build command (static site).

### Netlify

```bash
cd website
npx netlify deploy --prod --dir .
```

Or drag-and-drop the `website/` folder into the Netlify dashboard, or connect the repo and
set **Publish directory** to `website`.

## Before you launch — TODOs left for the owner

1. **App Store link**: every `href="#appstore"` CTA is a placeholder. Replace with the real
   App Store listing URL once it's live (search for `#appstore` across `index.html`).
2. **Domain**: `index.html`, `privacy.html`, `terms.html`, `robots.txt`, and `sitemap.xml`
   all reference the placeholder domain `https://manifestai.app/`. Update to your real
   production domain (canonical link, Open Graph/Twitter `og:url` + `og:image`, sitemap
   `Sitemap:` line, and the JSON-LD `url`/`image` fields).
3. **Legal pages**: `privacy.html` and `terms.html` are clearly-marked placeholders. Have a
   lawyer (or the `legal` skill in this workspace) produce the final versions before launch.
4. **App Store badge**: the CTA buttons use a custom-styled badge (not Apple's official
   marketing asset) to avoid trademark-asset licensing issues in this deliverable. Before
   shipping, consider swapping in Apple's official "Download on the App Store" badge from
   Apple's marketing resources page, sized/used per their brand guidelines.
5. **Support email**: `privacy.html` and `terms.html` reference "contact information on the
   App Store listing" — add a real support email if you'd like one listed directly.
6. **Social links**: the footer's Instagram/TikTok icons point to `#`. Wire them up once the
   accounts exist, or remove them.
7. **OG image**: `assets/img/og-image.png` (1200×630) was cropped from the generated hero
   nebula. Swap in a custom-designed share image with logo/wordmark if you want stronger
   branding in link previews.

## Design notes

- **Palette**: deep purple night-sky (`#1a1235` family) with gold accent (`#fcd471`),
  glass-morphism cards, defined as CSS variables in `css/styles.css` (`:root`).
- **Type**: Bitter (serif, headings) + Poppins (body), loaded from Google Fonts with
  `preconnect` for performance.
- **Animations** (all hand-rolled, no JS libraries, all respect
  `prefers-reduced-motion`):
  - Canvas starfield with twinkling + slow drift in the hero
  - Scroll-triggered reveals via `IntersectionObserver`, staggered by card index
  - Parallax on the hero nebula, phone mockup, and owl mascot (pointer + scroll driven)
  - Auto-crossfade between two real app screenshots inside the CSS-built phone frame
  - Gold shimmer sweep on primary CTA buttons
  - Floating 3-6-9 numerals drifting through the hero
  - Subtle 3D tilt on feature/testimonial cards on mouse move
  - Animated conic-gradient border on the pricing card
  - Accordion FAQ built on native `<details>`/`<summary>` (works without JS; JS closes
    sibling panels for a single-open accordion feel)
- **Assets**: owl mascot PNGs were copied from the iOS app's `Assets.xcassets` (see below),
  resized with `sips` and converted to WebP with `cwebp` for performance, with PNG fallback
  via `<picture>` where used for real content images.

## Owl assets used

Copied from `ManifestAI - Gratitude Journal/Assets.xcassets/` and optimized into
`assets/img/`:

| Website file | Source imageset | Used for |
|---|---|---|
| `owl-welcome.png/.webp` | `WelcomeOwl.imageset` | Nav logo mark, hero floating owl, footer logo |
| `owl-369.png/.webp` | `Method369Owl.imageset` | 369 Method feature card, final CTA owl |
| `owl-numerology.png/.webp` | `OwlIllustration.imageset` | Daily Numerology feature card |
| `owl-science.png/.webp` | `ScienceOwl.imageset` | (available for future use / alt insight art) |
| `owl-commit.png/.webp` | `CommitOwl.imageset` | Vision Boards feature card |
| `owl-analysis.png/.webp` | `AnalysisOwl.imageset` | AI Gratitude Journal feature card |

Real app screenshots (`screenshot-today.png/.webp`, `screenshot-369.png/.webp`) power the
CSS phone mockup in the hero, auto-crossfading between the Today screen and the 369 Method
screen.

The hero's cosmic nebula backdrop (`hero-nebula.png/.webp`) and the Open Graph share image
(`og-image.png/.webp`) were generated with the nano-banana Gemini image tool to match the
app's purple/gold palette.
