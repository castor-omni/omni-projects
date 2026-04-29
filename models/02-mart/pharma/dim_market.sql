select
  {{ dbt_utils.star(ref('stg_pharma__dim_market')) }}
from {{ ref('stg_pharma__dim_market') }}