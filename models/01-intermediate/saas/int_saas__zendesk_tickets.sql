select * from {{ ref('stg_saas__zendesk_tickets') }}
WHERE created_date < current_date