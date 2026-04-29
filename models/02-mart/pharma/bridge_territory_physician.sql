select
  {{ dbt_utils.star(ref('int_pharma__bridge_territory_physician')) }}
from {{ ref('int_pharma__bridge_territory_physician') }}