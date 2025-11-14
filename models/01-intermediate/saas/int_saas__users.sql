select * from {{ ref('stg_saas__users')}}
where created_date <= current_date