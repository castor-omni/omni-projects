with base as (
  select * from {{ ref('stg_pharma__dim_payer_formulary') }}
),

anchor_lud as (
  select max(LASTUPDATED) as anchor_date
  from base
),

anchor_efd as (
    select max(EFFECTIVEDATE) as anchor_date
    from base
),

anchor_exd as (
    select max(EXPIRATIONDATE) as anchor_date
    from base
)

select
  t.FORMULARYID as FORMULARYID,
  t.PAYER as PAYER,
  t.PLANNAME as PLANNAME,
  t.PRODUCTID as PRODUCTID,
  t.MARKETID as MARKETID,
  t.COVERAGESTATUS as COVERAGESTATUS,
  t.FORMULARYTIER as FORMULARYTIER,
  t.PRIORAUTHREQUIRED as PRIORAUTHREQUIRED,
  t.STEPTHERAPYREQUIRED as STEPTHERAPYREQUIRED,
  t.COPAY as COPAY,
  {{ pharma_shift_date('t.EFFECTIVEDATE', 'anchor_efd.anchor_date') }} as EFFECTIVEDATE,
  {{ pharma_shift_date('t.EXPIRATIONDATE', 'anchor_exd.anchor_date') }} as EXPIRATIONDATE,
  {{ pharma_shift_date('t.LASTUPDATED', 'anchor_lud.anchor_date') }} as LASTUPDATED,
  t.SOURCESYSTEM as SOURCESYSTEM
from base t
cross join anchor_efd
cross join anchor_exd
cross join anchor_lud