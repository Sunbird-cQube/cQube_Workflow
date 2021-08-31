base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
ansible-playbook ../ansible/install_ui.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_installation_config.yml" \
                                                             --extra-vars "@config.yml" \
                                                             --extra-vars "@datasource_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
                                                             --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
                                                             --extra-vars "usecase_name=test_usecase"

