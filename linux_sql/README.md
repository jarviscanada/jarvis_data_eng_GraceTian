# Linux Cluster Monitoring Agent

## Introduction
This project records the hardware specifications and real-time usage of nodes in a Linux cluster. 
It was created for the Jarvis Linux Cluster Administration (LCA) team to use the data for analysis/reports and influence future resource planning decisions.
This project uses a Docker container to run PostgreSQL, stores data in the RDBMS using SQL, uses bash scripts to execute commands, and a cron job to deploy and automate cluster monitoring.

## Quick Start
Please follow these instructions to use this project. 
Ensure you are running the following commands from the folder `jarvis_data_eng_GraceTian/linux_sql/`.
1. Start a psql instance with psql_docker.sh. The script usage is as follows:
    ```bash
   ./scripts/psql_docker.sh start|stop|create [db_username][db_password]
   ```
   First, create the Docker container that psql will be running on if it has not been created yet.
    ```bash
    ./scripts/psql_docker.sh create [db_username] [db_password]
    ```
   For example, if you have a username `postgres` and password `password`, run the following:
    ```bash
   ./scripts/psql_docker.sh create "postgres" "password"
   ```
   Next, start the Docker container.
    ```bash
   ./scripts/psql_docker.sh start
   ```
   Afterwards, when you do not need the monitoring anymore, stop the Docker container (do not run this step if you are just looking to start the application).
    ```bash
   ./scripts/psql_docker.sh stop
   ```
2. Create database and tables. 
    If you do not already have a database `host_agent`, create it using the commands below. You do not have to create it multiple times.
    ```shell
    psql -h localhost -U postgres -W
    
    -- Run the following using the psql CLI
    postgres=# \l
    postgres=# CREATE DATABASE host_agent;
    postgres=# \c host_agent;
   ```
   If the `host_agent` database already exists, run the following command in the terminal to switch to `host_agent` and create the tables.
    ```
   psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
   ```
3. Insert hardware specs data for your host.
    ```
   ./scripts/host_info.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
   ```
   For example, if you have a host `localhost`, port `5432`, database name `host_agent`, user `postgres`, and password `password`, run the following:
    ```
   ./scripts/host_info.sh "localhost" 5432 "host_agent" "postgres" "password"
   ```
4. Insert hardware usage data.
    ```
   bash ./scripts/host_usage.sh [psql_host] [psql_port] [db_name] [psql_user] [psql_password]
   ```
   For example, if you have a host `localhost`, port `5432`, database name `host_agent`, user `postgres`, and password `password`, run the following:
    ```
   ./scripts/host_usage.sh "localhost" 5432 "host_agent" "postgres" "password"
   ```
5. Setup crontab.
    ```bash
   crontab -e
   ```
   Add the following line to the crontab to collect data points automatically every minute. The path may differ depending on your device.
    ```
    * * * * bash /home/rocky/dev/jarvis_data_eng_GraceTian/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
   ```
   Save and exit the editor, then check that the crontab was added.
    ```bash
   crontab -l
   ```

## Implementation
The application is implemented with PostgreSQL running on a Docker container, and bash scripts for applications functionalities, including getting host information and usage from the device.

### Architecture
To be inserted. Will create a cluster diagram with three Linux hosts, a DB, and agents using the draw.io website, with image saved to the `assets` directory.

### Scripts

- `psql_docker.sh`: shell script to set up and start/stop the Docker container for `psql`.
- `host_info.sh`: bash script to retrieve and save host information. This script is only run once per host.
- `host_usage.sh`: bash script to retrieve and save host usage. This script is run every minute.
- `crontab`: host file containing commands for cron jobs and schedules.
- `ddl.sql`: SQL file to switch to correct database and create necessary tables.
- `queries.sql`: SQL file of queries to aid in business problems. 

### Database Modelling
- `host_info`: contains id, hostname, cpu number, cpu architecture, cpu model, cpu speed in mHz, l2 cache size in kB, total memory in kB, and the current date/time.
- `host_usage`: contains timestamp, host id (corresponds to `host_info` table), free memory in mB, cpu idle time in percentage, cpu kernel usage time in percentage, disk I/O usage in mB, and available disk space in mB.

## Test
The bash scripts were testing in the terminal using `bash -x [cmd]` to ensure accuracy.

## Deployment
The application is located on GitHub and automated with `crontab`.

## Improvements
For future reference, the application can be improved in the following ways:
- Create bash functions to align the code with DRY principles.
- Allow the application to handle hardware updates.
- Fully automate the entire application setup process, i.e. with one command.