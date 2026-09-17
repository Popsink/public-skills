---
name: popsink-api
description: Talk to a Popsink data-plane instance through its REST API — exchange an organization API key for a token, then list, inspect, start/stop, sync and monitor connectors, datamodels and subscriptions. Use whenever the user points at a Popsink URL (e.g. https://<tenant>.<region>.popsink.com), asks for the state of their pipelines, replication or sync, wants connector logs, throughput metrics or health, or wants to script anything against the Popsink API.
---

# Popsink API

Drive a Popsink deployment from the outside: **authenticate → discover →
call**. Every instance serves its own live OpenAPI schema, so the schema — not
this file — is the source of truth for request and response shapes.

## What you need

| | |
|---|---|
| **Instance URL** | The deployment's base URL, e.g. `https://<tenant>.<region>.popsink.com`. The API lives under `/api`. |
| **API key** | An organization API key, created in the **control plane** → `Dashboard` → `API keys` → `Create`. |

The key is shown **once, at creation** — it is never retrievable afterwards,
only a masked preview is. It starts with `psk_` and is granted access to a
chosen set of environments, each with a role (`admin` or `user`). A key only
works on the deployment that owns those environments.

Ask the user for both if they are not already in the environment:

```bash
export POPSINK_URL="https://<tenant>.<region>.popsink.com"
export POPSINK_API_KEY="psk_..."
```

Never echo the key, never write it into a file, a script, a commit, a log line
or a ticket. If one shows up in output you are about to save or share, redact
it and say so.

## 1. Authenticate

Exchange the key for a short-lived bearer token:

```bash
curl -sS -X POST "$POPSINK_URL/api/auth/jwt/login-from-api-key" \
  -H 'Content-Type: application/json' \
  -d "{\"api_key\": \"$POPSINK_API_KEY\"}"
# -> {"access_token": "...", "refresh_token": "", "token_type": "bearer"}
```

Then send `Authorization: Bearer <access_token>` on every call.

Two things to know about this token:

- **It lasts 10 minutes.**
- **No refresh token is issued** (`refresh_token` is deliberately empty). That
  is by design: the key is only re-checked at exchange time, so forcing a
  re-exchange caps how long a revoked key keeps working. When you get a `401`,
  exchange the key again — do not try `/api/auth/jwt/refresh`.

`scripts/popsink` wraps all of this — it caches the token, refreshes it when it
expires, and retries once on `401`:

```bash
skills/popsink-api/scripts/popsink GET  /envs/
skills/popsink-api/scripts/popsink GET  '/datamodels/?state=error&size=100'
skills/popsink-api/scripts/popsink POST /connectors/<connector-id>/stop
```

It needs `curl` and `jq`, and reads `POPSINK_URL` / `POPSINK_API_KEY` from the
environment. Prefer it over hand-rolled `curl` so the token dance stays in one
place.

## 2. Discover before you call

The API evolves. Read the live schema rather than trusting memory:

```bash
curl -sS "$POPSINK_URL/api/openapi.json" | jq '.paths | keys'
curl -sS "$POPSINK_URL/api/openapi.json" \
  | jq '.paths["/datamodels/"].get.parameters[] | {name, in, required}'
```

`$POPSINK_URL/api/docs` is the same schema as a browsable Swagger UI, for the
user.

`reference/api-map.md` is a **snapshot** of the endpoint inventory, useful to
find the right area fast. Confirm the exact path, parameters and body against
the live schema before calling — a snapshot of a moving API is a hint, not a
contract.

## 3. The domain model

```
environment
  └── source connector          reads a source system (CDC or batch)
        └── datamodel           one per replicated table / topic
              └── subscription  delivery of that datamodel to one target
                    └── target connector   writes to the destination
```

- **Environment** (`env`) — the top-level scope. Nearly everything is filtered
  by it. A key may grant several.
- **Team** — a grouping inside an environment; many list endpoints take
  `team_id`.
- **Connector** — a source or a target. Types are listed by
  `GET /connector-types/`; each type also has its own credential-check and
  table-listing endpoints (`POST /<type>/check-credentials`,
  `POST /<type>/list-tables`).
- **Datamodel** — one replicated table/stream produced by a source connector.
  Has a `status` and a worker state: `live`, `error`, `paused`, `building`,
  `stopping`.
- **Subscription** — one datamodel delivered to one target connector. Carries
  the target table name, mapper/filter config, backfill and error-table
  settings.

Environment scoping works two ways, and mixing them up is the most common
mistake:

- Most list endpoints take an explicit **`env`** (or `env_id`) query parameter —
  always pass it when you know it.
- Endpoints that take no such parameter fall back to the principal's **active
  environment**, which for an API-key principal is parked on the first granted
  environment. Change it with `PATCH /users/me {"active_env_id": "<uuid>"}`.

## 4. Recipes

Paths below are relative to `$POPSINK_URL/api`. Trailing slashes are part of
the path — `/datamodels/`, not `/datamodels`. The snippets assume the helper is
reachable as `popsink`:

```bash
alias popsink="$PWD/skills/popsink-api/scripts/popsink"
```

**Find your footing**

```bash
popsink GET /users/me                 # who am I, and my active_env_id
popsink GET /envs/                    # environments this key can reach
popsink GET /config/deployment        # deployment id, mode, name
popsink GET /healthchecks             # API liveness; also /healthchecks/db,
                                      # /broker, /schema-registry, /k8s,
                                      # /control-plane
```

**Inventory an environment** (`ENV` = an environment UUID)

```bash
popsink GET "/connectors/source-config?env_id=$ENV"     # source connectors
popsink GET "/connectors/target-config?env_id=$ENV"     # target connectors
popsink GET "/datamodels/?env=$ENV&size=100"            # replicated tables
popsink GET "/subscriptions/?env=$ENV&size=100"         # deliveries
```

Lists are paginated: `page` (from 1) and `size` (max **100**), returning
`{items, total, page, size, pages}`. Loop on `pages` — do not assume one page.

**Find what is broken**

```bash
popsink GET "/datamodels/?env=$ENV&state=error&size=100"
popsink GET "/datamodels/count-status"
popsink GET "/datamodels/$DATAMODEL_ID/monitoring"
popsink GET "/connectors/$CONNECTOR_ID/logs"
popsink GET "/workers/resource/$RESOURCE_ID/status"
```

`/connectors/{id}/logs` takes `filter_ids`, a comma-separated list of
datamodel/subscription UUIDs, to narrow the log lines to one pipeline.

**Throughput and freshness**

```bash
SINCE=$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)   # GNU: date -u -d '24 hours ago' ...
popsink GET "/workers/production-metrics?since=$SINCE&connector_id=$CONNECTOR_ID"
popsink GET "/workers/consumption-metrics?since=$SINCE&subscription_id=$SUB_ID"
popsink GET "/datamodels/environment/monitoring-summary"
popsink GET "/datamodels/environment/monitoring-chart"
```

Production metrics are CDC counts bucketed by Debezium operation code: `c`
insert, `u` update, `d` delete, `r` **snapshot read**. `r` being 0 on an
established stream is normal — it only counts rows read during the initial
snapshot — so don't report it as a gap.

**Operate**

```bash
popsink POST "/connectors/$CONNECTOR_ID/start"
popsink POST "/connectors/$CONNECTOR_ID/stop"
popsink POST "/datamodels/$DATAMODEL_ID/start"
popsink POST "/datamodels/$DATAMODEL_ID/stop"
popsink POST "/subscriptions/$SUB_ID/start"     # enable processing
popsink POST "/subscriptions/$SUB_ID/pause"     # disable processing
```

**Resync and backfill**

```bash
popsink GET  "/connectors/$CONNECTOR_ID/sync"           # current sync status
popsink GET  "/connectors/$CONNECTOR_ID/sync/history"
popsink POST "/connectors/$CONNECTOR_ID/sync"           # start a sync
popsink POST "/connectors/$CONNECTOR_ID/sync/cancel"
popsink POST "/connectors/$CONNECTOR_ID/trigger-incremental-load"
popsink POST "/datamodels/$DATAMODEL_ID/trigger-incremental-load"
```

## 5. Guardrails

**Confirm before anything that changes state.** Read-only exploration is free;
the rest is not. Say plainly what will happen, to which named resource, and
wait for a yes. Treat these as requiring explicit confirmation:

- `DELETE` on anything — `/connectors/{id}`, `/datamodels/{id}`,
  `/subscriptions/{id}`, `/envs/{id}`. Deleting a subscription can drop objects
  in the customer's warehouse; check first with
  `GET /subscriptions/{id}/target-objects`.
- `stop` / `pause` — halts replication; lag starts accumulating immediately.
- `sync`, `replay`, `trigger-blocking-snapshot`, `trigger-incremental-load`,
  `replay-source`, `rebuild-dynamic-table` — re-read source data and rewrite
  target data. Expensive on the source, on the warehouse, and on the bill. A
  blocking snapshot in particular stalls ongoing CDC.
- `PATCH` on connectors, datamodels or subscriptions — config changes can
  restart workers.

**Stay inside the ask.** One question ("is anything broken?") is a read pass,
not a licence to restart workers.

**Handle secrets like secrets.** Connector configs contain customer
credentials. Don't print them, don't paste them into a summary, don't save a
response body that contains one.

**Redact when reporting outward.** If output is going into a ticket, a
document, or anywhere public, strip client names, hostnames, schema and table
names, and IDs first.

## 6. Troubleshooting

| Symptom | Meaning |
|---|---|
| `401` on a call that worked minutes ago | Token expired (10 min). Exchange the key again. |
| `401 Invalid API key` | Key revoked, mistyped, or it grants no environment on *this* deployment. |
| `400 Environment <id> is not available on this deployment` | The key's environment belongs to another deployment, or hasn't synced here yet. |
| `400 This endpoint is only available in SELF_HOSTED mode` | API-key login is not enabled on that instance. Check `GET /config/deployment` → `deployment_mode`; get the user to confirm which instance they meant. |
| `307` redirect | Missing or extra trailing slash. Use the path exactly as the schema spells it. |
| `422` | Body or query params don't match the schema — re-read it from `/api/openapi.json` rather than guessing. |
