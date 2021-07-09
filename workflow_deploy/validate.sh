#!/bin/bash 

#INS_DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$INS_DIR" ]]; then INS_DIR="$PWD"; fi

usecase_name=$(awk ''/^usecase_name:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

if [[ $usecase_name == "" ]]; then
   echo "Error - in usecase_name. Unable to get the value. Please check."; fail=1
else

case $usecase_name in
   
   uc1_edu)
       . $INS_DIR/uc1_validate.sh
       ;;
   uc2_edu)
       . $INS_DIR/uc2_validate.sh
       ;;
   *)
       echo "Error - Please enter the correct value in usecase_name."; fail=1
       ;;
esac

fi
