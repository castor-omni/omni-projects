with base as (
  select * from {{ ref('stg_pharma__dim_sales_rep') }}
),

anchor_sd as (
  select max(STARTDATE) as anchor_date from base
),

anchor_ed as (
  select max(ENDDATE) as anchor_date from base
)

select
  t.SALESREPID as SALESREPID,
  t.SALESREPNAME as SALESREPNAME,
  t.ROLE as ROLE,
  t.EMAIL as EMAIL,
  t.PHONE as PHONE,
  {{ pharma_shift_date('t.STARTDATE', 'anchor_sd.anchor_date') }} as STARTDATE,
  {{ pharma_shift_date('t.ENDDATE', 'anchor_ed.anchor_date') }} as ENDDATE,
  t.GEOGRAPHYID as GEOGRAPHYID,
  t.MANAGERID as MANAGERID
from base t
cross join anchor_sd
cross join anchor_ed