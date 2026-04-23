select * from {{ ref('stg_saas__account_history')}}
WHERE LAST_MODIFIED_DATE <= current_date