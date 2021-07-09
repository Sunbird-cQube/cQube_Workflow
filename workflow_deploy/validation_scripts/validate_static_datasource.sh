#!/bin/bash
config_file=$1
base_directory=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' $config_file)
if [[ -e "$base_directory/cqube/.cqube_config" ]]; then
static_datasource=$(cat $base_directory/cqube/.cqube_config | grep CQUBE_STATIC_DATASOURCE )
current_datasource=$(cut -d "=" -f2 <<< "$static_datasource")
datasource_config=$(awk ''/^static_datasource:' /{ if ($2 !~ /#.*/) {print $2}}' $config_file)
if [[ ! $current_datasource == $datasource_config ]]; then
    sed -i '/datasource_status/c\datasource_status: unmatched' ansible/roles/createdb/vars/main.yml
else
    sed -i '/datasource_status/c\datasource_status: matched' ansible/roles/createdb/vars/main.yml
fi
fi
