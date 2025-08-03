{{ config(materialized='view') }}

-- This model serves as the primary, user-facing event-level table.
-- It's a simple pass-through from the intermediate layer, keeping the mart clean.
select * from {{ ref('int_customer_journey_events') }}