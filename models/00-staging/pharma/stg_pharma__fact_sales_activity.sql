select
  {{ dbt_utils.star(source('pharma', 'fact_sales_activity')) }}
from {{ source('pharma', 'fact_sales_activity') }}