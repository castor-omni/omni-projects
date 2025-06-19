select
  timestampadd(year, extract(year, current_date()) - 2016, asserted_ts) as asserted_ts,
  {{ dbt_utils.star(ref('stg_fhir__allergies'), except=["asserted_ts"]) }}
from {{ ref('stg_fhir__allergies') }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, asserted_ts)
    < current_date()