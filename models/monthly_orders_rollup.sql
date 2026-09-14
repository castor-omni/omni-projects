SELECT DATE_TRUNC('MONTH', CONVERT_TIMEZONE('UTC', 'America/New_York', "CREATED_AT")) AS "CREATED_AT[MONTH]",
    COALESCE(SUM("SALE_PRICE"), 0) AS "TOTAL_SALES"
FROM {{ref('order_items')}} AS "omni_dbt_ecomm__order_items"
WHERE "STATUS" NOT IN ('Cancelled', 'Returned') OR "STATUS" IS NULL
GROUP BY 1
