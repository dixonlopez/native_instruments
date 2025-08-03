{{ config(materialized='table') }}

-- This model calculates metrics at the customer-product level,
-- such as the time it takes for a customer to first use a product after purchase.

with purchase_dates as (
    select
        customer_id,
        product_id,
        min(event_timestamp) as purchase_timestamp
    from {{ ref('mart_customer_journey') }}
    where event_type = 'purchase'
    group by 1, 2
),

first_usage_dates as (
    select
        customer_id,
        product_id,
        min(event_timestamp) as first_usage_timestamp
    from {{ ref('mart_customer_journey') }}
    where event_category = 'usage'
    group by 1, 2
)

select
    pd.customer_id,
    pd.product_id,
    pd.purchase_timestamp,
    fud.first_usage_timestamp,
    datetime_diff(fud.first_usage_timestamp, pd.purchase_timestamp, day) as time_to_first_use_days
from purchase_dates as pd
left join first_usage_dates as fud
    on pd.customer_id = fud.customer_id and pd.product_id = fud.product_id