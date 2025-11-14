select
  {{ dbt_utils.star( source('asset_management', 'dim_assets') ) }}
from {{ source('asset_management', 'dim_assets') }}