select * from {{ ref('stg_saas__contacts')}}
where created_date <= current_date