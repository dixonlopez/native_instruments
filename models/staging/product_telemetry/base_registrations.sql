{{ config(materialized='view') }}

with source as (
    select * from {{ ref('registrations') }}
),

renamed as (
    select
        -- primary key
        cast(usage_id as string) as usage_id,

        -- foreign keys
        cast(customer_id as string) as customer_id,
        cast(product_id as string) as product_id,

        -- dimensions
        cast(registration_timestamp as timestamp) as registration_timestamp,
        cast(download_timestamp as timestamp) as download_timestamp,
        cast(installation_timestamp as timestamp) as installation_timestamp,
        cast(updated_at as timestamp) as updated_at
    from source
)

select * from renamed