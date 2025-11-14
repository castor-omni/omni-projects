
WITH params AS (
  SELECT current_date() AS as_of_date
),
base_opps AS (
  -- Only opportunities that exist as of today
  SELECT *
  FROM {{ ref('stg_saas__opportunities')}} o
  CROSS JOIN params p
  WHERE o.created_date <= p.as_of_date
),
closed_asof AS (
  -- Closed before today → keep the base row (explicit columns to match final schema)
  SELECT
    o.id,
    o.account_id,
    o.name,
    o.stage_name,
    o.amount,
    o.probability,
    o.close_date,
    o.type,
    o.next_steps,
    o.lead_source,
    o.is_won,
    o.forecast_category,
    o.owner_id,
    o.sales_engineer_id,
    o.created_date,
    o.contact_id,
    o.last_stage_change_date,
    o.first_demo_date,
    o.trial_start_date,
    o.competitor,
    o.loss_reason
  FROM base_opps o
  CROSS JOIN params p
  WHERE o.close_date IS NOT NULL
    AND o.close_date < p.as_of_date
),
open_asof AS (
  -- Not closed before today → candidate for history overlay
  SELECT *
  FROM base_opps o
  CROSS JOIN params p
  WHERE o.close_date IS NULL OR o.close_date >= p.as_of_date
),
latest_hist AS (
  -- Latest history row per opportunity on/before today
  -- If you have last_modified_date, prefer COALESCE(last_modified_date, created_date) in ORDER BY/WHERE
  SELECT *
  FROM (
    SELECT
      oh.*,
      ROW_NUMBER() OVER (
        PARTITION BY oh.opportunity_id
        ORDER BY oh.created_date DESC
      ) AS rn
    FROM {{ ref('stg_saas__opportunity_history') }} oh
    CROSS JOIN params p
    WHERE oh.created_date <= p.as_of_date
  )
  WHERE rn = 1
),
open_asof_overlay AS (
  -- Overlay history values where available; keep schema identical to `opportunities`
  SELECT
    o.id,
    o.account_id,
    COALESCE(h.name,               o.name)               AS name,
    COALESCE(h.stage_name,         o.stage_name)         AS stage_name,
    COALESCE(h.amount,             o.amount)             AS amount,
    COALESCE(h.probability,        o.probability)        AS probability,
    COALESCE(h.close_date,         o.close_date)         AS close_date,
    COALESCE(h.type,               o.type)               AS type,
    COALESCE(h.next_steps,         o.next_steps)         AS next_steps,
    COALESCE(h.lead_source,        o.lead_source)        AS lead_source,
    COALESCE(h.is_won,             o.is_won)             AS is_won,
    COALESCE(h.forecast_category,  o.forecast_category)  AS forecast_category,
    COALESCE(h.owner_id,           o.owner_id)           AS owner_id,
    COALESCE(h.sales_engineer_id,  o.sales_engineer_id)  AS sales_engineer_id,
    o.created_date,  -- creation gate already enforced (<= today)
    COALESCE(h.contact_id,         o.contact_id)         AS contact_id,
    COALESCE(h.last_stage_change_date, o.last_stage_change_date) AS last_stage_change_date,
    COALESCE(h.first_demo_date,    o.first_demo_date)    AS first_demo_date,
    COALESCE(h.trial_start_date,   o.trial_start_date)   AS trial_start_date,
    COALESCE(h.competitor,         o.competitor)         AS competitor,
    COALESCE(h.loss_reason,        o.loss_reason)        AS loss_reason
  FROM open_asof o
  LEFT JOIN latest_hist h
    ON h.opportunity_id = o.id
)
-- Same columns in the same order on both sides → no mismatch
SELECT * FROM closed_asof
UNION ALL
SELECT * FROM open_asof_overlay