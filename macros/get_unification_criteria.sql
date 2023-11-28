{% macro get_unification_criteria() %}
{% set yml_str %}

---
{# BELOW CONFIGURATION IS AN EXAMPLE #}
models:
  - name: stg_source_1
    identifiers:
          - name: shopify_id
            field_name: user_id
          - name: user_pseudo_id
            field_name: user_pseudo_id

  - name: stg_source_2
    identifiers:
          - name: shopify_id
            field_name: shopify_id
          - name: user_id
            field_name: user_id

  - name: stg_source_3
    identifiers:
          - name: user_id
            field_name: id
          - name: email
            field_name: email

  - name: stg_source_4
    identifiers:
          - name: email
            field_name: email
          - name: email_id
            field_name: email_id

  - name: stg_source_5
    identifiers:
          - name: email
            field_name: email
          - name: register_id
            field_name: register_id
            exclude_threshold: 1

  - name: stg_source_6
    identifiers:
          - name: feedback_id
            field_name: feedback_id
          - name: email_id
            field_name: email_id

{% endset %}
{% set conf_yml = fromyaml(yml_str) %}
{{ return(tojson(conf_yml.models)) }}
{% endmacro %}