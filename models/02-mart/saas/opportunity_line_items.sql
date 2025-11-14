select * from {{ ref('stg_saas__opportunity_line_items') }}
WHERE created_date <= current_date