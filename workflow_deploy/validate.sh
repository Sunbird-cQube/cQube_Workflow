#!/bin/bash 

#INS_DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$INS_DIR" ]]; then INS_DIR="$PWD"; fi

usecase_name=$(awk ''/^usecase_name:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

if [[ $usecase_name == "" ]]; then
   echo "Error - in usecase_name. Unable to get the value. Please check."; fail=1
else

case $usecase_name in
   
   education_usecase)
	 if [[ -f ${usecase_name}_config.yml ]]; then

       . $INS_DIR/${usecase_name}_validate.sh
       else 
	  echo "ERROR: education_usecase_config.yml is not available. Please copy education_usecase_config.yml.template as education_usecase_config.yml and fill all the details."
            exit;
   fi
     
       ;;
   test_usecase)
	 if [[ -f ${usecase_name}_config.yml ]]; then 
       . $INS_DIR/${usecase_name}_validate.sh
       else
          echo "ERROR: test_usecase_config.yml is not available. Please copy test_usecase_config.yml.template as test_usecase_config.yml and fill all the details."
            exit;
   fi

       ;;
   *)
       echo "Error - Please enter the correct value in usecase_name."; fail=1
       ;;
esac

fi
