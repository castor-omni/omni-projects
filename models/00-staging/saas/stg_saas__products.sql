select
  {{ dbt_utils.star(source('saas', 'products')) }}
from {{ source('saas', 'products') }}