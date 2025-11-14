select
  {{ dbt_utils.star(source('saas', 'users')) }}
from {{ source('saas', 'users') }}