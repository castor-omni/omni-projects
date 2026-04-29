with base as (
  select * from {{ ref('stg_pharma__fact_prescription') }}
),
anchor as (
  select max("DATE") as anchor_date from base
)
select
  t.PRESCRIPTIONID as PRESCRIPTIONID,
  t.PHYSICIANID as PHYSICIANID,
  t.PRODUCTID as PRODUCTID,
  t.MARKETID as MARKETID,
  t.CHANNELID as CHANNELID,
  t.GEOGRAPHYID as GEOGRAPHYID,
  {{ pharma_shift_date('t."DATE"', 'anchor.anchor_date') }} as "DATE",
  t.NRX as NRX,
  t.TRX as TRX,
  t.NBRX as NBRX,
  t.REPEATS as REPEATS,
  t.PAYERTYPE as PAYERTYPE,
  t.SOURCESYSTEM as SOURCESYSTEM
from base t
cross join anchor