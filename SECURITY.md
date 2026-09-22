# Security

## Reporting a vulnerability

Email **security@popsink.com**. Do not open a GitHub issue — this repository is
public, and so is everything in an issue.

Include what you did, what happened, and how to reproduce it. If it concerns a
Popsink deployment rather than this repository, say which deployment, but keep
credentials out of the report: we can reproduce from a description.

We acknowledge within two business days.

## Please do not paste

Issues and pull requests here are world-readable, indexed and permanent. Before
attaching anything from a real instance, strip:

- **API keys and tokens** — a `psk_…` key, a bearer token, a connector
  credential. Rotate it if it has already been sent somewhere;
- **hostnames** — write `https://<tenant>.<region>.popsink.com`;
- **resource ids** — connector, datamodel, subscription and environment UUIDs
  identify a tenant; write `<connector-id>`;
- **schema, table and column names**, and any row of data;
- **raw log output**, which usually carries several of the above at once.

A redacted description of the behaviour is always enough to open the
conversation. CI enforces the same rules on every pull request — see
`.github/scripts/check-public-safety.sh`.

## Using the skills safely

`skills/popsink-api` drives a live deployment. Two properties of the helper are
load-bearing, and worth keeping if you adapt it:

- it never puts the API key or a request body on a command line, where any
  local user can read it out of the process list;
- it refuses anything but `GET`/`HEAD` unless `POPSINK_ALLOW_WRITE=1` is set on
  that call, so stopping a connector or deleting a subscription cannot happen
  by accident or by an agent's enthusiasm.

An API key is scoped to the environments it was granted, and its exchanged
token lasts ten minutes. Revoking a key in the control plane therefore takes
effect within ten minutes, not instantly — assume that window when a key has
leaked, and stop the connectors if it matters.
