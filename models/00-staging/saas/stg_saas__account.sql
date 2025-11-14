{{ log("Current role: " ~ target.role, info=True) }}
{{ log("Current user: " ~ target.user, info=True) }}
{{ log("Current database: " ~ target.database, info=True) }}
{{ log("Current warehouse: " ~ target.warehouse, info=True) }}

select
  {{ dbt_utils.star(source('saas', 'account')) }}
from {{ source('saas', 'account') }}