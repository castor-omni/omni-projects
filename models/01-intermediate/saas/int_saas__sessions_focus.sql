WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET
)

SELECT
    "id" as ID,
    "account_id" as ACCOUNT_ID,
    "user_id" as USER_ID,
    "session_duration_seconds" as SESSION_DURATION_SECONDS,
    "session_duration_minutes" as SESSION_DURATION_MINUTES,
    "product_id" as PRODUCT_ID,
    "pages_visited" as PAGES_VISITED,
    "events_count" as EVENTS_COUNT,
    "unique_pages" as UNIQUE_PAGES,
    "bounce_rate" as BOUNCE_RATE,
    "exit_page" as EXIT_PAGE,
    "entry_page" as ENTRY_PAGE,
    "device_type" as DEVICE_TYPE,
    "browser" as BROWSER,
    "os" as OS,
    "country" as COUNTRY,
    "region" as REGION,
    "city" as CITY,
    "ip_address" as IP_ADDRESS,
    "user_agent" as USER_AGENT,
    "referrer" as REFERRER,
    "utm_source" as UTM_SOURCE,
    "utm_medium" as UTM_MEDIUM,
    "utm_campaign" as UTM_CAMPAIGN,
    "account_segment" as ACCOUNT_SEGMENT,
    "product_tier" as PRODUCT_TIER,
    "user_count" as USER_COUNT,
    "user_role" as USER_ROLE,
    "session_quality_score" as SESSION_QUALITY_SCORE,
    "errors_encountered" as ERRORS_ENCOUNTERED,
    "conversion_events" as CONVERSION_EVENTS,
    
    -- Shift the Date field
    DATEADD(MONTH, P.YEAR_OFFSET * 12, "session_date") AS SESSION_DATE,
    
    -- Shift the Timestamps
    DATEADD(MONTH, P.YEAR_OFFSET * 12, "session_start_time") AS SESSION_START_TIME,
    DATEADD(MONTH, P.YEAR_OFFSET * 12, "session_end_time") AS SESSION_END_TIME

FROM {{ ref('stg_saas__sessions_focus') }}
CROSS JOIN PARAMS P
-- Filter so sessions that haven't "happened yet" in our 2026 timeline are hidden
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, "session_start_time") < CURRENT_TIMESTAMP()
ORDER BY SESSION_DATE DESC