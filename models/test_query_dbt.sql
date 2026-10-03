SELECT "COMPETITOR",
    COALESCE(SUM("AMOUNT"), 0) AS "AMOUNT_SUM",
    COUNT(*) AS "COUNT"
FROM {{ref('opportunities')}} AS "analytics_dev_dbt_cestrada_prod_saas__opportunities"
GROUP BY 1
