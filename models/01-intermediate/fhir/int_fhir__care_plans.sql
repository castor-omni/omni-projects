select
  timestampadd(year, extract(year, current_date()) - 2016, start_ts) as start_ts,
  timestampadd(year, extract(year, current_date()) - 2016, end_ts) as end_ts,
  {{ dbt_utils.star(ref('stg_fhir__care_plans'), except=["start_ts", "end_ts"]) }}
from {{ ref('stg_fhir__care_plans') }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, start_ts)
    < current_date()