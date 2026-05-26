# Saudi Opportunity Hub — Brand Voice & Identity

_Source of truth for voice, tone, terminology, and bilingual rules._

---

## Voice attributes (the only four that matter)

1. **Quietly confident.** Government-grade, not startup-grade. State the
   value plainly; don't sell. The reader is a senior civil servant, a
   PIF analyst, a NEOM project lead, or a researcher building a proposal.
   They are intelligent and short on time.
2. **Bilingual by default.** English and Arabic are peers, not primary
   and translated. Headlines, microcopy, and error messages are written
   in both registers — and Arabic copy reads as if written in Arabic,
   not translated.
3. **Vision-2030-aware, never Vision-2030-cliché.** Saudi sovereign
   ambition is the context, not the slogan. Reference sectors, programs,
   and entities by their real names. Do not lean on "transformation",
   "unlock potential", "harness", "leverage synergies" — these are
   exactly the words that make government audiences distrust a platform.
4. **Specific over evocative.** "76 grants open across 12 sectors,
   updated weekly" beats "comprehensive funding landscape across the
   Kingdom." Concrete numbers, named programs, dated verification.

---

## Tone moves

**Do:**
- Lead with the noun and the number. "12 grants open. Deadlines this month."
- Use the institution's full proper name on first mention: Research,
  Development and Innovation Authority (RDIA). Acronym after.
- Date everything that has a deadline. "Closes 30 June 2026" not "Closing soon."
- Use plain verbs: open, close, accept, review, fund, award, publish.
- Keep buttons under 3 words. "View opportunity", "Sign in", "Request access".
- When in doubt, write less.

**Don't:**
- ❌ "Empower your future" / "Unlock opportunities" / "Transform your journey"
- ❌ "Oops! Something went wrong" — use "We couldn't load that. Try again."
- ❌ Emoji in any user-facing UI string. ✨🚀💡 are forbidden.
- ❌ Exclamation marks, except in literal quoted material.
- ❌ "Click here" — the link text must describe the destination.
- ❌ "We're sorry but…" — apologise once, in plain language, then act.
- ❌ "Hey there!" / "Howdy" / "Just a heads up" — too casual for the audience.

---

## Terminology (the GCC funding lexicon)

These are proper nouns. Capitalise correctly; never translate the brand
unless an Arabic form is officially used by the entity.

| English | Arabic | Notes |
|---|---|---|
| Vision 2030 | رؤية 2030 | Always capitalised in English. |
| Public Investment Fund (PIF) | صندوق الاستثمارات العامة | PIF in English on subsequent mentions. |
| Ministry of Investment (MISA) | وزارة الاستثمار | MISA after first mention. |
| Monsha'at — SME General Authority | منشآت — الهيئة العامة للمنشآت | Apostrophe in "Monsha'at" is required. |
| Research, Development and Innovation Authority (RDIA) | هيئة البحث والتطوير والابتكار | Spell out on first mention. |
| KAUST | جامعة الملك عبدالله للعلوم والتقنية | Acronym is universal; the Arabic is for formal contexts only. |
| Misk Foundation | مؤسسة مسك | Note: not "the Misk". |
| NEOM | نيوم | Always all-caps in English. |
| Saudi Development Bank (SDB) | بنك التنمية السعودي | |
| Aramco | أرامكو السعودية | "Saudi Aramco" in formal contexts. |
| GCC | دول الخليج | "the GCC" (with article) in English prose. |
| grant | منحة (plural: منح) | |
| tender / RFP | مناقصة / طلب عروض | "tender" for general use; "RFP" only for formal procurement. |
| accelerator | حاضنة أعمال / مسرّعة | |
| fellowship | زمالة | |
| investment program | برنامج استثماري | |
| eligibility | معايير الأهلية | |
| deadline | الموعد النهائي | |

**Numbers and dates:**
- English: ISO format for data tables (`2026-06-30`), prose-friendly for
  marketing (`30 June 2026`). Day before month, no comma.
- Arabic: Use Arabic-Indic numerals (٠–٩) in body copy; Western numerals
  in data tables and code. Date order in Arabic: day month year
  (٣٠ يونيو ٢٠٢٦).

---

## Voice patterns by component

### Empty states
- **Do**: "No opportunities match these filters. Try clearing the sector filter."
- **Don't**: "Nothing here yet! Try something else 🙂"
- Always include the action that will resolve the empty state.

### Errors
- **Do**: "We couldn't load this opportunity. Refresh, or [contact support](contact.html)."
- **Don't**: "An error has occurred."
- Name the thing that failed. Offer one action. Offer one fallback.

### Loading
- Skeleton states are silent. No "Loading..." text.
- If a real fetch will take >2s, replace skeleton with: "Still loading. This is taking longer than usual."

### Success
- One sentence, past tense. "Saved." "Sent." "Sign-in link emailed."
- No celebration ("Awesome!", "🎉"). Government context.

### Calls to action (buttons)
- ≤ 3 words. Verb-led.
- "View opportunity" not "Click to learn more"
- "Sign in" not "Login" (sign in is verb, login is noun)
- "Request access" not "Get started"

### Form labels
- Sentence case. No colon. Required by default; mark optional explicitly.
- Helper text under the field, not in a tooltip.
- Error message replaces helper text on invalid.

---

## Bilingual rules

1. **EN/AR parity, not EN/AR translation.** Every user-facing string has
   both. Arabic strings are reviewed by a native speaker before merge.
2. **RTL is structural.** Layouts mirror via `dir="rtl"` on `<html>` and
   logical CSS properties (`margin-inline-start`, `padding-inline-end`).
   Directional icons (chevrons, arrows) mirror; non-directional ones
   (search, settings, info) do not.
3. **Numbers in mixed text use LTR isolate** (`<bdi>` or `&#x2068;…&#x2069;`)
   so they render correctly inside RTL paragraphs.
4. **Fonts:**
   - English / Latin: **Inter** (body), with **Space Grotesk** retained
     for display headings where the existing system uses it.
   - Arabic: **IBM Plex Sans Arabic** is the default per the user's
     directive. Existing pages using **Noto Kufi Arabic** (login, contact)
     migrate in Phase 2. Satoshi is removed.
5. **Punctuation:**
   - Arabic comma: ،  (U+060C, not Latin `,`)
   - Arabic question mark: ؟ (U+061F)
   - Use them consistently in Arabic body text.

---

## Saudi visual culture — restrained, never kitschy

- The Saudi green `#006C35` (national flag) is the accent. Use it
  sparingly — for primary CTAs, key statuses, brand mark. Not for body
  backgrounds, not for hero floods.
- Geometric inspiration: **mashrabiya** (wooden lattice), **eight-point
  star** (Islamic geometry), **dune contour lines**. Used as subtle
  background motif at low opacity (~5-8%), behind hero or as section
  divider. Never as a foreground decoration.
- Gold (`#C9A66B` in the current cream palette) is a secondary accent
  — calligraphy gold, not Vegas gold. Reserve for moments that earn it
  (premium tier badges, verified marker, anniversary milestones).
- **Avoid:** dome silhouettes, camel illustrations, palm trees, generic
  "Middle East = sand and minarets" imagery. The audience is the people
  who actually live there.

---

## Existing voice — what the platform already does well

From `index.html` and the white-label theme taglines:

- Theme taglines are well-judged: "Aligned with Vision 2030",
  "Financing the Future of Saudi Arabia", "Investment Intelligence
  Platform". Restrained, specific, in voice.
- The white-label registry treats sponsors (MISA, Monsha'at, ADIO, NEOM,
  SDB, Swift Solve) with their own correct branding — that's brand respect.
- Bilingual structure exists at the schema level (`labelAr`, `taglineAr`,
  `navNameAr`). Polish work builds on it; doesn't rebuild it.

---

## What this document does NOT cover

- Visual design tokens (colours, type scale, spacing, motion) — see
  `polish/DESIGN_SYSTEM.md` and `assets/tokens.css`.
- Specific page copy — covered in Phase 4 with the UX-copy pass.
- Translation pipeline — covered in Phase 4 alongside Arabic localisation.
