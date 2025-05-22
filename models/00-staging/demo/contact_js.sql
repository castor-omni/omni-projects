select
  {{ dbt_utils.star(source('demo', 'contact_js')) }}
from {{ source('demo', 'contact_js') }}