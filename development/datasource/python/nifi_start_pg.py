from deploy_nifi import get_nifi_root_pg, get_processor_group_info, rq, prop, logging, sys


def start_processor_group(processor_group_name,state):
    header = {"Content-Type": "application/json"}
    pg_source = get_processor_group_info(processor_group_name)
    start_body = {"id": pg_source['component']['id'],
                  "state": state, "disconnectedNodeAcknowledged": False}
    start_response = rq.put(f"{prop.NIFI_IP}:{prop.NIFI_PORT}/nifi-api/flow/process-groups/{pg_source['component']['id']}",
                            json=start_body, headers=header)
    if start_response.status_code == 200:
        logging.info(f"Successfully {state} {pg_source['component']['name']} Processor Group.")
        return True
    else:
        return start_response.text

# Main.
if __name__ == "__main__":
    """[summary]

    sys arguments = 1.  processor group name .  Run this code after installing required data sources, 
    starts the processor group
    Ex: python nifi_start_pg.py cqube_telemetry_transformer 
    """
    header = {"Content-Type": "application/json"}
    processor_group_name = sys.argv[1]
    state = sys.argv[2]
    
    
    # enable/disable/start/stop the processor group 
    start_processor_group(processor_group_name,state)


