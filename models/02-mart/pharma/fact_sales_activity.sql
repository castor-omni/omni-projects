select
  {{ dbt_utils.star(ref('int_pharma__fact_sales_activity')) }}
from {{ ref('int_pharma__fact_sales_activity') }}