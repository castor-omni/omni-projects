# SaaS Usage Benchmarking — Omni handoff

Context for continuing this work in another agent/session. Everything here is verified against the live instance unless marked TODO.

## Goal
A SaaS product-usage **benchmarking** demo for Omni: "how does my company compare to peers?" Built on the `dbt-demo` repo. Surface the 4 new dbt models as an Omni experience: a company's own values, its percentile rank within a peer group, and the anonymized peer distribution (P25/median/P75/P90/mean).

## Hard constraint from the user
**Do NOT modify the shared Omni model** (it's a shared SE-team instance). Work must live in a **workbook** (or a branch that is never merged). Do not merge anything to the shared/production model without explicit approval. The user is an Omni SE and knows the UI.

## dbt side (DONE)
- Repo: `/Users/todd/code/dbt-demo`, branch **`jess-2`** (pushed). Models in `models/02-mart/saas/`.
- 4 models: `dim_metric` (18-metric catalog), `fact_company_usage_metrics` (company's own values, long form), `fact_benchmark_stats` (anonymized peer distribution, **no account_id**), `fact_company_percentile_rank` (rank within peer group).
- Change already made + pushed (commit `df5493e`): `fact_company_percentile_rank` now uses **`cume_dist()`** instead of `percent_rank()` (+ schema doc updated). Built & tested green in dbt Studio.
- RLS-aware by design: the 2 company facts carry `account_id` (restrict via access_filter); the benchmark table has no identifiers (open). `company_count` is in benchmark_stats for k-anonymity but NOT enforced.

## Omni environment (verified)
- Instance: `https://omni.demo.exploreomni.dev` — API base `…/api/v1`, auth header `Authorization: Bearer <token>`.
- **Shared model = "Extension Models"**, id `bbfe630c-a216-44b0-a0f8-c3e99cb98084`, on connection "Snowflake" (`c50411c5-41a2-4a7c-b0dd-27e0d78586f4`, dialect snowflake, **default DB `ANALYTICS_PROD`**).
- The 4 dbt tables are live in **`ANALYTICS_PROD.SAAS`**. Row counts: dim_metric 18, fact_company_usage_metrics 116,172, fact_benchmark_stats 106,200, fact_company_percentile_rank 258,160.
- Auto-generated Omni view names (extension mode): **`saas__dim_metric`, `saas__fact_company_usage_metrics`, `saas__fact_benchmark_stats`, `saas__fact_company_percentile_rank`**. Dimensions are the lowercased column names (e.g. `metric_id`, `value`, `percentile_rank`, `statistic`, `peer_group_segment`, …).

## Data shape (verified)
- 351 companies; segments **Enterprise / Mid-Market / SMB**; regions **APAC / EMEA / North America**; product_tier **only "Starter"** (tier cohorts are degenerate — lean on segment × region).
- 39 months, ~2023-03 → **2026-05** (latest complete month; current month correctly excluded).
- 18 metrics by category: **5 event-counts** (`total_events`, `total_agentic_events`, `total_api_events`, `total_ui_events`, `total_admin_other_events`), **9 rates** (`events_per_user`, … `ui_events_per_viewer_user`), **4 user-counts** (`total_users`, `total_admin_users`, `total_creator_users`, `total_viewer_users`).
- `fact_company_percentile_rank` now ranks **all 18 metrics** (changed from the original 5 event-counts). Rate metrics that can be NULL (a company with no active users of a given type) are filtered per metric (`where <metric> is not null`) before `cume_dist()`, so a company is ranked only among peers WITH adoption — matching the NULL-excluding stats in `fact_benchmark_stats`. Count metrics are never NULL (a 0 ranks at the bottom). **Needs a `dbt build --select fact_company_percentile_rank --full-refresh`** to take effect; row count grows ~3.6× (was 258,160 for 5 metrics). `my_percentile` now works for every metric.
- Peer-group cohorts use sentinel `'__ALL__'` for rolled-up dimensions; 8 cohort shapes exist and match between benchmark_stats and percentile_rank.
- **Featured company for the demo: "Yield Path"**, account_id `001xx000003E4A09CAAG` (Enterprise / North America). Story: ~99th pct vs all companies but ~94th within its Enterprise/N.America peer set; AI usage crosses above peer median mid-trend. (Company names: `ANALYTICS_PROD.SAAS.ACCOUNT.id = account_id`, `.name`.)

## What was actually built in Omni (DONE)
A workbook: **"SaaS Usage Benchmarking — Company vs Peers (sandbox)"**
- identifier **`7f4fa0cc`** → `https://omni.demo.exploreomni.dev/dashboards/7f4fa0cc`
- workbook's own model id (`modelKind: WORKBOOK`, base `bbfe630c`): **`d0e62ea8-774b-4954-97de-eccb8ae49b6c`** (same as workbook.id)
- 5 **raw-SQL table tiles** (SQL in `tiles.sql`). Shared model untouched.

### Why raw SQL (the key limitation)
Omni's REST API **cannot** create workbook-scoped views/measures/joins/topics — that semantic layer is **UI/IDE-only**. The Documents API treats the workbook model as server-owned. So an API-only, workbook-only implementation forced raw SQL. To get **real Omni semantic views**, the YAML must be pasted in the IDE (which edits the *shared* model — so use a **branch**), or the modeling must be done via the workbook's field-browser dialogs (Add measure / New join).

## Open decision (this is where we stopped)
The user wants real Omni views, not SQL. Three paths:
- **A (recommended): branch of the shared model.** Paste `workbook_model_additions.yaml` into the IDE on a NEW branch, build the workbook off the branch, never merge → shared model stays untouched until/unless promoted. Only true copy-paste path.
- **B: pure workbook, field-browser dialogs.** Re-express the measures/joins as Add-measure / New-join dialog inputs (no YAML paste). Strictly never touches shared model, even on a branch.
- **C: keep the raw-SQL workbook** that already exists (`7f4fa0cc`).

## Pending polish (if continuing)
- Convert the distribution tile → bar chart, trend tile → line chart (raw-SQL tiles are tables now).
- Hide the `ORD` sort-helper column in the distribution tile.
- Add filter controls (account / metric pickers) for live demoing.
- Fill `user_attributes.csv` with real `account_id` values if wiring RLS.

## Files in this folder
- `HANDOFF.md` — this file.
- `workbook_model_additions.yaml` — **the real-name semantic-layer YAML to paste** (measures + PKs per view, relationships, topic). Uses `saas__*` view names. ← primary artifact for paths A/B.
- `tiles.sql` — the 5 validated raw-SQL tile queries (path C / reference).
- `omni_api.py` — Python helper to drive the Omni REST API (token via `OMNI_API_TOKEN` env var). Has working examples: run SQL, list models, get model YAML, create/get documents.
- `views/`, `relationships`, `topics/`, `user_attributes.csv`, `README.md` — an EARLIER draft of the **shared-model full-deploy** bundle (full view files with placeholder table-name view names). Reference only; `workbook_model_additions.yaml` supersedes it for the workbook/branch route.

## Security
- The Omni API key was shared in plaintext chat — **rotate it.** Do not commit any token. `omni_api.py` reads `OMNI_API_TOKEN` from env.
