WITH PARAMS AS (
  SELECT 
    CURRENT_TIMESTAMP() AS AS_OF_TS,
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET
)

SELECT
    "id" as ID
    , "account_id" as ACCOUNT_ID
    , "user_id" as USER_ID
    , "event_type" as EVENT_TYPE
    , "event_name" as EVENT_NAME
    -- Shifting the date and timestamp forward to 2026
    , DATEADD(MONTH, P.YEAR_OFFSET * 12, "event_date") AS EVENT_DATE
    , DATEADD(MONTH, P.YEAR_OFFSET * 12, "event_timestamp") AS EVENT_TIMESTAMP
    , "session_id" as SESSION_ID
    , "sequence_number" as SEQUENCE_NUMBER
    , "product_id" as PRODUCT_ID
    , "page_url" as PAGE_URL
    , "user_agent" as USER_AGENT
    , "ip_address" as IP_ADDRESS
    , "country" as COUNTRY
    , "region" as REGION
    , "city" as CITY
    , "device_type" as DEVICE_TYPE
    , "browser" as BROWSER
    , "os" as OS
    , "screen_resolution" as SCREEN_RESOLUTION
    , "referrer" as REFERRER
    , "utm_source" as UTM_SOURCE
    , "utm_medium" as UTM_MEDIUM
    , "utm_campaign" as UTM_CAMPAIGN
    , "account_segment" as ACCOUNT_SEGMENT
    , "product_tier" as PRODUCT_TIER
    , "user_count" as USER_COUNT
    , "user_role" as USER_ROLE
    , "feature_name" as FEATURE_NAME
    , "event_properties" as EVENT_PROPERTIES
FROM {{ ref('stg_saas__usage_events_focus') }}
CROSS JOIN PARAMS P
-- Filter so events "appear" in real-time as the clock ticks today in 2026
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, "event_timestamp") < P.AS_OF_TS
ORDER BY EVENT_DATE DESC