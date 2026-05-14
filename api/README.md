# Saudi Opportunity Hub — API (v1.1)

Read-only REST API for the Saudi Opportunity Hub dataset.

## Install

```bash
cd api
npm install
```

## Run

```bash
npm start
```

Server starts at **http://localhost:3001**

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3001` | HTTP port |
| `NODE_ENV` | `development` | Logged in `/api/health` |
| `SUPABASE_URL` | demo project URL | Supabase project URL |
| `SUPABASE_ANON_KEY` | demo anon key | Supabase anon JWT |
| `ALLOWED_ORIGINS` | _(allow all)_ | Comma-separated CORS allowlist, e.g. `https://example.com,https://app.example.com` |
| `RATE_LIMIT_MAX` | `60` | Requests per minute per IP |

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/opportunities` | List opportunities (filterable, sortable, paginated) |
| GET | `/api/opportunities/:id` | Get a single opportunity by ID |
| GET | `/api/stats` | Aggregated counts + freshness signals |
| GET | `/api/meta` | All available filter values |
| GET | `/api/health` | Health check + cache state |

## Query parameters for `/api/opportunities`

| Param | Description | Example |
|-------|-------------|---------|
| `q` | Full-text search across title, sponsor, description | `?q=space` |
| `sector` | Filter by sector | `?sector=ICT` |
| `region` | Filter by eligibility region | `?region=saudi` |
| `type` | Filter by opportunity type | `?type=grant` |
| `status` | Filter by status (`open`, `recurring`, `closed`) | `?status=open` |
| `profile` | Filter by target profile | `?profile=startup` |
| `sort` | `newest`, `oldest`, `title` | `?sort=newest` |
| `page` | Page number (default `1`) | `?page=2` |
| `limit` | Results per page (default `20`, max `100`) | `?limit=10` |

Response:

```json
{
  "total": 412,
  "page": 1,
  "limit": 20,
  "pages": 21,
  "results": [ ... ]
}
```

## Security

The API ships with:

- **Strict security headers** — `X-Content-Type-Options`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, `Permissions-Policy`, `Strict-Transport-Security`
- **Origin allowlist** — set `ALLOWED_ORIGINS` in production to restrict CORS
- **Per-IP rate limiting** — 60 req/min by default, returns `429` with `Retry-After`
- **Input validation** — IDs constrained to `[A-Za-z0-9_-]`, query strings sanitised and length-capped
- **Request timeouts** — Supabase calls cancel after 15 s
- **Graceful shutdown** — `SIGTERM` / `SIGINT` drain connections

Cache TTL is **5 minutes**. Concurrent refresh attempts are coalesced into a single Supabase fetch.

## URLs

```
Base URL: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app

All opportunities:  /api/opportunities
Single item:        /api/opportunities/SA-001
Filter by sector:   /api/opportunities?sector=ICT
Filter by status:   /api/opportunities?status=open
Search + paginate:  /api/opportunities?q=space&page=2&limit=10
Stats:              /api/stats
Filter values:      /api/meta
Health:             /api/health
```
