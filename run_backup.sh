#!/bin/bash

CMD=pg_dump;
HOST_PROPERTY=host;
PORT_PROPERTY=port;
DB_PROPERTY=database;
USER_PROPERTY=user;
PASS_PROPERTY=password;

function log_fatal {
   message=$1;
   echo "$(date "+%m%d%Y %T") : $message" >&2;
   exit 1;
}

function log {
   message=$1;
   echo "$(date "+%m%d%Y %T") : $message" >&1;
}

# exit if a command doesn't exist
function assert_command_exists() {
   cmd=$1;

   if ! [ -x "$(command -v $cmd)" ]; then
      log_fatal "Command not found. Please make shure \"$cmd\" command is available.";
   fi
}

# get properties from file 
function get_property_from_file() {
   property_file=$1;
   property_key=$2;

   property_value=$(cat $property_file | grep "$property_key" | cut -d'=' -f2);
   echo $property_value;
}

function assert_property_exists() {
   property_file=$1;
   property_key=$2;

   property_value=$(get_property_from_file $property_file $property_key);
   if [[ -z $property_value ]]; then
      log_fatal "Property \"$property_key\" not defined in \"$property_file\". Make shure you assigned some value: $property_key=<value>" >&2;
   fi
}

assert_command_exists $MYSQL_CMD;

script_name=$0;
property_file=$1;

if [[ -z $property_file ]]; then
   log_fatal "Property file argument is required. Usage: $script_name <propery file>" >&2;
fi

if [[ ! -f $property_file ]]; then
   log_fatal "Property file does not exist. Please make shure \"$property_file\" is a valid file." >&2;
fi

assert_property_exists $property_file $HOST_PROPERTY;
assert_property_exists $property_file $DB_PROPERTY;
assert_property_exists $property_file $USER_PROPERTY;
assert_property_exists $property_file $PASS_PROPERTY;

required_args="";
host=$(get_property_from_file $property_file $HOST_PROPERTY)
port=$(get_property_from_file $property_file $PORT_PROPERTY)
database=$(get_property_from_file $property_file $DB_PROPERTY)
user=$(get_property_from_file $property_file $USER_PROPERTY)
password=$(get_property_from_file $property_file $PASS_PROPERTY)

args="--host=$host --user=$user --password=$password"

if [[ ! -z $port ]]; then
   args="--port=$port "$args;
fi

assert_command_exists $CMD;

log "Running \"$CMD $args\""

if output=$($CMD $args); then
    printf 'some_command succeded, the output was «%s»\n' "$output"
else
   log_fatal "Error: $output"
fi


echo $DB_HOST
echo $DB_USER
echo $DB_PASS
echo "Writing on DB ... "
