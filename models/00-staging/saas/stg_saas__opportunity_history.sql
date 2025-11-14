select
  {{ dbt_utils.star(source('saas', 'opportunity_history')) }}
from {{ source('saas', 'opportunity_history') }}