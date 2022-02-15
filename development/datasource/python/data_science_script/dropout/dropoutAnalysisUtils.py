import pandas as pd
import json
import numpy as np 
import logging
import boto3
from botocore.exceptions import ClientError
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import os
from pyspark.sql.types import IntegerType
from pyspark.sql import functions as F
from pyspark.sql.types import StructType,StructField, StringType
import itertools





spark = SparkSession.builder.appName("initial_dropout_analysis").master("local[*]").config("spark.executor.memory", "70g")\
.config("spark.driver.memory", "50g")\
.config("spark.memory.offHeap.enabled",True).config("spark.memory.offHeap.size","16g")\
.getOrCreate()

def read_data_postgres(db_name, db_user, db_password, query):
    db_driver="org.postgresql.Driver"
    db_url="jdbc:postgresql://localhost:5432/"+ db_name
    df = spark.read.jdbc(url = db_url,
                     table = query,
                     properties={"user": db_user, "password": db_password, "driver": db_driver})
    return df


def read_data_pyspark(df_loc):
    df = spark.read.csv(df_loc, sep = '|',header=True)
    return df

def column_rename(exam_code, subject_lookup, exam_lookup):
    subject_lookup = json.loads(subject_lookup[["subject_id","subject"]].drop_duplicates().toPandas().set_index('subject_id')['subject'].to_json())
    exam_lookup = exam_lookup.toPandas()
    exam_lookup['ExamCode'] = exam_lookup['exam_code'].apply(lambda x: x.strip())
    exam_lookup.set_index('ExamCode', inplace=True)
    exam_lookup['Subject'] = exam_lookup['subject_id'].apply(lambda x: subject_lookup[str(x)])
    res = exam_lookup.loc[exam_code]
    return str(res['exam_date']) + " Grade " + str(res['standard']) + " " + res['Subject']


def reshape_data(exam_result_df,groupby_col_ls, subject_lookup_loc, exam_lookup_loc):
    gpby_df = exam_result_df.groupby(groupby_col_ls).pivot("exam_code").agg(sum('obtained_marks').alias('sum'))
    pat_col_ls = [i for i in list(gpby_df.columns) if 'PAT' in i]
    renamed_pat_ls = [column_rename(i,subject_lookup_loc, exam_lookup_loc) for i in list(pat_col_ls)]
    column_renamed = groupby_col_ls + renamed_pat_ls
    gpby_df_pat = gpby_df.toDF(*column_renamed)
    sorted_column_ls = sorted(renamed_pat_ls)   
    gpby_df_pat = gpby_df_pat.select(groupby_col_ls + sorted_column_ls)
    return gpby_df_pat 


def calc_attendance_status(df, grade, no_of_exam):
    grade_col_ls = [i for i in list(df.columns) if 'Grade ' + str(grade) in i]  
    df = df.filter(df.studying_class==str(grade))
    for col in grade_col_ls:
        df = df.withColumn(col, when(df[col].isNull(), 1).otherwise(0)) 
    col_required = [df[col] for col in grade_col_ls[-no_of_exam:]]
    updated_df = df.withColumn('absent_count', np.sum(col_required))
    join_df = updated_df.withColumn("dropout_flag", when(updated_df["absent_count"]>=len(col_required),1).otherwise(0))  
    return join_df


def calc_retain_percentage(output_df, level, output_field_dict):
    meta_list =list(itertools.chain(*[[i.lower()+"_name",i.lower()+"_id"] for i in output_field_dict['data_field_dict'][level]]))
    geo_list = [level+ i for i in ["_longitude","_latitude","_id"]]
    percent_df = output_df.groupby(level+"_id").agg((100-((mean("dropout_flag")*100))).alias("retain_percentage"))
    customised_output = percent_df.join(output_df.select(meta_list).distinct(),[level + "_id"])
    customised_output = customised_output.join(output_df.select(geo_list).distinct(),[level + "_id"])
    customised_output = customised_output.withColumnRenamed(level+"_latitude", "latitude").withColumnRenamed(level+"_longitude", "longitude")
    col_list = [i for i in list(customised_output.columns) if i !='retain_percentage']
    df = customised_output.toPandas()
    details_list = df[col_list].to_dict(orient='records')
    metrics_list = df[["retain_percentage"]].to_dict(orient='records')
    data_dict = [{"details":i, "metrics":j} for i,j in (zip(details_list, metrics_list))]
    return data_dict


def calc_footer(output_df, output_field_dict, customised_output_json, level):
    school_df = output_df.groupby(output_field_dict['footer_field_dict'][level] +"_id").agg(countDistinct('school_id').alias("total_schools"))
    footer = [school_df.toPandas().set_index(output_field_dict['footer_field_dict'][level] + '_id').T.to_dict()]
    total_schools_dict = {"totalSchools": school_df.agg(F.sum("total_schools")).collect()[0][0]}
    return footer, total_schools_dict


def upload_file_s3(resource_file, cred, object_name=None): 
    """Upload a file to an S3 bucket

    :param resource_file: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """
    # If S3 object_name was not specified, use file_name
    bucket = cred['s3_output_bucket']
    access_key = cred['s3_access_key']
    secret_key = cred['s3_secret_key']
    region = cred['aws_default_region']
    if object_name is None:
        object_name = 'data_science/dropout/' + os.path.basename(resource_file)
    # Upload the file
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