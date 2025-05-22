select
  {{ dbt_utils.star(source('demo', 'shipped_order_items')) }}
from {{ source('demo', 'shipped_order_items') }}