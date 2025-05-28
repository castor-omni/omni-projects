select
  {{ dbt_utils.star(source('demo', 'user_js')) }}
from {{ source('demo', 'user_js') }}