from dropoutAnalysisUtils import *
from pyspark.sql.functions import *
from pyspark.sql import functions as F
from pyspark import SparkContext
import functools
from pyspark.sql.types import IntegerType
import numpy as np
import pandas as pd
import functools
import datetime
import json
import os
import logging
import shutil
import logging
from pyspark.sql import DataFrame

import sys
import yaml


sys.path.insert(0, '../../')

from nifi_env_db import db_name,db_pwd,db_user

now = datetime.datetime.now()

config_file = open('./dropoutAnalysis_config.json')
config_load = json.load(config_file)
config = config_load["ConfigDetails"]

with open('../../../../conf/base_config.yml') as f:
    conf_detail = yaml.safe_load(f)

storage_type = conf_detail['storage_type']

if storage_type == "local":
    with open('../../../../conf/local_storage_config.yml') as f:
        loc_detail = yaml.safe_load(f)
        output_dir = loc_detail['output_directory'] + "/data_science/dropout/"
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
elif storage_type == "s3":
    with open('../../../../conf/aws_s3_config.yml') as f:
        loc_detail = yaml.safe_load(f)

subject_lookup_table = config["subject_lookup_table"]
exam_lookup_table = config["exam_lookup_table"]
exam_result_table = config["exam_result_table"]
no_of_exam = config["no_of_exam"]
school_hierarchy_table = config["school_hierarchy_table"]
school_geo_master_table = config["school_geo_master_table"]


output_field_dict = {'data_field_dict':{'block': ['block','district'], 'school':['school','cluster','block','district'], 
                   'district':['district'], 'cluster':['cluster','block','district']},
                    'footer_field_dict': {'school':'cluster', 'cluster':'block', 'block':'district', 'district':'district'}} 
exam_master_query = "(select * from " + exam_lookup_table + ") as exam_master"
subject_master_query = "(select * from " + subject_lookup_table + ") as subject_master" 
exam_result_query = "(select * from " + exam_result_table + ") as exam_result"
sch_query = "(select sg.school_id, school_latitude, school_longitude, school_name, sg.district_id, district_latitude, district_longitude, district_name, sg.block_id, block_latitude, block_longitude, block_name, sg.cluster_id, cluster_latitude, cluster_longitude, cluster_name from " + school_hierarchy_table + " sh join " + school_geo_master_table + " sg on sh.school_id = sg.school_id) as sch_tbl"
level_ls = ["school","block","cluster","district"]

logging.basicConfig(filename='dropoutAnalysis.log', filemode='w', format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S')
logging.warning('Started data fetching') 


##Read data and output calculation
exam_result_df = read_data_postgres(db_name, db_user, db_pwd, exam_result_query)
exam_lookup = read_data_postgres(db_name, db_user, db_pwd, exam_master_query)
subject_lookup = read_data_postgres(db_name, db_user, db_pwd, subject_master_query)

meta_data = read_data_postgres(db_name, db_user, db_pwd, sch_query)
distinct_grade = [x.studying_class for x in exam_result_df.select('studying_class').distinct().collect()]
reshape_df = reshape_data(exam_result_df, ['school_id','student_uid','studying_class'], subject_lookup, exam_lookup)
logging.warning('Completed reshaping data frame for the analysis')


ls = [] 
for grade in distinct_grade:
    try:
        dropout_percent_df = calc_attendance_status(reshape_df, grade, no_of_exam)
        logging.warning('Completed attendance status calculation for the grade: ' + str(grade) )
        ls.append(dropout_percent_df)
    except:
        logging.warning('Failed attendance status calculation for the grade: ' + str(grade) ) 
output_df = functools.reduce(DataFrame.union, ls) 
output_df = output_df.join(meta_data, ['school_id'])

for level in level_ls:
    try:
        output = {}
        customised_output_json = calc_retain_percentage(output_df, level, output_field_dict)
        logging.warning('Completed Retain percetage calculation for the level: ' + level)
        footer_dict, school_dict = calc_footer(output_df, output_field_dict, customised_output_json, level)
        logging.warning('Completed Footer calculation for the level: ' + level) 
        output["all"+level[0].upper()+level[1: ]+"sFooter"] = school_dict
        output["data"] = customised_output_json
        if level!="district":
            output["footer"] = footer_dict
        file_name = 'dropout_' +level +'_map.json'
        with open(file_name, "w") as outfile:
            json.dump(output, outfile)
        logging.warning('Results saved for the level: ' + level)
        if storage_type == "local":
            shutil.copy(file_name, output_dir)
            os.remove(file_name)
        elif storage_type == "s3":
            upload_file_s3(file_name, loc_detail, object_name=None)
    except Exception as e:
        logging.warning('Failed Dropout evaluation for level: ' + level)
        logging.warning('Error: ' + repr(e))