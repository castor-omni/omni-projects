select
    timestampadd(year, extract(year, current_date()) - 2016, date_ts) as date_ts,
    {{ dbt_utils.star(ref("stg_fhir__immunizations"), except=["date_ts"]) }}
from {{ ref("stg_fhir__immunizations") }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, date_ts)
    < current_date()