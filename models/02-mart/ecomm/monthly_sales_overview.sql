{{ config(
    materialized='table',
    schema='ECOMM',
    post_hook="{{ run_sales_forecast(this) }}"
) }}

select
    date(date_trunc('MONTH', created_at)) as month,
    status,
    coalesce(sum(sale_price), 0) as total_sale_price,
    round(
        (total_sale_price - lag(total_sale_price, 1) over (order by month))
        / lag(total_sale_price, 1) over (order by month),
        2
    ) as mom_change

from {{ ref('order_items') }} as order_items
where not status = 'Returned' or status is null
group by 1,2
order by 1 desc