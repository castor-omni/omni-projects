{% macro run_sales_forecast(source_table) %}

  -- If we are running in the production database, force the ECOMM schema.
  -- Otherwise, fall back to your personal dev schema.
  {% if target.database == 'ANALYTICS_PROD' %}
    {% set output_schema = 'ECOMM' %}
  {% else %}
    {% set output_schema = target.schema %}
  {% endif %}

  {% set forecast_query %}
    -- Create clean training view using the passed-in model relation
    CREATE OR REPLACE TEMPORARY VIEW {{ target.database }}.{{ output_schema }}.sales_forecast_training_set AS
    SELECT 
        TO_TIMESTAMP_NTZ(month) AS MONTH_v1,
        SUM(total_sale_price) AS TOTAL_SALE_PRICE
    FROM {{ source_table }}   <-- CHANGED THIS LINE
    WHERE TO_TIMESTAMP_NTZ(month) < DATE_TRUNC('MONTH', CURRENT_DATE())
    GROUP BY 1;

    -- Train the ML Model
    CREATE OR REPLACE SNOWFLAKE.ML.FORECAST {{ target.database }}.{{ output_schema }}.sales_forecast(
        INPUT_DATA => TABLE({{ target.database }}.{{ output_schema }}.sales_forecast_training_set),
        TIMESTAMP_COLNAME => 'MONTH_v1',
        TARGET_COLNAME => 'TOTAL_SALE_PRICE'
    );

    -- Generate predictions directly into the verified schema
    CREATE OR REPLACE TABLE {{ target.database }}.{{ output_schema }}.TOTAL_SALES_FORECAST AS 
    SELECT * FROM TABLE({{ target.database }}.{{ output_schema }}.sales_forecast!FORECAST(
        FORECASTING_PERIODS => 15,
        CONFIG_OBJECT => {'prediction_interval': 0.80}
    ))
  {% endset %}

  {% do run_query(forecast_query) %}
  {% do log("Cortex sales forecast updated successfully.", info=True) %}

{% endmacro %}