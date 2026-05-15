{{
  config(
    materialized = 'incremental',
    unique_key = ['snapshot_month', 'peer_group_dimension', 'peer_group_value'],
    on_schema_change = 'sync_all_columns'
  )
}}

/*
  Computes benchmark distribution statistics (mean, median, p25, p75, p90)
  for each metric, broken out by peer group dimension + value.
  No company-level rows are ever stored here — only population statistics.
  Rows with fewer than 5 companies are suppressed to protect privacy.
*/

with snapshots as (

    select *
    from {{ ref('fct_benchmark_company_snapshots') }}

    {% if is_incremental() %}
    where snapshot_month
        >= dateadd('month', -1, date_trunc('month', current_date))
    {% endif %}

),

-- fan out each company row into one row per peer group dimension
peer_groups as (

    -- total population
    select
        snapshot_month,
        'all'           as peer_group_dimension,
        'all'           as peer_group_value,
        total_users, total_admin_users, total_creator_users,
        total_viewer_users, total_other_users,
        total_events, total_agentic_events, total_api_events,
        total_ui_events, total_admin_events,
        events_per_user, agentic_events_per_user, api_events_per_user,
        ui_events_per_user, admin_events_per_user
    from snapshots

    union all

    -- by segment
    select
        snapshot_month,
        'segment'       as peer_group_dimension,
        segment         as peer_group_value,
        total_users, total_admin_users, total_creator_users,
        total_viewer_users, total_other_users,
        total_events, total_agentic_events, total_api_events,
        total_ui_events, total_admin_events,
        events_per_user, agentic_events_per_user, api_events_per_user,
        ui_events_per_user, admin_events_per_user
    from snapshots
    where segment is not null

    union all

    -- by region
    select
        snapshot_month,
        'region'        as peer_group_dimension,
        region          as peer_group_value,
        total_users, total_admin_users, total_creator_users,
        total_viewer_users, total_other_users,
        total_events, total_agentic_events, total_api_events,
        total_ui_events, total_admin_events,
        events_per_user, agentic_events_per_user, api_events_per_user,
        ui_events_per_user, admin_events_per_user
    from snapshots
    where region is not null

    union all

    -- by product tier
    select
        snapshot_month,
        'product_tier'  as peer_group_dimension,
        product_tier    as peer_group_value,
        total_users, total_admin_users, total_creator_users,
        total_viewer_users, total_other_users,
        total_events, total_agentic_events, total_api_events,
        total_ui_events, total_admin_events,
        events_per_user, agentic_events_per_user, api_events_per_user,
        ui_events_per_user, admin_events_per_user
    from snapshots
    where product_tier is not null

),

aggregated as (

    select
        snapshot_month,
        peer_group_dimension,
        peer_group_value,

        -- company count (used for suppression check)
        count(*)                                                                        as company_count,

        -- ── total users ──────────────────────────────────────────────────────────
        avg(total_users)                                                                as mean_total_users,
        median(total_users)                                                             as median_total_users,
        percentile_cont(0.25) within group (order by total_users)                      as p25_total_users,
        percentile_cont(0.75) within group (order by total_users)                      as p75_total_users,
        percentile_cont(0.90) within group (order by total_users)                      as p90_total_users,

        -- ── admin users ───────────────────────────────────────────────────────────
        avg(total_admin_users)                                                          as mean_admin_users,
        median(total_admin_users)                                                       as median_admin_users,
        percentile_cont(0.25) within group (order by total_admin_users)                as p25_admin_users,
        percentile_cont(0.75) within group (order by total_admin_users)                as p75_admin_users,
        percentile_cont(0.90) within group (order by total_admin_users)                as p90_admin_users,

        -- ── creator users ─────────────────────────────────────────────────────────
        avg(total_creator_users)                                                        as mean_creator_users,
        median(total_creator_users)                                                     as median_creator_users,
        percentile_cont(0.25) within group (order by total_creator_users)              as p25_creator_users,
        percentile_cont(0.75) within group (order by total_creator_users)              as p75_creator_users,
        percentile_cont(0.90) within group (order by total_creator_users)              as p90_creator_users,

        -- ── viewer users ──────────────────────────────────────────────────────────
        avg(total_viewer_users)                                                         as mean_viewer_users,
        median(total_viewer_users)                                                      as median_viewer_users,
        percentile_cont(0.25) within group (order by total_viewer_users)               as p25_viewer_users,
        percentile_cont(0.75) within group (order by total_viewer_users)               as p75_viewer_users,
        percentile_cont(0.90) within group (order by total_viewer_users)               as p90_viewer_users,

        -- ── total events ──────────────────────────────────────────────────────────
        avg(total_events)                                                               as mean_total_events,
        median(total_events)                                                            as median_total_events,
        percentile_cont(0.25) within group (order by total_events)                     as p25_total_events,
        percentile_cont(0.75) within group (order by total_events)                     as p75_total_events,
        percentile_cont(0.90) within group (order by total_events)                     as p90_total_events,

        -- ── agentic events ────────────────────────────────────────────────────────
        avg(total_agentic_events)                                                       as mean_agentic_events,
        median(total_agentic_events)                                                    as median_agentic_events,
        percentile_cont(0.25) within group (order by total_agentic_events)             as p25_agentic_events,
        percentile_cont(0.75) within group (order by total_agentic_events)             as p75_agentic_events,
        percentile_cont(0.90) within group (order by total_agentic_events)             as p90_agentic_events,

        -- ── api events ────────────────────────────────────────────────────────────
        avg(total_api_events)                                                           as mean_api_events,
        median(total_api_events)                                                        as median_api_events,
        percentile_cont(0.25) within group (order by total_api_events)                 as p25_api_events,
        percentile_cont(0.75) within group (order by total_api_events)                 as p75_api_events,
        percentile_cont(0.90) within group (order by total_api_events)                 as p90_api_events,

        -- ── ui events ─────────────────────────────────────────────────────────────
        avg(total_ui_events)                                                            as mean_ui_events,
        median(total_ui_events)                                                         as median_ui_events,
        percentile_cont(0.25) within group (order by total_ui_events)                  as p25_ui_events,
        percentile_cont(0.75) within group (order by total_ui_events)                  as p75_ui_events,
        percentile_cont(0.90) within group (order by total_ui_events)                  as p90_ui_events,

        -- ── admin events ──────────────────────────────────────────────────────────
        avg(total_admin_events)                                                         as mean_admin_events,
        median(total_admin_events)                                                      as median_admin_events,
        percentile_cont(0.25) within group (order by total_admin_events)               as p25_admin_events,
        percentile_cont(0.75) within group (order by total_admin_events)               as p75_admin_events,
        percentile_cont(0.90) within group (order by total_admin_events)               as p90_admin_events,

        -- ── events per user ───────────────────────────────────────────────────────
        avg(events_per_user)                                                            as mean_events_per_user,
        median(events_per_user)                                                         as median_events_per_user,
        percentile_cont(0.25) within group (order by events_per_user)                  as p25_events_per_user,
        percentile_cont(0.75) within group (order by events_per_user)                  as p75_events_per_user,
        percentile_cont(0.90) within group (order by events_per_user)                  as p90_events_per_user,

        -- ── agentic events per user ───────────────────────────────────────────────
        avg(agentic_events_per_user)                                                    as mean_agentic_events_per_user,
        median(agentic_events_per_user)                                                 as median_agentic_events_per_user,
        percentile_cont(0.25) within group (order by agentic_events_per_user)          as p25_agentic_events_per_user,
        percentile_cont(0.75) within group (order by agentic_events_per_user)          as p75_agentic_events_per_user,
        percentile_cont(0.90) within group (order by agentic_events_per_user)          as p90_agentic_events_per_user,

        -- ── api events per user ───────────────────────────────────────────────────
        avg(api_events_per_user)                                                        as mean_api_events_per_user,
        median(api_events_per_user)                                                     as median_api_events_per_user,
        percentile_cont(0.25) within group (order by api_events_per_user)              as p25_api_events_per_user,
        percentile_cont(0.75) within group (order by api_events_per_user)              as p75_api_events_per_user,
        percentile_cont(0.90) within group (order by api_events_per_user)              as p90_api_events_per_user,

        -- ── ui events per user ────────────────────────────────────────────────────
        avg(ui_events_per_user)                                                         as mean_ui_events_per_user,
        median(ui_events_per_user)                                                      as median_ui_events_per_user,
        percentile_cont(0.25) within group (order by ui_events_per_user)               as p25_ui_events_per_user,
        percentile_cont(0.75) within group (order by ui_events_per_user)               as p75_ui_events_per_user,
        percentile_cont(0.90) within group (order by ui_events_per_user)               as p90_ui_events_per_user,

        -- ── admin events per user ─────────────────────────────────────────────────
        avg(admin_events_per_user)                                                      as mean_admin_events_per_user,
        median(admin_events_per_user)                                                   as median_admin_events_per_user,
        percentile_cont(0.25) within group (order by admin_events_per_user)            as p25_admin_events_per_user,
        percentile_cont(0.75) within group (order by admin_events_per_user)            as p75_admin_events_per_user,
        percentile_cont(0.90) within group (order by admin_events_per_user)            as p90_admin_events_per_user

    from peer_groups
    group by 1, 2, 3

)
-- suppress peer groups with fewer than 5 companies to protect privacy
select *
from aggregated
where company_count >= 5