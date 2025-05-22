select
  {{ dbt_utils.star(source('demo', 'product_images')) }}
from {{ source('demo', 'product_images') }}