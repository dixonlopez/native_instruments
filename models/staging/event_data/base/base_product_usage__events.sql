{{ config(materialized='view') }}

-- This model cleans and casts data types from the raw product usage events seed.
-- It serves as the single source of truth for all event data.

with source as (

    select * from {{ ref('product_usage_events') }}

),

renamed as (

    select
        -- Primary Key
        cast(event_id as string) as event_id,

        -- Foreign Keys
        cast(user_id as string) as user_id,
        cast(product_id as string) as product_id,

        -- Timestamps
        cast(event_timestamp as timestamp) as occurred_at,

        -- Dimensions
        cast(event_type as string) as event_type

    from source

)

select * from renamed