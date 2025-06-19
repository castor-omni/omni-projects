select
    {{
        dbt_utils.star(
            from=ref("stg_fhir__procedures"),
            except=["performed_ts", "performed_start_ts", "performed_end_ts"],
        )
    }},
    case when performed_ts is not null then true else false end as is_quick_procedure,
    timestampadd(year, extract(year, current_date()) - 2016, coalesce(performed_ts, performed_start_ts)) as performed_start_ts,
    timestampadd(year, extract(year, current_date()) - 2016, coalesce(performed_ts, performed_end_ts)) as performed_end_ts
from {{ ref("stg_fhir__procedures") }}
where 1=1
    and timestampadd(year, extract(year, current_date()) - 2016, performed_start_ts)
    < current_date()