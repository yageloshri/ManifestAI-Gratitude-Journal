# Manifest — Marketing Site

SEO-optimized static marketing site for **Manifest: Vision Board & 369**
(iOS, [App Store](https://apps.apple.com/us/app/manifest-vision-board-369/id6757018484)).

- **Domain:** https://ai-manifest.com (all canonicals, OG tags, and sitemap URLs point here)
- **Stack:** plain HTML + one CSS file. No build step, no JavaScript. Deploys to Vercel as-is
  (root directory = `website/`, framework preset = "Other").

## Structure

```
website/
├── index.html                  # Landing page (SoftwareApplication + FAQPage JSON-LD)
├── guides/                     # 10 SEO guide pages (Article + BreadcrumbList JSON-LD)
├── css/styles.css              # Full design system (dark night-sky theme)
├── assets/                     # App icon, screenshots (webp+png), owl art, App Store badge
├── privacy.html, terms.html    # ⚠️ Linked from App Store Connect — DO NOT modify/delete
├── sitemap.xml, robots.txt
├── keywords.md                 # Keyword research map (primary + long-tail → target pages)
└── app.md                      # App Store listing source data
```

## SEO notes

- Keyword → page mapping lives in `keywords.md`. Each guide targets exactly one search query
  cluster; the index FAQ mirrors People Also Ask phrasing with FAQPage JSON-LD.
- Every page has: one H1, unique title (≤60 chars), meta description (≤155 chars), canonical,
  OG/Twitter cards, descriptive alt text, `<picture>` webp-with-png-fallback, lazy-loaded images.
- Internal linking: index → all guides (grid + footer), guides ↔ guides ("Keep learning" + inline),
  guides → index (breadcrumbs + header).

## Editing guides

Guide pages were generated from a shared template; they are now plain static HTML and can be
edited directly. If you add a guide, also add it to: `sitemap.xml`, the index guide grid,
the index footer, and every guide's footer guide list.

## Deploy checklist

1. Point the `ai-manifest.com` domain at the Vercel project.
2. After deploy, submit `https://ai-manifest.com/sitemap.xml` in Google Search Console.
3. Keep `privacy.html` / `terms.html` URLs stable — App Store Connect links to them.
