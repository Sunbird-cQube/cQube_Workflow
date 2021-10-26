import requests as rq
import json
import sys
import properties_nifi_deploy as prop
import update_nifi_params
import update_jolt_params
import logging

logging.basicConfig(level=logging.DEBUG)


# Get nifi root processor group ID
def get_nifi_root_pg():
    """ Fetch nifi root processor group ID"""
    res = rq.get(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/root')
    if res.status_code == 200:
        global nifi_root_pg_id
        nifi_root_pg_id = res.json()['component']['id']
        return res.json()['component']['id']
    else:
        return res.text


# Upload template to Nifi
def upload_nifi_template(template):
    """
    upload the nifi template to Nifi
    """
    # Get the root processor group id
    nifi_pg_id = get_nifi_root_pg()

    # upload the template to Nifi
    file = {'template': (f'{prop.NIFI_TEMPLATE_PATH}{template}.xml', open(
        f'{prop.NIFI_TEMPLATE_PATH}{template}.xml', 'rb')), }
    template_upload_res = rq.post(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{nifi_pg_id}/templates/upload', files=file)

    if template_upload_res.status_code == 201:
        return True
    else:
        return template_upload_res.text


# create parameter
def create_parameter(parameter_context,parameter_body):
    """
    create nifi parameter
    """
    # create the parameter in nifi
    create_parameter_res = rq.post(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/parameter-contexts', json=parameter_body, headers=header)
    if create_parameter_res.status_code == 201:
        logging.info("Successfully Created parameter context %s",parameter_context)
        return True
    else:
        return create_parameter_res.text


# Instantiate Nifi Template
def instantiate_template(template):
    """
    Instantiate nifi template
    """
    template_list = rq.get(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/templates')
    if template_list.status_code == 200:
        for i in template_list.json()['templates']:
            if i['template']['name'] == template:
                template_instantiate_body = {
                    "templateId": i['template']['id'], "originX": 423, "originY": 52, "disconnectedNodeAcknowledged": False}

                template_instantiate_res = rq.post(
                    f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{nifi_root_pg_id}/template-instance', json=template_instantiate_body, headers=header)
                if template_instantiate_res.status_code == 201:
                    logging.info("Successfully Instatiated the template.")
                else:
                    return template_instantiate_res.text

    else:
        return template_list.text


# Get the  processor group details
def get_processor_group_info(processor_group_name):
    """
    Get procesor group details
    """
    nifi_root_pg_id = get_nifi_root_pg()
    pg_list = rq.get(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{nifi_root_pg_id}')
    if pg_list.status_code == 200:

        # Iterate over processGroups and find the required processor group details
        for i in pg_list.json()['processGroupFlow']['flow']['processGroups']:
            if i['component']['name'] == processor_group_name:
                global processor_group
                processor_group = i
                return i
    else:
        return False


# Get parameter context details
def get_parameter_context(parameter_context):
    parameter_context_res = rq.get(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/parameter-contexts')
    if parameter_context_res.status_code == 200:
        for i in parameter_context_res.json()['parameterContexts']:
            if i['component']['name'] == parameter_context:
                return i
    else:
        return False


# Connection of processor groups to respective parameter contexts
def link_parameter_with_processor_group(processor_group_name, parameter_context):
    """[Link the parameter context with respective processor group]

    Args:
        processor_group_name ([string]): [provide the processor group name]
        parameter_context ([string]): [provide the parameter context name to link with processor group]
    """
    # Get the processor group details
    pg_id = get_processor_group_info(
        processor_group_name)  

    # Get the parameter context details
    parameter_context = get_parameter_context(parameter_context)
    
    # Link parameter context to respective processor group
    parameter_link_body = {"revision": {"version": pg_id['revision']['version'], "lastModifier": "Python"}, "component": {
        "id": pg_id['component']['id'], "parameterContext": {"id": parameter_context['id']}}}

    link_parameter_res = rq.put(
        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{pg_id['component']['id']}", json=parameter_link_body, headers=header)
    if link_parameter_res.status_code == 200:
        logging.info(
            "Successfully linked parameter context with processor group")
    else:
        return link_parameter_res.text


# create distributed server
def create_controller_service(processor_group_name, port):
    procesor_group = get_processor_group_info(
        processor_group_name)

    controller_service_body = {"revision": {"clientId": "Python", "version": 0, "lastModifier": "Python"},
                               "component": {"type": "org.apache.nifi.distributed.cache.server.map.DistributedMapCacheServer",
                                             "properties": {"Port": port}}}

    create_controller_service_res = rq.post(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{procesor_group['component']['id']}/controller-services",
                                            json=controller_service_body, headers=header)
    if create_controller_service_res.status_code == 201:
        logging.info("Successfully Created distributed server")
    else:
        return create_controller_service_res.text


# List controller services
def get_controller_list(processor_group_name):
    controller_list_res = rq.get(
        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{processor_group_name['component']['id']}/controller-services")
    if controller_list_res.status_code == 200:
        return controller_list_res.json()
    else:
        return controller_list_res.text


# update controller service property # dynamic should be enabled
def update_controller_service_property(processor_group_name, controller_name):
    controller_details = get_controller_list(
        get_processor_group_info(processor_group_name))
    for i in controller_details['controllerServices']:
        if i['component']['name'] == controller_name:

            # Request body for aws controller
            update_controller_body_aws = {"revision": {
                "version": i['revision']['version'],
                "lastModifier": "Python"
            },
                "component": {"id": i['component']['id'], "name": controller_name,
                              "properties": {"Access Key": "#{s3_access_key}", "Secret Key": "#{s3_secret_key}"}}

            }
            # Request body for postgres controller
            update_controller_body_postgres = {"revision": {
                "version": i['revision']['version'],
                "lastModifier": "Python"
            },
                "component": {"id": i['component']['id'], "name": controller_name,
                              "properties": {"Password": "#{db_password}"}}

            }

            # controller body selection based on controller name
            update_controller_body = ''
            if "s3" in controller_name:

                update_controller_body = update_controller_body_aws
            elif "postgres" in controller_name:

                update_controller_body = update_controller_body_postgres

            update_controller_res = rq.put(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/controller-services/{i['component']['id']}",
                                           json=update_controller_body, headers=header)

            if update_controller_res.status_code == 200:
                return True
            else:
                return update_controller_res.text


# start or stop controller services
def controller_service_enable(processor_group_name):
    controller_details = get_controller_list(
        get_processor_group_info(processor_group_name))
    for i in controller_details['controllerServices']:
        if i['component']['state'] == 'DISABLED':

            controller_service_enable_body = {"revision": {
                "version": i['revision']['version'], }, "state": "ENABLED"}
            controller_service_enable_res = rq.put(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/controller-services/{i['component']['id']}/run-status",
                                                   json=controller_service_enable_body, headers=header)

            if controller_service_enable_res.status_code == 200:
                logging.info("Enabled Controller services")
                logging.info(
                    f"Controller Name = {controller_service_enable_res.json()['component']['name']}")
                logging.info(
                    f"Controller State = {controller_service_enable_res.json()['component']['state']}")

            else:
                return controller_service_enable_res.text


# Main # sys arguments 1. Template name 2. parameter context name 3. distributed server port
if __name__ == "__main__":
    nifi_root_pg_id = ''
    processor_group = ''
    header = {"Content-Type": "application/json"}

    processor_group_name = sys.argv[1]
    parameter_context_name = sys.argv[2]
    logging.info("Uploading Template to Nifi......")
    # 1.  Upload nifi template  # sys arg 1 - template name
    template_upload_status = upload_nifi_template(processor_group_name)
    if template_upload_status == True:
        logging.info("Successfully uploaded the template.")
    else:
        print(template_upload_status)

    # 2. Instantiate template
    logging.info("Instatiating the template.")
    instantiate_template(processor_group_name)

    #  3. Create parameters
    params = {
        'infra_parameters': 'infra_parameters.txt',
        'diksha_parameters': 'diksha_parameters.txt',
        'static_data_parameters': 'static_data_parameters.txt',
        'crc_parameters': 'crc_parameters.txt',
        'student_attendance_parameters': 'student_attendance_parameters.txt',
        'teacher_attendance_parameters': 'teacher_attendance_parameters.txt',
        'sat_parameters':'sat_parameters.txt',
        'cqube_telemetry_parameters': 'cqube_telemetry_parameters.txt',
        'cQube_data_storage_parameters': 'cQube_data_storage_parameters.txt',
        'udise_parameters': 'udise_parameters.txt',
        'composite_parameters': 'composite_parameters.txt',
        'progress_card_parameters':'progress_card_parameters.txt',
        'pat_parameters': 'pat_parameters.txt',
        'data_replay_parameters':'data_replay_parameters.txt'
        
    }
    # read the parameter file created by Ansible using configuration
    logging.info("Reading dynamic parameters from file %s.json",parameter_context_name)
    f = open(f'{prop.NIFI_PARAMETER_DIRECTORY_PATH}{parameter_context_name}.json', "rb")
    parameter_body = json.loads(f.read())
    
    # Load parameters from file to Nifi parameters
    if (params.get(parameter_context_name)) and (parameter_context_name !='cQube_data_storage_parameters'):        
        logging.info("Reading static parameters from file %s.txt",parameter_context_name)
        parameter_body=update_nifi_params.nifi_params_config(parameter_context_name, f'{prop.NIFI_STATIC_PARAMETER_DIRECTORY_PATH}{params.get(parameter_context_name)}',parameter_body)
    create_parameter(parameter_context_name,parameter_body)
    
    
    # Load dynamic Jolt spec from db to Nifi parameters
    dynamic_jolt_params_pg = ['composite_parameters',
                             'infra_parameters', 'udise_parameters']
    if sys.argv[2] in dynamic_jolt_params_pg:
        logging.info("Creating dynamic jolt parameters")
        update_jolt_params.update_nifi_jolt_params(parameter_context_name)
    
    # 4. Link parameter context to processor group
    logging.info("Linking parameter context with processor group")
    link_parameter_with_processor_group(processor_group_name, parameter_context_name)

    # 5. Create controller services
    if int(sys.argv[3]) !=0:
        logging.info("Creating distributed server")
        print(create_controller_service(processor_group_name, sys.argv[3]))

    # 6. Add sensitive value to controller services
    logging.info("Adding sensitive properties in controller services")
    controller_list_all = {
        'infra_transformer': ['cQube_s3_infra', 'postgres_infra'],
        'cQube_data_storage': ['cQube_s3_static_raw', 'postgres_static_raw'],
        'static_data_processor': ['cQube_s3_static', 'postgres_static'],
        'diksha_transformer': ['cQube_s3_diksha', 'postgres_diksha'],
        'static_data_transformer': ['cQube_s3_static', 'postgres_static'],
        'crc_transformer': ['cQube_s3_crc', 'postgres_crc'],
        'student_attendance_transformer': ['cQube_s3_stud_att', 'postgres_stud_att'],
        'teacher_attendance_transformer': ['cQube_s3_tch_att', 'postgres_tch_att'],
        'sat_transformer': ['cQube_s3_sat', 'postgres_sat'],
        'cqube_telemetry_transformer': ['cQube_s3_cqube_telemetry', 'postgres_cqube_telemetry'],
        'udise_transformer': ['cQube_s3_udise', 'postgres_udise'],
        'composite_transformer': ['cQube_s3_composite', 'postgres_composite'],
        'pat_transformer': ['cQube_s3_pat', 'postgres_pat'],
        'data_replay_transformer': ['cQube_s3_data_replay', 'postgres_data_replay'],
        'progress_card_transformer': ['cQube_s3_progress_card', 'postgres_progress_card']
    }
    
    if controller_list_all.get(processor_group_name):
        for controller in controller_list_all.get(processor_group_name):
            print(update_controller_service_property(processor_group_name, controller))

    # 7. Enable controller service
    logging.info("Enabling Controller services")
    controller_service_enable(processor_group_name)
    logging.info("***Successfully Loaded template and enabled controller services***")
