-- This model serves as a placeholder for the legacy data from the Qlik application.
-- In a real-world scenario, this would be a source pointing to an extract of the legacy "Balance and Transactions" table.
-- For the purpose of this exercise, we are using the new fact table as a stand-in to allow for comparison analysis.

select * from {{ ref('fct_gl_transactions') }}