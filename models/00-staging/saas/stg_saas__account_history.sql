{{ config(schema='demo') }}

select
  {{ dbt_utils.star(source('saas', 'account_history')) }}
from {{ source('saas', 'account_history') }}