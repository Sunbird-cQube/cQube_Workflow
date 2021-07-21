#!/bin/bash 

check_usecase(){
uc_status=0
if [[ ! "$2" = /* ]] || [[ ! -d $2 ]]; then
    echo "Error - Please enter the absolute path or make sure the directory is present."; fail=1
    uc_status=1
else
   if [[ -e "$2/cqube/.cqube_config" ]] ; then
        uc=$(cat $2/cqube/.cqube_config | grep CQUBE_USECASE_NAME )
        uc_name=$(cut -d "=" -f2 <<< "$uc")
        if [[ ! "$1" == "$uc_name" ]]; then
            echo "Error - Usecase Name should be same as previous installation"; fail=1
            uc_status=1
        fi
    else
       echo "Error - Unable to find previous installation config files. Please check base installation directory"; fail=1
       uc_status=1
    fi
fi
if [[ $uc_status == 1 ]]; then
  echo "Please rectify the Usecase name error and restart the upgradation"
  exit 1
fi
}

base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' upgradation_config.yml)
usecase_name=$(awk ''/^usecase_name:' /{ if ($2 !~ /#.*/) {print $2}}' upgradation_config.yml)

#check_usecase $usecase_name $base_dir

if [[ $usecase_name == "" ]]; then
   echo "Error - in usecase_name. Unable to get the value. Please check."; fail=1
else

case $usecase_name in
   
   education_usecase)
	   
	if [[ -f ${usecase_name}_upgradation_config.yml ]]; then
        . $INS_DIR/${usecase_name}_upgradation_validate.sh
       else
          echo "ERROR: education_usecase_upgradation_config.yml is not available. Please copy education_usecase_upgradation_config.yml.template as education_usecase_upgradation_config.yml and fill all the details."
            exit;
   fi
       ;;
   test_usecase)
	if [[ -f ${usecase_name}_upgradation_config.yml ]]; then   
       . $INS_DIR/${usecase_name}_upgradation_validate.sh
       else
          echo "ERROR: test_usecase_upgradation_config.yml is not available. Please copy test_usecase_upgradation_config.yml.template as test_usecase_upgradation_config.yml and fill all the details."
            exit;
   fi
       ;;
   *)
       echo "Error - Please enter the correct value in usecase_name."; fail=1
       ;;
esac

fi
