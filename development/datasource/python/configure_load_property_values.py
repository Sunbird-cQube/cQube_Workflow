import deploy_nifi as dn
import properties_nifi_deploy as prop
import update_nifi_params
import requests as rq, time, logging, sys

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


def start_processor_group(processor_group_name, state):
    header = {"Content-Type": "application/json"}
    pg_source = get_processor_group_info(processor_group_name)
    start_body = {"id": pg_source['component']['id'],
                  "state": state, "disconnectedNodeAcknowledged": False}
    start_response = rq.put(
        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{pg_source['component']['id']}",
        json=start_body, headers=header)
    if start_response.status_code == 200:
        logging.info(f"Successfully {state} {pg_source['component']['name']} Processor Group.")
        return True
    else:
        return start_response.text


def get_processor_group_ports(processor_group_name):
    # Get processor group details
    pg_source = get_processor_group_info(processor_group_name)
    pg_details = rq.get(
        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{pg_source['component']['id']}")
    if pg_details.status_code != 200:
        return pg_details.text
    else:
        return pg_details


def nifi_update_processor_property(processor_group_name, processor_name, properties):
    """[Update the processor property in the processor group]
    Args:
        processor_group_name ([string]): [provide the processor group name]
        processor_name ([string]): [provide the processor name]
        properties([dict]): [property to update in processor]
    """

    # Get the processors in the processor group
    pg_source = get_processor_group_ports(processor_group_name)
    if pg_source.status_code == 200:
        for i in pg_source.json()['processGroupFlow']['flow']['processors']:
            # Get the required processor details
            if i['component']['name'] == processor_name:
                # Request body creation to update processor property.
                update_processor_property_body = {
                    "component": {
                        "id": i['component']['id'],
                        "name": i['component']['name'],
                        "config": {
                            "properties": properties

                        }
                    },
                    "revision": {
                        "clientId": "python code: configure_load_property_values.py",
                        "version": i['revision']['version']
                    },
                    "disconnectedNodeAcknowledged": "False"
                }

                update_processor_res = rq.put(
                    f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/processors/{i['component']['id']}",
                    json=update_processor_property_body)

                if update_processor_res.status_code == 200:
                    logging.info(
                        f"Successfully updated the properties: {properties} in {i['component']['name']} processor")
                    return True

                else:
                    return update_processor_res.text


if __name__ == '__main__':
    """[summary]
    sys arguments = 1.Processor group name. 2.From date 3.To date 4.Stop hour
    Updates the summary rollup start date and end date in nifi processor property.

    syntax: python update_processor_property.py <processor group name> <yyyy-mm-dd> <yyyy-mm-dd> <stop hour>
            Example: python update_processor_property.py diksha_transformer 2021-10-22 2021-10-23 1
    """
    filename = sys.argv[1]
    header = {"Content-Type": "application/json"}
    processor_group_name = ['validate_datasource', 'cQube_data_storage', 'transaction_and_aggregation']
    processor_name = ['config_trans_route_based_on_s3_dir', "route_based_on_s3_input_dir", 'route_based_on_content',
                      'get_year_month_from_temp','config_datasource_delete_temp','config_datasource_delete_staging_1_table',
                      'config_datasource_delete_staging_2_table','config_delete_staging_1_table','conf_delete_staging_1_table',
                      'conf_delete_staging_2_table','Route_on_zip']

    data_storage_processor = 'cQube_data_storage'
    conf_key = "configure_file"
    conf_key1 = "SQL select query"
    conf_key2 = "putsql-sql-statement"
    conf_value = '${' + 'filename:startsWith("{0}"):or('.format(
        filename) + '${' + 'azure.blobname:startsWith("{0}")'.format(filename) + '})}'
    conf_value1 = '${' + "filename:startsWith('{0}')".format(filename) +'}'
    conf_value2 = "select distinct year,month  from " + filename + "_temp where ff_uuid='${zip_identifier}'"
    conf_value3 = "delete from " +filename+"_temp where ff_uuid='${zip_identifier}';"
    conf_value4 = "truncate table "+filename+"_staging_1"
    conf_value5 = "truncate table " + filename + "_staging_2"

    processor_properties1 = {
        conf_key: conf_value
    }
    processor_properties2 = {
        conf_key: conf_value1
    }
    processor_properties3 = {
        conf_key1: conf_value2
    }
    processor_properties4 = {
        conf_key2: conf_value3
    }
    processor_properties5 = {
        conf_key2: conf_value4
    }
    processor_properties6 = {
        conf_key2: conf_value5
    }
    # Enable the validation template and update
    time.sleep(5)

    # Stops the processors
    start_processor_group(processor_group_name[0], 'STOPPED')
    start_processor_group(processor_group_name[1], 'STOPPED')
    start_processor_group(processor_group_name[2], 'STOPPED')
    start_processor_group(data_storage_processor, 'STOPPED')

    # update processor property.
    nifi_update_processor_property(processor_group_name[0], processor_name[0], processor_properties1)
    nifi_update_processor_property(processor_group_name[1], processor_name[1], processor_properties2)
    nifi_update_processor_property(processor_group_name[1], processor_name[2], processor_properties2)
    nifi_update_processor_property(processor_group_name[2], processor_name[3], processor_properties3)
    nifi_update_processor_property(processor_group_name[2], processor_name[4], processor_properties4)
    nifi_update_processor_property(processor_group_name[0], processor_name[5], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[6], processor_properties6)
    nifi_update_processor_property(processor_group_name[0], processor_name[7], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[8], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[9], processor_properties6)
    nifi_update_processor_property(processor_group_name[1], processor_name[10], processor_properties2)

    parameter_context_names = ['validate_datasource_parameters', 'transaction_and_aggregation_parameters']

    for parameter_context_name in parameter_context_names:
        # Load parameters from file to Nifi parameters
        parameter_body = {
            "revision": {
                "clientId": "value",
                "version": 0,
                "lastModifier": "Admin"
            },
            "component": {
                "name": parameter_context_name,
                "parameters": [

                ]
            }
        }
        # if (dn.params.get(parameter_context_name)) and (parameter_context_name != 'cQube_data_storage_parameters'):
        logging.info("Reading static parameters from file %s.txt", parameter_context_name)
        parameter_body = update_nifi_params.nifi_params_config(parameter_context_name,
                                                               f'{prop.NIFI_STATIC_PARAMETER_DIRECTORY_PATH}postgres/{filename}/parameters.txt',
                                                               parameter_body)
        print(parameter_body)
        dn.create_parameter(parameter_context_name, parameter_body)

    # Runs the processors
    start_processor_group(processor_group_name[0], 'RUNNING')
    start_processor_group(processor_group_name[1], 'RUNNING')
    start_processor_group(processor_group_name[2], 'RUNNING')
    start_processor_group(data_storage_processor, 'RUNNING')
    time.sleep(5)
