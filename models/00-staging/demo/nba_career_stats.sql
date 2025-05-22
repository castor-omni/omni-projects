select
  {{ dbt_utils.star(source('demo', 'nba_career_stats')) }}
from {{ source('demo', 'nba_career_stats') }}