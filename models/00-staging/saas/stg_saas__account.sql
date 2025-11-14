select {{ dbt_utils.star(source('saas', 'account')) }}
from {{ source('saas', 'account') }}