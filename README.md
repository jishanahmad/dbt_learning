## setting dbt
* Install below packages
```
python 3.12
uv
git
```
* create a venv using python 3.12
* initiate virtual env
```
uv init
```
* add db-core
```
uv add dbt-core
uv add dbt-databricks
```
* install extension
    * python
    * git
    * power user for dbt

## Test dbt setup
* terminal/venv type `dbt init`
* give project name and select database.
* give host
    - goto databricks > sql warehouse > connection details > server_hostname
    - select access token and generate one from dfatabricks(setting > developer > access token > )
    - select use unity catalogue
    - pass catalogue and other details
* goto `cd dbt_basic`and run `dbt debug` to test if everything is fine


## Working with dbt

### Bronze layer
* under `models > create a bronze folder`
* create a source foldera nd define the sources
* under `bronze` define sql by referring the sources
* make that broze entry in `dbt_project.yml` file as well
```
models:
    dbt_basic
        bronze:
            +materialized: table
```
* to create the bronze table just run `dbt run` from `dbt_basic` folder
* In case you wanted to run any particular model(Not all) `dbt run --select bronze_date`
* goto database and verify if tables are created
* under `taregt` folder you can check the exact sql which dbt has run to create the bronze tables.

#### Create schema in dedicated place in bronze
* define schema under dbt_project.yml
```
models:
  dbt_basic:
    # Config indicated by + and applies to all files under models/example/
    bronze:
      +materialized: table
      schema: bronze
    silver:
      +materialized: table
      schema: silver
    gold:
      +materialized: table
      schema: gold
```
* create macros `/Users/jishanahmad/dbt_learning/dbt_basic/macros/generate_schema.sql` to take dynamic schema name

## DBT Tests
* Generic test can be added to any solution
* two types
    - singular
    - Generic
* `Generic Test` can be added in path /Users/jishanahmad/dbt_learning/dbt_basic/models/bronze/properties.yml
```
  - name: bronze_store
    columns:
      - name: store_sk
        data_tests:
          - unique
          - not_null

      - name: store_name
        data_tests:
          - accepted_values:
              arguments:
                values:
                  - 'MegaMart Manhattan'
                  - 'MegaMart Brooklyn'
                  - 'MegaMart Austin'
                  - 'MegaMart San Jose'
                  - 'MegaMart toronto'
```
* In case you dont want test to fail,you can add severity as well like like
```
      - name: store_name
        data_tests:
          - accepted_values:
              arguments:
                values:
                  - 'MegaMart Manhattan'
                  - 'MegaMart Brooklyn'
                  - 'MegaMart Austin'
                  - 'MegaMart San Jose'
                  - 'MegaMart Toronto'
                config:
                    severity: warn
```
* `singular test`: When you wanted to test a logic
* Generic test can be created and passed as `/Users/jishanahmad/dbt_learning/dbt_basic/tests/generic/generic_non_nagative.sql`
* add this test in code
```
  - name: bronze_sales
    columns:
      - name: sales_id
        data_tests:
          - unique
          - not_null
      - name: gross_amount
        data_tests:
          - generic_non_negative
```
* verufy by running `dbt test`


## DBT seeds
* Dbt Seeds allow you to load static data from CSV files into your database or data warehouse using dbt.
* Put the file inside ssed folder
* Define the location where seeds(tables) will get created in /Users/jishanahmad/dbt_learning/dbt_basic/dbt_project.yml
```
seeds:
  dbt_basic:
    +schema: bronze
```
* run `dbt seed` to register/create the table.

## Analysis
* If you wantedto analyze of run adhoc query on data,you can use analysis folder
* 