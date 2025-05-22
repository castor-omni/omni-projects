select
  {{ dbt_utils.star(source('demo', 'customer_health')) }}
from {{ source('demo', 'customer_health') }}