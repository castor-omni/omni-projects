with base as (
  select * from {{ ref('stg_pharma__dim_product') }}
),
anchor as (
  select max(date_from_parts(LAUNCHDATE, 1, 1)) as anchor_date from base
)
select
  t.PRODUCTID as PRODUCTID,
  t.BRANDNAME as BRANDNAME,
  t.GENERICNAME as GENERICNAME,
  t.THERAPEUTICAREA as THERAPEUTICAREA,
  t.FORM as FORM,
  t.STRENGTH as STRENGTH,
  t.NDC as NDC,
  cast(
    extract(
      year from {{ pharma_shift_date('date_from_parts(t.LAUNCHDATE, 1, 1)', 'anchor.anchor_date') }}
    ) as number(38, 0)
  ) as LAUNCHDATE,
  t.MARKETID as MARKETID
from base t
cross join anchor