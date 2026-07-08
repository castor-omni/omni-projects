WITH params AS (
    SELECT
        CURRENT_DATE()                AS as_of_date,
        (YEAR(CURRENT_DATE()) - 2025) AS year_offset,            -- kept ONLY to gate the population to "hired by now," preserving today's ~43-user set
        22                            AS new_count,              -- users to land in New
        27                            AS dormant_count,          -- users to land in Dormant
        30                            AS new_window_days,        -- New = joined within N days
        90                            AS dormant_threshold_days  -- Dormant = inactive for N+ days
),

-- Population gate: same users who are "hired by now," so Total Users stays put (~43).
population AS (
    SELECT s.*
    FROM {{ ref('stg_saas__users_detailed') }} s
    CROSS JOIN params p
    WHERE DATEADD(MONTH, p.year_offset * 12, s."created_date") <= p.as_of_date
),

-- Stable assignment. HASH(user_id) is deterministic, so a user keeps the same segment every run.
ranked AS (
    SELECT
        pop.*,
        ROW_NUMBER() OVER (ORDER BY HASH(pop."user_id")) AS seg_rank,
        ABS(HASH(pop."user_id", 17)) AS jitter_a,
        ABS(HASH(pop."user_id", 29)) AS jitter_b
    FROM population pop
),

segmented AS (
    SELECT
        r.*,
        p.as_of_date,
        p.dormant_threshold_days,
        CASE
            WHEN r.seg_rank <= p.new_count                   THEN 'New'
            WHEN r.seg_rank <= p.new_count + p.dormant_count THEN 'Dormant'
            ELSE 'Active'
        END AS demo_segment,
        -- Days since joining, banded by segment (always measured from today)
        CASE
            WHEN r.seg_rank <= p.new_count                   THEN 2   + MOD(r.jitter_a, p.new_window_days - 2)  -- 2..29 days ago
            WHEN r.seg_rank <= p.new_count + p.dormant_count THEN 200 + MOD(r.jitter_a, 400)                    -- 200..599 days ago
            ELSE                                                  120 + MOD(r.jitter_a, 400)                    -- 120..519 days ago
        END AS created_offset_days
    FROM ranked r
    CROSS JOIN params p
),

dated AS (
    SELECT
        sg.*,
        CASE
            WHEN demo_segment = 'New'
                THEN MOD(jitter_b, created_offset_days + 1)                                              -- 0..created (active, after joining)
            WHEN demo_segment = 'Dormant'
                THEN dormant_threshold_days + 5
                     + MOD(jitter_b, GREATEST(created_offset_days - dormant_threshold_days - 20, 30))    -- 95..(created-15), always >90 and after joining
            ELSE 1 + MOD(jitter_b, 25)                                                                   -- 1..25 days ago (active)
        END AS last_event_offset_days
    FROM segmented sg
)

SELECT
    "account_id"                  AS ACCOUNT_ID,
    last_event_offset_days        AS DAYS_SINCE_LAST_EVENT,     -- recomputed; the source value was stale after the date shift
    "department"                  AS DEPARTMENT,
    "email"                       AS EMAIL,
    -- Keep event counts honest for Dormant users so "active 150 days ago" isn't contradicted by recent-event totals
    CASE WHEN demo_segment = 'Dormant' THEN 0 ELSE "events_last_30d" END AS EVENTS_LAST_30D,
    CASE WHEN demo_segment = 'Dormant' THEN 0 ELSE "events_last_90d" END AS EVENTS_LAST_90D,
    "invited_by_user_id"          AS INVITED_BY_USER_ID,
    "is_admin"                    AS IS_ADMIN,
    "license_type"                AS LICENSE_TYPE,
    "lifecycle_stage"             AS LIFECYCLE_STAGE,
    "location"                    AS LOCATION,
    "manager_id"                  AS MANAGER_ID,
    "name"                        AS NAME,
    "onboarding_completed"        AS ONBOARDING_COMPLETED,
    "onboarding_steps_completed"  AS ONBOARDING_STEPS_COMPLETED,
    "role"                        AS ROLE,
    "signup_source"               AS SIGNUP_SOURCE,
    "status"                      AS STATUS,
    "timezone"                    AS TIMEZONE,
    "title"                       AS TITLE,
    "total_events_lifetime"       AS TOTAL_EVENTS_LIFETIME,
    "total_sessions_lifetime"     AS TOTAL_SESSIONS_LIFETIME,
    "user_id"                     AS USER_ID,
    demo_segment                  AS DEMO_SEGMENT,              -- optional helper column for the tabs
    -- All dates anchored to CURRENT_DATE(), so the demo stays live every day it runs
    DATEADD(DAY, -created_offset_days,    as_of_date) AS CREATED_DATE,
    DATEADD(DAY, -last_event_offset_days, as_of_date) AS LAST_EVENT_DATE,
    DATEADD(DAY, -last_event_offset_days, as_of_date) AS UPDATED_DATE,
    DATEADD(DAY, -created_offset_days,    as_of_date) AS ACTIVATED_DATE
FROM dated