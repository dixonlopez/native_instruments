{{
    config(
        materialized='table'
    )
}}

-- This model serves as a dimensional helper to provide account hierarchy context.
-- It uses a recursive CTE to flatten the account hierarchy, structured for BigQuery compatibility.

with recursive 
account_hierarchy as (
    select * from {{ ref('base_erp__account_hierarchies') }}
),

accounts as (
    select * from {{ ref('base_erp__accounts') }}
),

unpacked_hierarchy as (
    -- Anchor member: accounts that are at the lowest level of the hierarchy
    select
        hierarchy.account_id as base_account_id,
        hierarchy.account_id,
        hierarchy.parent_account_id,
        1 as level
    from account_hierarchy as hierarchy
    left join account_hierarchy as child_check on hierarchy.account_id = child_check.parent_account_id
    where child_check.parent_account_id is null -- It's a base account if it's not a parent to any other account

    union all

    -- Recursive member: join back to the hierarchy to find the next parent up
    select
        unpacked.base_account_id,
        hierarchy.account_id,
        hierarchy.parent_account_id,
        unpacked.level + 1 as level
    from unpacked_hierarchy as unpacked
    join account_hierarchy as hierarchy on unpacked.parent_account_id = hierarchy.account_id
)

-- Join back to get the names for each level.
-- Note: The sample data only contains a single level of hierarchy (level 1).
-- However, the recursive logic is designed to handle multiple levels if they exist in the source data.
select
    unpacked.base_account_id,
    unpacked.level,
    parent_accounts.account_name as parent_account_name,
    parent_accounts.account_code as parent_account_code
from unpacked_hierarchy as unpacked
join accounts as parent_accounts on unpacked.parent_account_id = parent_accounts.account_id
