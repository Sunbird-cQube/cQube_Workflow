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

. "$INS_DIR/validation_scripts/install_aws_cli.sh"
. "validate.sh"
. "$INS_DIR/validation_scripts/datasource_config_validation.sh"


sudo apt install ansible -y

if [ -e /etc/ansible/ansible.cfg ]; then
	sudo sed -i 's/^#log_path/log_path/g' /etc/ansible/ansible.cfg
fi

echo '127.0.0.0' >> /etc/ansible/hosts

if [ ! $? = 0 ]; then
tput setaf 1; echo "Error there is a problem installing Ansible"; tput sgr0
exit
fi

# getting the base_config.yml from cqube base_dir
usecase_name=$(awk ''/^usecase_name:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

if [[ $usecase_name == "" ]]; then
   echo "Error - in usecase_name. Unable to get the value. Please check."; fail=1
else

case $usecase_name in
   
   uc1_edu)
        . $INS_DIR/validation_scripts/validate_static_datasource.sh uc1_config.yml
        base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' uc1_config.yml)
        ansible-playbook ansible/install.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_installation_config.yml" --extra-vars "@uc1_config.yml" --extra-vars "@uc1_datasource_config.yml"      
       ;;
   uc2_edu)
        . $INS_DIR/validation_scripts/validate_static_datasource.sh uc2_config.yml
        base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' uc2_config.yml)
        ansible-playbook ansible/install.yml --tags "install" --extra-vars "@$base_dir/cqube/conf/base_installation_config.yml" --extra-vars "@uc2_config.yml" --extra-vars "@uc2_datasource_config.yml"
       ;;
   *)
       echo "Error - Please enter the correct value in usecase_name."; fail=1
       ;;
esac

fi

if [ $? = 0 ]; then
echo "cQube Workflow installed successfully!!"
fi
