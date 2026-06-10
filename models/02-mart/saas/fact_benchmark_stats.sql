-- models/02-mart/saas/fact_benchmark_stats.sql

{{ config(materialized='incremental', unique_key=[
    'snapshot_month','peer_group_segment','peer_group_region','peer_group_product_tier','metric_id','statistic'
, enabled=false
) }}

{# (canonical metric_id, suffix as it appears in usage_benchmarks) #}
{% set metrics = [
    ('total_users',                       'total_users'),
    ('total_admin_users',                 'admin_users'),
    ('total_creator_users',               'creator_users'),
    ('total_viewer_users',                'viewer_users'),
    ('total_events',                      'total_events'),
    ('total_agentic_events',              'agentic_events'),
    ('total_api_events',                  'api_events'),
    ('total_ui_events',                   'ui_events'),
    ('total_admin_other_events',          'admin_other_events'),
    ('events_per_user',                   'events_per_user'),
    ('agentic_events_per_user',           'agentic_events_per_user'),
    ('api_events_per_user',               'api_events_per_user'),
    ('ui_events_per_user',                'ui_events_per_user'),
    ('admin_other_events_per_user',       'admin_other_events_per_user'),
    ('admin_other_events_per_admin_user', 'admin_other_events_per_admin_user'),
    ('agentic_events_per_creator_user',   'agentic_events_per_creator_user'),
    ('ui_events_per_creator_user',        'ui_events_per_creator_user'),
    ('ui_events_per_viewer_user',         'ui_events_per_viewer_user')
] %}

{# (canonical statistic, column prefix as it appears in usage_benchmarks) #}
{% set statistics = [
    ('mean',   'mean'),
    ('p25',    'p25'),
    ('p50',    'median'),
    ('p75',    'p75'),
    ('p90',    'p90')
] %}

{% set pairs = [] %}
{% for metric_id, bench_suffix in metrics %}
    {% for stat_id, stat_prefix in statistics %}
        {% do pairs.append((metric_id, bench_suffix, stat_id, stat_prefix)) %}
    {% endfor %}
{% endfor %}

with src as (
    select * from {{ ref('usage_benchmarks') }}

    {% if is_incremental() %}
        where snapshot_month >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}
),

normalized as (
    select
        snapshot_month,
        coalesce(peer_group_segment,      '__ALL__') as peer_group_segment,
        coalesce(peer_group_region,       '__ALL__') as peer_group_region,
        coalesce(peer_group_product_tier, '__ALL__') as peer_group_product_tier,
        company_count,
        * exclude (snapshot_month, peer_group_segment, peer_group_region,
                   peer_group_product_tier, company_count)
    from src
)

{% for metric_id, bench_suffix, stat_id, stat_prefix in pairs %}
select
    snapshot_month,
    peer_group_segment,
    peer_group_region,
    peer_group_product_tier,
    '{{ metric_id }}'::varchar              as metric_id,
    '{{ stat_id }}'::varchar                as statistic,
    {{ stat_prefix }}_{{ bench_suffix }}::float as value,
    company_count
from normalized
{% if not loop.last %}union all{% endif %}
{% endfor %}