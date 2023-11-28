{{ config(materialized='table') }}

SELECT
  node_type,
  COUNT(DISTINCT node_value) AS count_values,
  COUNT(DISTINCT group_id) AS count_identities,
  COUNT(DISTINCT node_value) / COUNT(DISTINCT group_id) AS avg_occurence,
  ROUND(COUNT(DISTINCT group_id) / SUM(COUNT(DISTINCT group_id)) OVER(), 2) AS coverage_identities
FROM
  {{ ref('unification_identities_distincts') }}
GROUP BY
  node_type