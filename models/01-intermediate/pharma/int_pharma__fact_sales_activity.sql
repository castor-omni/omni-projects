with base as (
  select * from {{ ref('stg_pharma__fact_sales_activity') }}
), 

anchor as (
  select max(ACTIVITYDATE) as anchor_date from base
)
select
  t.SALESACTIVITYID as SALESACTIVITYID,
  t.SALESREPID as SALESREPID,
  t.PHYSICIANID as PHYSICIANID,
  t.GEOGRAPHYID as GEOGRAPHYID,
  t.PRODUCTID as PRODUCTID,
  t.ACTIVITYTYPE as ACTIVITYTYPE,
  t.CHANNELID as CHANNELID,
  {{ pharma_shift_date('t.ACTIVITYDATE', 'anchor.anchor_date') }} as ACTIVITYDATE,
  t.DURATIONMINUTES as DURATIONMINUTES,
  t.OUTCOME as OUTCOME,
  t.NOTES as NOTES
from base t
cross join anchor