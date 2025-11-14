select * from {{ ref('stg_saas__sessions') }}
WHERE session_end_time < current_timestamp