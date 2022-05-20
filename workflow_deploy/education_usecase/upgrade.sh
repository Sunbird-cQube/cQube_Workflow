#!/bin/bash

if [ `whoami` != root ]; then
    tput setaf 1; echo "Please run this script using sudo"; tput sgr0
    exit
else
    if [[ "$HOME" == "/root" ]]; then
        tput setaf 1; echo "Please run this script using normal user with 'sudo' privilege,  not as 'root'"; tput sgr0
    fi
fi

INS_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$INS_DIR" ]]; then INS_DIR="$PWD"; fi

sudo apt update -y
chmod u+x upgradation_validate.sh

if [[ ! -f config.yml ]]; then
    tput setaf 1; echo "ERROR: config.yml is not available. Please copy config.yml.template as config.yml and fill all the details."; tput sgr0
    exit;
fi

. "upgradation_validate.sh"
. "datasource_validation.sh" 

if [ -e /etc/ansible/ansible.cfg ]; then
	sudo sed -i 's/^#log_path/log_path/g' /etc/ansible/ansible.cfg
fi

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
ansible-playbook ../ansible/create_base.yml --tags "update" --extra-vars "@config.yml" --extra-vars "@$base_dir/cqube/conf/base_config.yml" 
. "$INS_DIR/validation_scripts/backup_postgres.sh" config.yml

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' $base_dir/cqube/conf/base_config.yml)
installation_host_ip=$(awk ''/^installation_host_ip:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)

if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook ../ansible/upgrade.yml -e "my_hosts=$installation_host_ip" --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                         --extra-vars "@config.yml" \
                                                                                     --extra-vars "@memory_config.yml" \
                                                         --extra-vars "@.version" \
                                                         --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
														 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                         --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                                                     --extra-vars "@datasource_config.yml" \
                                                         --extra-vars "usecase_name=education_usecase" \
                                                         --extra-vars "protocol=http"
else
ansible-playbook ../ansible/upgrade.yml -e "my_hosts=$installation_host_ip" --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                         --extra-vars "@config.yml" \
                                                                                     --extra-vars "@memory_config.yml" \
                                                         --extra-vars "@.version" \
                                                         --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
														 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                         --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                                                     --extra-vars "@datasource_config.yml" \
                                                         --extra-vars "usecase_name=education_usecase"
fi
if [ $? = 0 ]; then
. "update_ui.sh"
    if [ $? = 0 ]; then
       echo "cQube Workflow upgraded successfully!!"
    fi
fi

