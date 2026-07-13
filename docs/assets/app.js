function buildSidebar(){
  const nav = document.getElementById('sidebar');
  nav.innerHTML = NAV.map(group => `
    <div class="nav-group">
      <div class="nav-group-title">${group.title}</div>
      ${group.items.map(item => `
        <a class="nav-link" data-id="${item.id}" onclick="navigate('${item.id}')">
          ${icon(item.icon)}
          <span>${item.title}</span>${item.badge ? `<span class="tag-beta">${item.badge}</span>` : ''}
        </a>
      `).join('')}
    </div>
  `).join('');
}

function renderPage(id){
  const page = PAGES[id];
  if(!page){ navigate('about'); return; }

  document.title = `${page.title} · VexUI Docs`;

  document.querySelectorAll('.nav-link').forEach(el => {
    el.classList.toggle('active', el.dataset.id === id);
  });

  const idx = FLAT_PAGES.findIndex(p => p.id === id);
  const prev = FLAT_PAGES[idx - 1];
  const next = FLAT_PAGES[idx + 1];

  const heroBlock = page.isHero ? `
    <div class="hero">
      <div class="eyebrow">Introducing</div>
      <h1>${page.title}</h1>
      <p class="lede">${page.subtitle}</p>
      <div class="hero-rule"></div>
      <div class="hero-mock-wrap">
        <div class="ui-mock">
          <div class="ui-mock-head">
            <div class="ui-mock-brand">
              <div class="umb-icon">${icon('window', 16)}</div>
              <div>
                <div class="umb-title">VexUI Example</div>
                <div class="umb-sub">By SSHRK</div>
              </div>
            </div>
            <div class="ui-mock-actions">
              <div class="uma-icon">${icon('bell', 13)}</div>
              <div class="uma-icon">${icon('palette', 13)}</div>
              <div class="ui-mock-search">${icon('doc', 12)}<span>Search...</span></div>
            </div>
          </div>
          <div class="ui-mock-body">
            ${widgetRow('pointer','Button','This is a button','')}
            ${widgetRow('toggle','Toggle','This is a toggle', ctlToggle(true))}
            ${widgetRow('sliders','Slider','This is a slider', ctlSlider(25))}
            ${widgetRow('chevronBox','Dropdown','This is a dropdown', ctlChip('Option 1'))}
          </div>
        </div>
      </div>
    </div>
  ` : `
    <div class="hero" style="margin-bottom:6px;">
      <div class="eyebrow">${page.group ? FLAT_PAGES.find(p=>p.id===id).group : ''}</div>
      <h1 style="font-size:28px;">${page.title}</h1>
      <p class="lede">${page.subtitle}</p>
    </div>
  `;

  document.getElementById('content-inner').innerHTML = `
    ${heroBlock}
    <div class="prose">${page.html}</div>
    <div class="pager">
      ${prev ? `<div class="pager-link" onclick="navigate('${prev.id}')"><div class="pager-label">← Previous</div><div class="pager-title">${prev.title}</div></div>` : `<div></div>`}
      ${next ? `<div class="pager-link next" onclick="navigate('${next.id}')"><div class="pager-label">Next →</div><div class="pager-title">${next.title}</div></div>` : `<div></div>`}
    </div>
  `;

  document.getElementById('content').scrollTo({ top: 0, behavior: 'instant' in document.documentElement.style ? 'instant' : 'auto' });
  closeSidebar();
}

function navigate(id){
  window.location.hash = id;
}

function handleHash(){
  const id = window.location.hash.replace('#','') || 'about';
  renderPage(id);
}

function copyCode(el){
  const pre = el.closest('.code-block').querySelector('pre');
  navigator.clipboard.writeText(pre.innerText).then(() => {
    const old = el.innerText;
    el.innerText = 'Copied';
    setTimeout(() => el.innerText = old, 1200);
  });
}

function switchCodeTab(id, idx, btn){
  const wrap = document.getElementById(id);
  if(!wrap) return;
  wrap.querySelectorAll('.seg-btn').forEach(b => b.classList.toggle('active', b === btn));
  wrap.querySelectorAll('.code-variant').forEach(el => {
    el.style.display = (el.dataset.idx == idx) ? '' : 'none';
  });
}

function toggleTheme(){
  const root = document.documentElement;
  const next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
  if(next === 'light'){ root.setAttribute('data-theme','light'); } else { root.removeAttribute('data-theme'); }
  localStorage.setItem('vexui-theme', next);
}
(function initTheme(){
  const saved = localStorage.getItem('vexui-theme');
  if(saved === 'light') document.documentElement.setAttribute('data-theme','light');
})();

function openSidebar(){ document.getElementById('sidebar').classList.add('open'); }
function closeSidebar(){ document.getElementById('sidebar').classList.remove('open'); }

function openSearch(){
  document.getElementById('search-overlay').classList.add('open');
  const input = document.getElementById('search-input');
  input.value = '';
  input.focus();
  renderSearchResults('');
}
function closeSearch(){
  document.getElementById('search-overlay').classList.remove('open');
}
function renderSearchResults(q){
  const results = document.getElementById('search-results');
  const query = q.trim().toLowerCase();
  const matches = FLAT_PAGES.filter(p =>
    !query || p.title.toLowerCase().includes(query) || p.group.toLowerCase().includes(query)
  );
  if(matches.length === 0){
    results.innerHTML = `<div class="search-empty">No pages match “${q}”</div>`;
    return;
  }
  results.innerHTML = matches.map((p,i) => `
    <div class="search-item ${i===0?'sel':''}" onclick="navigate('${p.id}'); closeSearch();">
      <div class="si-group">${p.group}</div>
      <div class="si-title">${p.title}</div>
    </div>
  `).join('');
}

document.addEventListener('keydown', (e) => {
  if((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k'){
    e.preventDefault();
    openSearch();
  }
  if(e.key === 'Escape') closeSearch();
});

window.addEventListener('DOMContentLoaded', () => {
  buildSidebar();
  handleHash();
});
window.addEventListener('hashchange', handleHash);
