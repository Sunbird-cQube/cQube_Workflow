import logging

import requests as rq
import sys
import time
from update_nifi_parameters_main import *
import properties_nifi_deploy as prop
import update_nifi_params
from yaml.loader import SafeLoader
import yaml
import psycopg2
from update_nifi_parameters_main import get_parameter_context, update_parameter
import ast


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
        logging.error(f"Failed {state} {pg_source['component']['name']} Processor Group.")
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
            logging.info(
                f"Started updating the properties: {properties} in {i['component']['name']} processor")
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
                    logging.info(
                        f"Failed to update the properties: {properties} in {i['component']['name']} processor")
                    return update_processor_res.text


def parse_file(filename_path, key):
    with open(filename_path, 'r') as fd:
        parameter_data = fd.read()
    parameter_dict = ast.literal_eval(parameter_data)
    date_columns = parameter_dict.get(key)

    return date_columns


def execute_sql(state):
    with open('../../conf/base_config.yml') as f:
        data = yaml.load(f, Loader=SafeLoader)
        db_user = 'postgres'
        db_name = data['db_name']

    # establishing the connection
    conn = psycopg2.connect(
        database=db_name, user=db_user, host='localhost', port='5432')
    if conn:
        # Creating a cursor object using the cursor() method
        cursor = conn.cursor()
        cursor.execute(
            f"update configurable_datasource_properties set state ='{state}' where datasource_name ='{filename}'")
        conn.commit()
        conn.close()


if __name__ == '__main__':
    """[summary]
    sys arguments = 1.Processor group name
    According to the Datasource name will update the property and value
    """
    filename = sys.argv[1]
    processor_group_name = ['validate_datasource', 'cQube_data_storage', 'transaction_and_aggregation']
    processor_name = ['config_listing_files_from_emission', "route_based_on_s3_input_dir", 'route_based_on_content',
                      'get_year_month_from_temp', 'config_datasource_delete_temp',
                      'config_datasourcedelete_staging_1_table',
                      'config_datasource_delete_staging_2_table', 'config_delete_staging_1_table',
                      'conf_delete_staging_1_table',
                      'conf_delete_staging_2_table', 'Route_on_zip', 'temp_trans_agg_add_qry_filename',
                      'add_ff_uuid_and_convert_date', 'convert_date_to_ist', 'convert_management_date_to_ist',
                      'partition_according_columns_daily_queries', 'partition_management', 'config_datasource_save_s3_log_summary',
                      'config_datasource_update_filename_local', 'convert_date_to_ist1', 'convert_date_to_ist2',
                      'partition_according_year_month_week','convert_date_to_ist3','partition_according_year_month_week_subject_queries','partition_according_year_month_week_grade_queries']


    data_storage_processor = 'cQube_data_storage'
    conf_key = "configure_file"
    conf_key1 = "SQL select query"
    conf_key2 = "putsql-sql-statement"
    conf_key3 = "filename"
    conf_key4 = "Object Key"
    conf_value = '${' + 'filename:startsWith("{0}"):or('.format(
        filename) + '${' + 'azure.blobname:startsWith("{0}")'.format(filename) + '})}'
    conf_value1 = '${' + "filename:startsWith('{0}')".format(
        filename) + ':and(${path:startsWith("config"):or(${filename:startsWith("config"):or(${azure.blobname:startsWith("config")})}):not()})}'
    conf_value7 = '${' + "emission_filename:startsWith('{0}')".format(filename) + '}'
    conf_value2 = "select distinct academic_year,month  from " + filename + "_temp where ff_uuid='${zip_identifier}'"
    conf_value3 = "delete from " + filename + "_temp where ff_uuid='${zip_identifier}';"
    conf_value4 = "truncate table " + filename + "_staging_1"
    conf_value5 = "truncate table " + filename + "_staging_2"
    conf_value6 = "#{base_dir}/cqube/emission_app/python/postgres/" + filename + "/#{temp_trans_aggregation_queries}"
    conf_value8 = "log_summary_" + filename + ".json"
    conf_value9 = "log_summary/log_summary_" + filename + ".json"
    # Date_column_update
    res = parse_file(f'{prop.NIFI_STATIC_PARAMETER_DIRECTORY_PATH}postgres/{filename}/parameters.txt', 'date_column')
    res = ast.literal_eval(res)
    processor_properties_date = {}
    for date_column_name in res:
        date_value = "${field.value:format('yyyy-MM-dd','IST')}"
        date_key = "/{0}".format(date_column_name)
        processor_properties_date.update({date_key: date_value})

    # Partition_date_column_upload
    partition_res = parse_file(f'{prop.NIFI_STATIC_PARAMETER_DIRECTORY_PATH}postgres/{filename}/parameters.txt',
                               'partition_select_column')
    partition_date_key = 'day'
    partition_date_value = "/{0}".format(partition_res)

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
    processor_properties7 = {
        conf_key3: conf_value6
    }
    processor_properties8 = {
        partition_date_key: partition_date_value
    }
    processor_properties9 = {
        conf_key: conf_value7
    }
    processor_properties10 = {
        conf_key4: conf_value9
    }
    processor_properties11 = {
        conf_key3: conf_value8
    }

    # Stops the processors

    start_processor_group(processor_group_name[0], 'STOPPED')
    start_processor_group(processor_group_name[1], 'STOPPED')
    start_processor_group(processor_group_name[2], 'STOPPED')

    # update processor property.
    nifi_update_processor_property(processor_group_name[0], processor_name[0], processor_properties1)
    nifi_update_processor_property(processor_group_name[1], processor_name[1], processor_properties2)
    nifi_update_processor_property(processor_group_name[1], processor_name[2], processor_properties9)
    nifi_update_processor_property(processor_group_name[2], processor_name[3], processor_properties3)
    nifi_update_processor_property(processor_group_name[2], processor_name[4], processor_properties4)
    nifi_update_processor_property(processor_group_name[0], processor_name[5], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[6], processor_properties6)
    nifi_update_processor_property(processor_group_name[0], processor_name[7], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[8], processor_properties5)
    nifi_update_processor_property(processor_group_name[0], processor_name[9], processor_properties6)
    nifi_update_processor_property(processor_group_name[1], processor_name[10], processor_properties2)
    nifi_update_processor_property(processor_group_name[2], processor_name[11], processor_properties7)
    nifi_update_processor_property(processor_group_name[0], processor_name[12], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[13], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[14], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[15], processor_properties8)
    nifi_update_processor_property(processor_group_name[2], processor_name[16], processor_properties8)
    nifi_update_processor_property(processor_group_name[1], processor_name[17], processor_properties10)
    nifi_update_processor_property(processor_group_name[1], processor_name[18], processor_properties11)
    nifi_update_processor_property(processor_group_name[2], processor_name[19], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[20], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[21], processor_properties8)
    nifi_update_processor_property(processor_group_name[2], processor_name[22], processor_properties_date)
    nifi_update_processor_property(processor_group_name[2], processor_name[23], processor_properties8)
    nifi_update_processor_property(processor_group_name[2], processor_name[24], processor_properties8)


    # Update the parameters to validate_datasource_parameters, transaction_and_aggregation_parameters
    parameter_context_names = ['validate_datasource_parameters', 'transaction_and_aggregation_parameters']
    for parameter_context_name in parameter_context_names:
        # Load parameters from file to Nifi parameterss
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
        logging.info("Reading static parameters from file %s.txt", parameter_context_name)
        parameter_body = update_nifi_params.nifi_params_config(parameter_context_name,
                                                               f'{prop.NIFI_STATIC_PARAMETER_DIRECTORY_PATH}postgres/{filename}/parameters.txt',
                                                               parameter_body)
        pc = get_parameter_context(parameter_context_name)
        parameter_body['revision']['version'] = pc['version']
        parameter_body['id'] = pc['id']
        parameter_body['component']['id'] = pc['id']
        parameter_body['component']['name'] = pc['name']
        update_parameter(parameter_body)

    # Runs the processors
    start_processor_group(processor_group_name[0], 'RUNNING')
    start_processor_group(processor_group_name[1], 'RUNNING')
    start_processor_group(processor_group_name[2], 'RUNNING')

    # Executing the query to set the status "Running"
    execute_sql(state='RUNNING')

    stop_hour = int(sys.argv[2])
    if stop_hour > 0 and stop_hour <= 24:
        named_tuple = time.localtime()
        process_start_time = time.strftime("%Y-%m-%d, %H:%M:%S", named_tuple)
        stop_seconds = stop_hour * 60 * 60

        logging.info(f"Process start time: {process_start_time}")
        # Stop hour
        time.sleep(stop_seconds)

        # Stops the processors
        start_processor_group(processor_group_name[0], 'STOPPED')
        start_processor_group(processor_group_name[1], 'STOPPED')
        start_processor_group(processor_group_name[2], 'STOPPED')
    else:
        logging.warn(f"Stop hour should be greater than 0 and less than or equal to 24")
    # Executing the query to set the status "Stopped"
    execute_sql(state='STOPPED')
