base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
ansible-playbook ../ansible/update_ui.yml --tags "update" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                        --extra-vars "@config.yml" \
							--extra-vars "@memory_config.yml" \
                                                        --extra-vars "@.version" \
                                                        --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
                                                        --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
							--extra-vars "@datasource_config.yml" \
                                                        --extra-vars "usecase_name=teststate_usecase"

