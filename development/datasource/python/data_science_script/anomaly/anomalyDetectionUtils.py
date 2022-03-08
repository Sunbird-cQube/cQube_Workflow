from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark import SparkContext
import pandas as pd
import numpy as np
import itertools



from pyspark.sql.functions import *
import logging
import boto3
from botocore.exceptions import ClientError
import os
import re
import zipfile
import glob

spark = SparkSession.builder.appName("initial_anomaly_analysis").master("local[*]").config("spark.executor.memory", "10g")\
.config("spark.driver.memory", "25g")\
.config("spark.memory.offHeap.enabled",True).config("spark.memory.offHeap.size","16g")\
.getOrCreate()


def read_data_pyspark(df_loc):
    df = spark.read.text(df_loc)
    return df

def read_data_postgres(db_name, db_user, db_password, query):
    db_driver="org.postgresql.Driver"
    db_url="jdbc:postgresql://localhost:5432/"+ db_name
    df = spark.read.jdbc(url = db_url,
                     table = query,
                     properties={"user": db_user, "password": db_password, "driver": db_driver})
    return df


def upload_file_s3(resource_file, cred, object_name=None): 
    bucket = cred['s3_output_bucket']
    access_key = cred['s3_access_key']
    secret_key = cred['s3_secret_key']
    region = cred['aws_default_region']
    if object_name is None:
        object_name = 'data_science/anomaly/' + os.path.basename(resource_file)
    s3_client = boto3.client('s3', 
        aws_access_key_id = access_key, 
        aws_secret_access_key = secret_key,
        region_name = region)   

    try:
        response = s3_client.upload_file(resource_file, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True

def get_s3_details(s3_config_loc):
    read_credentials = spark.read.option("multiline", "true").json(s3_config_loc)
    key_list = peopleDF.select("ConfigDetails").rdd.flatMap(lambda x: x).collect()[0][0]
    return key_list
    
def unzip_files(path):
    import zipfile
    files = os.listdir(path)
    for file in files:
        if file.endswith('.zip'):
            filePath=path+'/'+file
            zip_file = zipfile.ZipFile(filePath)
            for names in zip_file.namelist():
                zip_file.extract(names,path)
            zip_file.close()  



def calc_anomaly_status(exam_result_df, method, maximum_score, minimum_score):
    gpby_df = exam_result_df.groupby(["school_id", "student_uid"]).agg(sum("obtained_marks").alias("score_sum"), countDistinct('exam_code').alias("total_exams"))
    
    if method =="minimum_score":
        flag_df = gpby_df.withColumn("anomaly_flag", F.when(F.col("score_sum")==minimum_score,1).otherwise(0))
    
    if method =="maximum_score":
        gpby_df = gpby_df.withColumn('max_score_obtained', (col('total_exams')*maximum_score))
        flag_df = gpby_df.withColumn("anomaly_flag", F.when(F.col("score_sum")==F.col("max_score_obtained"),1).otherwise(0))
        
    if method =="percentile_score":
        score_sum_data = [x.score_sum for x in gpby_df.select(col('score_sum').astype('float')).collect()]
        q25, q75 = np.percentile(score_sum_data, 25), np.percentile(score_sum_data, 75)
        iqr = q75 - q25
        cut_off = iqr * 1.5
        lower, upper = q25 - cut_off, q75 + cut_off
        flag_df = gpby_df.withColumn("anomaly_flag", F.when((gpby_df["score_sum"]<lower) | (gpby_df["score_sum"]>upper),1).otherwise(0))
    

    return flag_df


def calc_anomaly_percentage(output_df, level, output_field_dict):
    meta_list =list(itertools.chain(*[[i.lower()+"_name",i.lower()+"_id"] for i in output_field_dict['data_field_dict'][level]]))
    geo_list = [level+ i for i in ["_longitude","_latitude","_id"]]
    percent_df = output_df.groupby(level+"_id").agg((mean("anomaly_flag")*100).alias("anomaly_percentage"))
    customised_output = percent_df.join(output_df.select(meta_list).distinct(),[level + "_id"])
    customised_output = customised_output.join(output_df.select(geo_list).distinct(),[level + "_id"])
    customised_output = customised_output.withColumnRenamed(level+"_latitude", "latitude").withColumnRenamed(level+"_longitude", "longitude")
    col_list = [i for i in list(customised_output.columns) if i !='anomaly_percentage']
    df = customised_output.toPandas()
    details_list = df[col_list].to_dict(orient='records')
    metrics_list = df[["anomaly_percentage"]].to_dict(orient='records')
    data_dict = [{"details":i, "metrics":j} for i,j in (zip(details_list, metrics_list))]
    return data_dict


def calc_footer(output_df, output_field_dict, customised_output_json, level):
    school_df = output_df.groupby(output_field_dict['footer_field_dict'][level] +"_id").agg(countDistinct('school_id').alias("total_schools"))
    footer = [school_df.toPandas().set_index(output_field_dict['footer_field_dict'][level] + '_id').T.to_dict()]
    total_schools_dict = {"totalSchools": school_df.agg(F.sum("total_schools")).collect()[0][0]}
    return footer, total_schools_dict


def outputdf_To_json(df, col_list1, col_list2):
    list1 = list(map(lambda row: row.asDict(), df.select(col_list1).collect()))  
    list2 = list(map(lambda row: row.asDict(), df.select(col_list2).collect()))
    output_json = {}
    output_json["allSchoolsFooter"] = {"totalSchools": df.count()} 
    output_json["data"] = [{"details":i, "metrics":j} for i,j in (zip(list1, list2))] 
    return output_json 

