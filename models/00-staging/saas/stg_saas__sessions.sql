select
  {{ dbt_utils.star(source('saas', 'sessions')) }}
from {{ source('saas', 'sessions') }}