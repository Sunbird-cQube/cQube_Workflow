#!/bin/bash

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' /tmp/cqube_migration/config.yml)
installation_host_ip=$(awk ''/^installation_host_ip:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook -i hosts ../ansible/install_ui.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@/tmp/cqube_migration/config.yml" \
	                                                     --extra-vars "@config.yml" \
							                                 --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@/tmp/cqube_migration/aws_s3_config.yml" \
							     --extra-vars "@/tmp/cqube_migration/azure_container_config.yml" \
                                                             --extra-vars "@/tmp/cqube_migration/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase" \
                                                             --extra-vars "protocol=http"
else
ansible-playbook -i hosts ../ansible/install_ui.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@/tmp/cqube_migration/config.yml" \
	                                                      --extra-vars "@config.yml" \
							     --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@/tmp/cqube_migration/aws_s3_config.yml" \
							     --extra-vars "@/tmp/cqube_migration/azure_container_config.yml" \
							     --extra-vars "usecase_name=education_usecase" \
                                                             --extra-vars "@/tmp/cqube_migration/local_storage_config.yml" 
fi

