select
  {{ dbt_utils.star(ref('stg_asset_management__dim_clients')) }}
from {{ ref('stg_asset_management__dim_clients') }}