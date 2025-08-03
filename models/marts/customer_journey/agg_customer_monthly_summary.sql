{{ config(materialized='table') }}

-- This model provides a monthly aggregated summary of customer purchases.
-- It's optimized for performance and ease of use in BI tools.
select
    date_trunc(event_timestamp, month) as summary_month,
    customer_id,
    product_id,
    product_name,
    count(event_id) as monthly_purchase_count,
    sum(sale_amount) as monthly_purchase_amount
from {{ ref('mart_customer_journey') }}
where event_type = 'purchase'
group by 1, 2, 3, 4