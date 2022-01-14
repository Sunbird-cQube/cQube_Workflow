import shutil
from env import *
import os
import zipfile
import csv
import pandas as pd
import boto3
import sys
from update_batch_id import update_parameter_ctx

def creat_csv_file(list_of_items, filename):
    f_name = filename.lower()
    f = f_name.split(' ', 2)[2]
    f2 = f.replace('-', ' ')
    removeSpecialChars = f2.replace(' ', '_')
    filename_d = 'diksha_' + removeSpecialChars + '.csv'



    with open(filename_d, 'w') as file:
        csvwriter = csv.writer(file, delimiter='|')
        csvwriter.writerows(list_of_items)


    with zipfile.ZipFile(local_path+'/' +'diksha_' + removeSpecialChars + '.zip', 'w',zipfile.ZIP_DEFLATED) as zip_file:
        zip_file.write(filename_d)

    with zipfile.ZipFile('diksha_' + removeSpecialChars + '.zip', 'w',
                         zipfile.ZIP_DEFLATED) as zip_file:
        zip_file.write(filename_d)

    if storage_type == 's3':
        upload_file_s3('diksha_' + removeSpecialChars + '.zip')

    if os.path.exists('diksha_' + removeSpecialChars + '.zip'):
        os.remove('diksha_' + removeSpecialChars + '.zip')

    if os.path.exists(filename_d):
        os.remove(filename_d)






def emission_folder(local_path,destination_path,storage_type):
    if storage_type == 'local':
        src_files = os.listdir(local_path)
        for file_name in src_files:
            full_file_name = os.path.join(local_path, file_name)
            if os.path.isfile(full_file_name):
                shutil.copy(full_file_name, destination_path)





def delete_files(local_path):

    folder = local_path

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)

            if os.path.exists(local_path):
                if len(os.listdir(local_path)) == 0:
                    os.rmdir(local_path)

            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))





def count_number(local_path):
    return (len(os.listdir(local_path)))



def upload_file_s3(file):
    PATH_IN_COMPUTER = file
    BUCKET_NAME = EMISSION_BUCKET_NAME
    KEY = 'diksha_enrolment/' + PATH_IN_COMPUTER
    s3_resource = boto3.resource(
        's3',
        region_name=AWS_DEFAULT_REGION,
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY
    )
    s3_resource.Bucket(BUCKET_NAME).put_object(
        Key=KEY,
        Body=open(PATH_IN_COMPUTER, 'rb')
    )



def separate_csv(filepath):
    file = open(filepath)
    keywords = ['End of Program-Course Details', 'End Of program details', 'End Of Course details',
                'End of Course enrolments']

    mycsv = []
    keyIndex = 0
    key = keywords[keyIndex]
    for row in csv.reader(file):

        if row[0] == key:
            if row[0] == 'End of Program-Course Details':
                df = pd.DataFrame(mycsv)
                new_header = df.iloc[0].str.strip().str.lower()
                nan_value = float("NaN")
                df.replace("", nan_value, inplace=True)
                df.dropna(how= 'all', inplace=True)
                df.replace(nan_value,'',inplace= True)
                df = df[1:]
                df.columns = new_header
                df.insert(0, 'program_id', range(1, 1 + len(df)))
                d = pd.melt(df, id_vars=['program_id', 'program_name'], var_name='Course_Id') \
                    .sort_values(['program_id', 'program_name', ]).reset_index(drop=True)
                df1 = d.drop(columns=['Course_Id']).rename(columns={'value': 'Course_ID'})
                df1.replace("", nan_value, inplace=True)
                df2 = df1.dropna(subset=['Course_ID'], inplace=False)
                col = df2.columns.tolist()
                val = df2.values.tolist()

                if df2[2:].empty:
                    del df2
                else:
                    mycsv = [col] + val
                    creat_csv_file(mycsv, key)

            else:
                df_1 = pd.DataFrame(mycsv)
                new_header = df_1.iloc[0].str.strip().str.lower()
                nan_value = float("NaN")
                df_1.replace("", nan_value, inplace=True)
                df_1.dropna(how='all', inplace=True)
                df_1.replace(nan_value, "", inplace=True)
                df_1.dropna(how='all', axis=1, inplace=True)
                df_1 = df_1[1:]
                df_1.columns = new_header
                col = df_1.columns.tolist()
                val = df_1.values.tolist()
                if df_1.empty:
                    del df_1
                else:
                    mycsv = [col] + val
                    creat_csv_file(mycsv, key)

            keyIndex += 1
            del mycsv[:]
            if keyIndex == len(keywords):
                break
            key = keywords[keyIndex]
        else:
            mycsv.append(row)



if len(sys.argv[1:]) > 0:
    global local_path
    local_path = 'new_diksha_directory/'
    if not os.path.exists(local_path):
        os.mkdir(local_path)
    path = sys.argv[1]
    storage_type = sys.argv[2]
    emission_dir_path = sys.argv[3]
    separate_csv(path)
    value = count_number(local_path)
    print(value)
    emission_folder(local_path,emission_dir_path,storage_type)
    update_parameter_ctx("static_data_parameters", "diksha_enrolment_file_count", value)
    delete_files(local_path)

else:
    print('please provide the arguement')
