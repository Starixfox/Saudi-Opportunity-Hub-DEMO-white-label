/* ============================================================================
   Saudi Opportunity Hub — Per-opportunity JSON-LD emitter
   ----------------------------------------------------------------------------
   This module produces schema.org-compliant structured data for an individual
   opportunity record and injects it into the document as a <script type=
   "application/ld+json"> element. Search engines and AI crawlers (Google,
   ChatGPT, Perplexity, Claude) read it to model the opportunity directly.

   Why a separate file:
     The opportunities dataset is rendered client-side by the SPA. The head-
     level JSON-LD in index.html only declares Organization + WebSite, because
     per-record metadata can't be statically baked in. This module fills the
     gap — call it when each opportunity panel opens, remove its output when
     the panel closes.

   How to use from the SPA:

     // When opening an opportunity panel:
     OpportunitySchema.inject(opportunity);

     // When closing it (so the page doesn't accumulate stale schema):
     OpportunitySchema.clear();

     // Or, if you just want the object without DOM-mutation:
     const ldJson = OpportunitySchema.build(opportunity);

   Expected opportunity shape (fields used; all optional unless flagged):
     {
       id,                     // REQUIRED — stable string; used as @id fragment
       title,                  // REQUIRED — schema.org "name"
       title_ar,               // alternateName when set
       description,            // schema.org "description"
       description_ar,         // adds inLanguage variant when set
       type,                   // 'grant' | 'tender' | 'accelerator' |
                               // 'fellowship' | 'investment' | other —
                               // selects schema.org subtype
       sponsor,                // funder/provider organisation name
       sponsor_ar,             // Arabic name; used as alternateName
       sponsor_url,            // funder homepage if known
       country,                // for areaServed
       sector,                 // domain/field
       status,                 // 'open' | 'closed' | 'review' — feeds an
                               // optional "actionStatus" hint where applicable
       deadline,               // ISO YYYY-MM-DD; becomes applicationDeadline
       opens_at,               // ISO; becomes startDate
       url,                    // canonical opportunity URL (external link)
       amount,                 // free-text or number; becomes amount (Money-
                               // adjacent) on MonetaryGrant types
       currency,               // ISO 4217 (defaults to "SAR" if amount set
                               // and currency missing)
       eligibility             // free-text; becomes eligibilityCriteria where
                               // the schema type supports it
     }

   This file is dependency-free, IIFE-wrapped, ES5-compatible (matches the
   existing script.js authoring style — no classes, no template strings in
   places that older browsers we still support might choke on). Browser
   support: anything that runs the SPA today.
============================================================================ */

(function (global) {
  'use strict';

  /* ------------------------------------------------------------------ Config */

  var SITE_BASE = 'https://starixfox.github.io/Saudi-Opportunity-Hub-DEMO-white-label/';
  var ORG_REF   = SITE_BASE + '#organization';
  var SITE_REF  = SITE_BASE + '#website';
  var SCRIPT_ID = 'oh-opportunity-ld-json';

  /* Internal opportunity-type → schema.org @type. Grant is the default for
     anything ambiguous because it's the most semantically meaningful for the
     platform's audience (researchers, founders, civil servants). */
  var TYPE_MAP = {
    grant:        'Grant',
    monetary:     'MonetaryGrant',
    tender:       'GovernmentService',
    rfp:          'GovernmentService',
    accelerator:  'EducationalOccupationalProgram',
    fellowship:   'EducationalOccupationalProgram',
    investment:   'FundingScheme',
    other:        'CreativeWork'
  };

  /* ------------------------------------------------------------------ Helpers */

  function pickSchemaType(typeRaw) {
    if (!typeRaw) return 'Grant';
    var key = String(typeRaw).toLowerCase().trim();
    return TYPE_MAP[key] || 'Grant';
  }

  function ensureIsoDate(d) {
    if (!d) return null;
    // Accept Date, ISO string, or YYYY-MM-DD; coerce to YYYY-MM-DD.
    if (d instanceof Date) return d.toISOString().slice(0, 10);
    var s = String(d).trim();
    // Already ISO-ish? Accept first 10 chars if they look right.
    if (/^\d{4}-\d{2}-\d{2}/.test(s)) return s.slice(0, 10);
    // Fall through: schema.org tolerates strings; let the consumer decide.
    return s;
  }

  function buildOpportunityId(opp) {
    if (opp && opp.id) {
      return SITE_BASE + '#opportunity-' + encodeURIComponent(String(opp.id));
    }
    // Fallback: derive a stable hash-ish key from title.
    var t = (opp && opp.title) ? String(opp.title) : 'untitled';
    return SITE_BASE + '#opportunity-' + encodeURIComponent(
      t.toLowerCase().replace(/\s+/g, '-').slice(0, 80)
    );
  }

  function asArrayMaybe(en, ar) {
    if (en && ar && en !== ar) return [en, ar];
    if (en) return en;
    if (ar) return ar;
    return undefined;
  }

  function omitUndef(obj) {
    // Returns a shallow copy with undefined / null / '' values stripped.
    var out = {};
    for (var k in obj) {
      if (!Object.prototype.hasOwnProperty.call(obj, k)) continue;
      var v = obj[k];
      if (v === undefined || v === null || v === '') continue;
      if (Array.isArray(v) && v.length === 0) continue;
      out[k] = v;
    }
    return out;
  }

  /* ------------------------------------------------------------------ Funder */

  function buildFunder(opp) {
    if (!opp.sponsor && !opp.sponsor_ar) return undefined;
    return omitUndef({
      '@type': 'Organization',
      'name': opp.sponsor,
      'alternateName': opp.sponsor_ar && opp.sponsor_ar !== opp.sponsor ? opp.sponsor_ar : undefined,
      'url': opp.sponsor_url
    });
  }

  /* --------------------------------------------------------- AreaServed glue */

  function buildAreaServed(opp) {
    if (!opp.country) return undefined;
    var c = String(opp.country).trim();
    // Common GCC shortcuts → typed Country / AdministrativeArea
    var KSA   = { '@type': 'Country', 'name': 'Saudi Arabia' };
    var GCC   = { '@type': 'AdministrativeArea', 'name': 'Gulf Cooperation Council' };
    var GLOBE = { '@type': 'Place', 'name': 'Global' };

    var lc = c.toLowerCase();
    if (lc === 'ksa' || lc === 'saudi arabia' || lc === 'saudi') return KSA;
    if (lc === 'gcc' || lc === 'gulf') return GCC;
    if (lc === 'global' || lc === 'international' || lc === 'worldwide') return GLOBE;

    // Otherwise pass it through as a generic Country.
    return { '@type': 'Country', 'name': c };
  }

  /* --------------------------------------------------------------- Amount glue */

  function buildAmount(opp) {
    if (opp.amount === undefined || opp.amount === null || opp.amount === '') return undefined;
    // schema.org/Grant uses "amount" as a MonetaryAmount or Number.
    // If the input is purely numeric, return a MonetaryAmount.
    var n = Number(opp.amount);
    if (!isNaN(n) && isFinite(n)) {
      return {
        '@type': 'MonetaryAmount',
        'value': n,
        'currency': opp.currency || 'SAR'
      };
    }
    // Otherwise pass through as a free-text amount (schema.org tolerates this).
    return String(opp.amount);
  }

  /* -------------------------------------------------------- Status → action hint */

  function buildActionStatus(opp) {
    if (!opp.status) return undefined;
    switch (String(opp.status).toLowerCase()) {
      case 'open':       return 'https://schema.org/ActiveActionStatus';
      case 'closed':     return 'https://schema.org/CompletedActionStatus';
      case 'review':
      case 'pending':    return 'https://schema.org/PotentialActionStatus';
      default:           return undefined;
    }
  }

  /* ================================================================= BUILD */

  /**
   * Build a JSON-LD object for a single opportunity.
   * Returns a plain JS object — call JSON.stringify(…, null, 2) to serialise.
   */
  function build(opp) {
    if (!opp) throw new Error('OpportunitySchema.build: opportunity is required');

    var schemaType = pickSchemaType(opp.type);
    var funder     = buildFunder(opp);
    var areaServed = buildAreaServed(opp);
    var amount     = buildAmount(opp);
    var openDate   = ensureIsoDate(opp.opens_at);
    var closeDate  = ensureIsoDate(opp.deadline);
    var statusUrl  = buildActionStatus(opp);
    var oppId      = buildOpportunityId(opp);

    // Common fields that apply to nearly every schema type the platform uses.
    var base = omitUndef({
      '@context':     'https://schema.org',
      '@type':        schemaType,
      '@id':          oppId,
      'name':         opp.title,
      'alternateName': opp.title_ar && opp.title_ar !== opp.title ? opp.title_ar : undefined,
      'description':  opp.description,
      'url':          opp.url || oppId,
      'identifier':   opp.id ? String(opp.id) : undefined,
      'inLanguage':   asArrayMaybe(opp.description ? 'en' : null, opp.description_ar ? 'ar' : null),
      'isPartOf':     { '@id': SITE_REF },
      'publisher':    { '@id': ORG_REF }
    });

    // Schema-type-specific extensions. Grant / MonetaryGrant carry the funder
    // + funded amount; GovernmentService describes a public-sector channel;
    // EducationalOccupationalProgram covers cohort-based accelerators and
    // fellowships; FundingScheme covers structured investment programmes.
    switch (schemaType) {
      case 'Grant':
      case 'MonetaryGrant':
        return omitUndef(Object.assign({}, base, {
          'funder':              funder,
          'sponsor':             funder,           // intentionally duplicated; spec recognises both
          'amount':              amount,
          'areaServed':          areaServed,
          'applicationDeadline': closeDate,
          'startDate':           openDate,
          'endDate':             closeDate,
          'eligibilityCriteria': opp.eligibility,
          'actionStatus':        statusUrl,
          'about':               opp.sector
        }));

      case 'GovernmentService':
        return omitUndef(Object.assign({}, base, {
          'provider':            funder,
          'serviceType':         opp.sector || 'Funding programme',
          'areaServed':          areaServed,
          'availableChannel':    opp.url ? {
            '@type': 'ServiceChannel',
            'serviceUrl': opp.url
          } : undefined,
          'audience':            opp.eligibility ? {
            '@type': 'Audience',
            'audienceType': opp.eligibility
          } : undefined,
          // GovernmentService doesn't have applicationDeadline; surface it via
          // hoursAvailable as a workaround so the date stays visible.
          'hoursAvailable':      closeDate ? {
            '@type': 'OpeningHoursSpecification',
            'validThrough': closeDate
          } : undefined
        }));

      case 'EducationalOccupationalProgram':
        return omitUndef(Object.assign({}, base, {
          'provider':            funder,
          'programType':         opp.type === 'fellowship' ? 'Fellowship' : 'Accelerator',
          'occupationalCategory': opp.sector,
          'applicationDeadline': closeDate,
          'startDate':           openDate,
          'educationalProgramMode': 'Cohort',
          'audience':            opp.eligibility ? {
            '@type': 'Audience',
            'audienceType': opp.eligibility
          } : undefined,
          'inLanguage':          base.inLanguage
        }));

      case 'FundingScheme':
        return omitUndef(Object.assign({}, base, {
          'funder':              funder,
          'areaServed':          areaServed,
          'amount':              amount,
          'applicationDeadline': closeDate,
          'eligibilityCriteria': opp.eligibility
        }));

      default:
        // CreativeWork / unknown — keep the minimum.
        return base;
    }
  }

  /* ================================================================ INJECT */

  /** Inject (or replace) the per-opportunity JSON-LD script in <head>. */
  function inject(opp) {
    if (typeof document === 'undefined') return null;
    var json;
    try { json = JSON.stringify(build(opp), null, 2); }
    catch (e) {
      try { (console && console.warn) && console.warn('[OpportunitySchema] build failed:', e); } catch (_) {}
      return null;
    }

    var existing = document.getElementById(SCRIPT_ID);
    var el = existing || document.createElement('script');
    el.type = 'application/ld+json';
    el.id = SCRIPT_ID;
    el.textContent = json;
    if (!existing) document.head.appendChild(el);
    return el;
  }

  /** Remove the per-opportunity JSON-LD script if present. */
  function clear() {
    if (typeof document === 'undefined') return;
    var el = document.getElementById(SCRIPT_ID);
    if (el && el.parentNode) el.parentNode.removeChild(el);
  }

  /* ================================================================ EXPORT */

  global.OpportunitySchema = {
    build:   build,
    inject:  inject,
    clear:   clear,
    // Exposed for tests / debugging.
    _pickSchemaType: pickSchemaType,
    _buildFunder:    buildFunder,
    _buildAreaServed: buildAreaServed
  };

  // Also export as CommonJS for any node-side tooling that wants it.
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = global.OpportunitySchema;
  }
})(typeof window !== 'undefined' ? window : globalThis);
