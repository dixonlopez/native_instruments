{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}

with sales_orders as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id']) }} as event_id,
        customer_id,
        product_id,
        order_timestamp as event_timestamp,
        'purchase' as event_type,
        'purchase' as event_category,
        sale_amount
    from {{ ref('base_sales_orders') }}
    {% if is_incremental() %}
      where order_timestamp > (select max(event_timestamp) from {{ this }})
    {% endif %}
),

registrations as (
    select * from {{ ref('base_registrations') }}
    {% if is_incremental() %}
      -- This robust logic re-processes any registration record that has been updated
      -- since the last event was processed, catching late-arriving installation dates.
      where updated_at > (select max(event_timestamp) from {{ this }})
    {% endif %}
),

registrations_unpivoted as (
    select
        {{ dbt_utils.generate_surrogate_key(['usage_id', "'registered'"]) }} as event_id,
        customer_id, product_id, registration_timestamp as event_timestamp, 'registered' as event_type, 'registered' as event_category, null as sale_amount
    from registrations
    where registration_timestamp is not null
    union all
    select
        {{ dbt_utils.generate_surrogate_key(['usage_id', "'downloaded'"]) }} as event_id,
        customer_id, product_id, download_timestamp as event_timestamp, 'downloaded' as event_type, 'downloaded' as event_category, null as sale_amount
    from registrations
    where download_timestamp is not null
    union all
    select
        {{ dbt_utils.generate_surrogate_key(['usage_id', "'installed'"]) }} as event_id,
        customer_id, product_id, installation_timestamp as event_timestamp, 'installed' as event_type, 'installed' as event_category, null as sale_amount
    from registrations
    where installation_timestamp is not null
),

product_usage as (
    select
        {{ dbt_utils.generate_surrogate_key(['usage_id']) }} as event_id,
        customer_id,
        product_id,
        usage_timestamp as event_timestamp,
        feature_id as event_type,
        'usage' as event_category,
        null as sale_amount
    from {{ ref('base_product_usage') }}
    {% if is_incremental() %}
      where usage_timestamp > (select max(event_timestamp) from {{ this }})
    {% endif %}
)

select * from sales_orders
union all
select * from registrations_unpivoted
union all
select * from product_usage