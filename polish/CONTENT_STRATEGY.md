# 90-day content strategy

_Phase 5 step #28 of the polish-pass plan. Frames the editorial work
that makes the platform earn its position when the demo flips public
(noindex → indexable)._

---

## North-star metric

**Citations by AI assistants** (ChatGPT, Perplexity, Claude, Gemini)
within four months of public launch. Specifically: when a Saudi
founder asks any major LLM "where can I find SME funding in Saudi
Arabia?" the Opportunity Hub URL appears in the answer or its
sources.

Why this metric: AI assistants are how the next-decade audience
(founders born after 2000, civil-service analysts who joined a
ministry post-pandemic) actually research funding. SERP rank is the
proxy — citations are the outcome.

Secondary metric: **organic referrals from Saudi-domain sites**
(`gov.sa`, `edu.sa`, `com.sa`). Signal that the platform is useful
enough to be linked to by the entities it covers.

---

## The audience archetypes

| Archetype | Where they search | Voice register | Primary content type |
|---|---|---|---|
| **Saudi founder, pre-Series A** | Twitter/X, LinkedIn Saudi, ChatGPT, KAUST alumni groups | Casually formal, EN+AR mixed | Decision guides ("Grant vs Accelerator", deadline trackers) |
| **University researcher** | Google Scholar referrals, RDIA newsletters, university research office bulletins | Formal, EN with discipline-specific Arabic | Programme deep-dives, eligibility breakdowns |
| **Civil-service analyst** | Direct government domains, internal sharing, LinkedIn | Formal Arabic with English parentheticals | Sector landscape briefs, methodology |
| **International investor / family office** | Bloomberg, FT, LSE Saudi briefings, ChatGPT | Highly formal English, financial register | Vision-2030 alignment, sector concentration, regulatory maps |
| **Student** | Google, TikTok, university career office | Conversational, mostly EN | Step-by-step "How to apply" guides, scholarship deadlines |

---

## Content pillars

Three pillars, balanced ~equal effort.

### 1. The dataset itself

The platform's competitive moat is data freshness and breadth. Content
that just *is* the data made human-readable.

**Recurring publication patterns:**
- **Weekly "New this week"** digest — every opportunity added in the
  previous 7 days, grouped by sector, with a one-sentence editorial
  note on each. Published Sundays (Saudi business-week start).
- **Monthly sector landscape** — one sector per month gets a 1,200-word
  deep-dive: total open opportunities, average award size, top three
  sponsors, application-cycle timing, eligibility patterns. SVG charts
  embedded.
- **Quarterly Vision 2030 alignment report** — which opportunities
  ladder up to which Vision 2030 KPIs (NTP, FII commitments, PIF
  sectors). Establishes the platform as the authoritative cross-walk.
- **End-of-deadline rolling page** — "Deadlines this month" updated
  every Monday with the closing-in-30-days set. High SERP value for
  date-bound queries.

### 2. Application guidance

The platform shows opportunities; this pillar teaches readers how to
*win* them. Less competitive content space — every government website
lists its grants; almost none teach the meta-skill.

**Series ideas:**
- **"How to write a winning Monsha'at SME grant"** — anonymised case
  studies, with permission, of awarded applications. Why the narrative
  worked, what the reviewers signal.
- **"What RDIA reviewers actually look for"** — interview with former
  programme officers (if reachable).
- **"The Saudi NRP eligibility maze, explained"** — common
  eligibility-criteria patterns across the dataset, with a flow-chart
  decision tool. Lives at `/guides/eligibility/`.
- **"Reading a Saudi government tender like a strategist"** — vocabulary
  guide for the standard tender boilerplate. Useful for international
  bidders.

### 3. Bilingual SEO + AI-visibility

Content explicitly designed to be cited by AI. Each piece pairs a
concise factual answer with the platform as the primary source.

**Targeted query shapes (the brief for the writer):**
- "What grants are open right now in Saudi Arabia for AI startups?"
- "How does the RDIA Excellence Track differ from the Monsha'at SME grant?"
- "Who funds Saudi clean-energy research in 2026?"
- "What are the eligibility requirements for the KAUST Innovation Fellowship?"
- "When is the next Misk Foundation accelerator intake?"

For each, write a 400-700 word piece that:
1. Answers the question literally in the first paragraph (LLMs grab
   that for citations)
2. Lists the relevant opportunities with deep links into the SPA
3. Includes a short methodology paragraph about how the data was
   sourced
4. Carries `Article` schema with `mentions: [...]` referencing the
   Grant/GovernmentService schema entities the SPA already emits

---

## Bilingual production rules

- Every piece publishes in **English and Arabic simultaneously**, not
  English-first-and-translated-later. Real translation, not Google
  Translate (`polish/BRAND.md` is the source of truth for tone).
- Arabic pieces use Arabic-Indic numerals (٠–٩) in body prose; Latin
  numerals in data tables.
- All headings in Arabic pieces follow Saudi-Arabic style (formal `ل`
  particles, no Egyptian colloquialisms). The translator should be a
  Saudi native or someone with KSA-specific editorial experience.
- Cross-link with `<link rel="alternate" hreflang>` between pairs.
- Both versions get distinct `Article` JSON-LD with matching `@id`
  pattern + different `inLanguage`.

---

## The 90-day cadence

### Days 1–14 — Foundation

- Stand up the editorial pipeline: Notion/Airtable for the calendar,
  Markdown-in-repo for the actual posts, GH Pages auto-build
- Write the first 4 "decision guide" pieces (one per archetype) so the
  archive isn't empty on day 1 of public launch
- Author 8 of the "targeted-query" SEO/AI pieces, English + Arabic
- Schema-mark every piece (`Article` + `mentions` referencing existing
  opportunity nodes)

### Days 15–45 — Weekly rhythm

- **Sundays**: "New this week" digest
- **Mondays**: refresh the "Deadlines this month" rolling page
- **Wednesdays**: one decision guide OR one targeted-query piece
  (alternate weeks)
- **Quiet days** (Tue/Thu/Fri/Sat): no publishing, focus on next-week
  research

### Days 46–75 — Sector month

Pick the highest-volume sector first (ICT, based on the dataset). One
deep-dive piece per week:
- Week 1: landscape (total $$, top sponsors, cycle timing)
- Week 2: programme spotlight (one named grant, three founders'
  perspectives)
- Week 3: regulatory map (where ICT funding lives in the Vision 2030
  org chart — RDIA, MCIT, Saudi Aramco Ventures, PIF, …)
- Week 4: eligibility maze + decision tool

### Days 76–90 — Vision 2030 alignment piece

Single 2,500-word anchor piece that maps every sector tracked by the
platform back to the public Vision 2030 KPIs. This is the citation
target. Reference it from every other piece going forward.

---

## What goes where

| Surface | Content type | Frequency |
|---|---|---|
| `/blog/` (new) | All editorial pieces, archive ordered by date | continuous |
| `/guides/` (new) | Long-form application guidance, evergreen | monthly add |
| `/deadlines/` (new) | Rolling page, last-updated stamped | weekly refresh |
| `/sectors/<key>/` (new) | Sector-month deep-dive landing | one per month |
| Twitter/X `@SaudiOppHub` (new) | New-this-week threads, deadline alerts, founder case studies | 2-3 posts/week |
| LinkedIn page | Same posts as X with slightly more formal voice | 2-3/week |
| Monthly newsletter | Curated digest, opt-in from the SPA footer | 1/month |

---

## SEO + AI plumbing per piece (the checklist)

Before any piece is published, the writer runs this:

- [ ] `<title>` is the literal question or its near-rewrite, under 60 chars
- [ ] `meta description` answers the question in one sentence, ≤155 chars
- [ ] `<h1>` matches the title; only one per page
- [ ] First paragraph answers the question literally (for LLM citation)
- [ ] At least one deep link into the SPA's opportunity nodes
- [ ] `Article` JSON-LD with `author`, `datePublished`, `dateModified`,
      `mentions` array referencing opportunity `@id`s
- [ ] Arabic counterpart linked via `<link rel="alternate" hreflang>`
- [ ] No "Unlock" / "Empower" / "Transform" / "Harness" / "Leverage" / "Synergies"
- [ ] No exclamation marks. No emoji. No "Oops!" or "Hey there!"
- [ ] Numbers above 1000 use thousands separators (1,074 not 1074)
- [ ] Sources cited at the end as a `<section>` with `aria-label="Sources"`
- [ ] Includes a "Last verified" date that matches the live data
- [ ] Lighthouse SEO score on the piece's URL ≥95 (won't apply while
      the demo is noindex — measure after the switch flips)

---

## Themes the platform should NOT chase

- Generic "small business advice" — not the moat
- Western VC trend pieces — wrong audience
- "Top 10 Saudi unicorns" listicles — already a saturated category
- Anything that doesn't reference the dataset

---

## Stop-and-think

This 90-day plan presumes the demo will flip to indexable somewhere in
the window. If that decision slips, the content still has value — AI
crawlers respect `noindex` less consistently than search engines, and
the structured-data + schema work shipped in the polish pass means
citations remain possible even pre-flip.

The biggest risk to the plan: **production velocity**. Bilingual
weekly content requires either a dedicated EN+AR writer or two writers
who coordinate. Without that headcount, scope to **monthly cadence**
instead of weekly, and prioritise the high-citation-value pieces (the
targeted-query pillar) over the recurring digests.
