select
  {{ dbt_utils.star(source('demo', 'product_images_staging')) }}
from {{ source('demo', 'product_images_staging') }}