select
  {{ dbt_utils.star(source('demo', 'users')) }}
from {{ source('demo', 'users') }}