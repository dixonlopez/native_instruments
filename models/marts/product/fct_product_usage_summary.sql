{{
    config(
        materialized='view'
    )
}}

-- This model serves as the final, user-facing summary table.
-- It is a simple view that selects from the intermediate summary model,
-- keeping the mart layer clean and simple. The complex incremental logic
-- is handled in the intermediate layer.

select
    metric_date,
    product_id,
    metric_type,
    metric_value
from {{ ref('int_product_usage_summary') }}