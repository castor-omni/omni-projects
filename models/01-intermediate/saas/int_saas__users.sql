WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    -- Dynamic offset to move 2025 data to 2026
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET
)

SELECT
  ID
  , FIRST_NAME
  , LAST_NAME
  , EMAIL
  , ROLE
  , REGION
  , SEGMENT
  , MANAGER_ID
  , SE_ID
  , QUOTA_TARGET
  , QUOTA_2024
  , QUOTA_2025
  , QUOTA_2026
  , QUOTA_ATTAINMENT_PCT
  , PERFORMANCE_TIER
  -- Shift the creation date forward to 2026
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) AS CREATED_DATE
  -- Shift the ramp end date forward to stay logically consistent
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, RAMP_END_DATE) AS RAMP_END_DATE
FROM {{ ref('stg_saas__users') }}
CROSS JOIN PARAMS P
-- Only show users who have "been hired" by today in our new timeline
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) <= P.AS_OF_DATE