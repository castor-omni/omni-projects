select
  {{ dbt_utils.star(source('pharma', 'dim_market')) }}
from {{ source('pharma', 'dim_market') }}