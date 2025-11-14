select
  {{ dbt_utils.star(source('saas', 'opportunity_line_items')) }}
from {{ source('saas', 'opportunity_line_items') }}