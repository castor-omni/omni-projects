select
  {{ dbt_utils.star(source('pharma', 'fact_prescription')) }}
from {{ source('pharma', 'fact_prescription') }}