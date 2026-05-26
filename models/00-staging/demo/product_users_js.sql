select
  {{ dbt_utils.star(source('demo', 'product_users_js')) }}
from {{ source('demo', 'product_users_js') }}