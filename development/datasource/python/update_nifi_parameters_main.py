import requests
import logging
from nifi_env_db import nifi_port
import get_jolt_spec_db as jolt_spec



logging.basicConfig(level=logging.DEBUG)


def parameters_builder(name,sensitive,value="",description=""):
    """
    Function creates the parameter
    """
    parameter = {"parameter":{"name":"","sensitive":"","value":"","description":""}}
    parameter['parameter']['name']=name
    parameter['parameter']['sensitive']=sensitive
    parameter['parameter']['value']=value
    parameter['parameter']['description']=description
    return parameter

def parameter_list_builder(parameter_name,config_parameters):
    """
    Function creates the parameter body
    """
    parameters_list =  parameters_builder(parameter_name,False,config_parameters)
    return parameters_list

def get_parameter_context(parameter_context):
    """
    Function will get the parameter context details
    """
    res = requests.get('http://localhost:{}/nifi-api/flow/parameter-contexts'.format(nifi_port))
    if res.status_code == 200:
        for i in res.json()['parameterContexts']:
            if i['component']['name'] == parameter_context:
                return {"id":i['id'],"version":i['revision']['version'],"name":i['component']['name']}
    else:
        logging.error("Failed to get parameter contexts")
        return {"Error":"Failed to get parameter contexts","error":res.json()}


def update_parameters(nifi_parameters):
    '''
    Function will update parameter context 
    '''
    update_pr = requests.post("http://localhost:{}/nifi-api/parameter-contexts/{}/update-requests".format(nifi_port,nifi_parameters['id']),json=nifi_parameters)
    if update_pr.status_code == 200:
        print("Successfully updated the parameter!!")
        return update_pr
    else:
        logging.error("Error updating  parameter context details")
        return  {"Error":"Failed to update parameter context ","error":update_pr.json()}  


def update_parameter(par_data):
    # update the parameter into NiFi
    up_status=update_parameters(par_data)
    if up_status.status_code == 200:
        logging.info("Successfully updated parameter")
    return par_data
