WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    -- Dynamic offset: moves 2025 data to 2026
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET 
)

SELECT
  -- Identifiers
  ID,
  ACCOUNT_ID,
  
  -- Account Attributes
  TYPE,
  STATUS,
  INDUSTRY,
  ANNUAL_REVENUE,
  NUMBER_OF_EMPLOYEES,
  SEGMENT,
  OWNER_ID,
  CSM_ID,

  -- THE SHIFTED TIMELINE
  -- 1. When this specific snapshot record was created
  DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) AS CREATED_DATE,

  -- 2. When the account was last modified at the time of this record
  DATEADD(MONTH, P.YEAR_OFFSET * 12, LAST_MODIFIED_DATE) AS LAST_MODIFIED_DATE,

  -- 3. Churn Date logic
  -- If shifted churn is in the future, the account hasn't churned yet (NULL)
  IFF(
    DATEADD(MONTH, P.YEAR_OFFSET * 12, CHURN_DATE) > P.AS_OF_DATE,
    NULL,
    DATEADD(MONTH, P.YEAR_OFFSET * 12, CHURN_DATE)
  ) AS CHURN_DATE,

  CHURN_REASON

FROM {{ ref("stg_saas__account_history") }}
CROSS JOIN PARAMS P
WHERE 
  -- Snapshot must have been created by today in our 2026 timeline
  DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) <= P.AS_OF_DATE 
  AND (
    -- AND the modification must have logically happened by today
    LAST_MODIFIED_DATE IS NULL 
    OR DATEADD(MONTH, P.YEAR_OFFSET * 12, LAST_MODIFIED_DATE) <= P.AS_OF_DATE
  )
ORDER BY ID ASC, CREATED_DATE DESC