WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    -- Dynamic offset to move 2025 data to 2026
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET 
)

SELECT
  -- Use REPLACE to swap the original CREATED_DATE with the shifted version
  * REPLACE (
      DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) AS CREATED_DATE
  )
FROM {{ ref('stg_saas__opportunity_line_items') }}
CROSS JOIN PARAMS P
-- Filter: Line items only appear once their shifted creation date has passed
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) <= P.AS_OF_DATE
ORDER BY CREATED_DATE DESC