select
  {{ dbt_utils.star( source('asset_management', 'dim_portfolios') ) }}
from {{ source('asset_management', 'dim_portfolios') }}