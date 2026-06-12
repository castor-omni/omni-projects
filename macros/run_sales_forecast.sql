{% macro run_sales_forecast() %}

  {% set forecast_query %}
    -- 1. Create clean training view using native dbt ref() lookup
    CREATE OR REPLACE TEMPORARY VIEW {{ target.database }}.{{ target.schema }}.sales_forecast_training_set AS
    SELECT 
        TO_TIMESTAMP_NTZ(month) AS MONTH_v1,
        SUM(total_sale_price) AS TOTAL_SALE_PRICE
    FROM {{ ref('monthly_sales_overview') }}
    WHERE TO_TIMESTAMP_NTZ(month) < DATE_TRUNC('MONTH', CURRENT_DATE())
    GROUP BY 1;

    -- 2. Train the ML Model
    CREATE OR REPLACE SNOWFLAKE.ML.FORECAST {{ target.database }}.{{ target.schema }}.sales_forecast(
        INPUT_DATA => TABLE({{ target.database }}.{{ target.schema }}.sales_forecast_training_set),
        TIMESTAMP_COLNAME => 'MONTH_v1',
        TARGET_COLNAME => 'TOTAL_SALE_PRICE'
    );

    -- 3. Generate predictions directly into a table
    CREATE OR REPLACE TABLE {{ target.database }}.{{ target.schema }}.TOTAL_SALES_FORECAST AS 
    SELECT * FROM TABLE({{ target.database }}.{{ target.schema }}.sales_forecast!FORECAST(
        FORECASTING_PERIODS => 15,
        CONFIG_OBJECT => {'prediction_interval': 0.80}
    ))
  {% endset %}

  {% do run_query(forecast_query) %}
  {% do log("Cortex sales forecast updated successfully.", info=True) %}

{% endmacro %}