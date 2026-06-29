-- models/02-mart/saas/company_usage_metrics.sql

{{ config(materialized='incremental', unique_key=['account_id','snapshot_month','metric_id']) }}

{% set metrics = [
    'total_users', 'total_admin_users', 'total_creator_users', 'total_viewer_users',
    'total_events', 'total_agentic_events', 'total_api_events', 'total_ui_events', 'total_admin_other_events',
    'events_per_user', 'agentic_events_per_user', 'api_events_per_user', 'ui_events_per_user', 'admin_other_events_per_user',
    'admin_other_events_per_admin_user', 'agentic_events_per_creator_user',
    'ui_events_per_creator_user', 'ui_events_per_viewer_user'
] %}

with src as (
    select * from {{ ref('int_saas__company_usage') }}

    {% if is_incremental() %}
        where snapshot_month >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}
)

{% for m in metrics %}
select
    account_id,
    snapshot_month,
    segment,
    region,
    product_tier,
    '{{ m }}'::varchar      as metric_id,
    {{ m }}::float          as value
from src
{% if not loop.last %}union all{% endif %}
{% endfor %}