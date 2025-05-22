select
  {{ dbt_utils.star(source('demo', 'opportunity_line_item')) }}
from {{ source('demo', 'opportunity_line_item') }}