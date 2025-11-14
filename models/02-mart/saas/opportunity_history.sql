select * from {{ ref('stg_saas__opportunity_history') }}
WHERE created_date <= current_date