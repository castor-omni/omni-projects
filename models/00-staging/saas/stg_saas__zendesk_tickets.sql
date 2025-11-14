select
  {{ dbt_utils.star(source('saas', 'zendesk_tickets')) }}
from {{ source('saas', 'zendesk_tickets') }}