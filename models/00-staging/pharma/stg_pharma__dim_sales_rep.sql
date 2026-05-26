select
  {{ dbt_utils.star(source('pharma', 'dim_sales_rep')) }}
from {{ source('pharma', 'dim_sales_rep') }}