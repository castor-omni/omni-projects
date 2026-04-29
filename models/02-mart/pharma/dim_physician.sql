select
  {{ dbt_utils.star(ref('stg_pharma__dim_physician')) }}
from {{ ref('stg_pharma__dim_physician') }}