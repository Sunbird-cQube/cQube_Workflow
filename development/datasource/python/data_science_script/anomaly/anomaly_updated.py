from anomalyDetectionUtils import *
import os
import datetime
import json
import shutil
import logging
import sys
import yaml
import shutil, os


sys.path.insert(0, '../../')

from nifi_env_db import db_name,db_pwd,db_user

now = datetime.datetime.now()

##Read data locations from config file

config_file = open('./anomalyAnalysis_config.json')


config_load = json.load(config_file)
config = config_load["ConfigDetails"]

with open('../../../../conf/base_config.yml') as f:
    conf_detail = yaml.safe_load(f)

storage_type = conf_detail['storage_type']

if storage_type == "local":
    with open('../../../../conf/local_storage_config.yml') as f:
        loc_detail = yaml.safe_load(f)
        output_dir = loc_detail['output_directory'] + "/data_science/anomaly/"
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
elif storage_type == "s3":
    with open('../../../../conf/aws_s3_config.yml') as f:
        loc_detail = yaml.safe_load(f)


maximum_score = int(config["maximum_score"])
minimum_score = int(config["minimum_score"])
exam_result_table = config["exam_result_table"]
school_hierarchy_table = config["school_hierarchy_table"]
school_geo_master_table = config["school_geo_master_table"]

output_field_dict = {'data_field_dict':{'block': ['block','district'], 'school':['school','cluster','block','district'], 
                   'district':['district'], 'cluster':['cluster','block','district']},
                    'footer_field_dict': {'school':'cluster', 'cluster':'block', 'block':'district', 'district':'district'}} 

exam_result_query = "(select * from " + exam_result_table + ") as exam_result"
sch_query = "(select sg.school_id, school_latitude, school_longitude, school_name, sg.district_id, district_latitude, district_longitude, district_name, sg.block_id, block_latitude, block_longitude, block_name, sg.cluster_id, cluster_latitude, cluster_longitude, cluster_name from " + school_hierarchy_table + " sh join " + school_geo_master_table + " sg on sh.school_id = sg.school_id) as sch_tbl"
level_ls = ["school","block","cluster","district"]
method_ls = ["minimum_score","maximum_score","percentile_score"]

logging.basicConfig(filename='anomalyAnalysis.log', filemode='w', format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S')
logging.warning('Started data fetching') 


##Read data and output calculation
exam_result_df = read_data_postgres(db_name, db_user, db_pwd, exam_result_query)
meta_data = read_data_postgres(db_name, db_user, db_pwd, sch_query)

for method_item in method_ls:
    output_df = calc_anomaly_status(exam_result_df, method_item, maximum_score, minimum_score) 
    now = datetime.datetime.now()
    output_df = output_df.join(meta_data, ['school_id'])
    for level in level_ls:
        try:
            output = {}
            customised_output_json = calc_anomaly_percentage(output_df, level, output_field_dict)
            logging.warning('Completed Anomaly percetage calculation for the level: ' + level)
            footer_dict, school_dict = calc_footer(output_df, output_field_dict, customised_output_json, level)
            logging.warning('Completed Footer calculation for the level: ' + level) 

            output["all"+level[0].upper()+level[1: ]+"sFooter"] = school_dict
            output["data"] = customised_output_json
            if level!="district":
                output["footer"] = footer_dict
            file_name = 'anomaly_' +level +'_map_'+method_item+'.json'
            with open(file_name, "w") as outfile:
                json.dump(output, outfile)
            logging.warning('Results saved for the level: ' + level) 
            if storage_type == "local":
                shutil.copy(file_name, output_dir)
                os.remove(file_name)
            elif storage_type == "s3":
                upload_file_s3(file_name, loc_detail, object_name=None)
        except Exception as e:
            logging.warning('Failed Anomaly evaluation for level: ' + level) 
            logging.warning('Error: ' + repr(e)) 

