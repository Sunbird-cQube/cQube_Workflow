from deploy_nifi import rq, prop, logging, sys
from connect_nifi_processors import get_processor_group_ports


def data_storage_disable_processor(processor_group_name, data_storage_type):
    disable_processor_name = ""
    if data_storage_type == "s3":
        disable_processor_name = "data_storage_ListFile"
    elif data_storage_type == "local":
        disable_processor_name = "s3_list_emission"

    # disable the nifi processor
    nifi_enable_disable_processor(processor_group_name, disable_processor_name,"DISABLED")


def nifi_enable_disable_processor(processor_group_name, processor_name,state):

    pg_source = get_processor_group_ports(processor_group_name)
    if pg_source.status_code == 200:
        for i in pg_source.json()['processGroupFlow']['flow']['processors']:
            if i['component']['name'] == processor_name:
                disable_body = {"revision": {"clientId": "python deployment code", "version": i['revision']['version']},
                                "state": state, "disconnectedNodeAcknowledged": False}
                disable_response = rq.put(
                    f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/processors/{i['component']['id']}/run-status", json=disable_body, headers=header)
                if disable_response.status_code == 200:
                    if state=="STOPPED": 
                        state="ENABLED"
                        logging.info(
                            f"Successfuly {state} {i['component']['name']} processor in {processor_group_name} processor group")
                        return True
                else:
                    return disable_response.text

def diksha_enable_disable_processor(processor_group_name, storage_type, dataset, emission_method):
    # ETB
    if dataset == "etb":
        if emission_method == "emission":
            disable_processor = ['diksha_api_summary_rollup_get_today_request']
            enable_processor =[]
            if storage_type == 'local':
                disable_processor.append("s3_list_emission_ETB")
                enable_processor.append("diksha_ListFile_ETB")
                
                for i in disable_processor:
                    # disable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
                for i in enable_processor:
                    # enable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"STOPPED")
                    
            elif storage_type == 's3':
                disable_processor.append("diksha_ListFile_ETB")
                enable_processor.append("s3_list_emission_ETB")
                
            for i in disable_processor:
                # disable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
            for i in enable_processor:
                    # enable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"STOPPED")

        elif emission_method == "api":
            # add the lists3,listfile processors
            disable_processor = ['diksha_ListFile_ETB', 's3_list_emission_ETB']
            enable_processor=["diksha_api_summary_rollup_get_today_request"]
            for i in disable_processor:
                # disable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
            for i in enable_processor:
                # enable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"STOPPED")
                
                
    # TPD
    if dataset == "tpd":
        if emission_method == "emission":
            disable_processor = ['diksha_api_progress_exhaust_get_today_request']
            enable_processor =[]
            if storage_type == 'local':
                disable_processor.append("s3_list_emission_TPD")
                enable_processor.append("diksha_ListFile_TPD")
                
                for i in disable_processor:
                    # disable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
                for i in enable_processor:
                    # enable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"STOPPED")
                    
            elif storage_type == 's3':
                disable_processor.append("diksha_ListFile_TPD")
                enable_processor.append("s3_list_emission_TPD")
                
            for i in disable_processor:
                # disable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
            for i in enable_processor:
                    # enable the nifi processor
                    nifi_enable_disable_processor(processor_group_name, i,"STOPPED")

        elif emission_method == "api":
            # add the lists3,listfile processors
            disable_processor = ['diksha_ListFile_TPD', 's3_list_emission_TPD']
            enable_processor=["diksha_api_progress_exhaust_get_today_request"]
            for i in disable_processor:
                # disable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"DISABLED")
            for i in enable_processor:
                # enable the nifi processor
                nifi_enable_disable_processor(processor_group_name, i,"STOPPED")


# Main.
if __name__ == "__main__":
    """[summary]
    sys arguments = 1.Processor group name. 2.Data storage type
    Disables the processor based on data storage type
    Ex: python nifi_disable_processor.py student_attendance_transformer s3
    """
    header = {"Content-Type": "application/json"}
    print("length=", len(sys.argv))
    if len(sys.argv) <= 3:

        processor_group_name = sys.argv[1]
        data_storage_type = sys.argv[2]
        # disable processor based on data storage type.
        data_storage_disable_processor(processor_group_name, data_storage_type)

    elif len(sys.argv) > 4:
        processor_group_name = sys.argv[1]
        storage_type = sys.argv[2]
        dataset = sys.argv[3]
        emission_method = sys.argv[4]
        # disable processor based on emission method.
        diksha_enable_disable_processor(processor_group_name.lower(), storage_type.lower(), dataset.lower(), emission_method.lower())
