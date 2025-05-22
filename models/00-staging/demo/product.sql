select
  {{ dbt_utils.star(source('demo', 'product')) }}
from {{ source('demo', 'product') }}