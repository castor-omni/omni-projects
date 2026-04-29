with base as (
  select * from {{ ref('stg_pharma__dim_market') }}
),

anchor as (
  select coalesce(max(LAUNCHYEAR), extract(year from current_date())) as max_launch_year
  from base
)
select
  t.MARKETID as MARKETID,
  t.MARKETNAME as MARKETNAME,
  t.THERAPEUTICAREA as THERAPEUTICAREA,
  t.PRIMARYCOMPETITORS as PRIMARYCOMPETITORS,
  (t.LAUNCHYEAR + (extract(year from current_date()) - anchor.max_launch_year)) as LAUNCHYEAR,
  t.MARKETSIZEUSD as MARKETSIZEUSD,
  t.LIFECYCLESTAGE as LIFECYCLESTAGE
from base t
cross join anchor