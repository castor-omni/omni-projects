select
  {{ dbt_utils.star(source('saas', 'contacts')) }}
from {{ source('saas', 'contacts') }}