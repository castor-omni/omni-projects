select
  {{ dbt_utils.star(source('demo', 'account_history')) }}
from {{ source('demo', 'account_history') }}