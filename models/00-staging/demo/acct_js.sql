select
  {{ dbt_utils.star(source('demo', 'acct_js')) }}
from {{ source('demo', 'acct_js') }}