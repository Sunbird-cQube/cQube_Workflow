from env import *
import os
import zipfile
import csv
import sys
import pandas as pd
import boto3



def creat_csv_file(list_of_items, filename):
    f_name = filename.lower()
    f = f_name.split(' ',2)[2]
    f2 = f.replace('-', ' ')
    removeSpecialChars = f2.replace(' ', '_')
    filename_d = 'diksha_' + removeSpecialChars + '.csv'

    with open(filename_d, 'w') as file:
        csvwriter = csv.writer(file,delimiter = '|')
        csvwriter.writerows(list_of_items)

    with zipfile.ZipFile('diksha_' + removeSpecialChars  +'.zip', 'w', zipfile.ZIP_DEFLATED) as zip_file:
        zip_file.write(filename_d )

    if storage_type == 's3':
        upload_file(removeSpecialChars)
    elif storage_type == 'local':
        os.rename('diksha_' + removeSpecialChars  +'.zip', emission_dir_path+'/'+'diksha_' + removeSpecialChars  +'.zip')

    if os.path.exists(filename_d):
         os.remove(filename_d)



def upload_file(file):
    PATH_IN_COMPUTER = 'diksha_' + file  +'.zip'
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
    keywords = ['End of Program-Course Details','End Of program details','End Of Course details','End of Course enrolments']
    mycsv = []
    keyIndex = 0
    key = keywords[keyIndex]
    for row in csv.reader(file):
        if row[0] == key:
            if row[0] == 'End of Program-Course Details' :
                df = pd.DataFrame(mycsv)
                new_header = df.iloc[0].str.strip().str.lower()
                df = df[1:]
                df.columns = new_header
                df.insert(0, 'program_id', range(1, 1 + len(df)))
                d = pd.melt(df,id_vars=['program_id','program_name' , 'expected_enrollments'],var_name= 'Course_Id')\
                    .sort_values(['program_id','program_name' , 'expected_enrollments']).reset_index(drop=True)
                df1 = d.drop(columns = ['Course_Id']).rename(columns = {'value' : 'Course_ID'})
                df2 = df1.dropna(subset = ['Course_ID'],inplace = False)
                col = df2.columns.tolist()
                val = df2.values.tolist()
                mycsv = [col]+val
            creat_csv_file(mycsv, key)
            mycsv.clear()
            keyIndex+=1
            if keyIndex == len(keywords):
                break
            key = keywords[keyIndex]
        else:
            mycsv.append(row)


if len (sys.argv[1:]) > 0:
    path = sys.argv[1]
    storage_type = sys.argv[2]
    emission_dir_path = sys.argv[3]
    separate_csv(path)

else:
    print('please provide the arguement')


