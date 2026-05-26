select
  {{ dbt_utils.star(source('demo', 'opp_js')) }}
from {{ source('demo', 'opp_js') }}