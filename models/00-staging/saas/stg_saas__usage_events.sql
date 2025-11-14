select
  {{ dbt_utils.star(source('saas', 'usage_events')) }}
from {{ source('saas', 'usage_events') }}