select
  {{ dbt_utils.star(ref('int_pharma__dim_product')) }}
from {{ ref('int_pharma__dim_product') }}