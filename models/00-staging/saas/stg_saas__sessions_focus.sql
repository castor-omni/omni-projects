select
  {{ dbt_utils.star(source('saas', 'sessions_focus')) }}
from {{ source('saas', 'sessions_focus') }}
