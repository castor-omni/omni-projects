select
  {{ dbt_utils.star(source('demo', 'product_usage')) }}
from {{ source('demo', 'product_usage') }}