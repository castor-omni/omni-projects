WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET 
)

SELECT 
    * REPLACE (
        -- 1. Shift Created Date (Original Logic)
        DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) AS CREATED_DATE,

        -- 2. Logic: If shifted Updated Date is in the future, cap it at TODAY
        IFF(
            DATEADD(MONTH, P.YEAR_OFFSET * 12, UPDATED_DATE) > P.AS_OF_DATE,
            P.AS_OF_DATE,
            DATEADD(MONTH, P.YEAR_OFFSET * 12, UPDATED_DATE)
        ) AS UPDATED_DATE,

        -- 3. Logic: If shifted Resolved Date is in the future, it's not resolved yet (NULL)
        IFF(
            DATEADD(MONTH, P.YEAR_OFFSET * 12, RESOLVED_DATE) > P.AS_OF_DATE,
            NULL,
            DATEADD(MONTH, P.YEAR_OFFSET * 12, RESOLVED_DATE)
        ) AS RESOLVED_DATE
    )
FROM {{ ref('stg_saas__jira_issues') }}
CROSS JOIN PARAMS P
-- Only show issues that have been 'created' in our 2026 timeline
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, CREATED_DATE) <= P.AS_OF_DATE
ORDER BY CREATED_DATE DESC