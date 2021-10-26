#!/bin/bash

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' $base_dir/cqube/conf/base_config.yml)
if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook ../ansible/update_ui.yml --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                             --extra-vars "@config.yml" \
                                                                                         --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase_theme2" \
                                                             --extra-vars "protocol=http"
else
ansible-playbook ../ansible/update_ui.yml --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                             --extra-vars "@config.yml" \
                                                                                         --extra-vars "@memory_config.yml" \
                                                             --extra-vars "@.version" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=education_usecase_theme2"
fi

