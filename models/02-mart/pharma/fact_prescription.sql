select
  {{ dbt_utils.star(ref('int_pharma__fact_prescription')) }}
from {{ ref('int_pharma__fact_prescription') }}