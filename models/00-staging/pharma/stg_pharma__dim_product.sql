select
  {{ dbt_utils.star(source('pharma', 'dim_product')) }}
from {{ source('pharma', 'dim_product') }}