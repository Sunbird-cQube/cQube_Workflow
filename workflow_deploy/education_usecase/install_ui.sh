#!/bin/bash

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' $base_dir/cqube/conf/base_config.yml)
if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook -i hosts ../ansible/install_ui.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
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
ansible-playbook -i hosts ../ansible/install_ui.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                             --extra-vars "@config.yml" \
							                                 --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
															 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase"
fi
