#!/bin/bash
#set -eu
config_file=$1
base_directory=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' $config_file)
if [[ -e "$base_directory/cqube/.cqube_config" ]]; then
    static_datasource=$( grep CQUBE_STATIC_DATASOURCE $base_directory/cqube/.cqube_config )
    current_datasource=$(cut -d "=" -f2 <<< "$static_datasource")
    if [[ ! $current_datasource == "" ]]; then
        datasource_config=$(awk ''/^static_datasource:' /{ if ($2 !~ /#.*/) {print $2}}' $config_file)
        if [[ ! $current_datasource == $datasource_config ]]; then
            sed -i '/datasource_status/c\datasource_status: unmatched' ../ansible/roles/createdb/vars/main.yml
            echo "static_datasource value from config.yml is not matching with previous installation value. If continued with this option, it will truncate the tables from db and clear the objects from output bucket."
            while true; do
                read -p "yes to continue, no to cancel the installation (yes/no)? : " yn
                case $yn in
                    yes) break;;
                    no) echo "Cancelling the installation." 
                        exit ;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
            echo "continuing"
        else
            sed -i '/datasource_status/c\datasource_status: matched' ../ansible/roles/createdb/vars/main.yml
        fi
    fi
fi

