select
  {{ dbt_utils.star(source('pharma', 'dim_affiliation')) }}
from {{ source('pharma', 'dim_affiliation') }}