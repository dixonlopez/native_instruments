{{ config(materialized='view') }}

with source as (
    select * from {{ ref('product_usage') }}
),

renamed as (
    select
        -- primary key
        cast(usage_id as string) as usage_id,

        -- foreign keys
        cast(customer_id as string) as customer_id,
        cast(product_id as string) as product_id,

        -- dimensions
        cast(feature_id as string) as feature_id,
        cast(usage_timestamp as timestamp) as usage_timestamp
    from source
)

select * from renamed