# Saudi Opportunity Hub — API (v1)

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

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/opportunities` | List all opportunities (paginated) |
| GET | `/api/opportunities/:id` | Get single opportunity by ID |
| GET | `/api/stats` | Summary statistics |
| GET | `/api/meta` | Available filter values |

## Query Parameters for `/api/opportunities`

| Param | Description | Example |
|-------|-------------|---------|
| `q` | Search title, sponsor, description | `?q=space` |
| `sector` | Filter by sector | `?sector=ict` |
| `region` | Filter by eligibility region | `?region=saudi` |
| `type` | Filter by opportunity type | `?type=grant` |
| `status` | Filter by status | `?status=open` |
| `profile` | Filter by target profile | `?profile=startup` |
| `page` | Page number (default: 1) | `?page=2` |
| `limit` | Results per page (default: 20, max: 100) | `?limit=10` |

## Example URLs

```
All opportunities: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/opportunities

Single item: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/opportunities/SA-001

Filter by sector: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/opportunities?sector=ict

Filter by status: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/opportunities?status=open

Stats: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/stats

Filter values: https://saudi-opportunity-hub-demo-white-label-production.up.railway.app/api/meta
```
