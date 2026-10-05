# The data contract

Every project on `myprojects.cc` is drawn from one small JSON file. The site
does not know anything about League, Rise of Kingdoms or RuneScape — it only
knows this shape. A project "connects" to the site by writing one of these
files into `site/data/<project>.json` and letting the site redeploy.

That is the whole seam. No passwords, no live backend, no manual copying of
HTML. Each project builds its own JSON and publishes it; the site renders it.

## The shape

```json
{
  "project": "warroom",
  "title": "Kingdom War Room",
  "updated": "2026-10-05T05:55:00Z",
  "status": "ok",
  "summary": "Week 41 ranked — 312 governors scored.",
  "stats": [
    { "label": "Governors", "value": "312" },
    { "label": "Week", "value": "41", "hint": "resets Monday 00:00 UTC" }
  ],
  "sections": [
    {
      "heading": "Top movers",
      "columns": ["Governor", "Alliance", "Score"],
      "rows": [
        ["Aethel", "WAR", "1,204,885"],
        ["Borin", "WAR", "988,120"]
      ]
    }
  ],
  "note": "Lifetime totals are converted to weekly deltas automatically.",
  "source": "https://github.com/mtc53/rok-ranking-assistant"
}
```

## Fields

| Field | Required | What it is |
| --- | --- | --- |
| `project` | yes | the slug, matching the file name (`warroom`, `league`, `osrs`) |
| `title` | yes | the human name shown as the page heading |
| `updated` | yes | ISO-8601 UTC timestamp of when this data was produced |
| `summary` | yes | one sentence describing the current state |
| `status` | no | `ok`, `stale`, or `offline` — drives the status dot colour |
| `stats` | no | tiles of `{ label, value, hint? }`; `hint` is small print under the value |
| `sections` | no | tables of `{ heading, columns[], rows[][] }`; cells are plain strings |
| `note` | no | a footnote under the content |
| `source` | no | a URL (usually the project repo) shown in the page footer |

Anything the site cannot recognise is ignored, so a project may add extra
keys for its own use without breaking the page.

## Staleness

The site compares `updated` to the current time when it renders. Data older
than 24h shows a "stale" badge regardless of the `status` field, so a
publisher that stops running is visible at a glance rather than silently
showing old numbers.

## Publishing

A project writes its JSON into this repo's `site/data/` folder (via a commit
from its own GitHub Action, using a token with push access) and then fires a
`repository_dispatch` event of type `data-updated` at this repo. The deploy
workflow here redeploys the static site within a minute. See each project's
`.github/workflows/publish-*.yml` for the exact steps.

Until a project is wired up, a seed file in `site/data/` keeps its page
rendering with placeholder data marked `status: "offline"`.
