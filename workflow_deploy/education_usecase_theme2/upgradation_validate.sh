#!/bin/bash 

check_keycloak_credentials(){
$base_dir/cqube/keycloak/bin/kcadm.sh get realms --no-config --server http://localhost:8080/auth --realm master --user $1 --password $2 > /dev/null 2>&1
if [ ! $? -eq 0 ]; then 
  echo "Error - Invalid keycloak user or password"; fail=1
fi

$base_dir/cqube/keycloak/bin/kcadm.sh get realms/$realm_name --no-config --server http://localhost:8080/auth --realm master --user $1 --password $2 > /dev/null 2>&1
if [ ! $? -eq 0 ]; then 
  echo "Error - Unable to find cQube realm"; fail=1
fi
}

check_kc_config_otp(){
if ! [[ $2 == "true" || $2 == "false" ]]; then
    echo "Error - Please enter either true or false for $1"; fail=1
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

check_state()
{
sc=$(cat $base_dir/cqube/.cqube_config | grep CQUBE_STATE_CODE )
installed_state_code=$(cut -d "=" -f2 <<< "$sc")
if [[ ! "$2" == "$installed_state_code" ]]; then
    echo "Error - State code should be same as previous installation. Please refer the state_list file and enter the correct value."; fail=1
fi
}

check_static_datasource(){
if ! [[ $2 == "udise" || $2 == "state" ]]; then
    echo "Error - Please enter either udise or state for $1"; fail=1
    else
    if [[ -e "$base_dir/cqube/.cqube_config" ]] ; then
        static_dts=$(cat $base_dir/cqube/.cqube_config | grep CQUBE_STATIC_DATASOURCE )
        dts=$(cut -d "=" -f2 <<< "$static_dts")
        if [[ ! "$2" == "$dts" ]]; then
            echo "Error - Static_datasource should be same as previous installation static_datasource"; fail=1
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
       echo "Error - Unable to find previous installation config files. Please check base installation directory"; fail=1
       base_dir_status=1
    fi
fi
if [[ $base_dir_status == 1 ]]; then
  echo "Please rectify the base_dir error and restart the upgradation"
  exit 1
fi
}

check_s3_bucket(){

s3_bucket=$(cat $base_dir/cqube/.cqube_config | grep $3 )
s3_bucket_name=$(cut -d "=" -f2 <<< "$s3_bucket")
if [[ ! "$2" == "$s3_bucket_name" ]]; then
    echo "Error - $1 must be same as previously used bucket"; fail=1
fi

}

check_version(){

# getting the installed version
if [[ ! "$base_dir" = /* ]] || [[ ! -d $base_dir ]]; then
    echo "Error - Please enter the absolute path or make sure the directory is present."; 
    exit 1
else
   if [[ -e "$base_dir/cqube/.cqube_config" ]]; then
        installed_ver=$(cat $base_dir/cqube/.cqube_config | grep CQUBE_WORKFLOW_VERSION )
        installed_version=$(cut -d "=" -f2 <<< "$installed_ver")
    else
       echo "Error - Invalid base_dir or Unable to find the cQube in given base_dir";
       exit 1
    fi
fi

# getting this release version
if [[ -e ".version" ]]; then
    this_version=$(awk ''/^cqube_workflow_version:' /{ if ($2 !~ /#.*/) {print $2}}' .version)
    this_version=$(sed -e 's/^"//' -e 's/"$//' <<<"$this_version")
    if [[ $this_version == "" ]] || [[ ! `echo $this_version | grep -E '^[0-9]{1,2}\.[0-9]{1,2}\.?[0-9]{1,2}?$'` ]]; then
       echo "Error - cQube's constant settings are affected. Re-clone the repository again";
       exit 1 
    fi
else
   echo "Error - cQube's constant settings are affected. Re-clone the repository again";
   exit 1
fi

reupgrade=0
if [[ $installed_version == $this_version ]]; then
   echo "cQube is already upgraded to $this_version version.";
   while true; do
    read -p "Do you wish to rerun the upgrade (yes/no)? " yn
    case $yn in
        yes) 
	        reupgrade=1	
		      break;;
        no) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi

if [[ $reupgrade == 0 ]]; then
   if [[ ! $installed_version == $version_upgradable_from ]]; then
        echo "Version $this_version is only upgradeable from $version_upgradable_from version";
        exit 1
   fi
fi
}

check_postgres(){
echo "Checking for Postgres ..."
temp=$(psql -V > /dev/null 2>&1; echo $?)
check_postgres_status=0
if [ ! $temp == 0 ]; then
    echo "Error - Unable to check the Postgres."; fail=1
    check_postgres_status=1
fi
}


check_ip()
{
    local ip=$2
    ip_stat=1
    ip_pass=0

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        ip_stat=$?
        if [[ ! $ip_stat == 0 ]]; then
            echo "Error - Invalid value for $key"; fail=1
            ip_pass=0
        fi
        is_local_ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'` > /dev/null 2>&1
        if [[ $ip_pass == 0 && $is_local_ip != *$2* ]]; then
            echo "Error - Invalid value for $key. Please enter the local ip of this system."; fail=1 
        fi
    else
        echo "Error - Invalid value for $key"; fail=1
    fi
}

check_vpn_ip()
{
    local ip=$2
    ip_stat=1
    ip_pass=0

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        ip_stat=$?
        if [[ ! $ip_stat == 0 ]]; then
            echo "Error - Invalid value for $key"; fail=1
            ip_pass=0
        fi
    else
        echo "Error - Invalid value for $key"; fail=1
    fi
}

check_aws_key(){
    aws_key_status=0
    export AWS_ACCESS_KEY_ID=$1
    export AWS_SECRET_ACCESS_KEY=$2
    aws s3api list-buckets > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then echo "Error - Invalid aws access or secret keys"; fail=1
        aws_key_status=1
    fi
}

check_db_naming(){
dir=$(cat $base_dir/cqube/.cqube_config | grep $3 )
temp_db_name=$(cut -d "=" -f2 <<< "$dir")
if [[ ! $temp_db_name == $2 ]]; then
   echo "Error - $1 should be same as previous installation"; fail=1
fi
}

check_db_password(){
if [[ $check_postgres_status == 0 ]]; then 
    export PGPASSWORD=$3
    psql -h localhost -d $1 -U $2 -c "\l" > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then echo "Error - Invalid Postgres credentials"; fail=1
    fi
else
   "Error - Since unable to check Postgres, credentials could not verified."; fail=1
fi
}

# Only for release 1.9
check_length(){
    len_status=1
    str_length=${#1}
    if [[ $str_length -ge 3 && $str_length -le 63 ]]; then 
        len_status=0
        return $len_status;
    else 
        return $len_status;
    fi
}

check_api_endpoint(){
temp_ep=`grep '^KEYCLOAK_HOST =' $base_dir/cqube/dashboard/server_side/.env | awk '{print $3}' | sed s/\"//g`
if [[ ! $temp_ep == "https://$2" ]]; then
    echo "Error - Change in domain name. Please verify the api_endpoint "; fail=1
fi
}

check_aws_default_region(){
    region_len=${#2}
    if [[ $region_len -ge 9 ]] && [[ $region_len -le 15 ]]; then
        curl https://s3.$2.amazonaws.com > /dev/null 2>&1
        if [[ ! $? == 0 ]]; then 
            echo "Error - There is a problem reaching the aws default region. Please check the $1 value." ; fail=1
        fi
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

check_map_name(){
if ! [[ $2 == "mapmyindia" || $2 == "googlemap" || $2 == "leafletmap" ]]; then
    echo "Error - Please enter either mapmyindia or googlemap or leafletmap for $1"; fail=1
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
declare -a arr=("base_dir" "state_code" "diksha_columns" "static_datasource" "management"  "session_timeout" "map_name" "google_api_key")

# Create and empty array which will store the key and value pair from config file
declare -A vals

# Constant variables
realm_name=cQube


# Getting base_dir
map_name=$(awk ''/^map_name:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

check_mem
# Check the version before starting validation
version_upgradable_from=3.0
check_version

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
   google_api_key)
          check_google_api_key $key $value
       ;;       
   *)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}Error - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       fi
       ;;
esac
done

if [[ $fail -eq 1 ]]; then
   echo -e "\e[0;34m${bold}Config file has errors. Please rectify the issues and restart the upgradation${normal}"
   exit 1
else
   echo -e "\e[0;32m${bold}Config file successfully validated${normal}"
fi
