from deploy_nifi import rq, prop, logging, sys
from connect_nifi_processors import get_processor_group_ports


def disable_processor(processor_group_name, data_storage_type):
    disable_processor_name = ""
    if data_storage_type == "s3":
        disable_processor_name = "data_storage_ListFile"
    elif data_storage_type == "local":
        disable_processor_name = "s3_list_emission"

    pg_source = get_processor_group_ports(processor_group_name)
    if pg_source.status_code == 200:
        for i in pg_source.json()['processGroupFlow']['flow']['processors']:
            if i['component']['name'] == disable_processor_name:
                disable_body = {"revision": {"clientId": "python deployment code", "version": i['revision']['version']},
                                "state": "DISABLED", "disconnectedNodeAcknowledged": False}
                disable_response = rq.put(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/processors/{i['component']['id']}/run-status",
                                          json=disable_body, headers=header)
                if disable_response.status_code == 200:
                    logging.info(
                        f"Successfuly disabled {i['component']['name']}")
                    return True
                else:
                    return disable_response.text


# Main.
if __name__ == "__main__":
    """[summary]
    sys arguments = 1.Processor group name. 2.Data storage type
    Run this code after installing required data sources, 
    Disables the processor based on data storage type
    Ex: python nifi_disable_processor.py student_attendance_transformer s3
    """
    header = {"Content-Type": "application/json"}
    processor_group_name = sys.argv[1]
    data_storage_type = sys.argv[2]

    # disable processor based on data storage type.
    disable_processor(processor_group_name, data_storage_type)
