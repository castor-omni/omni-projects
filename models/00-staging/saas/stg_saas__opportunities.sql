select
  {{ dbt_utils.star(source('saas', 'opportunities')) }}
from {{ source('saas', 'opportunities') }}