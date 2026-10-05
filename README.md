# myprojects.cc

A small static hub for my projects. One front page, one page per project, and
**no passwords** — everything shown is read-only and published automatically.

```
site/
  index.html          the hub (links + live status dots)
  league/             League Vault
  warroom/            Kingdom War Room
  osrs/               OSRS Bot
  assets/             shared style.css + hub.js
  data/               one JSON file per project (the data contract)
```

## How it stays current

Each project builds a small JSON file and publishes it into `site/data/`. The
site reads that file and renders it — it knows nothing project-specific. See
[`DATA_CONTRACT.md`](DATA_CONTRACT.md) for the shape.

Publishing is automatic. A project either commits its JSON here with a token,
or fires a `repository_dispatch` so a workflow writes it:

- **Deploy site** (`.github/workflows/deploy.yml`) ships `site/` to GitHub
  Pages on every push and on a `data-updated` dispatch.
- **Accept published data** (`.github/workflows/accept-data.yml`) lets a
  project without push access send `{ project, data }` in a `publish-data`
  dispatch; the workflow validates and commits it, which redeploys.

So a new War Room week, a League Vault refresh or a bot run updates the site on
its own — no copying files to a server, no reverse proxy, no password gate.

## Hosting

**GitHub Pages** is the default (the Deploy workflow). Enable Pages → Source:
GitHub Actions.

**Self-hosting** the same static files behind Caddy still works: copy
`Caddyfile.example` to `Caddyfile`, set the domain, and run `run.bat`. It just
serves `site/` — there is no backend to run anymore.
