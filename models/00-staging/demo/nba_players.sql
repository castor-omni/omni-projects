select
  {{ dbt_utils.star(source('demo', 'nba_players')) }}
from {{ source('demo', 'nba_players') }}