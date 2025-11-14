-- don't judge, used chatgpt

WITH params AS (
  SELECT current_date() AS as_of_date
),
base_accounts AS (
  -- Only accounts that exist as of today
  SELECT *
  FROM {{ ref('stg_saas__account') }} a
  CROSS JOIN params p
  WHERE a.created_date <= p.as_of_date
),
history_asof AS (
  -- Latest history per account with effective date <= today
  SELECT *
  FROM (
    SELECT
      ah.*,
      COALESCE(ah.last_modified_date, ah.created_date) AS effective_date,
      ROW_NUMBER() OVER (
        PARTITION BY ah.account_id
        ORDER BY COALESCE(ah.last_modified_date, ah.created_date) DESC,
                 ah.created_date DESC
      ) AS rn
    FROM {{ ref('stg_saas__account_history') }} ah
    CROSS JOIN params p
    WHERE COALESCE(ah.last_modified_date, ah.created_date) <= p.as_of_date
  )
  WHERE rn = 1
)
SELECT
  -- Keep the exact original ACCOUNT schema & order
  a.id,
  a.name,
  /* TYPE rule:
     Prefer the as-of-today history value.
     Fall back to account.type only when no as-of history exists. */
  COALESCE(h.type, a.type) AS type,
  a.billing_street,
  a.billing_state,
  a.billing_city,
  a.billing_zip,
  a.billing_country,
  a.region,
  COALESCE(h.industry, a.industry) AS industry,
  CAST(COALESCE(h.annual_revenue, a.annual_revenue) AS INT)           AS annual_revenue,
  CAST(COALESCE(h.number_of_employees, a.number_of_employees) AS INT) AS number_of_employees,
  COALESCE(h.segment, a.segment) AS segment,
  COALESCE(h.owner_id, a.owner_id) AS owner_id,
  a.created_date
FROM base_accounts a
LEFT JOIN history_asof h
  ON h.account_id = a.id