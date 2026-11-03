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

### 