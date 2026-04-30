/* Maigret Enhanced — Frontend Application */

const state = {
  targets: {},       // { username: { jobId, profiles, graphData, rawData, status } }
  activeTarget: null,
  starred: new Set(),
  sortField: 'site',
  sortAsc: true,
  filterStarred: false,
  tags: [],
  includedTags: new Set(),
  excludedTags: new Set(),
  simulation: null,
};

/* ── Init ── */
document.addEventListener('DOMContentLoaded', () => {
  loadTags();
  document.getElementById('inputUsername').addEventListener('keydown', e => {
    if (e.key === 'Enter') startScan();
  });
});

/* ── Tags ── */
async function loadTags() {
  try {
    const res = await fetch('/api/tags');
    state.tags = await res.json();
    renderTagCloud('tagCloudInclude', state.includedTags, 'included');
    renderTagCloud('tagCloudExclude', state.excludedTags, 'excluded');
  } catch (_) {}
}

function renderTagCloud(containerId, selectedSet, cssClass) {
  const el = document.getElementById(containerId);
  el.innerHTML = '';
  const top = state.tags.slice(0, 30);
  top.forEach(t => {
    const chip = document.createElement('span');
    chip.className = 'tag-chip' + (selectedSet.has(t.tag) ? ` ${cssClass}` : '');
    chip.textContent = `${t.tag} (${t.count})`;
    chip.onclick = () => {
      if (selectedSet.has(t.tag)) selectedSet.delete(t.tag);
      else selectedSet.add(t.tag);
      renderTagCloud(containerId, selectedSet, cssClass);
    };
    el.appendChild(chip);
  });
}

/* ── Advanced toggle ── */
function toggleAdvanced() {
  document.getElementById('advancedBody').classList.toggle('open');
}

/* ── Scan ── */
async function startScan() {
  const raw = document.getElementById('inputUsername').value.trim();
  if (!raw) return;

  const usernames = raw.split(/[,\s]+/).filter(Boolean);
  const topSites = parseInt(document.getElementById('inputTopSites').value) || 500;
  const timeout = parseInt(document.getElementById('inputTimeout').value) || 30;
  const recursive = document.getElementById('chkRecursive').checked;
  const tags = state.includedTags.size ? [...state.includedTags] : null;
  const excludedTags = state.excludedTags.size ? [...state.excludedTags] : null;

  document.getElementById('searchPanel').style.display = 'none';
  document.getElementById('btnNewScan').style.display = 'inline-block';
  document.getElementById('resultsContainer').classList.add('active');

  for (const username of usernames) {
    try {
      const res = await fetch('/api/scan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, top_sites: topSites, timeout, tags, excluded_tags: excludedTags, recursive }),
      });
      const data = await res.json();
      state.targets[username] = {
        jobId: data.id,
        profiles: [],
        graphData: null,
        rawData: null,
        status: 'running',
      };
      addTargetTab(username);
      listenProgress(username, data.id);
    } catch (err) {
      console.error('Scan start failed:', err);
    }
  }

  if (usernames.length > 0 && !state.activeTarget) {
    selectTarget(usernames[0]);
  }

  showProgress();
}

/* ── Target tabs ── */
function addTargetTab(username) {
  const bar = document.getElementById('targetBar');
  bar.classList.add('active');
  const tab = document.createElement('div');
  tab.className = 'target-tab';
  tab.id = `target-${username}`;
  tab.innerHTML = `${username} <span class="count" id="tcount-${username}">0</span>`;
  tab.onclick = () => selectTarget(username);
  bar.appendChild(tab);
}

function selectTarget(username) {
  state.activeTarget = username;
  document.querySelectorAll('.target-tab').forEach(t => t.classList.remove('active'));
  const tab = document.getElementById(`target-${username}`);
  if (tab) tab.classList.add('active');
  renderCurrentTarget();
}

/* ── SSE Progress ── */
function listenProgress(username, jobId) {
  const es = new EventSource(`/api/scan/${jobId}/progress`);
  es.onmessage = (evt) => {
    const data = JSON.parse(evt.data);
    if (!data.type) {
      updateProgress(username, data);
    } else if (data.type === 'done') {
      es.close();
      state.targets[username].status = 'done';
      fetchResults(username, jobId);
    } else if (data.type === 'error') {
      es.close();
      state.targets[username].status = 'error';
    }
  };
  es.onerror = () => {
    es.close();
    fetchResults(username, jobId);
  };
}

function updateProgress(username, data) {
  const t = state.targets[username];
  if (!t) return;

  if (state.activeTarget === username) {
    const pct = data.total > 0 ? Math.round((data.completed / data.total) * 100) : 0;
    document.getElementById('progressFill').style.width = pct + '%';
    document.getElementById('progressText').textContent = `Checking ${data.completed} / ${data.total} sites`;
    document.getElementById('progressFound').textContent = `${data.found} found`;
    document.getElementById('progressSite').textContent = data.site || '';
  }

  const countEl = document.getElementById(`tcount-${username}`);
  if (countEl) countEl.textContent = data.found;

  if (data.status === 'claimed' && data.url) {
    showLiveHit(data.site, data.url);
    t.profiles.push({
      site: data.site,
      url: data.url,
      tags: [],
      response_time: null,
    });
    if (state.activeTarget === username) {
      renderProfiles(t.profiles);
      document.getElementById('badgeFound').textContent = t.profiles.length;
    }
  }
}

function showProgress() {
  document.getElementById('progressContainer').classList.add('active');
}

/* ── Fetch final results ── */
async function fetchResults(username, jobId) {
  try {
    const [resResults, resGraph] = await Promise.all([
      fetch(`/api/scan/${jobId}/results`),
      fetch(`/api/scan/${jobId}/graph`),
    ]);
    const results = await resResults.json();
    const graphData = await resGraph.json();

    const t = state.targets[username];
    t.profiles = results.profiles || [];
    t.rawData = results;
    t.graphData = graphData;
    t.status = 'done';

    const countEl = document.getElementById(`tcount-${username}`);
    if (countEl) countEl.textContent = t.profiles.length;

    if (state.activeTarget === username) {
      renderCurrentTarget();
    }
  } catch (err) {
    console.error('Fetch results failed:', err);
  }
}

/* ── Render current target ── */
function renderCurrentTarget() {
  const t = state.targets[state.activeTarget];
  if (!t) return;

  if (t.status === 'done') {
    document.getElementById('progressContainer').classList.remove('active');
    const r = t.rawData || {};
    document.getElementById('sumChecked').textContent = r.total_checked || 0;
    document.getElementById('sumFound').textContent = r.total_found || 0;
    document.getElementById('sumElapsed').textContent = (r.elapsed_seconds || 0) + 's';

    const tagSet = new Set();
    (t.profiles || []).forEach(p => (p.tags || []).forEach(tg => tagSet.add(tg)));
    document.getElementById('sumCategories').textContent = tagSet.size;

    renderProfiles(t.profiles);
    document.getElementById('badgeFound').textContent = t.profiles.length;
    renderTagsHeatmap(t.profiles);
    document.getElementById('rawJson').textContent = JSON.stringify(r, null, 2);
  } else {
    renderProfiles(t.profiles);
    document.getElementById('badgeFound').textContent = t.profiles.length;
  }
}

/* ── Profiles table ── */
function renderProfiles(profiles) {
  const body = document.getElementById('profilesBody');
  const filter = (document.getElementById('filterInput').value || '').toLowerCase();
  let list = profiles || [];

  if (filter) {
    list = list.filter(p => p.site.toLowerCase().includes(filter) || (p.url || '').toLowerCase().includes(filter));
  }
  if (state.filterStarred) {
    list = list.filter(p => state.starred.has(p.site));
  }

  list.sort((a, b) => {
    let cmp = 0;
    if (state.sortField === 'site') cmp = a.site.localeCompare(b.site);
    else if (state.sortField === 'time') cmp = (a.response_time || 999) - (b.response_time || 999);
    return state.sortAsc ? cmp : -cmp;
  });

  body.innerHTML = list.map(p => {
    const starred = state.starred.has(p.site);
    const timeClass = p.response_time ? (p.response_time < 1 ? 'fast' : p.response_time > 3 ? 'slow' : '') : '';
    const timeText = p.response_time ? p.response_time + 's' : '-';
    const tagsHtml = (p.tags || []).map(t => `<span class="profile-tag">${t}</span>`).join('');
    return `<tr>
      <td><button class="star-btn ${starred ? 'starred' : ''}" onclick="toggleStar('${p.site}')">${starred ? '★' : '☆'}</button></td>
      <td>${p.site}</td>
      <td><a href="${p.url}" target="_blank" rel="noopener">${p.url}</a></td>
      <td><div class="profile-tags">${tagsHtml}</div></td>
      <td><span class="response-time ${timeClass}">${timeText}</span></td>
    </tr>`;
  }).join('');
}

function filterProfiles() {
  const t = state.targets[state.activeTarget];
  if (t) renderProfiles(t.profiles);
}

function sortProfiles(field) {
  if (state.sortField === field) state.sortAsc = !state.sortAsc;
  else { state.sortField = field; state.sortAsc = true; }
  const t = state.targets[state.activeTarget];
  if (t) renderProfiles(t.profiles);
}

function toggleStar(site) {
  if (state.starred.has(site)) state.starred.delete(site);
  else state.starred.add(site);
  const t = state.targets[state.activeTarget];
  if (t) renderProfiles(t.profiles);
}

function showStarred() {
  state.filterStarred = !state.filterStarred;
  const t = state.targets[state.activeTarget];
  if (t) renderProfiles(t.profiles);
}

/* ── Tabs ── */
function switchTab(el) {
  document.querySelectorAll('.result-tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  el.classList.add('active');
  const panel = document.getElementById('panel-' + el.dataset.tab);
  if (panel) panel.classList.add('active');

  if (el.dataset.tab === 'graph') {
    const t = state.targets[state.activeTarget];
    if (t && t.graphData) renderGraph(t.graphData);
  }
}

/* ── D3.js Force Graph ── */
let graphSvg, graphG, zoomBehavior;

function renderGraph(data) {
  const container = document.getElementById('graphContainer');
  const svg = d3.select('#graphSvg');
  svg.selectAll('*').remove();

  const width = container.clientWidth;
  const height = container.clientHeight;

  zoomBehavior = d3.zoom().scaleExtent([0.1, 8]).on('zoom', (e) => {
    graphG.attr('transform', e.transform);
  });
  svg.call(zoomBehavior);

  graphG = svg.append('g');

  const nodes = data.nodes || [];
  const links = data.links || [];

  if (state.simulation) state.simulation.stop();

  state.simulation = d3.forceSimulation(nodes)
    .force('link', d3.forceLink(links).id(d => d.id).distance(80))
    .force('charge', d3.forceManyBody().strength(-200))
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force('collision', d3.forceCollide().radius(d => (d.size || 10) + 4));

  const link = graphG.append('g')
    .selectAll('line')
    .data(links)
    .join('line')
    .attr('stroke', '#3a3a4a')
    .attr('stroke-width', d => d.weight || 1);

  const node = graphG.append('g')
    .selectAll('circle')
    .data(nodes)
    .join('circle')
    .attr('r', d => d.size || 8)
    .attr('fill', d => d.color || '#7c3aed')
    .attr('stroke', '#1a1a24')
    .attr('stroke-width', 1.5)
    .call(d3.drag()
      .on('start', (e, d) => {
        if (!e.active) state.simulation.alphaTarget(0.3).restart();
        d.fx = d.x; d.fy = d.y;
      })
      .on('drag', (e, d) => { d.fx = e.x; d.fy = e.y; })
      .on('end', (e, d) => {
        if (!e.active) state.simulation.alphaTarget(0);
        d.fx = null; d.fy = null;
      })
    );

  const label = graphG.append('g')
    .selectAll('text')
    .data(nodes)
    .join('text')
    .text(d => d.id)
    .attr('font-size', d => d.group === 1 ? 13 : 10)
    .attr('fill', '#8888a0')
    .attr('dx', d => (d.size || 8) + 4)
    .attr('dy', 4);

  node.append('title').text(d => d.url || d.id);

  node.on('click', (e, d) => {
    if (d.url) window.open(d.url, '_blank');
  });

  state.simulation.on('tick', () => {
    link
      .attr('x1', d => d.source.x).attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x).attr('y2', d => d.target.y);
    node.attr('cx', d => d.x).attr('cy', d => d.y);
    label.attr('x', d => d.x).attr('y', d => d.y);
  });
}

function graphZoom(factor) {
  const svg = d3.select('#graphSvg');
  svg.transition().duration(300).call(zoomBehavior.scaleBy, factor);
}

function graphReset() {
  const svg = d3.select('#graphSvg');
  svg.transition().duration(500).call(zoomBehavior.transform, d3.zoomIdentity);
}

function toggleFullscreen() {
  document.getElementById('graphContainer').classList.toggle('fullscreen');
  const t = state.targets[state.activeTarget];
  if (t && t.graphData) setTimeout(() => renderGraph(t.graphData), 100);
}

/* ── Tags Heatmap ── */
function renderTagsHeatmap(profiles) {
  const counts = {};
  (profiles || []).forEach(p => {
    (p.tags || []).forEach(t => { counts[t] = (counts[t] || 0) + 1; });
  });
  const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]);
  const max = sorted.length ? sorted[0][1] : 1;
  const grid = document.getElementById('tagsGrid');
  grid.innerHTML = sorted.map(([tag, count]) => {
    const pct = Math.round((count / max) * 100);
    return `<div class="tag-card" onclick="filterByTag('${tag}')">
      <div class="tag-name">${tag}</div>
      <div class="tag-count">${count}</div>
      <div class="tag-bar"><div class="tag-bar-fill" style="width:${pct}%"></div></div>
    </div>`;
  }).join('');
}

function filterByTag(tag) {
  document.getElementById('filterInput').value = tag;
  switchTab(document.querySelector('[data-tab="found"]'));
  filterProfiles();
}

/* ── Export ── */
function exportReport(fmt) {
  const t = state.targets[state.activeTarget];
  if (!t) return;
  window.open(`/api/scan/${t.jobId}/export/${fmt}`, '_blank');
}

/* ── Live hit flash ── */
function showLiveHit(site, url) {
  const div = document.createElement('div');
  div.className = 'live-hit';
  div.innerHTML = `<strong>${site}</strong><br><a href="${url}" target="_blank" style="color:inherit">${url}</a>`;
  document.body.appendChild(div);
  setTimeout(() => div.remove(), 3500);
}

/* ── Show search panel ── */
function showSearch() {
  document.getElementById('searchPanel').style.display = 'block';
  document.getElementById('resultsContainer').classList.remove('active');
  document.getElementById('progressContainer').classList.remove('active');
  document.getElementById('targetBar').classList.remove('active');
  document.getElementById('targetBar').innerHTML = '';
  document.getElementById('btnNewScan').style.display = 'none';
  state.targets = {};
  state.activeTarget = null;
  if (state.simulation) { state.simulation.stop(); state.simulation = null; }
}
