-- models/02-mart/saas/fact_company_percentile_rank.sql

{{ config(materialized='incremental', unique_key=[
    'account_id','snapshot_month','metric_id',
    'peer_group_segment','peer_group_region','peer_group_product_tier'
]) }}

{# All 18 metrics from dim_metric (same list as fact_company_usage_metrics).       #}
{# NULL handling: per-active-user-of-type rate metrics are NULL when a company     #}
{# had no active users of that type that month. Each metric's select below filters #}
{# `where <metric> is not null`, so cume_dist() ranks a company only among peers   #}
{# WITH adoption of that metric — matching the NULL-excluding stats in             #}
{# fact_benchmark_stats. Count metrics are never NULL, so the filter is a no-op    #}
{# for them (a genuine 0 still ranks at the bottom, as it should).                 #}
{% set metrics = [
    'total_users', 'total_admin_users', 'total_creator_users', 'total_viewer_users',
    'total_events', 'total_agentic_events', 'total_api_events', 'total_ui_events', 'total_admin_other_events',
    'events_per_user', 'agentic_events_per_user', 'api_events_per_user', 'ui_events_per_user', 'admin_other_events_per_user',
    'admin_other_events_per_admin_user', 'agentic_events_per_creator_user', 'ui_events_per_creator_user', 'ui_events_per_viewer_user'
] %}

{# Each cohort: (segment_expr, region_expr, product_tier_expr, partition_cols)        #}
{# Sentinel '__ALL__' marks a dimension that is rolled up (not in the partition).     #}
{% set cohorts = [
    ("'__ALL__'", "'__ALL__'", "'__ALL__'",  "snapshot_month"),
    ("segment",   "'__ALL__'", "'__ALL__'",  "snapshot_month, segment"),
    ("'__ALL__'", "region",    "'__ALL__'",  "snapshot_month, region"),
    ("'__ALL__'", "'__ALL__'", "product_tier","snapshot_month, product_tier"),
    ("segment",   "region",    "'__ALL__'",  "snapshot_month, segment, region"),
    ("segment",   "'__ALL__'", "product_tier","snapshot_month, segment, product_tier"),
    ("'__ALL__'", "region",    "product_tier","snapshot_month, region, product_tier"),
    ("segment",   "region",    "product_tier","snapshot_month, segment, region, product_tier")
] %}

{# Flatten metric × cohort so we only rely on loop.last #}
{% set combos = [] %}
{% for m in metrics %}
    {% for seg_expr, reg_expr, tier_expr, partition_cols in cohorts %}
        {% do combos.append((m, seg_expr, reg_expr, tier_expr, partition_cols)) %}
    {% endfor %}
{% endfor %}

with src as (

    select
        account_id,
        snapshot_month,
        segment,
        region,
        product_tier,
        {% for m in metrics %}
        {{ m }}{% if not loop.last %},{% endif %}
        {% endfor %}

    from {{ ref('company_usage') }}

    {% if is_incremental() %}
        where snapshot_month >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}

)

{% for m, seg_expr, reg_expr, tier_expr, partition_cols in combos %}
select
    account_id,
    snapshot_month,
    '{{ m }}'::varchar          as metric_id,
    {{ seg_expr }}::varchar     as peer_group_segment,
    {{ reg_expr }}::varchar     as peer_group_region,
    {{ tier_expr }}::varchar    as peer_group_product_tier,
    cume_dist() over (
        partition by {{ partition_cols }}
        order by {{ m }}
    )                           as percentile_rank
from src
where {{ m }} is not null
{% if not loop.last %}union all{% endif %}
{% endfor %}