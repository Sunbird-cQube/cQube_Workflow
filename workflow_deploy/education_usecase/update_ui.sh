base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' upgradation_config.yml)
ansible-playbook ../ansible/update_ui.yml --tags "update" --extra-vars "@$base_dir/cqube/conf/base_upgradation_config.yml" \
                                                        --extra-vars "@upgradation_config.yml" \
                                                        --extra-vars "@$base_dir/cqube/conf/aws_s3_upgradation_config.yml" \
                                                        --extra-vars "@$base_dir/cqube/conf/local_storage_upgradation_config.yml" \
							--extra-vars "@datasource_config.yml" \
                                                        --extra-vars "usecase_name=test_usecase"

