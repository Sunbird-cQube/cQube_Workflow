from update_nifi_parameters_main import *
import time
import ast


def nifi_params_config(param_name, filename,par_data):
    params = {param_name: filename}
    for param_name, filename in params.items():
        with open(filename, 'r') as fd:
            parameter_data = fd.read()
        parameter_dict = ast.literal_eval(parameter_data)
        for parameter_name, value in parameter_dict.items():
            parameter_body = parameter_list_builder(parameter_name, value)
            par_data['component']['parameters'].append(parameter_body)
    
    return par_data
