{{ config(materialized='table') }}

with customer_events as (
    select * from {{ ref('int_customer_events_unioned') }}
),

products as (
    select * from {{ ref('base_products') }}
),

-- Calculate purchase-specific metrics using window functions
purchase_events as (
    select
        event_id,
        customer_id,
        event_timestamp,
        row_number() over (partition by customer_id order by event_timestamp, event_id) as purchase_number,
        lag(event_timestamp, 1) over (partition by customer_id order by event_timestamp, event_id) as previous_purchase_timestamp,
        sum(sale_amount) over (partition by customer_id order by event_timestamp, event_id rows between unbounded preceding and current row) as running_total_spend
    from customer_events
    where event_type = 'purchase'
)

-- Join all events with the calculated purchase metrics
select
    customer_events.event_id,
    customer_events.customer_id,
    customer_events.product_id,
    products.product_name,
    customer_events.event_timestamp,
    customer_events.event_type,
    customer_events.event_category,
    customer_events.sale_amount,
    purchase_events.purchase_number,
    datetime_diff(customer_events.event_timestamp, purchase_events.previous_purchase_timestamp, day) as days_since_previous_purchase,
    purchase_events.running_total_spend
from customer_events
left join purchase_events
    on customer_events.event_id = purchase_events.event_id
left join products
    on customer_events.product_id = products.product_id