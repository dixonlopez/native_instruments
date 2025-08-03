{{
    config(
        materialized='incremental',
        unique_key=['activity_date', 'user_id', 'product_id']
    )
}}

-- This model is the core of the efficient DAU/MAU calculation.
-- It incrementally calculates the distinct users who were active on a given product each day.
-- By processing only new events, it avoids full scans of the massive events table.

select
    date(occurred_at) as activity_date,
    user_id,
    product_id
from {{ ref('base_product_usage__events') }}

-- This WHERE clause ensures that we only process data for completed days, making the DAU metric final and reliable.
where date(occurred_at) < current_date()

{% if is_incremental() %}

  -- and in incremental runs, only process events since the last successful run
  and occurred_at > (select max(activity_date) from {{ this }})

{% endif %}

group by 1, 2, 3
