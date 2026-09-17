# Popsink data-plane API — endpoint map

Snapshot of the endpoint inventory, grouped by area, to find the right
endpoint fast. It is **not** a contract: every instance serves its own live
schema at `$POPSINK_URL/api/openapi.json` (browsable at `$POPSINK_URL/api/docs`),
and that is what you call against. Confirm the path, parameters and body shape
there before issuing a request.

All paths are relative to `$POPSINK_URL/api`. Trailing slashes are part of the
path. Everything except the auth exchange and the probes needs an
`Authorization: Bearer <token>` header.

## Authentication

| Endpoint | Purpose |
|---|---|
| `POST /auth/forgot-password` | Forgot password |
| `POST /auth/jwt/impersonate/{user_id}` | Impersonate another user (admin only) |
| `POST /auth/jwt/login` | Login |
| `POST /auth/jwt/login-from-api-key` | Login from api key |
| `POST /auth/jwt/login-from-control-plane-token` | Login from control plane token |
| `POST /auth/jwt/logout` | Logout |
| `POST /auth/jwt/refresh` | Refresh |
| `POST /auth/register` | Register |
| `POST /auth/request-verify-token` | Request verify token |
| `POST /auth/reset-password` | Reset password |
| `POST /auth/verify` | Verify |

## Users and service accounts

| Endpoint | Purpose |
|---|---|
| `GET /users` | List users |
| `GET /users/export-all` | Export all users, envs, teams, and their relations |
| `POST /users/import-all` | Import all users, envs, teams, and their relations |
| `GET /users/me` | Get the current principal, including `active_env_id` |
| `PATCH /users/me` | Update the current principal — e.g. switch `active_env_id` |
| `POST /users/me/change-password` | Change password |
| `POST /users/me/service-account-token` | Mint a service-account token |
| `GET /users/{user_id}` | Get one user |
| `PATCH /users/{user_id}` | Update a user |
| `DELETE /users/{user_id}` | Delete a user |

## Deployment configuration

| Endpoint | Purpose |
|---|---|
| `GET /config/deployment` | Get deployment configuration |
| `GET /config/features` | Get feature flags |
| `GET /config/navigation` | Get organization/deployment switcher context |
| `POST /config/switch-deployment` | Switch to another deployment |

## Environments

| Endpoint | Purpose |
|---|---|
| `POST /envs/` | Create an environment |
| `GET /envs/` | List environments |
| `POST /envs/check-byok-credentials` | Check byok credentials |
| `GET /envs/filter-one` | Look up a single environment by filter |
| `DELETE /envs/{env_id}` | Delete an environment |
| `GET /envs/{env_id}` | Get one environment |
| `PATCH /envs/{env_id}` | Update an environment |

## Environment members

| Endpoint | Purpose |
|---|---|
| `GET /envs/members` | List members of the active environment |
| `GET /envs/members/me` | Get my membership in the active environment |
| `DELETE /envs/members/{member_id}` | Remove an environment member |

## Environment access requests

| Endpoint | Purpose |
|---|---|
| `GET /envs/requests/me` | List user env requests with details |
| `GET /envs/requests/{request_id}` | Get env request |
| `PATCH /envs/requests/{request_id}` | Update env request |
| `DELETE /envs/requests/{request_id}` | Delete env request |
| `GET /envs/{env_id}/requests` | List env requests |
| `POST /envs/{env_id}/requests` | Register an env request |

## Teams

| Endpoint | Purpose |
|---|---|
| `POST /teams/` | Create a team |
| `GET /teams/` | List teams |
| `GET /teams/filter-one` | Look up a single team by filter |
| `PATCH /teams/{team_id}` | Update a team |
| `DELETE /teams/{team_id}` | Delete a team |
| `GET /teams/{team_id}` | Get one team |

## Team members

| Endpoint | Purpose |
|---|---|
| `GET /teams/{team_id}/members` | List team members |
| `POST /teams/{team_id}/members/bulk` | Add several team members at once |
| `GET /teams/{team_id}/members/me` | Get my membership in the team |
| `DELETE /teams/{team_id}/members/{member_id}` | Delete a team member |

## Team access requests

| Endpoint | Purpose |
|---|---|
| `GET /teams/requests/me` | List user team requests with details |
| `POST /teams/{team_id}/request-membership` | Request to join a team |
| `GET /teams/{team_id}/requests` | List team requests |
| `POST /teams/{team_id}/requests` | Register a team request |
| `POST /teams/{team_id}/requests/bulk` | Register multiple team requests in one call |
| `GET /teams/{team_id}/requests/{request_id}` | Get a team request |
| `PATCH /teams/{team_id}/requests/{request_id}` | Update a team request |
| `DELETE /teams/{team_id}/requests/{request_id}` | Delete a team request |

## Connectors

| Endpoint | Purpose |
|---|---|
| `POST /connectors/` | Create connector |
| `GET /connectors/filter-one` | Get Connector By Filter |
| `GET /connectors/source-config` | List source configurations |
| `GET /connectors/target-config` | List target configurations |
| `GET /connectors/{connector_id}` | Get connector by ID |
| `PATCH /connectors/{connector_id}` | Update connector |
| `DELETE /connectors/{connector_id}` | Delete connector |
| `POST /connectors/{connector_id}/cancel-incremental-load` | Cancel incremental load |
| `GET /connectors/{connector_id}/incremental-load-status` | Get incremental load status |
| `GET /connectors/{connector_id}/logs` | Get the current connector worker logs snapshot |
| `GET /connectors/{connector_id}/source-topics` | List source topics or tables |
| `GET /connectors/{connector_id}/source-worker-config` | Get connector source worker configuration |
| `POST /connectors/{connector_id}/start` | Start connector worker |
| `POST /connectors/{connector_id}/stop` | Stop connector worker |
| `POST /connectors/{connector_id}/sync` | Start a sync |
| `GET /connectors/{connector_id}/sync` | Get sync status |
| `POST /connectors/{connector_id}/sync/abort` | Abort the in-progress sync table |
| `POST /connectors/{connector_id}/sync/cancel` | Cancel the whole sync |
| `GET /connectors/{connector_id}/sync/history` | Get sync history |
| `POST /connectors/{connector_id}/sync/remove` | Remove queued tables from the sync |
| `POST /connectors/{connector_id}/sync/reorder` | Reorder the sync queue |
| `GET /connectors/{connector_id}/target-worker-config` | Get connector target worker configuration |
| `POST /connectors/{connector_id}/trigger-blocking-snapshot` | Trigger blocking snapshot |
| `POST /connectors/{connector_id}/trigger-incremental-load` | Trigger incremental load |

## Datamodels

| Endpoint | Purpose |
|---|---|
| `GET /datamodels/` | List datamodels |
| `GET /datamodels/count-status` | Count datamodels by status |
| `GET /datamodels/environment/monitoring-chart` | Environment daily metrics chart |
| `GET /datamodels/environment/monitoring-summary` | Environment monitoring summary |
| `GET /datamodels/statuses` | Read the status of the given datamodels |
| `GET /datamodels/{datamodel_id}` | Get datamodel by id |
| `PATCH /datamodels/{datamodel_id}` | Update datamodel |
| `DELETE /datamodels/{datamodel_id}` | Delete datamodel |
| `PATCH /datamodels/{datamodel_id}/error-table` | Update datamodel error table configuration |
| `POST /datamodels/{datamodel_id}/fetch-schema` | Trigger schema fetch |
| `GET /datamodels/{datamodel_id}/monitoring` | Get datamodel monitoring |
| `POST /datamodels/{datamodel_id}/replay-source` | Re-read this datamodel's Kafka source topic from the beginning |
| `GET /datamodels/{datamodel_id}/schema` | Get datamodel schema |
| `POST /datamodels/{datamodel_id}/start` | Start datamodel |
| `POST /datamodels/{datamodel_id}/stop` | Stop datamodel |
| `GET /datamodels/{datamodel_id}/stream` | Poll recent Kafka records for a datamodel's topic |
| `POST /datamodels/{datamodel_id}/sync` | Start a sync for a single datamodel |
| `POST /datamodels/{datamodel_id}/trigger-blocking-snapshot` | Trigger blocking snapshot for a single datamodel |
| `POST /datamodels/{datamodel_id}/trigger-incremental-load` | Trigger incremental load for a single datamodel |

## Subscriptions

| Endpoint | Purpose |
|---|---|
| `GET /subscriptions/` | List subscriptions |
| `POST /subscriptions/` | Create a subscription |
| `GET /subscriptions/statuses` | Read the status of the given subscriptions |
| `POST /subscriptions/subscribe-all` | Create subscriptions for multiple targets |
| `POST /subscriptions/sync` | Synchronize subscriptions |
| `GET /subscriptions/{subscription_id}` | Get subscription details |
| `PATCH /subscriptions/{subscription_id}` | Update a subscription |
| `DELETE /subscriptions/{subscription_id}` | Delete subscription |
| `POST /subscriptions/{subscription_id}/pause` | Disable subscription from processing |
| `POST /subscriptions/{subscription_id}/rebuild-dynamic-table` | Rebuild the subscription's Snowflake dynamic table |
| `POST /subscriptions/{subscription_id}/replay` | Replay a subscription from the broker retention |
| `POST /subscriptions/{subscription_id}/start` | Enable subscription for processing |
| `GET /subscriptions/{subscription_id}/target-objects` | List the objects a deletion with target cleanup would drop |

## Error tables

| Endpoint | Purpose |
|---|---|
| `POST /error-table/configure/{pipeline_id}/{target_id}` | Configure Error Table |
| `GET /error-table/error-tables` | List error table configurations |

## Workers and metrics

| Endpoint | Purpose |
|---|---|
| `GET /workers/consumption-metrics` | List per-subscription consumption metrics since a given date |
| `POST /workers/ingest-consumption-metrics` | Ingest per-subscription consumption metrics from a sink worker |
| `POST /workers/ingest-production-metrics` | Ingest CDC production metrics from a source worker |
| `GET /workers/production-metrics` | List CDC production metrics since a given date |
| `POST /workers/resource/{resource_id}/heartbeat` | Receive heartbeat from worker |
| `PATCH /workers/resource/{resource_id}/state` | Update worker state by connector ID |
| `GET /workers/resource/{resource_id}/status` | Get the current worker status snapshot for a resource |

## Topic inspection

| Endpoint | Purpose |
|---|---|
| `GET /datamodels/{datamodel_id}/kotatsu/messages` | Read recent messages from the datamodel topic |
| `GET /datamodels/{datamodel_id}/kotatsu/topic` | Get the datamodel topic metadata |

## Per-connector-type helpers

| Endpoint | Purpose |
|---|---|
| `POST /bigquery-source/check-credentials` | Check BigQuery credentials |
| `POST /bigquery-source/list-tables` | List BigQuery tables |
| `POST /bigquery-target/check-credentials` | Bigquery-Target:Check-Credentials |
| `GET /connector-types/` | List connector types |
| `POST /dlt-source/list-tables` | List DLT source tables |
| `POST /elasticsearch-target/check-credentials` | Elasticsearch-Target:Check-Credentials |
| `POST /facebook-ads-source/list-tables` | List Facebook Ads source tables |
| `POST /filesystem-dlt-source/check-credentials` | Check filesystem source credentials / bucket reachability |
| `POST /filesystem-dlt-source/list-tables` | List configured filesystem source resources |
| `POST /google-ads-source/list-tables` | List Google Ads source tables |
| `POST /hubspot-source/check-credentials` | Check HubSpot credentials |
| `POST /hubspot-source/list-tables` | List HubSpot source tables |
| `GET /hubspot-target/{connector_id}/properties` | Hubspot-Target:List-Properties |
| `POST /hubspot-target/{connector_id}/properties` | Hubspot-Target:Create-Property |
| `GET /hubspot-target/{connector_id}/property-groups` | Hubspot-Target:List-Property-Groups |
| `POST /ibmi-source/check-credentials` | Check IBM i credentials |
| `POST /ibmi-source/fetch-schema` | Fetch table schema |
| `POST /ibmi-source/list-tables` | List IBM i tables |
| `POST /iceberg-target/check-credentials` | Iceberg-Target:Check-Credentials |
| `POST /kafka-source/check-credentials` | Kafka-Source:Check-Credentials |
| `POST /kafka-source/fetch-messages` | Kafka-Source:Fetch-Messages |
| `POST /kafka-source/list-topics` | Kafka-Source:List-Topics |
| `POST /mssql-dlt-source/check-credentials` | Check SQL Server (batch) credentials |
| `POST /mssql-dlt-source/list-tables` | List SQL Server (batch) source tables |
| `POST /mssql-log-source/check-credentials` | Check SQL Server transaction-log source credentials |
| `POST /mssql-log-source/fetch-schema` | Fetch SQL Server table schema |
| `POST /mssql-log-source/list-tables` | List SQL Server tables readable from the transaction log |
| `POST /mssql-source/check-credentials` | Check Microsoft SQL Server credentials |
| `POST /mssql-source/fetch-schema` | Fetch SQL Server table schema |
| `POST /mssql-source/list-tables` | List SQL Server tables |
| `POST /mssql-target/check-credentials` | Mssql-Target:Check-Credentials |
| `POST /mysql-dlt-source/check-credentials` | Check MySQL (batch) credentials |
| `POST /mysql-dlt-source/list-tables` | List MySQL (batch) source tables |
| `POST /mysql-source/check-credentials` | Check MySQL credentials |
| `POST /mysql-source/fetch-schema` | Fetch MySQL table schema |
| `POST /mysql-source/list-tables` | List MySQL tables |
| `POST /oracle-dlt-source/check-credentials` | Check Oracle (batch) credentials |
| `POST /oracle-dlt-source/list-tables` | List Oracle (batch) source tables |
| `POST /oracle-source/check-credentials` | Check Oracle credentials |
| `POST /oracle-source/fetch-schema` | Fetch table schema |
| `POST /oracle-source/list-tables` | List Oracle tables |
| `POST /oracle-target/check-credentials` | Oracle-Target:Check-Credentials |
| `POST /pipedrive-source/check-credentials` | Check Pipedrive credentials |
| `POST /pipedrive-source/list-tables` | List Pipedrive source tables |
| `POST /postgres-dlt-source/check-credentials` | Check PostgreSQL (batch) credentials |
| `POST /postgres-dlt-source/list-tables` | List PostgreSQL (batch) source tables |
| `POST /postgres-source/check-credentials` | Check PostgreSQL credentials |
| `POST /postgres-source/fetch-schema` | Fetch table schema |
| `POST /postgres-source/list-tables` | List PostgreSQL tables |
| `POST /postgres-target/check-credentials` | Postgres-Target:Check-Credentials |
| `POST /salesforce-source/check-credentials` | Check Salesforce credentials |
| `POST /salesforce-source/list-tables` | List Salesforce SObjects |
| `POST /sharepoint-source/list-tables` | List SharePoint source tables |
| `POST /shopify-source/list-tables` | List Shopify source tables |
| `POST /snowflake-source/check-credentials` | Check Snowflake credentials |
| `POST /snowflake-source/list-tables` | List Snowflake tables |
| `POST /snowflake-target/check-credentials` | Snowflake-Target:Check-Credentials |
| `POST /snowflake-target/warehouses` | Snowflake-Target:List-Warehouses |
| `GET /snowflake-target/{connector_id}/schemas` | List the schemas a dynamic table can be built in |
| `POST /unity-catalog-target/check-credentials` | Unity-Catalog-Target:Check-Credentials |
| `POST /webhook-target/check-credentials` | Webhook-Target:Check-Credentials |
| `POST /zendesk-source/check-credentials` | Check Zendesk credentials |
| `POST /zendesk-source/list-tables` | List Zendesk source tables |

## Connector OAuth

| Endpoint | Purpose |
|---|---|
| `POST /connector-oauth/{provider}/exchange` | Exchange an OAuth authorization code |
| `POST /connector-oauth/{provider}/start` | Start an OAuth authorization flow |

## Schema registry

| Endpoint | Purpose |
|---|---|
| `POST /schemas/{subject}` | Act on a schema |

## Brokers

| Endpoint | Purpose |
|---|---|
| `POST /brokers/` | Create a broker |

## Kubernetes secrets

| Endpoint | Purpose |
|---|---|
| `GET /k8s-secrets` | List Kubernetes secrets available in the worker namespace |
| `GET /k8s-secrets/{name}/keys` | List keys inside a Kubernetes secret |

## Notifications

| Endpoint | Purpose |
|---|---|
| `GET /notifications/count` | Get the current user's unread notification count |

## Audit log

| Endpoint | Purpose |
|---|---|
| `GET /user-logs` | List audit log entrys |

## Health checks

| Endpoint | Purpose |
|---|---|
| `GET /healthchecks` | API liveness |
| `GET /healthchecks/broker` | Broker reachability |
| `GET /healthchecks/control-plane` | Control-plane reachability |
| `GET /healthchecks/db` | Database reachability |
| `GET /healthchecks/debug` | Aggregated debug health report |
| `GET /healthchecks/k8s` | Kubernetes API reachability |
| `GET /healthchecks/schema-registry` | Schema-registry reachability |

## Liveness probes

| Endpoint | Purpose |
|---|---|
| `GET /livez` | Liveness probe |
| `GET /readyz` | Readiness probe |

## Internal diagnostics

| Endpoint | Purpose |
|---|---|
| `POST /internal/heap-baseline` | Re-anchor the answering process's heap-growth window to now |
| `GET /internal/heap-growth` | Heap growth of the answering process since its baseline |
| `GET /internal/resource-metrics` | CPU/memory of the answering process |

## SMT jobs

| Endpoint | Purpose |
|---|---|
| `POST /smt/process_mapper` | Preview a single-message-transform mapper against sample records |
