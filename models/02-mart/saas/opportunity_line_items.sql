select * from {{ ref('stg_saas__opportunity_line_items') }}
WHERE CREATED_DATE <= current_date