select
  {{ dbt_utils.star(ref('stg_pharma__dim_affiliation')) }}
from {{ ref('stg_pharma__dim_affiliation') }}