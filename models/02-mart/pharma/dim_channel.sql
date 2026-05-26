select
  {{ dbt_utils.star(ref('stg_pharma__dim_channel')) }}
from {{ ref('stg_pharma__dim_channel') }}