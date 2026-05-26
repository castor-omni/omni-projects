select
  {{ dbt_utils.star(source('pharma', 'dim_physician')) }}
from {{ source('pharma', 'dim_physician') }}