{{ config(materialized='table') }}

SELECT 
    iteration,
    COUNT(DISTINCT group_id) AS count_uniques
FROM {{ ref('unification_iterations') }}
GROUP BY iteration
ORDER BY iteration ASC