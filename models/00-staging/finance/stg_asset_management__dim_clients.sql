select
  {{ dbt_utils.star( source('asset_management', 'dim_clients') ) }}
from {{ source('asset_management', 'dim_clients') }}