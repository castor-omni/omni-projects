# SaaS Usage Benchmarking — Omni model bundle

Surfaces the four dbt models in `models/02-mart/saas/` as an Omni benchmarking
experience: **"how does my company compare to my peers?"**

| Source table (ANALYTICS_PROD.SAAS) | View | RLS |
|---|---|---|
| `dim_metric` | `views/dim_metric.view` | open (shared dim) |
| `fact_company_usage_metrics` | `views/fact_company_usage_metrics.view` | **restricted** by `account_id` |
| `fact_company_percentile_rank` | `views/fact_company_percentile_rank.view` | **restricted** by `account_id` |
| `fact_benchmark_stats` | `views/fact_benchmark_stats.view` | **open** (no identifiers) |

## Topics
- **`saas_company_benchmark`** (hero) — base `fact_company_percentile_rank`, joined to the metric catalog, the company's own value, and the peer distribution. The one-stop "me vs. peers." Restricted.
- **`saas_peer_benchmarks`** — base `fact_benchmark_stats`. Anonymized peer distributions. Open.
- **`saas_company_usage`** — base `fact_company_usage_metrics`. My own usage over time. Restricted.

## Design notes
- **Long-form facts** (`metric_id` + `value`) are modeled with **generic measures + a metric filter** (pick `dim_metric.name`), not 18 named measures — so the me-vs-peer comparison works uniformly for any metric.
- **Pre-computed stats** (`statistic = mean|p25|p50|p75|p90`) are surfaced as **filtered `max()` measures** — cheap and fan-out-safe.
- Every view has a **`primary_key`** (composite where needed) so Omni's symmetric aggregates dedup the hero topic's fan-in/fan-out joins correctly.

## Deploy (Omni CLI)
Requires `OMNI_API_TOKEN` + the model ID. **View-name prefix:** these files assume
the schema-layer view name equals the table name. If your connection prefixes
views with the schema (check the IDE file tree, e.g. `saas__fact_...`), prepend
that prefix everywhere in `relationships` and the topics first.

1. `omni models get-schemas <model_id> -o json` → confirm the `ANALYTICS_PROD.SAAS` schema name / view prefix.
2. `omni models create-branch <model_id> --name demo-saas-benchmark -o json` → capture branch UUID from `.model.id`.
3. `omni models yaml-create <model_id> --body '{...}'` for each file:
   - views: `fileName: "<schema>/<view>.view"`, `mode: "extension"`
   - topics + `relationships`: push at root (no prefix), `mode: "extension"`
4. `omni models validate <model_id> --branchid <UUID> -o json` → fix any `is_warning:false` issues.
5. Open the branch IDE link, review, **merge in the UI** (deploy never auto-merges).

## RLS wiring (currently a manual UI step)
The `access_filters` YAML above is correct per Omni docs, but the demo pipeline
has historically wired RLS by hand because some RLS YAML was rejected on push.
If validate rejects the `access_filters`, do this instead:
1. **Settings → Attributes** → new attribute `account_id` (reference name `account_id`).
2. **Settings → Attributes → Upload** `user_attributes.csv` (fill in real values first).
3. Assign each demo user/persona their `account_id` value (use `__ALL__` for the admin bypass).
4. Demo by impersonating users — restricted topics change per company; the peer benchmark stays constant.

## Before the demo
- The hero topic is incremental upstream — make sure `fact_company_percentile_rank`
  was rebuilt with `--full-refresh` after the `cume_dist()` change so old rows aren't stale.
- Fill `user_attributes.csv` with **real `account_id` values** from the data.
- Consider a `peer_company_count` minimum filter before showing benchmarks for thin cohorts.
