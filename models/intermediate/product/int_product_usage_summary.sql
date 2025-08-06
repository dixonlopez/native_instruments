{{
    config(
        materialized='incremental',
        unique_key=['metric_date', 'product_id', 'metric_type'],
        partition_by={
            "field": "metric_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by=['product_id', 'metric_type']
    )
}}

-- This model creates a single summary table for both DAU and MAU metrics.
-- It is built incrementally to ensure efficiency. The logic handles the different
-- aggregation patterns required for daily (append-only) and monthly (update) metrics.

with daily_activity as (
    select * from {{ ref('stg_daily_user_activity') }}
),

-- This CTE identifies only the new daily activity records that need to be processed in the current incremental run.
new_daily_activity as (
    select * from daily_activity
    {% if is_incremental() %}
      where activity_date > (select coalesce(max(metric_date), '1900-01-01') from {{ this }} where metric_type = 'DAU')
    {% endif %}
),

-- DAU is a simple aggregation of the new daily activity.
dau as (
    select
        activity_date as metric_date,
        product_id,
        'DAU' as metric_type,
        count(distinct user_id) as metric_value
    from new_daily_activity
    group by 1, 2, 3
),

-- For MAU, we need to recalculate the metric for all months that have new daily activity.
months_with_new_activity as (
    select distinct
        date_trunc(activity_date, month) as summary_month
    from new_daily_activity
),

mau as (
    select
        date_trunc(daily_activity.activity_date, month) as metric_date,
        daily_activity.product_id,
        'MAU' as metric_type,
        count(distinct daily_activity.user_id) as metric_value
    from daily_activity
    -- Join against the months we need to update to only recalculate what's necessary.
    inner join months_with_new_activity
        on date_trunc(daily_activity.activity_date, month) = months_with_new_activity.summary_month
    group by 1, 2, 3
)

select * from dau
union all
select * from mau
