select
    timestampadd(year, extract(year, current_date()) - 2016, birth_date) as birth_date,
    timestampadd(year, extract(year, current_date()) - 2016, deceased_ts) as deceased_ts,
    {{ dbt_utils.star(ref("stg_fhir__patients"), except=["birth_date", "deceased_ts"]) }}
from {{ ref('stg_fhir__patients') }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, birth_date)
    < current_date()