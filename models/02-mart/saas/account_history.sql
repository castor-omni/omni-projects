select * from {{ ref('stg_saas__account_history')}}
WHERE last_modified_date <= current_date