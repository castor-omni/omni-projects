/*
  Benchmark distribution statistics (mean, median, p25, p75, p90) for every
  combination of (segment, region, product_tier) via GROUPING SETS.

  NULL in a dimension column means "all values" for that dimension. With three
  3-value dimensions, this produces ~64 rows per snapshot_month (8 grouping
  combinations × up to 27 dimension combinations).

  No company-level rows or identifiers exist in this table. Pair it with
  fact_benchmark_stats to expose benchmark statistics in long form, or with a
  company-level metric fact to support "my company vs. peer distribution"
  comparisons.

  Distribution semantics for per-active-user-of-type metrics: companies
  with zero users of a given type contribute NULL, which AVG and
  PERCENTILE_CONT ignore. Stats represent "the distribution among companies
  with adoption of that user type," not the full population.

  No company-count suppression is applied (demo dataset).
*/


{{ config(
  enabled=false
) }}

with snapshots as (

    select *
    from {{ ref('company_usage') }}

    {% if is_incremental() %}
    where snapshot_month >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}

)

select
    snapshot_month,

    -- NULL means "all values" for that dimension
    segment as peer_group_segment,
    region as peer_group_region,
    product_tier as peer_group_product_tier,

    -- company count surfaced so consumers can flag thin cohorts
    count(*) as company_count,

    -- total users
    avg(total_users) as mean_total_users,
    median(total_users) as median_total_users,
    percentile_cont(0.25) within group (order by total_users) as p25_total_users,
    percentile_cont(0.75) within group (order by total_users) as p75_total_users,
    percentile_cont(0.90) within group (order by total_users) as p90_total_users,

    -- admin users
    avg(total_admin_users) as mean_admin_users,
    median(total_admin_users) as median_admin_users,
    percentile_cont(0.25) within group (order by total_admin_users) as p25_admin_users,
    percentile_cont(0.75) within group (order by total_admin_users) as p75_admin_users,
    percentile_cont(0.90) within group (order by total_admin_users) as p90_admin_users,

    -- creator users
    avg(total_creator_users) as mean_creator_users,
    median(total_creator_users) as median_creator_users,
    percentile_cont(0.25) within group (order by total_creator_users) as p25_creator_users,
    percentile_cont(0.75) within group (order by total_creator_users) as p75_creator_users,
    percentile_cont(0.90) within group (order by total_creator_users) as p90_creator_users,

    -- viewer users
    avg(total_viewer_users) as mean_viewer_users,
    median(total_viewer_users) as median_viewer_users,
    percentile_cont(0.25) within group (order by total_viewer_users) as p25_viewer_users,
    percentile_cont(0.75) within group (order by total_viewer_users) as p75_viewer_users,
    percentile_cont(0.90) within group (order by total_viewer_users) as p90_viewer_users,

    -- total events
    avg(total_events) as mean_total_events,
    median(total_events) as median_total_events,
    percentile_cont(0.25) within group (order by total_events) as p25_total_events,
    percentile_cont(0.75) within group (order by total_events) as p75_total_events,
    percentile_cont(0.90) within group (order by total_events) as p90_total_events,

    -- agentic events
    avg(total_agentic_events) as mean_agentic_events,
    median(total_agentic_events) as median_agentic_events,
    percentile_cont(0.25) within group (order by total_agentic_events) as p25_agentic_events,
    percentile_cont(0.75) within group (order by total_agentic_events) as p75_agentic_events,
    percentile_cont(0.90) within group (order by total_agentic_events) as p90_agentic_events,

    -- api events
    avg(total_api_events) as mean_api_events,
    median(total_api_events) as median_api_events,
    percentile_cont(0.25) within group (order by total_api_events) as p25_api_events,
    percentile_cont(0.75) within group (order by total_api_events) as p75_api_events,
    percentile_cont(0.90) within group (order by total_api_events) as p90_api_events,

    -- ui events
    avg(total_ui_events) as mean_ui_events,
    median(total_ui_events) as median_ui_events,
    percentile_cont(0.25) within group (order by total_ui_events) as p25_ui_events,
    percentile_cont(0.75) within group (order by total_ui_events) as p75_ui_events,
    percentile_cont(0.90) within group (order by total_ui_events) as p90_ui_events,

    -- admin / other events
    avg(total_admin_other_events) as mean_admin_other_events,
    median(total_admin_other_events) as median_admin_other_events,
    percentile_cont(0.25) within group (order by total_admin_other_events) as p25_admin_other_events,
    percentile_cont(0.75) within group (order by total_admin_other_events) as p75_admin_other_events,
    percentile_cont(0.90) within group (order by total_admin_other_events) as p90_admin_other_events,

    -- per-user rates
    avg(events_per_user) as mean_events_per_user,
    median(events_per_user) as median_events_per_user,
    percentile_cont(0.25) within group (order by events_per_user) as p25_events_per_user,
    percentile_cont(0.75) within group (order by events_per_user) as p75_events_per_user,
    percentile_cont(0.90) within group (order by events_per_user) as p90_events_per_user,

    avg(agentic_events_per_user) as mean_agentic_events_per_user,
    median(agentic_events_per_user) as median_agentic_events_per_user,
    percentile_cont(0.25) within group (order by agentic_events_per_user) as p25_agentic_events_per_user,
    percentile_cont(0.75) within group (order by agentic_events_per_user) as p75_agentic_events_per_user,
    percentile_cont(0.90) within group (order by agentic_events_per_user) as p90_agentic_events_per_user,

    avg(api_events_per_user) as mean_api_events_per_user,
    median(api_events_per_user) as median_api_events_per_user,
    percentile_cont(0.25) within group (order by api_events_per_user) as p25_api_events_per_user,
    percentile_cont(0.75) within group (order by api_events_per_user) as p75_api_events_per_user,
    percentile_cont(0.90) within group (order by api_events_per_user) as p90_api_events_per_user,

    avg(ui_events_per_user) as mean_ui_events_per_user,
    median(ui_events_per_user) as median_ui_events_per_user,
    percentile_cont(0.25) within group (order by ui_events_per_user) as p25_ui_events_per_user,
    percentile_cont(0.75) within group (order by ui_events_per_user) as p75_ui_events_per_user,
    percentile_cont(0.90) within group (order by ui_events_per_user) as p90_ui_events_per_user,

    avg(admin_other_events_per_user) as mean_admin_other_events_per_user,
    median(admin_other_events_per_user) as median_admin_other_events_per_user,
    percentile_cont(0.25) within group (order by admin_other_events_per_user) as p25_admin_other_events_per_user,
    percentile_cont(0.75) within group (order by admin_other_events_per_user) as p75_admin_other_events_per_user,
    percentile_cont(0.90) within group (order by admin_other_events_per_user) as p90_admin_other_events_per_user,

    -- per-active-user-of-type rates (NULL companies excluded)
    avg(admin_other_events_per_admin_user) as mean_admin_other_events_per_admin_user,
    median(admin_other_events_per_admin_user) as median_admin_other_events_per_admin_user,
    percentile_cont(0.25) within group (order by admin_other_events_per_admin_user) as p25_admin_other_events_per_admin_user,
    percentile_cont(0.75) within group (order by admin_other_events_per_admin_user) as p75_admin_other_events_per_admin_user,
    percentile_cont(0.90) within group (order by admin_other_events_per_admin_user) as p90_admin_other_events_per_admin_user,

    avg(agentic_events_per_creator_user) as mean_agentic_events_per_creator_user,
    median(agentic_events_per_creator_user) as median_agentic_events_per_creator_user,
    percentile_cont(0.25) within group (order by agentic_events_per_creator_user) as p25_agentic_events_per_creator_user,
    percentile_cont(0.75) within group (order by agentic_events_per_creator_user) as p75_agentic_events_per_creator_user,
    percentile_cont(0.90) within group (order by agentic_events_per_creator_user) as p90_agentic_events_per_creator_user,

    avg(ui_events_per_creator_user) as mean_ui_events_per_creator_user,
    median(ui_events_per_creator_user) as median_ui_events_per_creator_user,
    percentile_cont(0.25) within group (order by ui_events_per_creator_user) as p25_ui_events_per_creator_user,
    percentile_cont(0.75) within group (order by ui_events_per_creator_user) as p75_ui_events_per_creator_user,
    percentile_cont(0.90) within group (order by ui_events_per_creator_user) as p90_ui_events_per_creator_user,

    avg(ui_events_per_viewer_user) as mean_ui_events_per_viewer_user,
    median(ui_events_per_viewer_user) as median_ui_events_per_viewer_user,
    percentile_cont(0.25) within group (order by ui_events_per_viewer_user) as p25_ui_events_per_viewer_user,
    percentile_cont(0.75) within group (order by ui_events_per_viewer_user) as p75_ui_events_per_viewer_user,
    percentile_cont(0.90) within group (order by ui_events_per_viewer_user) as p90_ui_events_per_viewer_user
from snapshots
group by grouping sets (
    (snapshot_month, segment, region, product_tier),
    (snapshot_month, segment, region),
    (snapshot_month, segment, product_tier),
    (snapshot_month, region, product_tier),
    (snapshot_month, segment),
    (snapshot_month, region),
    (snapshot_month, product_tier),
    (snapshot_month)
)
