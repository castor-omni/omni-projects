# Codex handoff prompt (paste this)

You're picking up a half-finished task. Read `omni/saas_benchmarking/HANDOFF.md` in
this repo (`/Users/todd/code/dbt-demo`) FIRST — it has the full context, verified IDs,
data shape, and the exact state. Summary:

We're building a SaaS usage **benchmarking** demo in Omni ("how does my company
compare to peers?") on top of 4 dbt models in `models/02-mart/saas/`
(`dim_metric`, `fact_company_usage_metrics`, `fact_benchmark_stats`,
`fact_company_percentile_rank`). The dbt side is done and pushed on branch `jess-2`.

Omni instance: https://omni.demo.exploreomni.dev (REST API base `/api/v1`,
`Authorization: Bearer $OMNI_API_TOKEN`). Shared model "Extension Models"
id `bbfe630c-a216-44b0-a0f8-c3e99cb98084`, default DB `ANALYTICS_PROD`; the tables
are in `ANALYTICS_PROD.SAAS` with views `saas__dim_metric`,
`saas__fact_company_usage_metrics`, `saas__fact_benchmark_stats`,
`saas__fact_company_percentile_rank`.

HARD CONSTRAINT: **do NOT modify the shared Omni model.** Work must stay in a
workbook, or a branch that is never merged. Do not merge anything to the shared
model without explicit approval.

What exists: a workbook "SaaS Usage Benchmarking — Company vs Peers (sandbox)"
(identifier `7f4fa0cc`) with 5 **raw-SQL** table tiles (SQL in
`omni/saas_benchmarking/tiles.sql`). The user wants **real Omni semantic views**
(measures/joins/topic), not raw SQL. The blocker: Omni's REST API can't write
workbook-scoped modeling — it's UI/IDE only. The ready-to-paste semantic-layer
YAML (real `saas__` view names) is in
`omni/saas_benchmarking/workbook_model_additions.yaml`.

DECISION NEEDED from the user before proceeding — ask which path:
  A) Paste `workbook_model_additions.yaml` into the Omni IDE on a NEW BRANCH
     (never merge → shared model untouched), then build the workbook off the branch.
  B) Re-express those measures/joins as Omni field-browser dialog inputs
     (Add measure / New join) so it stays purely workbook-scoped (no branch).
  C) Keep the raw-SQL workbook as-is and just polish it.

Helper: `omni/saas_benchmarking/omni_api.py` (set `OMNI_API_TOKEN` env var first;
the previously shared key should be rotated). It can run SQL, list models, get
documents, and get model YAML — use it to inspect/validate, not to touch the
shared model.

Pending polish (any path): distribution tile → bar chart, trend tile → line chart,
hide the `ORD` helper column, add account/metric filter controls, and (if wiring
RLS) fill `user_attributes.csv` with real account_id values.

Start by reading HANDOFF.md and workbook_model_additions.yaml, then ask me which
path (A/B/C) to take.
