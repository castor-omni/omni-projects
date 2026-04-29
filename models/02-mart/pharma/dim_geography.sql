select
  {{ dbt_utils.star(ref('stg_pharma__dim_geography')) }}
from {{ ref('stg_pharma__dim_geography') }}