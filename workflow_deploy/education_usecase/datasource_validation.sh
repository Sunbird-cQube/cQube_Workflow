
#!/bin/bash 

check_datasource(){

if ! [[ $2 == "true" || $2 == "false" ]]; then
    echo "Error - Please enter either true or false for $1"; fail=1
fi

while read line; do
  ext_ds=`echo "$line" | cut -d ":" -f1`  
  if [[ $ext_ds == $1 ]] ; then
     if ! [[ -d ../../development/datasource/$1 ]]; then
	echo "Error- $1  directory not found"       
     fi	
  fi
done < datasource_config.yml

}

get_config_values(){
key=$1
vals[$key]=$(awk ''/^$key:' /{ if ($2 !~ /#.*/) {print $2}}' datasource_config.yml)
}

bold=$(tput bold)
normal=$(tput sgr0)
fail=0
if [[ ! $# -eq 0 ]]; then
   core_install=$1
else
   core_install="NA"
fi

echo "Validating the Datasource_config.yml file..."

# An array of mandatory values
declare -a arr=("crc" "attendance" "infra" "diksha" "telemetry" "udise" "pat" "composite" "progresscard" "teacher_attendance" "data_replay" "sat")

# Create and empty array which will store the key and value pair from config file
declare -A vals


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
  crc)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  attendance)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  infra)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  diksha)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  telemetry)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  udise)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  pat)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  composite)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  healthcard)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  teacher_attendance)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  data_replay)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
       fi
       ;;
  sat)
       if [[ $value == "" ]]; then
          echo "Error - Value for $key cannot be empty. Please fill this value"; fail=1
       else
          check_datasource $key $value
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
   echo -e "\e[0;34m${bold}datasource_config.yml file has errors. Please rectify the issues and restart the process${normal}"
   exit 1
else
   echo -e "\e[0;32m${bold}datasource_config.yml file successfully validated${normal}"
fi

