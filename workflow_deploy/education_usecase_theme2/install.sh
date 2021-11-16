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

sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible-2.9 -y
sudo apt update -y
sudo apt install python -y
sudo apt-get install python-apt -y
sudo apt-get install python3-pip -y
chmod u+x validate.sh
sudo apt install unzip -y

if [[ ! -f config.yml ]]; then
    tput setaf 1; echo "ERROR: config.yml is not available. Please copy config.yml.template as config.yml and fill all the details."; tput sgr0
    exit;
fi

. "validate.sh"
. "datasource_validation.sh"

sudo apt install ansible -y

if [ -e /etc/ansible/ansible.cfg ]; then
	sudo sed -i 's/^#log_path/log_path/g' /etc/ansible/ansible.cfg
fi

echo '127.0.0.0' >> /etc/ansible/hosts

if [ ! $? = 0 ]; then
tput setaf 1; echo "Error there is a problem installing Ansible"; tput sgr0
exit
fi
   
. "$INS_DIR/validation_scripts/validate_static_datasource.sh" config.yml 
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

mode_of_installation=$(awk ''/^mode_of_installation:' /{ if ($2 !~ /#.*/) {print $2}}' $base_dir/cqube/conf/base_config.yml)
if [[ $mode_of_installation == "localhost" ]]; then
ansible-playbook ../ansible/install.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                         --extra-vars "@config.yml" \
							                             --extra-vars "@memory_config.yml" \
                                                         --extra-vars "@.version" \
                                                         --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
														 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                         --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
							                             --extra-vars "@datasource_config.yml" \
                                                         --extra-vars "usecase_name=education_usecase_theme2" \
                                                         --extra-vars "protocol=http"
else
ansible-playbook ../ansible/install.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_config.yml" \
                                                         --extra-vars "@config.yml" \
							                             --extra-vars "@memory_config.yml" \
                                                         --extra-vars "@.version" \
                                                         --extra-vars "@$base_dir/cqube/conf/aws_s3_config.yml" \
														 --extra-vars "@$base_dir/cqube/conf/azure_container_config.yml" \
                                                         --extra-vars "@$base_dir/cqube/conf/local_storage_config.yml" \
							                             --extra-vars "@datasource_config.yml" \
                                                         --extra-vars "usecase_name=education_usecase_theme2"
fi
if [ $? = 0 ]; then
. "install_ui.sh"
    if [ $? = 0 ]; then
       echo "cQube Workflow installed successfully!!"
    fi
fi

