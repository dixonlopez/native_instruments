{{ config(materialized='view') }}

with source as (
    select * from {{ ref('sales_orders') }}
),

renamed as (
    select
        -- primary key
        cast(order_id as string) as order_id,

        -- foreign keys
        cast(customer_id as string) as customer_id,
        cast(product_id as string) as product_id,

        -- dimensions
        cast(order_timestamp as timestamp) as order_timestamp,
        cast(currency as string) as currency,

        -- measures
        cast(sale_amount as numeric) as sale_amount
    from source
)

select * from renamed