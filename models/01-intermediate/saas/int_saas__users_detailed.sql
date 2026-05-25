WITH PARAMS AS (
  SELECT 
    CURRENT_DATE() AS AS_OF_DATE,
    -- Dynamic offset to move 2025 data to 2026
    (YEAR(CURRENT_DATE()) - 2025) AS YEAR_OFFSET
)

SELECT
    "account_id" AS ACCOUNT_ID,
    "days_since_last_event" AS DAYS_SINCE_LAST_EVENT,
    "department" AS DEPARTMENT,
    "email" AS EMAIL,
    "events_last_30d" AS EVENTS_LAST_30D,
    "events_last_90d" AS EVENTS_LAST_90D,
    "invited_by_user_id" AS INVITED_BY_USER_ID,
    "is_admin" AS IS_ADMIN,
    "license_type" AS LICENSE_TYPE,
    "lifecycle_stage" AS LIFECYCLE_STAGE,
    "location" AS LOCATION,
    "manager_id" AS MANAGER_ID,
    "name" AS NAME,
    "onboarding_completed" AS ONBOARDING_COMPLETED,
    "onboarding_steps_completed" AS ONBOARDING_STEPS_COMPLETED,
    "role" AS ROLE,
    "signup_source" AS SIGNUP_SOURCE,
    "status" AS STATUS,
    "timezone" AS TIMEZONE,
    "title" AS TITLE,
    "total_events_lifetime" AS TOTAL_EVENTS_LIFETIME,
    "total_sessions_lifetime" AS TOTAL_SESSIONS_LIFETIME,
    "user_id" AS USER_ID
  -- Shift the creation date forward to 2026
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, "created_date") AS CREATED_DATE
  -- Shift the update  date forward to stay logically consistent
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, "updated_date") AS UPDATED_DATE
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, "activated_date") AS ACTIVATED_DATE
  , DATEADD(MONTH, P.YEAR_OFFSET * 12, "last_event_date") AS LAST_EVENT_DATE,

FROM {{ ref('stg_saas__users_detailed') }}
CROSS JOIN PARAMS P
-- Only show users who have "been hired" by today in our new timeline
WHERE DATEADD(MONTH, P.YEAR_OFFSET * 12, "created_date") <= P.AS_OF_DATE