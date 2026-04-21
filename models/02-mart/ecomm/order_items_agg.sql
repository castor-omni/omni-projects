SELECT AVG("MARGIN") AS "MARGIN_AVERAGE"
FROM {{ref('order_items')}} AS "ecomm__order_items"
WHERE "STATUS" = 'Complete'
