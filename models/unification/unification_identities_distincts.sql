{{ config(materialized='table') }}

WITH MAX_ITERATION AS (
  SELECT MAX(iteration) max_it FROM {{ ref('unification_iterations') }}
)
SELECT 
    DISTINCT
    group_id,
    node_type,
    node_value
FROM {{ ref('unification_iterations') }}, MAX_ITERATION
WHERE iteration = MAX_ITERATION.max_it