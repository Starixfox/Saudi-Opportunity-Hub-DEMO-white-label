(function () {
  'use strict';

  const state = {
    dataset: [],
    filtered: [],
    currentPage: 1,
    pageSize: 10,
    activeProfile: 'All profiles',
    theme: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  };

  const SELECTORS = {
    searchInput: '[aria-label="Search opportunities"]',
    sectorSelect: '[aria-label="Filter by sector"]',
    regionSelect: '[aria-label="Filter by country group"]',
    typeSelect: '[aria-label="Filter by opportunity type"]',
    statusSelect: '[aria-label="Filter by status"]',
    feedbackType: '[aria-label="TYPE OF FEEDBACK"]',
    feedbackContact: '[aria-label="HOW CAN WE CONTACT YOU? (optional)"]',
    feedbackDetails: 'textarea',
    themeToggle: '[data-theme-toggle]'
  };

  const ui = {};

  document.addEventListener('DOMContentLoaded', init);

  async function init() {
    cacheDom();
    bindTheme();
    bindFilters();
    bindFeedbackForm();
    state.dataset = await loadDataset();
    state.filtered = [...state.dataset];
    renderAll();
  }

  function cacheDom() {
    ui.searchInput = document.querySelector(SELECTORS.searchInput);
    ui.sectorSelect = document.querySelector(SELECTORS.sectorSelect);
    ui.regionSelect = document.querySelector(SELECTORS.regionSelect);
    ui.typeSelect = document.querySelector(SELECTORS.typeSelect);
    ui.statusSelect = document.querySelector(SELECTORS.statusSelect);
    ui.feedbackType = document.querySelector(SELECTORS.feedbackType);
    ui.feedbackContact = document.querySelector(SELECTORS.feedbackContact);
    ui.feedbackDetails = document.querySelector(SELECTORS.feedbackDetails);
    ui.themeToggle = document.querySelector(SELECTORS.themeToggle);

    ui.resultsCount = findTextNodeElement(/opportunities found/i);
    ui.cardsContainer = ensureContainer('opportunity-cards', guessCardsMount());
    ui.paginationContainer = ensureContainer('opportunity-pagination', ui.cardsContainer?.parentElement || document.body);

    ui.typeChart = ensureContainer('insights-type-chart', findInsightsMount());
    ui.regionChart = ensureContainer('insights-region-chart', ui.typeChart.parentElement);
    ui.statusChart = ensureContainer('insights-status-chart', ui.typeChart.parentElement);
    ui.topInstitutions = ensureContainer('insights-top-institutions', ui.typeChart.parentElement);
    ui.snapshot = ensureContainer('insights-snapshot', ui.typeChart.parentElement);

    ui.profileButtons = Array.from(document.querySelectorAll('button, [role="button"], .chip, .filter-chip')).filter((el) => {
      const text = normalize(el.textContent);
      return ['all profiles', 'startup / sme', 'researcher / university', 'government', 'investor', 'student'].includes(text);
    });

    ui.resetButton = Array.from(document.querySelectorAll('button, [role="button"], a')).find((el) => /reset filters/i.test(el.textContent || '')) || null;
    ui.feedbackForm = ui.feedbackDetails ? ui.feedbackDetails.closest('form') : null;
  }

  function bindTheme() {
    applyTheme(state.theme);
    if (!ui.themeToggle) return;

    updateThemeToggleLabel();
    ui.themeToggle.addEventListener('click', () => {
      state.theme = state.theme === 'dark' ? 'light' : 'dark';
      applyTheme(state.theme);
      updateThemeToggleLabel();
    });
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
  }

  function updateThemeToggleLabel() {
    if (!ui.themeToggle) return;
    ui.themeToggle.setAttribute('aria-label', `Switch to ${state.theme === 'dark' ? 'light' : 'dark'} mode`);
  }

  function bindFilters() {
    [ui.searchInput, ui.sectorSelect, ui.regionSelect, ui.typeSelect, ui.statusSelect]
      .filter(Boolean)
      .forEach((el) => el.addEventListener('input', onFiltersChanged));

    ui.profileButtons.forEach((button) => {
      button.addEventListener('click', () => {
        state.activeProfile = button.textContent.trim();
        ui.profileButtons.forEach((btn) => btn.setAttribute('aria-pressed', String(btn === button)));
        state.currentPage = 1;
        applyFilters();
      });
    });

    if (ui.resetButton) {
      ui.resetButton.addEventListener('click', (event) => {
        event.preventDefault();
        resetFilters();
      });
    }
  }

  function bindFeedbackForm() {
    const handler = (event) => {
      event.preventDefault();
      const type = ui.feedbackType?.value || 'General feedback';
      const contact = ui.feedbackContact?.value?.trim() || 'No contact supplied';
      const details = ui.feedbackDetails?.value?.trim() || '';
      if (!details) {
        alert('Please add feedback details before sending.');
        return;
      }
      const subject = encodeURIComponent(`[Opportunity Hub Demo] ${type}`);
      const body = encodeURIComponent(`Contact: ${contact}\n\nDetails:\n${details}`);
      window.location.href = `mailto:jblancoapodaca@gmail.com?subject=${subject}&body=${body}`;
    };

    if (ui.feedbackForm) {
      ui.feedbackForm.addEventListener('submit', handler);
      return;
    }

    const sendButton = Array.from(document.querySelectorAll('button, a')).find((el) => /send feedback/i.test(el.textContent || ''));
    if (sendButton) sendButton.addEventListener('click', handler);
  }

  function onFiltersChanged() {
    state.currentPage = 1;
    applyFilters();
  }

  function resetFilters() {
    if (ui.searchInput) ui.searchInput.value = '';
    if (ui.sectorSelect) ui.sectorSelect.selectedIndex = 0;
    if (ui.regionSelect) ui.regionSelect.selectedIndex = 0;
    if (ui.typeSelect) ui.typeSelect.selectedIndex = 0;
    if (ui.statusSelect) ui.statusSelect.selectedIndex = 0;
    state.activeProfile = 'All profiles';
    ui.profileButtons.forEach((btn) => btn.setAttribute('aria-pressed', String(/all profiles/i.test(btn.textContent || ''))));
    state.currentPage = 1;
    applyFilters();
  }

  function applyFilters() {
    const term = normalize(ui.searchInput?.value || '');
    const sector = ui.sectorSelect?.value || 'All sectors';
    const region = ui.regionSelect?.value || 'All regions';
    const type = ui.typeSelect?.value || 'All types';
    const status = ui.statusSelect?.value || 'All statuses';
    const profile = normalize(state.activeProfile);

    state.filtered = state.dataset.filter((item) => {
      const haystack = normalize([
        item.title,
        item.sponsor,
        item.description,
        item.sector,
        item.region,
        item.type,
        item.status,
        ...(item.tags || [])
      ].join(' '));

      const termMatch = !term || haystack.includes(term);
      const sectorMatch = sector === 'All sectors' || item.sector === sector;
      const regionMatch = region === 'All regions' || item.region === region;
      const typeMatch = type === 'All types' || item.type === type;
      const statusMatch = status === 'All statuses' || normalizeStatus(item.status) === normalizeStatus(status);
      const profileMatch = profile === 'all profiles' || (item.profiles || []).some((p) => normalize(p) === profile);

      return termMatch && sectorMatch && regionMatch && typeMatch && statusMatch && profileMatch;
    });

    renderAll();
  }

  function renderAll() {
    renderCount();
    renderCards();
    renderPagination();
    renderInsights();
  }

  function renderCount() {
    if (ui.resultsCount) {
      ui.resultsCount.textContent = `${state.filtered.length} opportunities found`;
    }
  }

  function renderCards() {
    if (!ui.cardsContainer) return;
    const start = (state.currentPage - 1) * state.pageSize;
    const pageItems = state.filtered.slice(start, start + state.pageSize);

    if (!pageItems.length) {
      ui.cardsContainer.innerHTML = '<div class="empty-state"><h3>No matching opportunities</h3><p>Try broadening your search or resetting the filters.</p></div>';
      return;
    }

    ui.cardsContainer.innerHTML = pageItems.map((item) => `
      <article class="opportunity-card">
        <div class="opportunity-card__meta">
          <span class="badge badge--type">${escapeHtml(item.type)}</span>
          <span class="badge badge--region">${escapeHtml(item.region)}</span>
          <span class="badge badge--status">${escapeHtml(item.status)}</span>
        </div>
        <h3>${escapeHtml(item.title)}</h3>
        <p>${escapeHtml(item.description)}</p>
        <div class="opportunity-card__details">
          <span><strong>Sponsor:</strong> ${escapeHtml(item.sponsor)}</span>
          <span><strong>Sector:</strong> ${escapeHtml(item.sector)}</span>
          <span><strong>Funding / Size:</strong> ${escapeHtml(item.funding)}</span>
          <span><strong>Deadline / Verified:</strong> ${escapeHtml(item.deadline)}</span>
        </div>
        <div class="opportunity-card__tags">${(item.tags || []).map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join('')}</div>
        <a href="${escapeAttribute(item.url)}" target="_blank" rel="noopener noreferrer" class="opportunity-card__link">Go to website</a>
      </article>
    `).join('');
  }

  function renderPagination() {
    if (!ui.paginationContainer) return;
    const totalPages = Math.max(1, Math.ceil(state.filtered.length / state.pageSize));
    state.currentPage = Math.min(state.currentPage, totalPages);

    ui.paginationContainer.innerHTML = `
      <div class="pagination-shell">
        <button type="button" data-page="prev" ${state.currentPage === 1 ? 'disabled' : ''}>Previous</button>
        <span>Page ${state.currentPage} of ${totalPages}</span>
        <button type="button" data-page="next" ${state.currentPage === totalPages ? 'disabled' : ''}>Next</button>
      </div>
    `;

    ui.paginationContainer.querySelectorAll('button[data-page]').forEach((button) => {
      button.addEventListener('click', () => {
        state.currentPage += button.dataset.page === 'next' ? 1 : -1;
        renderCards();
        renderPagination();
      });
    });
  }

  function renderInsights() {
    const source = state.filtered.length ? state.filtered : state.dataset;
    renderBars(ui.typeChart, countBy(source, 'type'), 'Program type');
    renderBars(ui.regionChart, countBy(source, 'region'), 'Region');
    renderBars(ui.statusChart, countBy(source, 'status'), 'Status');
    renderTopInstitutions(source);
    renderSnapshot(source);
  }

  function renderBars(container, counts, label) {
    if (!container) return;
    const entries = Object.entries(counts).sort((a, b) => b[1] - a[1]);
    const max = entries[0]?.[1] || 1;

    container.innerHTML = `
      <div class="insight-block">
        <div class="insight-block__title">${escapeHtml(label)}</div>
        <div class="bar-list">
          ${entries.map(([name, value]) => `
            <div class="bar-row">
              <div class="bar-row__label"><span>${escapeHtml(name)}</span><strong>${value}</strong></div>
              <div class="bar-row__track"><div class="bar-row__fill" style="width:${(value / max) * 100}%"></div></div>
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }

  function renderTopInstitutions(source) {
    if (!ui.topInstitutions) return;
    const counts = Object.entries(countBy(source, 'sponsor')).sort((a, b) => b[1] - a[1]).slice(0, 8);
    ui.topInstitutions.innerHTML = `
      <div class="insight-block">
        <div class="insight-block__title">Top institutions</div>
        <ol class="institution-list">
          ${counts.map(([name, value]) => `<li><span>${escapeHtml(name)}</span><strong>${value}</strong></li>`).join('')}
        </ol>
      </div>
    `;
  }

  function renderSnapshot(source) {
    if (!ui.snapshot) return;
    const regionCounts = countBy(source, 'region');
    const typeCounts = countBy(source, 'type');
    const statusCounts = countBy(source, 'status');
    const topRegion = topEntry(regionCounts);
    const topType = topEntry(typeCounts);
    const topStatus = topEntry(statusCounts);

    ui.snapshot.innerHTML = `
      <div class="insight-block">
        <div class="insight-block__title">Landscape snapshot</div>
        <p>This view tracks <strong>${source.length}</strong> opportunities. The largest regional bucket is <strong>${escapeHtml(topRegion.name)}</strong> with ${topRegion.value} listings, while <strong>${escapeHtml(topType.name)}</strong> is the most common program type. The dominant status is <strong>${escapeHtml(topStatus.name)}</strong>, which helps explain the current pipeline mix.</p>
      </div>
    `;
  }

  async function loadDataset() {
    const candidates = ['./opportunitiesData.json', './data/opportunities.json', './opportunities.json', './data/dataset.json', './dataset.json'];
    for (const url of candidates) {
      try {
        const response = await fetch(url, { cache: 'no-store' });
        if (!response.ok) continue;
        const json = await response.json();
        const arr = Array.isArray(json) ? json : (Array.isArray(json.items) ? json.items : null);
        if (arr?.length) return arr.map(normalizeRecord);
      } catch (_) {}
    }

    return fallbackDataset();
  }

  function normalizeRecord(item) {
    return {
      title: item.title || item.name || 'Untitled opportunity',
      type: titleCase(item.type || item.programType || 'Other'),
      region: normalizeRegion(item.region || item.countryGroup || item.market || 'Global'),
      status: normalizeStatus(item.status || 'Open', true),
      sponsor: item.sponsor || item.institution || item.organization || 'Unknown sponsor',
      description: item.description || item.summary || 'No description provided.',
      sector: item.sector || item.category || 'General',
      funding: item.funding || item.size || item.amount || 'Not specified',
      deadline: item.deadline || item.verified || item.lastVerified || 'Check source',
      url: item.url || item.link || '#',
      tags: uniqueArray([...(item.tags || []), item.instrument, item.audience].filter(Boolean).map(titleCase)),
      profiles: uniqueArray([...(item.profiles || []), ...(item.audience ? [item.audience] : [])].filter(Boolean).map(normalizeProfile))
    };
  }

  function fallbackDataset() {
    return [
      {
        title: 'CST SpaceUp Competition',
        type: 'Tender / Competition',
        region: 'Saudi Arabia',
        status: 'Recurring',
        sponsor: 'Communications, Space & Technology Commission (CST) + Saudi Space Agency',
        description: 'Global competition for entrepreneurs developing space-based solutions across national priority sectors.',
        sector: 'ICT',
        funding: '~USD 28M total contractual opportunities',
        deadline: '2025 edition closed; 2026 edition tentatively planned',
        url: 'https://www.cst.gov.sa/en/about/program-and-initiatives/spaceup-competition',
        tags: ['Contract', 'Startup', 'Innovation'],
        profiles: ['Startup / SME']
      },
      {
        title: 'EWC Space Technologies Track (CST)',
        type: 'Accelerator',
        region: 'Saudi Arabia',
        status: 'Recurring',
        sponsor: 'CST + Monsha\'at + Misk Foundation + GEN',
        description: 'Space-specific track within the Entrepreneurship World Cup for innovation-led startups.',
        sector: 'ICT',
        funding: 'USD 100K per winning startup',
        deadline: 'Next cycle expected 2026',
        url: 'https://www.entrepreneurshipworldcup.com/',
        tags: ['Grant', 'Startup', 'Education'],
        profiles: ['Startup / SME']
      },
      {
        title: 'Custodian of the Two Holy Mosques Scholarship - Space Fields',
        type: 'Fellowship',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'Ministry of Education + CST + Saudi Space Agency',
        description: 'Government scholarship program covering tuition, living expenses, and medical insurance.',
        sector: 'Education',
        funding: 'Full tuition + living + medical insurance',
        deadline: 'Annual cycle; check website for current deadlines',
        url: 'https://www.cst.gov.sa/en/about/program-and-initiatives/custodian-of-the-two-holy-mosques-space',
        tags: ['Grant', 'Student', 'Education'],
        profiles: ['Student', 'Researcher / University']
      },
      {
        title: 'RDIA Research Grants - National Priorities',
        type: 'Grant',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'Research, Development and Innovation Authority (RDIA)',
        description: 'Multi-program research grants aligned with national priorities, including space-adjacent fields.',
        sector: 'Healthcare & Life Sciences',
        funding: 'Varies by program',
        deadline: 'Rolling calls per priority area',
        url: 'https://saudiminds.rdia.gov.sa/',
        tags: ['Grant', 'Researcher', 'Government'],
        profiles: ['Researcher / University', 'Government']
      },
      {
        title: 'KAUST Innovation Fund',
        type: 'Investment program',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'King Abdullah University of Science and Technology (KAUST)',
        description: 'Early-stage venture fund investing in deep-tech startups and international spin-ins.',
        sector: 'Innovation & Entrepreneurship',
        funding: 'Seed to early-stage funding up to USD 2M',
        deadline: 'Rolling / Open',
        url: 'https://innovation.kaust.edu.sa/entrepreneurs/kaust-innovation-ventures/',
        tags: ['Equity', 'Startup', 'Investor'],
        profiles: ['Startup / SME', 'Investor']
      },
      {
        title: 'Misk Accelerator',
        type: 'Accelerator',
        region: 'Saudi Arabia',
        status: 'Recurring',
        sponsor: 'Misk Foundation',
        description: 'Zero-equity accelerator for seed-stage technology startups scaling in Saudi Arabia.',
        sector: 'ICT',
        funding: 'Non-financial support; zero equity',
        deadline: 'Annual cohorts',
        url: 'https://hub.misk.org.sa/programs/entrepreneurship/misk-accelerator/',
        tags: ['Startup', 'Innovation'],
        profiles: ['Startup / SME']
      },
      {
        title: 'Monsha\'at SME Programs',
        type: 'Grant',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'Monsha\'at',
        description: 'Suite of accelerator programs and non-dilutive grants for high-tech SMEs.',
        sector: 'Financial Services',
        funding: 'Varies by program',
        deadline: 'Rolling / Open',
        url: 'https://www.monshaat.gov.sa/',
        tags: ['Startup', 'Financial', 'Innovation'],
        profiles: ['Startup / SME']
      },
      {
        title: 'Saudi Space Academy Training Programs',
        type: 'Fellowship',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'Saudi Space Agency (SSA)',
        description: 'Professional training programs covering satellite technology, remote sensing, and mission operations.',
        sector: 'Education',
        funding: 'Fully funded training programs',
        deadline: 'Multiple rounds per year',
        url: 'https://www.ssa.gov.sa/spaceacademyen/',
        tags: ['Student', 'Government', 'Education'],
        profiles: ['Student', 'Government']
      },
      {
        title: 'Neo Space Group - EO Marketplace & Partnerships',
        type: 'Other',
        region: 'Saudi Arabia',
        status: 'Open',
        sponsor: 'Neo Space Group (PIF company)',
        description: 'PIF-backed national space company offering partnership and vendor opportunities.',
        sector: 'ICT',
        funding: 'Partnership / vendor opportunities',
        deadline: 'Rolling / Open',
        url: 'https://www.neospacegroup.com/',
        tags: ['Investor', 'Innovation'],
        profiles: ['Investor', 'Startup / SME']
      },
      {
        title: 'ESA - MENA Space Economy Partnership Program',
        type: 'Grant',
        region: 'Global',
        status: 'Open',
        sponsor: 'European Space Agency',
        description: 'Regional collaboration program supporting the emerging MENA space economy.',
        sector: 'Innovation & Entrepreneurship',
        funding: 'Program-specific support',
        deadline: 'Added March 2026',
        url: 'https://esa.int/Newsroom/Press_Releases',
        tags: ['Researcher', 'Innovation'],
        profiles: ['Researcher / University', 'Government']
      }
    ];
  }

  function countBy(list, key) {
    return list.reduce((acc, item) => {
      const value = item[key] || 'Unknown';
      acc[value] = (acc[value] || 0) + 1;
      return acc;
    }, {});
  }

  function topEntry(obj) {
    const [name = 'Unknown', value = 0] = Object.entries(obj).sort((a, b) => b[1] - a[1])[0] || [];
    return { name, value };
  }

  function findTextNodeElement(regex) {
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
    let node;
    while ((node = walker.nextNode())) {
      if (regex.test(node.textContent || '')) return node.parentElement;
    }
    return null;
  }

  function guessCardsMount() {
    const insightsHeading = Array.from(document.querySelectorAll('h1, h2, h3, h4')).find((el) => /insights/i.test(el.textContent || ''));
    if (!insightsHeading) return document.body;
    let current = insightsHeading.previousElementSibling;
    while (current) {
      if (current.querySelector && current.querySelector('a[href^="http"]')) return current.parentElement || document.body;
      current = current.previousElementSibling;
    }
    return insightsHeading.parentElement || document.body;
  }

  function findInsightsMount() {
    const insightsHeading = Array.from(document.querySelectorAll('h1, h2, h3, h4')).find((el) => /insights/i.test(el.textContent || ''));
    return insightsHeading?.parentElement || document.body;
  }

  function ensureContainer(id, parent) {
    if (!parent) return null;
    let el = document.getElementById(id);
    if (el) return el;
    el = document.createElement('div');
    el.id = id;
    parent.appendChild(el);
    return el;
  }

  function normalize(text) {
    return String(text || '').toLowerCase().replace(/\s+/g, ' ').trim();
  }

  function normalizeStatus(status, pretty = false) {
    const value = normalize(status);
    if (value.includes('recurring') || value.includes('closed but recurring')) return pretty ? 'Recurring' : 'recurring';
    if (value.includes('closed')) return pretty ? 'Closed' : 'closed';
    return pretty ? 'Open' : 'open';
  }

  function normalizeRegion(region) {
    const value = normalize(region);
    if (value.includes('saudi')) return 'Saudi Arabia';
    if (value.includes('gcc')) return 'GCC';
    return 'Global';
  }

  function normalizeProfile(profile) {
    const value = normalize(profile);
    if (value.includes('startup') || value.includes('sme')) return 'Startup / SME';
    if (value.includes('research')) return 'Researcher / University';
    if (value.includes('government')) return 'Government';
    if (value.includes('investor')) return 'Investor';
    if (value.includes('student')) return 'Student';
    return titleCase(profile);
  }

  function titleCase(value) {
    return String(value || '')
      .replace(/[_-]+/g, ' ')
      .split(' ')
      .filter(Boolean)
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
      .join(' ');
  }

  function uniqueArray(items) {
    return [...new Set(items.filter(Boolean))];
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function escapeAttribute(value) {
    return escapeHtml(value || '#');
  }
 
