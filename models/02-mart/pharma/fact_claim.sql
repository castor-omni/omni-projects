select
  {{ dbt_utils.star(ref('int_pharma__fact_claim')) }}
from {{ ref('int_pharma__fact_claim') }}