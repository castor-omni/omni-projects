select
  {{ dbt_utils.star(source('demo', 'opportunity')) }}
from {{ source('demo', 'opportunity') }}