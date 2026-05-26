select
  {{ dbt_utils.star(source('pharma', 'bridge_territory_physician')) }}
from {{ source('pharma', 'bridge_territory_physician') }}