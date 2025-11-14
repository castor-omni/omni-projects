select * from {{ ref('stg_saas__usage_events') }}
WHERE event_timestamp < current_timestamp