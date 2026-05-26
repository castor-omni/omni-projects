select
  {{ dbt_utils.star(source('pharma', 'fact_claim')) }}
from {{ source('pharma', 'fact_claim') }}