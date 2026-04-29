select
  {{ dbt_utils.star(ref('int_pharma__dim_sales_rep')) }}
from {{ ref('int_pharma__dim_sales_rep') }}