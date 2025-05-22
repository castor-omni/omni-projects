select
  {{ dbt_utils.star(source('demo', 'account')) }}
from {{ source('demo', 'account') }}