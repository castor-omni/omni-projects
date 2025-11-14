select
  {{ dbt_utils.star( source('asset_management', 'fct_transactions') ) }}
from {{ source('asset_management', 'fct_transactions') }}