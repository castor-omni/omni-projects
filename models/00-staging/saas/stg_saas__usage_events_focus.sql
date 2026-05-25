select
  {{ dbt_utils.star(source('saas', 'usage_events_focus')) }}
from {{ source('saas', 'usage_events_focus') }}
