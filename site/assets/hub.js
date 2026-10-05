// Shared rendering for every project page on myprojects.cc.
//
// A page sets <body data-project="warroom"> and includes this script. We fetch
// data/<project>.json (the data contract, see DATA_CONTRACT.md) and render it.
// The site knows nothing project-specific — only the contract shape.

const DAY = 24 * 60 * 60 * 1000;

const esc = (s) =>
  String(s).replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

function ago(iso) {
  const t = Date.parse(iso);
  if (Number.isNaN(t)) return "";
  const s = Math.max(0, Date.now() - t) / 1000;
  if (s < 90) return "just now";
  if (s < 3600) return `${Math.round(s / 60)}m ago`;
  if (s < 86400) return `${Math.round(s / 3600)}h ago`;
  return `${Math.round(s / 86400)}d ago`;
}

// ok | stale | offline — data older than a day is always "stale"
function effectiveStatus(d) {
  const t = Date.parse(d.updated);
  const old = !Number.isNaN(t) && Date.now() - t > DAY;
  if (d.status === "offline") return "offline";
  if (old) return "stale";
  return d.status || "ok";
}

function tiles(stats) {
  if (!Array.isArray(stats) || !stats.length) return "";
  const cells = stats
    .map(
      (s) => `<div class="tile">
        <div class="v">${esc(s.value)}</div>
        <div class="l">${esc(s.label)}</div>
        ${s.hint ? `<div class="h">${esc(s.hint)}</div>` : ""}
      </div>`
    )
    .join("");
  return `<div class="stats">${cells}</div>`;
}

function section(sec) {
  const cols = (sec.columns || []).map((c) => `<th>${esc(c)}</th>`).join("");
  const rows = (sec.rows || [])
    .map(
      (r) =>
        `<tr>${(Array.isArray(r) ? r : [r]).map((c) => `<td>${esc(c)}</td>`).join("")}</tr>`
    )
    .join("");
  return `<div class="section">
    ${sec.heading ? `<h2>${esc(sec.heading)}</h2>` : ""}
    <table>${cols ? `<thead><tr>${cols}</tr></thead>` : ""}<tbody>${rows}</tbody></table>
  </div>`;
}

function render(d) {
  const root = document.getElementById("app");
  const st = effectiveStatus(d);
  const badge =
    st === "ok" ? "" : `<span class="badge ${st}">${st}</span>`;
  const sections = Array.isArray(d.sections)
    ? d.sections.map(section).join("")
    : "";

  root.innerHTML = `
    <div class="head in">
      <h1>${esc(d.title || d.project)}</h1>
      <p class="summary">${esc(d.summary || "")}</p>
      <p class="stamp"><span class="dot ${st}"></span>
        ${d.updated ? `updated ${esc(ago(d.updated))}` : "no data yet"} ${badge}</p>
    </div>
    ${tiles(d.stats)}
    ${sections}
    ${d.note ? `<p class="note">${esc(d.note)}</p>` : ""}
    <footer>
      <span>myprojects.cc</span>
      ${d.source ? `<a href="${esc(d.source)}">${esc(d.source.replace(/^https?:\/\//, ""))}</a>` : ""}
    </footer>`;
}

async function load() {
  const project = document.body.dataset.project;
  const root = document.getElementById("app");
  try {
    const res = await fetch(`../data/${project}.json`, { cache: "no-store" });
    if (!res.ok) throw new Error(res.status);
    render(await res.json());
  } catch (e) {
    root.innerHTML = `<div class="head"><h1>${esc(
      document.title.replace(/ · .*/, "")
    )}</h1><p class="empty">No data published yet.</p></div>`;
  }
}

load();
