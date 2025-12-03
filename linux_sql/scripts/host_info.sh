#!/bin/bash

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Parse host hardware specs
lscpu_out=`lscpu`
hostname=$(hostname -f)

cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model(\s)name" | awk '{$1=$2=""; print $0}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^Model(\s)name:" | awk '{printf "%.3f", $7 * 1000}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2(\s)cache:" | awk '{print $3}' | xargs) # in kB
total_mem=$(vmstat | tail -1 | awk '{print $4}') # in kB
timestamp=$(date +"%Y-%m-%d %H:%M:%S") # current timestamp

# Set the id automatically
get_key_stmt="SELECT setval(pg_get_serial_sequence('host_info', 'id'), (SELECT MAX(id) FROM host_info) + 1);"
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$get_key_stmt"

# Construct the INSERT statement
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
  VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem');"

# Execute INSERT statement
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?