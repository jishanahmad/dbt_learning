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

## working with dbt
* terminal/venv type `dbt init`
* give project name and select database.
* give host
    - goto databricks > sql warehouse > connection details > server_hostname
    - select access token and generate one from dfatabricks(setting > developer > access token > )
    - select use unity catalogue
    - pass catalogue and other details
* goto `cd dbt_basic`and run `dbt debug` to test if everything is fine
