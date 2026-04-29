with base as (
  select * from {{ ref('stg_pharma__bridge_territory_physician') }}
),

anchor_asd as (
  select max(ASSIGNMENTSTARTDATE) as anchor_date from base
),

anchor_aed as (
  select max(ASSIGNMENTENDDATE) as anchor_date from base
)
select
  t.BRIDGEID as BRIDGEID,
  t.TERRITORYID as TERRITORYID,
  t.PHYSICIANID as PHYSICIANID,
  {{ pharma_shift_date('t.ASSIGNMENTSTARTDATE', 'anchor_asd.anchor_date') }} as ASSIGNMENTSTARTDATE,
  {{ pharma_shift_date('t.ASSIGNMENTENDDATE', 'anchor_aed.anchor_date') }} as ASSIGNMENTENDDATE
from base t
cross join anchor_asd
cross join anchor_aed