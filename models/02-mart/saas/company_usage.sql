/*
  One row per (account_id, snapshot_month) with monthly usage metrics.

  Notes on semantics:
  - user_type is derived from user_role:
      Admin       -> Admin
      Builder, DE -> Creator
      Analyst, V  -> Viewer
      (anything else falls through; currently no Other bucket is materialized)
  - Active-in-role semantics: a user counted in admin/creator/viewer reflects
    whether they were active *in that role* during the month. Buckets can sum
    to MORE than total_users for users who held multiple roles in the month.
  - Per-total-user metrics divide by total active users in the month.
  - Per-active-user-of-type metrics divide by the count of active users of
    that specific type. NULL when that user type was not active that month;
    AVG/PERCENTILE_CONT downstream will ignore those nulls, yielding "among
    companies with adoption of this type" distribution semantics.
  - Current in-progress month is excluded.
*/

with events as (

    select
        account_id,
        user_id,
        session_id,
        event_type,
        id                                       as event_id,
        date_trunc('month', event_timestamp)     as snapshot_month,
        account_segment                          as segment,
        region,
        product_tier

    from {{ ref('usage_events') }}

    where event_timestamp is not null
      -- exclude the current incomplete month
      and date_trunc('month', event_timestamp) < date_trunc('month', current_date)

    {% if is_incremental() %}
        and date_trunc('month', event_timestamp)
            >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}

),

sessions as (

    select
        id        as session_id,
        user_id,
        user_role,
        case
            when user_role = 'Admin'                        then 'Admin'
            when user_role in ('Builder', 'Data Engineer')  then 'Creator'
            when user_role in ('Analyst', 'Viewer')         then 'Viewer'
            else 'Other'
        end as user_type

    from {{ ref('user_sessions') }}

),

events_with_user_type as (

    select
        e.account_id,
        e.user_id,
        e.event_id,
        e.event_type,
        e.snapshot_month,
        e.segment,
        e.region,
        e.product_tier,
        coalesce(s.user_type, 'Other') as user_type

    from events e
    left join sessions s
        on  e.session_id = s.session_id
        and e.user_id    = s.user_id

)

select
    account_id,
    snapshot_month,
    max(segment)      as segment,
    max(region)       as region,
    max(product_tier) as product_tier,

    -- ── active users (at least one event in the month) ──────────────────────
    count(distinct user_id)                                                  as total_users,
    count(distinct case when user_type = 'Admin'   then user_id end)         as total_admin_users,
    count(distinct case when user_type = 'Creator' then user_id end)         as total_creator_users,
    count(distinct case when user_type = 'Viewer'  then user_id end)         as total_viewer_users,

    -- ── events by type ──────────────────────────────────────────────────────
    count(distinct event_id)                                                 as total_events,
    count(distinct case when event_type = 'AI/Agentic'  then event_id end)   as total_agentic_events,
    count(distinct case when event_type = 'API'         then event_id end)   as total_api_events,
    count(distinct case when event_type = 'UI Feature'  then event_id end)   as total_ui_events,
    count(distinct case when event_type = 'Admin/Other' then event_id end)   as total_admin_other_events,

    -- ── per-total-user rates (denominator = all active users) ───────────────
    case when count(distinct user_id) = 0 then null
         else count(distinct event_id)::float
              / count(distinct user_id) end                                  as events_per_user,

    case when count(distinct user_id) = 0 then null
         else count(distinct case when event_type = 'AI/Agentic'
                                  then event_id end)::float
              / count(distinct user_id) end                                  as agentic_events_per_user,

    case when count(distinct user_id) = 0 then null
         else count(distinct case when event_type = 'API'
                                  then event_id end)::float
              / count(distinct user_id) end                                  as api_events_per_user,

    case when count(distinct user_id) = 0 then null
         else count(distinct case when event_type = 'UI Feature'
                                  then event_id end)::float
              / count(distinct user_id) end                                  as ui_events_per_user,

    case when count(distinct user_id) = 0 then null
         else count(distinct case when event_type = 'Admin/Other'
                                  then event_id end)::float
              / count(distinct user_id) end                                  as admin_other_events_per_user,

    -- ── per-active-user-of-type rates (denominator = users of that type) ────
    --   NULL when that user type was not active in the month.
    case when count(distinct case when user_type = 'Admin' then user_id end) = 0 then null
         else count(distinct case when event_type = 'Admin/Other'
                                  then event_id end)::float
              / count(distinct case when user_type = 'Admin'
                                    then user_id end) end                    as admin_other_events_per_admin_user,

    case when count(distinct case when user_type = 'Creator' then user_id end) = 0 then null
         else count(distinct case when event_type = 'AI/Agentic'
                                  then event_id end)::float
              / count(distinct case when user_type = 'Creator'
                                    then user_id end) end                    as agentic_events_per_creator_user,

    case when count(distinct case when user_type = 'Creator' then user_id end) = 0 then null
         else count(distinct case when event_type = 'UI Feature'
                                  then event_id end)::float
              / count(distinct case when user_type = 'Creator'
                                    then user_id end) end                    as ui_events_per_creator_user,

    case when count(distinct case when user_type = 'Viewer' then user_id end) = 0 then null
         else count(distinct case when event_type = 'UI Feature'
                                  then event_id end)::float
              / count(distinct case when user_type = 'Viewer'
                                    then user_id end) end                    as ui_events_per_viewer_user

from events_with_user_type
group by 1, 2