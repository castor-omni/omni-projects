select
  {{ dbt_utils.star(source('demo', 'contact')) }}
from {{ source('demo', 'contact') }}