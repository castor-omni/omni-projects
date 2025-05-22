select
  {{ dbt_utils.star(source('demo', 'users_js')) }}
from {{ source('demo', 'users_js') }}