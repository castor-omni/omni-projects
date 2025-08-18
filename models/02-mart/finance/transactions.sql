select
  {{ dbt_utils.star(ref('stg_asset_management__fct_transactions')) }}
from {{ ref('stg_asset_management__fct_transactions') }}