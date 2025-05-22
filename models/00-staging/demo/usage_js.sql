select
  {{ dbt_utils.star(source('demo', 'usage_js')) }}
from {{ source('demo', 'usage_js') }}