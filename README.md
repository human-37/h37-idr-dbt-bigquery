# Introduction

This DBT module provides a framework for identity resolution. It is meant to solve the challenges of complex joins inbetween many tables to build a so-called 360 view of users.

To do so, the process scans defined models for identifiers. It then builds nodes and edges from these occurences, and resolves identities with a connected component algorithm. 

**Important**: to accomodate with existing identifiers, this module **DOES NOT** create a new permanent unified ID. Instead, it creates a `group_id`which is temporary and changes over runs. It is therefore strongly advised against using this `group_id` for processes that require a persistent ID. This modules is made to support analytical & marketing purposes only.

The unification lineage looks as the following:
![idr_flow](/images/idr_flow.png)


# Getting started

## 1. Copy the files into your DBT project
1. Copy the `models/unification` folder into your models folder
2. Copy the `macros/unification` folder into your macros folder

## 2. Install the required packages
1. Add the `dbt-labs/dbt_utils` package in your `packages.yml` file (cfr `packages.yml` in this repo)
2. Run `dbt deps` to install your new package

## 3. Configure your identities and source models

Modify the `models/unification/get_unification_criteria.sql` file to match your identities and your models.

**Example**:

````
models:
  - name: stg_ga4
    identifiers:
          - name: shopify_id
            field_name: user_id
          - name: user_pseudo_id
            field_name: user_pseudo_id

  - name: stg_shopify_sales
    identifiers:
          - name: shopify_id
            field_name: shopify_id
          - name: user_id
            field_name: user_id
            exclude_threshold: 1
````
**Parameters:**

| Parameter | Type | Description |
| ----------- | ----------- | ----------- |
| models | ARRAY(MODELS) ||
| models.name | STRING | Name of the model that contains identifiers and that should be scanned for identities. Note that this **must** be a model that exists in your project, note a source table. |
| models.identifiers | ARRAY(IDENTIFIERS) | |
| models.identifiers.name | STRING| Name of the identifier as conceptualized in your business logic. This name **must** be similar across the models for the identity resolution to resolve this identifier. |
| models.identifiers.field_name | STRING | Name of the column relative to the identifier, as it appears in your model. |
| models.identifiers.exclude_threshold | INTEGER | **[OPTIONAL]** Number of occurences above which an identifier will be excluded from the identity resolution. Set this number if your model contains values that are equal but that should not cause an identity merge. A common use case for this is for contact emails, which can be similar for different users. When excluded, an identifier is not completely removed from the identity resolution. Instead, it is redacted under the format: `{identifier_value}-REDACTED-{GENERATED_UUID}.` Default: 0. |

## 4. Configure the number of iterations

The Identity resolution does not dynamically adapt the number of iterations the process goes under. Instead, you need to manually adapt the `models/unification/unification_iterations.sql` file on the following line:
```
{% set iterations = 7 %}
```

The process can be considered as converging whenever an additional iteration does not decrease the number of unified identities. 

The table `unification_iterations_metrics` provides a detail on the number of unified identities for each iteration. In order to fine-tune the `iterations` parameter, you thus need to check the results in the `unification_iterations_metrics` table after a run.

## 5. Run the models

Run the following command to execute the unification flow: `dbt build --models unification`.

For small data volumes, it is expected to take a few minutes. For larger data volumes (>10M nodes), it is expected to take between 15-20min. If the process is running too slow, consider decreasing the `iterations` parameter (See above).

# Populated tables

The following tables are populated and meant for use. This module also populates other tables that are meant for **internal processing only**.

| Table | Description |
| ----------- | ----------- |
| unification_iterations_metrics | This table gives an overview of the number of merged identities per iteration. Consult this table to confirm if the number of iterations was sufficiently high to converge (last two iterations should have the same number of unified identities). |
| unification_identities_distincts |This table maps all encountered identifiers with the unified `group_id`. Use this table to join with other models. |
| unification_identities_grouped |This table groups for convinience all the identifiers per `group_id`. Iedntifiers in this table are string concatenations of the identifier name and its value. |
| unification_identities_metrics |This table provides metrics on the overall encountered identifiers, such as coverage (% of users having this identifier), the number of encountered values and the number of merged identities having a specific identifier. |
| unification_exclusions |This table maps all the values for identifiers that have been excluded with the parameter `exclude_threshold` in the file `models/unification/unification_iterations.sql`.  |
| unification_heatmap |This table provides a pivot table of the crossing of all identifiers, to output their crossover. |
