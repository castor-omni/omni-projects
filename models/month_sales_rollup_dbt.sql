SELECT DATE_TRUNC('MONTH', CONVERT_TIMEZONE('UTC', 'America/New_York', "CREATED_AT")) AS "CREATED_AT[MONTH]",
    COALESCE(SUM("SALE_PRICE"), 0) AS "TOTAL_SALE_PRICE",
    COUNT(*) AS "COUNT"
FROM {{ref('order_items')}} AS "ecomm__order_items"
WHERE "STATUS" = 'Complete'
GROUP BY 1
