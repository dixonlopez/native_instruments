{{ config(materialized='table') }}

with customer_events as (
    select * from {{ ref('mart_customer_journey') }}
),

customers as (
    select * from {{ ref('base_customers') }}
),

customer_summary as (
    select
        customer_id,
        min(case when event_type = 'purchase' then event_timestamp end) as first_purchase_timestamp,
        max(case when event_type = 'purchase' then event_timestamp end) as last_purchase_timestamp,
        sum(sale_amount) as customer_lifetime_value,
        count(distinct case when event_type = 'purchase' then product_id end) as total_products_purchased
    from customer_events
    group by 1
)

select
    customers.customer_id,
    customers.customer_name,
    customer_summary.first_purchase_timestamp,
    customer_summary.last_purchase_timestamp,
    customer_summary.customer_lifetime_value,
    customer_summary.total_products_purchased
from customers
left join customer_summary
    on customers.customer_id = customer_summary.customer_id