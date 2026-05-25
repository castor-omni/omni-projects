select
  {{ dbt_utils.star(source('saas', 'users_detailed')) }}
from {{ source('saas', 'users_detailed') }}
