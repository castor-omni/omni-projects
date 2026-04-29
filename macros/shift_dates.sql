{% macro pharma_shift_date(column_ref, anchor_date_ref) -%}
  -- Shift `column_ref` by the day delta needed to move `anchor_date_ref` to today.
  -- `anchor_date_ref` should be a scalar (typically from an aggregate CTE like `anchor.anchor_date`).
  DATEADD(
    'day',
    DATEDIFF('day', {{ anchor_date_ref }}, CURRENT_DATE()),
    {{ column_ref }}
  )
{%- endmacro %}