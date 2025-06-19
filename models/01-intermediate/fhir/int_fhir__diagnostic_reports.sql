select
  timestampadd(year, extract(year, current_date()) - 2016, effective_ts) as effective_ts,
  timestampadd(year, extract(year, current_date()) - 2016, issued_ts) as issued_ts,
  {{ dbt_utils.star(ref('stg_fhir__diagnostic_reports'), except=["effective_ts", "issued_ts"]) }}
from {{ ref('stg_fhir__diagnostic_reports') }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, issued_ts)
    < current_date()