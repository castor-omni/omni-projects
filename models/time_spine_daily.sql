-- https://docs.getdbt.com/guides/mf-time-spine?step=2
{{
    config(
        materialized = 'table',
    )
}}

{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2019-01-01' as date)",
    end_date="cast('2026-01-01' as date)"
   )
}}