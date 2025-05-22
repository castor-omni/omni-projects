select
  {{ dbt_utils.star(source('demo', 'nba_game_stats')) }}
from {{ source('demo', 'nba_game_stats') }}