{{ config(materialized='table') }}

SELECT
    group_id,
    ARRAY_AGG(DISTINCT CONCAT(node_type, '_', node_value)) AS nodes
FROM {{ ref('unification_identities_distincts') }}
GROUP BY group_id