select
  {{ dbt_utils.star(source('pharma', 'dim_payer_formulary')) }}
from {{ source('pharma', 'dim_payer_formulary') }}