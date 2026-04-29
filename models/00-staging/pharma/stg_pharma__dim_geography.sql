select
  {{ dbt_utils.star(source('pharma', 'dim_geography')) }}
from {{ source('pharma', 'dim_geography') }}