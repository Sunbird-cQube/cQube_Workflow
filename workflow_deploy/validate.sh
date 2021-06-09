#!/bin/bash 

check_state()
{
state_found=0
while read line; do
  if [[ $line == $2 ]] ; then
   state_found=1
  fi
done < validation_scripts/state_codes
if [[ $state_found == 0 ]] ; then
  echo "Error - Invalid State code. Please refer the state_list file and enter the correct value."; fail=1
fi
}

check_static_datasource(){
if ! [[ $2 == "udise" || $2 == "state" ]]; then
    echo "Error - Please enter either udise or state for $1"; fail=1
fi
}

check_base_dir(){
base_dir_status=0
if [[ ! "$2" = /* ]] || [[ ! -d $2 ]]; then
    echo "Error - Please enter the absolute path or make sure the directory is present."; fail=1
    base_dir_status=1
else
   if [[ -e "$2/cqube/.cqube_config" ]] && [[ -e "$2/cqube/conf/base_installation_config.yml" ]]; then
        dir=$(cat $2/cqube/.cqube_config | grep CQUBE_BASE_DIR )
        base_dir_path=$(cut -d "=" -f2 <<< "$dir")
        if [[ ! "$2" == "$base_dir_path" ]]; then
            echo "Error - Base directory should be same as previous installation directory"; fail=1
            base_dir_status=1
        fi
    else
       echo "Error - Base directory should be same as previous installation directory / base_config.yml is missing"; fail=1
       base_dir_status=1
    fi
fi
if [[ $base_dir_status == 1 ]]; then
  echo "Please rectify the base_dir error and restart the upgradation"
  exit 1
fi
}

check_version(){
if [[ ! "$base_dir" = /* ]] || [[ ! -d $base_dir ]]; then
    echo "Error - Please enter the absolute path or make sure the directory is present.";
    exit 1
else
   if [[ -e "$base_dir/cqube/.cqube_config" ]]; then
        installed_ver=$(cat $base_dir/cqube/.cqube_config | grep CQUBE_VERSION )
        installed_version=$(cut -d "=" -f2 <<< "$installed_ver")
         echo "Currently cQube $installed_version version is installed in this machine. Follow Upgradtion process if you want to upgrade."
         echo "If you re-run the installation, all data will be lost"
	 while true; do
             read -p "Do you still want to re-run the installation (yes/no)? " yn
             case $yn in
                 yes) break;;
                 no) exit;;
                 * ) echo "Please answer yes or no.";;
             esac
         done
   fi
fi
}

check_kc_config_otp(){
if ! [[ $2 == "true" || $2 == "false" ]]; then
    echo "Error - Please enter either true or false for $1"; fail=1
fi
}


check_postgres(){
echo "Checking for Postgres ..."
temp=$(psql -V > /dev/null 2>&1; echo $?)

if [ $temp == 0 ]; then
    version=`psql -V | head -n1 | cut -d" " -f3`
    if [[ $(echo "$version >= 10.12" | bc) == 1 ]]
    then
        echo "WARNING: Postgres found."
        echo "Removing Postgres..."
        sudo systemctl stop kong.service > /dev/null 2>&1
        sleep 5
        sudo systemctl stop keycloak.service > /dev/null 2>&1
        sleep 5
        sudo systemctl stop postgresql
        sudo apt-get --purge remove postgresql* -y
        echo "Done"
     fi
fi
}



get_config_values(){
key=$1
vals[$key]=$(awk ''/^$key:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
}

bold=$(tput bold)
normal=$(tput sgr0)
fail=0
if [[ ! $# -eq 0 ]]; then
   core_install=$1
else
   core_install="NA"
fi

echo -e "\e[0;33m${bold}Validating the config file...${normal}"


# An array of mandatory values
declare -a arr=("diksha_columns" "state_code" "static_datasource" "management" "base_dir") 

# Create and empty array which will store the key and value pair from config file
declare -A vals


# Getting base_dir
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)


# Iterate the array and retrieve values for mandatory fields from config file
for i in ${arr[@]}
do
get_config_values $i
done

for i in ${arr[@]}
do
key=$i
value=${vals[$key]}
case $key in
   
   diksha_columns)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_kc_config_otp $key $value
       fi
       ;;
   state_code)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_state $key $value
       fi
       ;;
   static_datasource)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_static_datasource $key $value
       fi
       ;;
   management)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       fi
       ;;
   base_dir)	 
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_base_dir $key $value
       fi
       ;;
   *)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}Error - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       fi
       ;;
esac
done

if [[ $fail -eq 1 ]]; then
   echo -e "\e[0;34m${bold}Config file has errors. Please rectify the issues and restart the installation${normal}"
   exit 1
else
   echo -e "\e[0;32m${bold}Config file successfully validated${normal}"
fi
