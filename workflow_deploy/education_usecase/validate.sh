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

check_timeout()
{
  if [[ $2 =~ ^[0-9]+[M|D]$  ]] ; then
        raw_value="$( echo "$2" | sed -e 's/[M|D]$//' )"
        if [[ ! $raw_value == 0 ]]; then
		    if [[ $2 =~ M$ ]] ; then
		    	if [[ $raw_value -ge 30 && $raw_value -le 5256000 ]]; then 
		    		timeout_value=$(($raw_value*60))
		    	else
		    		echo "Error - Minutes should be between 30 and 5256000"; fail=1
		    	fi
		    fi
		    if [[ $2 =~ D$ ]] ; then
		    	if [[ $raw_value -ge 1 && $raw_value -le 3650 ]]; then 
		    		timeout_value=$(($raw_value*24*60*60))
		    	else
		    		echo "Error - Days should be between 1 and 3650"; fail=1
		    	fi
		    fi
		else
			echo "Error - Timeout should not be 0"; fail=1
	    fi
    else
        echo "Error - please enter proper value as mentioned in comments"; fail=1
    fi
sed -i '/session_timeout_in_seconds:/d' ../ansible/roles/keycloak/vars/main.yml
echo "session_timeout_in_seconds: $timeout_value" >> ../ansible/roles/keycloak/vars/main.yml
}

check_static_datasource(){
if ! [[ $2 == "udise" || $2 == "state" ]]; then
    echo "Error - Please enter either udise or state for $1"; fail=1
else
    if [[ -e "$base_dir/cqube/.cqube_config" ]]; then
        static_datasource=$( grep CQUBE_STATIC_DATASOURCE $base_dir/cqube/.cqube_config )
        current_datasource=$(cut -d "=" -f2 <<< "$static_datasource")
        if [[ ! $current_datasource == "" ]]; then
            if [[ ! $current_datasource == $2 ]]; then
                sed -i '/datasource_status/c\datasource_status: unmatched' ../ansible/roles/createdb/vars/main.yml
                echo "static_datasource value from config.yml is not matching with previous installation value. If continued with this option, it will truncate the tables from db and clear the objects from output bucket."
                while true; do
                    read -p "yes to continue, no to cancel the installation (yes/no)? : " yn
                    case $yn in
                        yes) break;;
                        no) echo "Cancelling the installation."
                            exit ;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            else
                sed -i '/datasource_status/c\datasource_status: matched' ../ansible/roles/createdb/vars/main.yml
             fi
        else
            sed -i '/datasource_status/c\datasource_status: matched' ../ansible/roles/createdb/vars/main.yml
        fi
    fi
fi
}

check_base_dir(){
base_dir_status=0
if [[ ! "$2" = /* ]] || [[ ! -d $2 ]]; then
    echo "Error - Please enter the absolute path or make sure the directory is present."; fail=1
    base_dir_status=1
else
   if [[ -e "$2/cqube/.cqube_config" ]] && [[ -e "$2/cqube/conf/base_config.yml" ]]; then
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
        installed_ver=$(cat $base_dir/cqube/.cqube_config | grep CQUBE_WORKFLOW_VERSION )
        installed_version=$(cut -d "=" -f2 <<< "$installed_ver") 
	if [[ ! $installed_version == "" ]]; then	
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
fi
}

check_kc_config_otp(){
if ! [[ $2 == "true" || $2 == "false" ]]; then
    echo "Error - Please enter either true or false for $1"; fail=1
fi
}

check_mem(){
mem_total_kb=`grep MemTotal /proc/meminfo | awk '{print $2}'`
mem_total=$(($mem_total_kb/1024))

if [ $(( $mem_total / 1024 )) -ge 30 ] && [ $(($mem_total / 1024)) -le 60 ] ; then
  min_shared_mem=$(echo $mem_total*13/100 | bc)
  min_work_mem=$(echo $mem_total*2/100 | bc)
  min_java_arg_2=$(echo $mem_total*13/100 | bc)
  min_java_arg_3=$(echo $mem_total*65/100 | bc)
  echo """---
shared_buffers: ${min_shared_mem}MB
work_mem: ${min_work_mem}MB
java_arg_2: -Xms${min_java_arg_2}m
java_arg_3: -Xmx${min_java_arg_3}m""" > memory_config.yml

elif [ $(( $mem_total / 1024 )) -gt 60 ]; then
  max_shared_mem=$(echo $mem_total*13/100 | bc)
  max_work_mem=$(echo $mem_total*2/100 | bc)
  max_java_arg_2=$(echo $mem_total*7/100 | bc)
  max_java_arg_3=$(echo $mem_total*65/100 | bc)
  echo """---
shared_buffers: ${max_shared_mem}MB
work_mem: ${max_work_mem}MB
java_arg_2: -Xms${max_java_arg_2}m
java_arg_3: -Xmx${max_java_arg_3}m""" > memory_config.yml
else
  echo "Error - Minimum Memory requirement to install cQube is 32GB. Please increase the RAM size."; 
  exit 1
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

check_theme(){
if ! [[ $2 == "theme1" || $2 == "theme2" || $2 == "theme3" ]]; then
    echo "Error - Please enter either theme1 or theme2 or theme3 for $1"; fail=1
fi
}

check_map_name(){
if ! [[ $2 == "mapmyindia" || $2 == "googlemap" || $2 == "leafletmap" || $2 == "none" ]]; then
    echo "Error - Please enter either mapmyindia or googlemap or leafletmap or none for $1"; fail=1
fi
}

check_google_api_key(){
if [[ $map_name == "googlemap" ]]; then
    if [[ -z $2 ]]; then  
        echo "Error - Please enter google_api_key value it should not be empty $1"; fail=1
    else
    google_api_status=`curl -X POST https://language.googleapis.com/v1/documents:analyzeEntities\?key\=$2 -o /dev/null -s -w "%{http_code}\n"`

    if [[ $google_api_status == 400 ]]; then
         echo "Error - Invalid google api key. Please check the $1 value." ; fail=1
    fi
	    
   fi 
fi    
}

check_slab(){
if [[ $slab1 =~ ^[0-9]{,2}$ && $slab2 =~ ^[0-9]{,2}\-[0-9]{,2}$ && $slab3 =~ ^[0-9]{,2}\-[0-9]{,2}$ && $slab4 =~ ^[0-9]{,2}$ ]]; then

if ! [[ $slab1 -ge 1 && $slab1 -le 100 ]]; then
 echo "Error - Incorrect slab1 value please refer the slab1 comment in config.yml" ; fail=1
fi

slab21=`echo $slab2 | cut -d- -f1`
slab22=`echo $slab2 | cut -d- -f2`

if ! [[ $slab21 -eq $slab1 && $slab21 -le 100 ]]; then
 echo "Error - Incorrect slab2 value please refer the slab2 comment in config.yml" ; fail=1
fi

if ! [[ $slab22 -gt $slab21 && $slab22 -le 100 ]]; then
 echo "Error - Incorrect slab2 value please refer the slab2 comment in config.yml" ; fail=1	
fi

slab31=`echo $slab3 | cut -d- -f1`
slab32=`echo $slab3 | cut -d- -f2`

if ! [[ $slab31 -eq $slab22 && $slab31 -le 100 ]]; then
echo "Error - Incorrect slab3 value please refer the slab3 comment in config.yml" ; fail=1	
fi

if ! [[ $slab32 -gt $slab31 && $slab32 -le 100 ]]; then
echo "Error - Incorrect slab3 value please refer the slab3 comment in config.yml" ; fail=1 
fi

if ! [[ $slab4 -eq $slab32 && $slab4 -le 100 ]]; then
echo "Error - Incorrect slab4 value please refer the slab4 comment in config.yml" ; fail=1
fi

else
	echo "Error - Incorrect slab value please refer the slab comments in config.yml " ; fail=1
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
declare -a arr=("base_dir" "state_code" "diksha_columns" "static_datasource" "management" "session_timeout" "map_name" "theme" "google_api_key" "slab1" "slab2" "slab3" "slab4" "auth_api")  
# Create and empty array which will store the key and value pair from config file
declare -A vals


# Getting base_dir

map_name=$(awk ''/^map_name:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
slab1=$(awk ''/^slab1:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
slab2=$(awk ''/^slab2:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
slab3=$(awk ''/^slab3:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
slab4=$(awk ''/^slab4:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

#check_mem
check_version 

# Iterate the array and retrieve values for mandatory fields from config file
for i 
	in ${arr[@]}
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
   session_timeout)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_timeout $key $value
       fi
       ;;
   map_name)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_map_name $key $value
       fi
       ;;
   theme)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_theme $key $value
       fi
       ;;
   google_api_key)
          check_google_api_key $key $value
       ;;
   slab1)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_slab $key $value
       fi
       ;;    
   slab2)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_slab $key $value
       fi
       ;;
   slab3)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_slab $key $value
       fi
       ;;
   slab4)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
       else
          check_slab $key $value
       fi
       ;;
   auth_api)
       if [[ $value == "" ]]; then
          echo "Error - in $key. Unable to get the value. Please check."; fail=1
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
