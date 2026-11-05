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

## Jinja
* Templating framework
* using jinja you can write the dynamic queries to parse sql.
* example jinja: /Users/jishanahmad/dbt_learning/dbt_basic/analyses/jinja-1.sql

## Macros
* similar to functions
* example: /Users/jishanahmad/dbt_learning/dbt_basic/macros/generate_schema.sql

## Silver layer
* Define silve table cte and run the silver script `dbt run --select "models/silver"`

## Snapshots
* to work with scd.
* create a scd table (items) in databricks and add a source for it.
```
create table items(
    id int,
    name string,
    catogory string,
    updated_date timestamp
);

insert into items values(
    1, 'item1', 'cat1', current_timestamp()),
    (2, 'item2', 'cat2', current_timestamp()),
    (3, 'item3', 'cat3', current_timestamp());
```
* create a gold table named `source_gold_items`. Take only unique values.
* create a snapshots called `gold_items.yaml` for scd type 2
```
snapshots:
  - name: gold_items
    relation: ref('source_gold_items')
    config:
      schema: gold
      database: dbt_learning
      unique_key: id
      strategy: timestamp
      updated_at: updated_date
      dbt_valid_to_current: "to_date('9999-12-31')"
```
* populate the snapshot `dbt build` to buid everything
* insert new data into table
```
insert into items values(
    (3, 'item3_new', 'cat3', current_timestamp()))
```
* again run `dbt build`.

## CICD
* Move the chnages from dev/test to prod
* create a catalogue name `dbt_learning_prod` in databricks
* make an entry for prod here `/Users/jishanahmad/dbt_learning/dbt_basic/profiles.yml`
```
dbt_basic:
  outputs:
    dev:
      catalog: dbt_learning
      host: dbc-6456dea0-a695.cloud.databricks.com
      http_path: /sql/1.0/warehouses/8e0624c454f8ef21
      schema: source
      threads: 1
      token: 
      type: databricks
    prod:
      catalog: dbt_learning_prod
      host: dbc-6456dea0-a695.cloud.databricks.com
      http_path: /sql/1.0/warehouses/8e0624c454f8ef21
      schema: source
      threads: 1
      token: 
      type: databricks
  target: dev
```
* Now whereever we have harcoded the cataloue name,we need to parametrized it.
* file `/Users/jishanahmad/dbt_learning/dbt_basic/models/source/sources.yml` and `/Users/jishanahmad/dbt_learning/dbt_basic/snapshots/gold_items.yaml`
* create a source table in `dbt_learning_prod` by doing like
```
create table dbt_learning_prod.source.fact_sales
as
select * from dbt_learning.source.fact_sales
```
* deploy in prodution by running `dbt build --target prod`
* see what all steps passed/failed