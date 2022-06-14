#!/bin/bash

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' $base_dir/cqube/conf/base_config.yml)
installation_host_ip=$(awk ''/^installation_host_ip:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook ../ansible/update_ui.yml -e "my_hosts=$installation_host_ip" --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                             --extra-vars "@config.yml" \
                                                                                         --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
															 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase" \
                                                             --extra-vars "protocol=http"
else
ansible-playbook ../ansible/update_ui.yml -e "my_hosts=$installation_host_ip" --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                             --extra-vars "@config.yml" \
                                                                                         --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
															 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase"
fi

