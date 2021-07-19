from deploy_nifi import get_nifi_root_pg,get_processor_group_info, rq, prop, logging, sys
from connect_nifi_processors import get_processor_group_ports, create_funnel


# create dummy connection for the ports belonging to unselected data sources
def dummy_connection_creator(processor_group_name):
    pg_source = get_processor_group_ports(processor_group_name)
    funnel_details = create_funnel()
    funnel_details = funnel_details['processGroupFlow']['flow']['funnels'][0]
    dummy_connections = {'input_port': [],
                         'output_port': []
                         }
    
    # Get all the invalid inputPorts
    for input_port_name in pg_source.json()['processGroupFlow']['flow']['inputPorts']:        
       # check for  invalid port in inputPort
        if 'Invalid' in input_port_name['status']['runStatus']:
            #  set source and destination connection details
            funnel_connect_body = {"revision": {
                "clientId": "Python",
                "version": 0
            },
                "disconnectedNodeAcknowledged": False,
                "component": {
                "name": "",
                "source": {
                    "id": funnel_details['component']['id'],
                    "groupId": funnel_details['component']['parentGroupId'],
                    "type": "FUNNEL"
                },
                "destination": {
                    "id": input_port_name['status']['id'],
                    "groupId": input_port_name['status']['groupId'],
                    "type": "INPUT_PORT"
                }}}

            dummy_connections['input_port'].append(funnel_connect_body)
    
    # Get all the invalid outputPorts
    for output_port_name in pg_source.json()['processGroupFlow']['flow']['outputPorts']:
        # check for  invalid port in outputPort
        if 'Invalid' in output_port_name['status']['runStatus']:
            funnel_connect_body = {"revision": {
                "clientId": "Python",
                "version": 0
            },
                "disconnectedNodeAcknowledged": False,
                "component": {
                "name": "",
                "source": {
                    "id": output_port_name['status']['id'],
                    "groupId": output_port_name['status']['groupId'],
                    "type": "OUTPUT_PORT"
                },
                "destination": {
                    "id": funnel_details['component']['id'],
                    "groupId": funnel_details['component']['parentGroupId'],
                    "type": "FUNNEL"
                }}}

            dummy_connections['output_port'].append(funnel_connect_body)

    # dummy connection from funnel to input port
    for input_port_body in dummy_connections['input_port']:
        funnel_connect_res = rq.post(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{get_nifi_root_pg()}/connections",
                                     json=input_port_body, headers=header)
        if funnel_connect_res.status_code == 201:            
            logging.info(f"Connection established between source={funnel_connect_res.json()['component']['source']['name']} and  destination={funnel_connect_res.json()['component']['destination']['name']}")
        else:
            return funnel_connect_res.text

    # dummy connection from output port to funnel
    for output_port_body in dummy_connections['output_port']:
        funnel_connect_res = rq.post(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/process-groups/{get_nifi_root_pg()}/connections",
                                     json=output_port_body, headers=header)
        if funnel_connect_res.status_code == 201:
            logging.info(f"Connection established between source={funnel_connect_res.json()['component']['source']['name']} and destination={funnel_connect_res.json()['component']['destination']['name']}")
        else:
            return funnel_connect_res.text
    return "Successfully connected invalid ports with funnel"
    
# Main.
if __name__ == "__main__":
    """[summary]
    
    sys arguments = 1. cQube_data_storage processor name . Run this code after installing required data sources.
    Ex: python nifi_dummy_connection_creator.py cQube_data_storage 
    """
    header = {"Content-Type": "application/json"}
    processor_group_name = sys.argv[1]
    
    # create dummy connection for un selection data source
    dummy_connection_creator(processor_group_name)
    logging.info('Successfully completed all the connections between processor groups')
