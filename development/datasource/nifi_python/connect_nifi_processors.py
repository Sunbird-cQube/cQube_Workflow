from deploy_nifi import get_nifi_root_pg, get_processor_group_info, rq, prop, logging, sys, json


def get_processor_group_ports(processor_group_name):

    # Get processor group details
    pg_source = get_processor_group_info(processor_group_name)
    pg_details = rq.get(
        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{pg_source['component']['id']}")
    if pg_details.status_code != 200:
        return pg_details.text
    else:
        return pg_details

# create funnel


def create_funnel():
    # check funnel exist
    pg_list = rq.get(
        f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{get_nifi_root_pg()}')
    if pg_list.status_code == 200:
        if len(pg_list.json()['processGroupFlow']['flow']['funnels']) == 0:
            # create funnel
            header = {"Content-Type": "application/json"}
            create_funnel_body = {"revision": {"clientId": "PYTHON", "version": 0},
                                  "disconnectedNodeAcknowledged": False, "component": {"position": {"x": 373.83218347370484, "y": 484.90403183806325}}}
            create_funnel_res = rq.post(f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{get_nifi_root_pg()}/funnels', json=create_funnel_body, headers=header)

            if create_funnel_res.status_code == 201:
                pg_list = rq.get(
                    f'{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{get_nifi_root_pg()}')
                if pg_list.status_code == 200:
                    return pg_list.json()
            else:
                return False
        return pg_list.json()


# connect [INPUT/OUTPUT PORT] between process groups
def connect_output_input_port(source_processor_group, destination_processor_group):
    """[summary]
    connects output port to input port between processor group.

    Args:
        source_processor_group ([string]): [processor group name where output ports are available]
        destination_processor_group ([string]): [processor group name where input port are available]

    Returns:
        [Boolean]: [Return True if connection is success]
    """
    pg_source_details = get_processor_group_ports(source_processor_group)
    pg_dest_details = get_processor_group_ports(destination_processor_group)

    connect_port_body = {
        "revision": {
            "clientId": "PYTHON",
            "version": 0
        },
        "disconnectedNodeAcknowledged": False,
        "component": {
            "name": "",
            "source": {
                "id": "",
                "groupId": "",
                "type": "OUTPUT_PORT"
            },
            "destination": {
                "id": "",
                "groupId": "",
                "type": "INPUT_PORT"
            }
        }
    }

    params = prop.NIFI_INPUT_OUTPUT_PORTS
    # Get Output ports [static values]
    for key, value in params.items():        
        if source_processor_group == key:
            if 'cQube_data_storage' in source_processor_group:
                params = params[source_processor_group]
                source_processor_group = destination_processor_group
            
            # iterate over the configured ports from params
            if params[source_processor_group]:
                for ports in params[source_processor_group]:
                    # port details of processor group
                    for i in pg_source_details.json()['processGroupFlow']['flow']['outputPorts']:
                        # if output port name match, assign the ID,parentGroupID
                        if i['component']['name'] == ports['OUTPUT_PORT']:
                            connect_port_body['component']['source']['id'] = i['component']['id']
                            connect_port_body['component']['source']['groupId'] = i['component']['parentGroupId']

                            # get input port details of processor group
                            for input_port_name in pg_dest_details.json()['processGroupFlow']['flow']['inputPorts']:
                                if input_port_name['component']['name'] == ports['INPUT_PORT']:
                                    connect_port_body['component']['destination']['id'] = input_port_name['component']['id']
                                    connect_port_body['component']['destination']['groupId'] = input_port_name['component']['parentGroupId']
                                    connect_port_res = rq.post(
                                        f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{get_nifi_root_pg()}/connections", json=connect_port_body, headers=header)

                                    if connect_port_res.status_code == 201:
                                        logging.info(f"Successfully Connection done between {i['component']['name']} and {input_port_name['component']['name']} port")

                                    else:
                                        return connect_port_res.text


# Main.
if __name__ == "__main__":
    """[summary]
    sys arguments = 1. cQube_raw_data_fetch processor name 2. transformer processor group name.
    Ex: python connect_nifi_processors.py cQube_raw_data_fetch_static static_data_processor 
    """
    header = {"Content-Type": "application/json"}
    source_pg = sys.argv[1].strip()
    destination_pg = sys.argv[2].strip()
    
    logging.info('Connection between PORTS started...')
    if 'composite_transformer' in destination_pg or 'progress_card_transformer' in destination_pg:
        logging.info("Processor group=",destination_pg)
    else: 
        res_1 = connect_output_input_port(source_pg, destination_pg)
    
    res_2 = connect_output_input_port(destination_pg, source_pg)
    logging.info('Successfully Connection done between PORTS.')
