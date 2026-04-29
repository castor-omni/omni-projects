select
  {{ dbt_utils.star(source('pharma', 'dim_channel')) }}
from {{ source('pharma', 'dim_channel') }}