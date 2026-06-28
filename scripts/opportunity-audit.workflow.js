/* ============================================================================
   Opportunity Audit — multi-agent workflow
   ----------------------------------------------------------------------------
   Implements OPPORTUNITY_AUDIT_MASTER_PROMPT.md: validates every non-archived
   opportunity against its real source page using CHEAP (Haiku) subagents that
   visit each site, then applies the safe Apply Policy.

   Run with the Workflow tool:
     Workflow({ scriptPath: "scripts/opportunity-audit.workflow.js" })
   Pilot first:
     Workflow({ scriptPath: "...", args: { sampleLimit: 25 } })

   Context-safe: checker agents read their OWN slice from Supabase and return
   only issues + a tiny dedup key per row; the heavy data never enters the
   orchestrator context. The final return is a summary + file paths only.

   Web access: each checker prefers Bright Data MCP (ToolSearch "brightdata
   scrape") for real HTTP status, falling back to WebFetch. If only WebFetch is
   available, a failed load is AMBIGUOUS, so dead-link findings are QUEUED, not
   auto-applied (see Apply Policy in the master prompt).
============================================================================ */

export const meta = {
  name: 'opportunity-audit',
  description: 'Validate every opportunity (deadline, description, country, dead links, duplicates) via cheap web-visiting subagents; auto-apply safe high-confidence fixes, queue the rest.',
  whenToUse: 'Full data-quality sweep of public.opportunities with source-page verification.',
  phases: [
    { title: 'Discover' },
    { title: 'Verify',    detail: 'cheap Haiku subagents visit each source page', model: 'haiku' },
    { title: 'Cross-check', detail: 'adversarial re-verification of flagged rows', model: 'haiku' },
    { title: 'Dedup',     detail: 'cluster collisions, choose canonical', model: 'sonnet' },
    { title: 'Apply',     detail: 'auto-apply safe fixes, queue the rest' },
    { title: 'Report' },
  ],
};

// ── Config (args override) ─────────────────────────────────────────────────
const PROJECT_ID = 'dshrbbnjahjcwxzvzygh';
const BATCH_SIZE = (args && args.batchSize) || 20;
const SAMPLE_LIMIT = (args && args.sampleLimit) || null;   // e.g. 25 for a pilot
const RECHECK_WINDOW_D = (args && args.recheckDays != null) ? args.recheckDays : 14;
// Resumable loop support: process only rows not verified in the last
// RECHECK_WINDOW_D days (oldest first), and optionally cap how many this run.
// Each run stamps last_verified on EVERY checked row so the stale set shrinks
// and repeated runs converge to "everything verified". Pass allRows:true to
// re-check fresh rows too; perRunLimit:N to bound a single loop chunk.
const ONLY_STALE = !(args && args.allRows);
const PER_RUN_LIMIT = (args && args.perRunLimit) || null;   // e.g. 500 per loop pass
const RUN_CAP = SAMPLE_LIMIT || PER_RUN_LIMIT || null;
const STALE_CLAUSE = ONLY_STALE
  ? `AND (last_verified IS NULL OR last_verified < current_date - ${RECHECK_WINDOW_D})`
  : '';
const ORDER = ONLY_STALE ? 'last_verified ASC NULLS FIRST, id' : 'id';
const COLS = 'id,title,description_short,type,sponsor_institution,country,eligibility_region,funding_type,application_link,deadline_date,status,last_verified';
// Web tool: pass args.noBrightData=true to force WebFetch/WebSearch only.
const USE_BRIGHTDATA = !(args && args.noBrightData);
const WEB = USE_BRIGHTDATA
  ? 'Prefer Bright Data MCP (ToolSearch "brightdata scrape") for real HTTP status; fall back to WebFetch. Use WebSearch to corroborate.'
  : 'Bright Data is DISABLED for this run. Use WebFetch to read pages and WebSearch to corroborate/relocate. Do NOT call any Bright Data tool.';

// ── Schemas ─────────────────────────────────────────────────────────────────
const CHECK_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['results'],
  properties: {
    results: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        required: ['id', 'dedup_key', 'domain', 'unchecked', 'link', 'deadline', 'description', 'country'],
        properties: {
          id: { type: 'string' },
          dedup_key: { type: 'string' },     // lower(trim(title)) sans punctuation/years + sponsor + registrable domain
          domain: { type: 'string' },
          sponsor: { type: 'string' },
          unchecked: { type: 'boolean' },     // page would not load after retries
          link: {
            type: 'object', additionalProperties: false,
            required: ['verdict', 'confidence'],
            properties: {
              verdict: { type: 'string', enum: ['live', 'dead', 'redirected_generic', 'blocked_or_unknown'] },
              replacement_url: { type: 'string' },   // if the program moved: the new live URL (FIX, don't delete)
              program_gone: { type: 'boolean' },      // true ONLY if corroborated discontinued/no live equivalent
              evidence: { type: 'string' }, source_url: { type: 'string' }, confidence: { type: 'number' },
            },
          },
          deadline: {
            type: 'object', additionalProperties: false,
            required: ['ok', 'confidence'],
            properties: { ok: { type: 'boolean' }, current: { type: 'string' }, suggested: { type: 'string' }, suggested_status: { type: 'string' }, evidence: { type: 'string' }, confidence: { type: 'number' } },
          },
          description: {
            type: 'object', additionalProperties: false,
            required: ['ok', 'confidence'],
            properties: { ok: { type: 'boolean' }, suggested: { type: 'string' }, evidence: { type: 'string' }, confidence: { type: 'number' } },
          },
          country: {
            type: 'object', additionalProperties: false,
            required: ['ok', 'confidence'],
            properties: { ok: { type: 'boolean' }, current: { type: 'string' }, suggested: { type: 'string' }, evidence: { type: 'string' }, confidence: { type: 'number' } },
          },
        },
      },
    },
  },
};

const VERDICT_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['confirmations'],
  properties: {
    confirmations: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        required: ['id', 'field', 'confirmed', 'reason'],
        properties: {
          id: { type: 'string' },
          field: { type: 'string', enum: ['link', 'deadline', 'description', 'country'] },
          confirmed: { type: 'boolean' },     // true only if the refutation attempt FAILED
          reason: { type: 'string' },
        },
      },
    },
  },
};

const DEDUP_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['clusters'],
  properties: {
    clusters: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        required: ['canonical_id', 'archive_ids', 'reason'],
        properties: {
          canonical_id: { type: 'string' },
          archive_ids: { type: 'array', items: { type: 'string' } },
          reason: { type: 'string' },
        },
      },
    },
  },
};

const SCOPE = [
  `status <> 'archived'`,
  ONLY_STALE ? `not verified in last ${RECHECK_WINDOW_D}d` : `all rows`,
  RUN_CAP ? `capped at ${RUN_CAP} this run` : null,
].filter(Boolean).join(', ');

const checkerPrompt = (batchIndex) => `
You are a cheap, careful data-verification agent. PROJECT_ID=${PROJECT_ID}.

1) Load your slice. Use the Supabase MCP execute_sql (ToolSearch "supabase execute_sql"):
   SELECT ${COLS} FROM public.opportunities
   WHERE status <> 'archived' ${STALE_CLAUSE}
   ORDER BY ${ORDER}
   LIMIT ${BATCH_SIZE} OFFSET ${batchIndex * BATCH_SIZE};
   ${RUN_CAP ? `(Capped run: if OFFSET >= ${RUN_CAP}, return {"results":[]}.)` : ''}

2) For EACH row, visit application_link to verify. ${WEB}
   Make TWO independent attempts before declaring a link "dead".
   IMPORTANT: if the page won't load (block/timeout), the result is AMBIGUOUS —
   use verdict "blocked_or_unknown" (NOT "dead").
   If the link looks dead/moved, do a WebSearch for the program + sponsor:
     - found at a new live URL  -> set link.replacement_url (this is a FIX, not a delete)
     - clearly discontinued, OR no live equivalent anywhere AND the domain is
       truly dead (404/NXDOMAIN/parked) -> set link.program_gone=true
     - otherwise (just blocked/uncertain) -> leave both unset; do NOT mark gone.

3) Run the five checks (see master prompt): link liveness/404, deadline vs page,
   description accuracy, country (sponsor/program HOME country — not eligibility;
   id prefix SA-/GCC-/GL- is a strong signal), and emit a dedup_key
   (lower(trim(title)) minus punctuation/years, + sponsor, + registrable domain
   of application_link).

RULES: quote a short evidence snippet + source_url for every non-ok finding.
Never invent a deadline or URL. If you cannot confirm a value, mark ok:true and
move on (do NOT guess). Set unchecked:true for any row whose page never loaded.
Confidence 0..1. Return ONLY the schema object.`;

const verifierPrompt = (flagsJson) => `
You are an adversarial verifier guarding an AUTONOMOUS run that will write to a
production database. For each proposed change below, independently RE-VISIT the
source_url and TRY TO REFUTE it. ${WEB}
Set confirmed:true ONLY if you cannot refute it.
Default confirmed:false when uncertain or the page won't load.
EXTRA CAUTION for deletions (field "link" with a "gone" claim): confirm true ONLY
if the program is genuinely discontinued / has no live equivalent anywhere — a
mere bot-block, timeout, or a moved URL is NOT a deletion (it's keep-or-fix).
Quote your reason. Proposed changes:
${flagsJson}
Return ONLY the schema object.`;

// ── Phase: Discover ──────────────────────────────────────────────────────────
phase('Discover');
const disc = await agent(
  `Using Supabase MCP execute_sql (ToolSearch "supabase execute_sql"), run exactly:
   SELECT count(*)::int AS n FROM public.opportunities
   WHERE status <> 'archived' ${STALE_CLAUSE};
   PROJECT_ID=${PROJECT_ID}. Return the count.`,
  { label: 'discover:count', model: 'sonnet',
    schema: { type: 'object', additionalProperties: false, required: ['n'], properties: { n: { type: 'integer' } } } }
);
const remainingStale = (disc && disc.n) || 0;
const totalInScope = RUN_CAP ? Math.min(RUN_CAP, remainingStale) : remainingStale;
const N = Math.max(0, Math.ceil(totalInScope / BATCH_SIZE));
log(`Auditing ${totalInScope} opportunities (${SCOPE}) in ${N} batches of ${BATCH_SIZE}.`);
if (!N) return { error: 'No rows in scope (discover returned 0).' };

// ── Phases: Verify -> Cross-check (pipeline, no barrier) ─────────────────────
const batchIdx = Array.from({ length: N }, (_, i) => i);

const perBatch = await pipeline(
  batchIdx,
  // Stage 1 — cheap checker visits every source page in its slice
  (i) => agent(checkerPrompt(i), { label: `check:b${i}`, phase: 'Verify', model: 'haiku', schema: CHECK_SCHEMA })
           .then((r) => ({ i, results: (r && r.results) || [] })),
  // Stage 2 — adversarial re-verification of only the flagged rows in this batch
  (checked) => {
    const flags = [];
    for (const row of checked.results) {
      if (row.unchecked) continue;
      if (row.link && (row.link.verdict === 'dead' || row.link.verdict === 'redirected_generic'))
        flags.push({ id: row.id, field: 'link', source_url: row.link.source_url, claim: row.link.verdict, evidence: row.link.evidence });
      if (row.deadline && row.deadline.ok === false)
        flags.push({ id: row.id, field: 'deadline', source_url: (row.link && row.link.source_url) || '', claim: row.deadline.suggested || row.deadline.suggested_status, evidence: row.deadline.evidence });
      if (row.description && row.description.ok === false)
        flags.push({ id: row.id, field: 'description', source_url: (row.link && row.link.source_url) || '', claim: row.description.suggested, evidence: row.description.evidence });
      if (row.country && row.country.ok === false)
        flags.push({ id: row.id, field: 'country', source_url: (row.link && row.link.source_url) || '', claim: row.country.suggested, evidence: row.country.evidence });
    }
    if (!flags.length) return { i: checked.i, results: checked.results, confirmations: [] };
    return agent(verifierPrompt(JSON.stringify(flags)), { label: `verify:b${checked.i}`, phase: 'Cross-check', model: 'haiku', schema: VERDICT_SCHEMA })
      .then((v) => ({ i: checked.i, results: checked.results, confirmations: (v && v.confirmations) || [] }));
  }
);

// Flatten (drop any failed batches to keep the run resilient; count them)
const batches = perBatch.filter(Boolean);
const allRows = batches.flatMap((b) => b.results);
const confirmedSet = new Set(
  batches.flatMap((b) => (b.confirmations || []).filter((c) => c.confirmed).map((c) => c.id + '|' + c.field))
);
const uncheckedIds = allRows.filter((r) => r.unchecked).map((r) => r.id);
const failedBatches = N - batches.length;
log(`Checked ${allRows.length} rows; ${uncheckedIds.length} unchecked; ${failedBatches} batch(es) failed.`);

// ── Phase: Dedup (barrier — needs all keys at once) ──────────────────────────
phase('Dedup');
const byKey = {};
for (const r of allRows) {
  if (!r.dedup_key) continue;
  (byKey[r.dedup_key] = byKey[r.dedup_key] || []).push({ id: r.id, domain: r.domain, sponsor: r.sponsor });
}
const collisions = Object.keys(byKey).filter((k) => byKey[k].length > 1).map((k) => ({ key: k, rows: byKey[k] }));
let clusters = [];
if (collisions.length) {
  const dz = await agent(
    `These opportunity rows share a normalised dedup key. Decide TRUE duplicates only
     (same program/intake). Same title alone or shared portal domain is NOT enough —
     require corroboration. For each true-duplicate cluster pick the canonical id
     (structured id SA-/GCC-/GL- beats a bare UUID; else the richer record) and list
     the archive_ids. Give a one-line reason. Ignore groups that are not real dups.
     Candidates:\n${JSON.stringify(collisions).slice(0, 60000)}`,
    { label: 'dedup:cluster', model: 'sonnet', schema: DEDUP_SCHEMA }
  );
  clusters = (dz && dz.clusters) || [];
}
log(`${collisions.length} key-collision groups -> ${clusters.length} confirmed duplicate clusters.`);

// ── Phase: Apply (autonomous — direct fixes + reversible archive-delete) ─────
phase('Apply');

// AUTONOMOUS: build the direct-FIX set and the DELETE(=archive) set from rows
// whose change the verifier CONFIRMED. Always prefer FIX over DELETE.
const fixItems = [];    // {id, field, value, evidence, source_url}
const deleteItems = []; // {id, reason, evidence, source_url}
for (const r of allRows) {
  if (r.unchecked) continue;
  const src = (r.link && r.link.source_url) || '';
  // Link: moved -> fix the URL; confirmed gone -> delete(archive); else leave.
  if (r.link && confirmedSet.has(r.id + '|link')) {
    if (r.link.replacement_url)
      fixItems.push({ id: r.id, field: 'application_link', value: r.link.replacement_url, evidence: r.link.evidence, source_url: src });
    else if (r.link.program_gone === true && (r.link.verdict === 'dead' || r.link.verdict === 'redirected_generic'))
      deleteItems.push({ id: r.id, reason: 'link ' + r.link.verdict + ' + program gone (corroborated)', evidence: r.link.evidence, source_url: src });
  }
  if (r.deadline && r.deadline.ok === false && confirmedSet.has(r.id + '|deadline')) {
    if (r.deadline.suggested)             fixItems.push({ id: r.id, field: 'deadline_date', value: r.deadline.suggested, evidence: r.deadline.evidence, source_url: src });
    else if (r.deadline.suggested_status) fixItems.push({ id: r.id, field: 'status', value: r.deadline.suggested_status, evidence: r.deadline.evidence, source_url: src });
  }
  if (r.description && r.description.ok === false && r.description.suggested && confirmedSet.has(r.id + '|description'))
    fixItems.push({ id: r.id, field: 'description_short', value: r.description.suggested, evidence: r.description.evidence, source_url: src });
  if (r.country && r.country.ok === false && r.country.suggested && confirmedSet.has(r.id + '|country'))
    fixItems.push({ id: r.id, field: 'country', value: r.country.suggested, evidence: r.country.evidence, source_url: src });
}

// Writers (sonnet) — chunked so each agent does a bounded amount of SQL.
const chunk = (arr, n) => { const o = []; for (let i = 0; i < arr.length; i += n) o.push(arr.slice(i, i + n)); return o; };

// 5a. Archive confirmed duplicates (the only web-independent auto-apply).
let archived = 0;
if (clusters.length) {
  const res = await parallel(chunk(clusters, 25).map((cl, ci) => () => agent(
    `Auto-apply duplicate archiving on Supabase (PROJECT_ID=${PROJECT_ID}) via execute_sql.
     For EACH cluster, for EACH archive_id: INSERT the full row into
     public.opportunities_archive setting review_reason=<reason>, and a kept_id
     reference to canonical_id; then UPDATE public.opportunities SET status='archived'
     WHERE id=<archive_id>. NEVER DELETE. Idempotent: skip ids already archived.
     Return how many rows you archived as {"n": <int>}. Clusters:\n${JSON.stringify(cl)}`,
    { label: `apply:archive:${ci}`, phase: 'Apply', model: 'sonnet',
      schema: { type: 'object', additionalProperties: false, required: ['n'], properties: { n: { type: 'integer' } } } }
  )));
  archived = res.filter(Boolean).reduce((a, b) => a + (b.n || 0), 0);
}

// 5b. Apply confirmed field fixes DIRECTLY to public.opportunities (UPDATE).
const oneOf = "('application_link','deadline_date','status','description_short','country')";
let fixed = 0;
if (fixItems.length) {
  const res = await parallel(chunk(fixItems, 30).map((q, qi) => () => agent(
    `Autonomously apply field fixes to public.opportunities (PROJECT_ID=${PROJECT_ID}) via execute_sql.
     For each item: UPDATE public.opportunities SET <field>=<value>, last_verified=current_date
     WHERE id=<id>. Set ONLY the single named field (must be one of ${oneOf}). Never blank a
     field, never change any other column. Idempotent. Return {"n":<rows updated>}.
     Items:\n${JSON.stringify(q)}`,
    { label: `apply:fix:${qi}`, phase: 'Apply', model: 'sonnet',
      schema: { type: 'object', additionalProperties: false, required: ['n'], properties: { n: { type: 'integer' } } } }
  )));
  fixed = res.filter(Boolean).reduce((a, b) => a + (b.n || 0), 0);
}

// 5c. Delete (= archive, reversible) opportunities confirmed genuinely gone.
let deleted = 0;
if (deleteItems.length) {
  const res = await parallel(chunk(deleteItems, 25).map((d, di) => () => agent(
    `Autonomously remove genuinely-dead opportunities (PROJECT_ID=${PROJECT_ID}) via execute_sql.
     DELETE_MODE=archive (reversible): for each id, INSERT its full current row into
     public.opportunities_archive with review_reason=<reason>, then
     UPDATE public.opportunities SET status='archived' WHERE id=<id>. Do NOT hard-delete.
     Idempotent: skip ids already archived. Return {"n":<archived>}.
     Items:\n${JSON.stringify(d)}`,
    { label: `apply:delete:${di}`, phase: 'Apply', model: 'sonnet',
      schema: { type: 'object', additionalProperties: false, required: ['n'], properties: { n: { type: 'integer' } } } }
  )));
  deleted = res.filter(Boolean).reduce((a, b) => a + (b.n || 0), 0);
}

// 5d. Stamp last_verified=today on EVERY cleanly-checked row (not just the ones
// we fixed) so the stale set shrinks and repeated loop runs converge to done.
// Unchecked (blocked/won't-load) rows are intentionally NOT stamped — they stay
// in scope so a later run with better web access can retry them.
let stamped = 0;
const checkedIds = allRows.filter((r) => !r.unchecked).map((r) => r.id);
if (checkedIds.length) {
  const res = await parallel(chunk(checkedIds, 200).map((ids, si) => () => agent(
    `Stamp verification dates on Supabase (PROJECT_ID=${PROJECT_ID}) via execute_sql.
     Run exactly ONE statement:
       UPDATE public.opportunities SET last_verified = current_date
       WHERE id IN (${ids.map((x) => `'${String(x).replace(/'/g, "''")}'`).join(',')});
     Do NOT change any other column. Idempotent. Return {"n":<rows updated>}.`,
    { label: `apply:stamp:${si}`, phase: 'Apply', model: 'haiku',
      schema: { type: 'object', additionalProperties: false, required: ['n'], properties: { n: { type: 'integer' } } } }
  )));
  stamped = res.filter(Boolean).reduce((a, b) => a + (b.n || 0), 0);
}

// ── Phase: Report ────────────────────────────────────────────────────────────
phase('Report');
const counts = {
  stale_before_run: remainingStale,
  audited: allRows.length,
  stamped_verified: stamped,
  unchecked: uncheckedIds.length,
  failed_batches: failedBatches,
  duplicate_clusters: clusters.length,
  dedup_archived: archived,
  fixed_fields: fixed,
  deleted_archived: deleted,
  flagged_link: allRows.filter((r) => r.link && (r.link.verdict === 'dead' || r.link.verdict === 'redirected_generic')).length,
  flagged_deadline: allRows.filter((r) => r.deadline && r.deadline.ok === false).length,
  flagged_description: allRows.filter((r) => r.description && r.description.ok === false).length,
  flagged_country: allRows.filter((r) => r.country && r.country.ok === false).length,
};

// Synthesis agent writes the audit-trail CSVs + markdown and returns only paths.
// (Audit log of everything the autonomous run changed/removed — the substitute
// for a human review queue.) Capped to keep the prompt bounded; totals show any
// truncation so nothing is silently hidden.
const CAP = 1000;
const reportPayload = {
  counts,
  fix_total: fixItems.length, fixes: fixItems.slice(0, CAP),
  delete_total: deleteItems.length, deletes: deleteItems.slice(0, CAP),
  dedup_total: clusters.length, dedup: clusters.slice(0, CAP),
  unchecked_total: uncheckedIds.length, unchecked: uncheckedIds.slice(0, CAP),
};
const report = await agent(
  `Write the audit trail to the repo with the Write tool, then return the paths.
   Use TODAY's date (YYYY-MM-DD) in each filename. From this payload:
   ${JSON.stringify(reportPayload).slice(0, 200000)}
   write: audit_fixed_<date>.csv (id,field,value,evidence,source_url),
   audit_deleted_<date>.csv (id,reason,evidence,source_url),
   audit_dedup_<date>.csv (canonical_id,archive_ids,reason),
   audit_unchecked_<date>.csv (id), and audit_opportunity_run.md (totals from
   counts, the unchecked count + why, note if any list was capped at ${CAP}, and
   5-10 worked examples). Keep the markdown tight. Return {"files":[...],"summary":"..."}.`,
  { label: 'report:write', model: 'sonnet',
    schema: { type: 'object', additionalProperties: false, required: ['summary'], properties: { files: { type: 'array', items: { type: 'string' } }, summary: { type: 'string' } } } }
);

// Convergence signal for a "keep going until finished" loop: how many stale
// rows remain AFTER this run. ~= stale_before_run - stamped (unchecked stay).
const remaining_after = Math.max(0, remainingStale - stamped);
return {
  counts,
  remaining_stale_after: remaining_after,
  done: remaining_after === 0,
  report: report || null,
  unchecked_sample: uncheckedIds.slice(0, 20),
};
