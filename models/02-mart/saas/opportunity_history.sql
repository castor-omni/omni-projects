select * from {{ ref('stg_saas__opportunity_history') }}
WHERE CREATED_DATE <= current_date