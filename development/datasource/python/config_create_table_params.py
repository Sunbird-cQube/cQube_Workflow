import csv
import sys
import pandas as pd
import configparser
import yaml
import os
from yaml.loader import SafeLoader
# import psycopg2

config = configparser.ConfigParser()
config.read('configurable_datasource_path_config.ini')

path = config['DEFAULT']['path']

def read_input():
    if len(sys.argv[1:]) > 0:
        input_file_path = sys.argv[1]
        data_source_name = input_file_path.split('/').pop()
        global file_name
        global file_name_sql
        file_name = data_source_name.split('.')[0]
        file = open(input_file_path)
        file_name_sql = file_name
        return file

def create_parameters_queries():
    input_df = pd.read_csv(read_input())
    keywords = input_df['keywords'].dropna().tolist()
    mycsv = []
    key_index = 0
    key = keywords[key_index]
    table_names = ''
    validation_queries = ''
    global all_param_queries
    all_param_queries = ''
    for row in csv.reader(read_input()):
        if row[0] == key:
            if 'trans' in row[0]:
                df = pd.DataFrame(mycsv)
                new_header = df.iloc[0].str.strip().str.lower()
                df.replace("", float("NaN"), inplace=True)
                df.dropna(how='all', inplace=True)
                df = df[1:]
                if df[2:].empty:
                    del df
                else:
                    df.columns = new_header
                    table_names = df['table_name'].dropna().to_string(index=False)
                    raw_columns = df['columns'].dropna().tolist()
                    columns = []
                    for column in(raw_columns):
                        columns1 = ''
                        columns2 = ''
                        if column.isdigit() is True:
                            columns1 = 'day_'+column
                        else:
                            columns2 = column.replace(" ","_")
                        final = columns2 + columns1
                        columns.append(final)
                    for i in range(len(columns)):
                        columns[i] = columns[i]+','
                    new_column = columns
                    new_column[-1] = new_column[-1].replace(',', '')
                    same_columns = df['columns'].dropna().tolist()
                    for i in range(len(same_columns)):
                        same_columns[i] = 'b.' + same_columns[i]+','
                    same_id = ''.join(same_columns)
                    data_types = df['data_type']
                    ref_table_df = df['ref_table'].dropna().to_list()
                    ref_col_df = df['ref_column'].dropna()
                    null_validation_df = df[df['null_validation_required'] == 'Yes']
                    null_validation_columns = null_validation_df['columns'].tolist()
                    check_same_id = df[df['check_same_id'] == 'Yes']
                    check_same_id_columns = check_same_id['columns'].tolist()
                    for i in range(len(check_same_id_columns)):
                        check_same_id_columns[i] = check_same_id_columns[i] + ','
                    columns_check_id =''.join(check_same_id_columns)
                    no_of_columns = len(columns)
                    foriegn_key_df2 = df[df['constraints'] == 'foreign key']
                    f_k_columns_l = foriegn_key_df2['columns'].to_list()
                    f_k_columns = ','.join(f_k_columns_l)
                    # Check if null query
                    query1 = ''
                    query2 = ''
                    check_if_null_query = ''
                    for num in (null_validation_columns):
                        query1 = ''
                        if null_validation_columns.index(num) == 0:
                            query1 = query1 + '{ "check_if_null":"""select * from ' + table_names + '_staging_1 where '

                        if null_validation_columns.index(num) == len(null_validation_columns) - 1:
                            query2 = num + ' is null """,'
                        else:
                            query2 = num + ' is null or '
                        final = query1+query2
                        check_if_null_query = check_if_null_query +final
                    # Saving duplicates
                    save_dup = '"save_to_dup_table":"""' + table_names + '_dup """,'
                    # Delete null values query
                    delete_null_values_qry = ''
                    for num in (null_validation_columns):
                        query1 = ''
                        if null_validation_columns.index(num) == 0:
                            query1 = '"delete_null_values_qry":"""delete from ' + table_names + '_staging_1 where '

                        if null_validation_columns.index(num) == len(null_validation_columns) - 1:
                            query2 = num + 'is null """,'
                        else:
                            query2 = num + ' is null or '
                        final = query1 + query2
                        delete_null_values_qry = delete_null_values_qry + final
                    # queries_filename
                    queries_filename = '"queries_filename":"""../../emission_app/python/postgres/'+table_names+'/'+table_names+'_queries.json""",'

                    #staging_1_tb_name
                    staging_1_tb_name = '"staging_1_tb_name":"""'+table_names+'_staging_1""",'

                    # Update Null log to db
                    query1 = ''
                    query2 = ''
                    for num in (null_validation_columns):

                        if null_validation_columns.index(num) == 0:
                            query1 = '"null_to_log_db":"""update log_summary SET '
                        query2 = num + '=' + table_names+ '_null_col.count_null_ '+num+','

                    query3 = 'from '+ table_names+ '_null_col where ' +table_names+ '_null_col.ff_uuid = log_summary.ff_uuid""",'
                    null_to_log_db = query1 + query2 +query3

                    # stg2 to temp query
                    clmn = ''.join(columns)
                    clmns = ''.join(new_column)
                    q1 = '"stg_2_to_temp_qry": """ insert into ' +table_names+'_temp('
                    stg_2_to_temp_query = q1 + clmn +'ff_uuid) select '+clmn+'ff_uuid' ' from '+table_names+'_staging_2 """,'
                    val_same_id = ''.join(check_same_id_columns)
                    # check_same_id
                    check_same_id_qry = '"check_same_id_records":"""SELECT ' +same_id+'b.ff_uuid,b.cnt num_of_times from (select sas.*,count(*) over (PARTITION by ' + val_same_id+'ff_uuid) as cnt from' +table_names+'_staging_2  sas ) b where cnt>1 group by'+columns_check_id+'b.ff_uuid,b.cnt;""",'

                    # normalize
                    lis_clm = list(clmns.split(','))
                    norm_column = ''
                    unwanted_cls = ['academic_year', 'distribution_date', 'month']
                    for cl in lis_clm:
                        if cl not in unwanted_cls:
                            norm_column += cl + ','

                    query_check1 = ''
                    query_check2 = ''
                    query_check3 = ''
                    for check_norm_col in raw_columns:
                        if check_norm_col == 'academic_year':
                            query_check1 += '"academic_year",'
                        if check_norm_col == 'distribution_date':
                            query_check2 += '"distribution_date",'
                        if check_norm_col == 'month':
                            query_check3 += '"month"'
                    normalize = '"normalize":"""select ' + norm_column + query_check1 + query_check2 + query_check3 + ' from flowfile""",'

                    # Datatype check
                    d_type1 = ''
                    d_type2 = ''
                    d_type3 = ''
                    d_type4 = ''
                    for d_type in data_types:
                        if d_type == 'bigint':
                            d_type1 = 'Optional(parseLong()),' + d_type1
                        if d_type.startswith('Varchar'):
                            d_type2 = 'Optional(StrNotNullOrEmpty()),' + d_type2
                        if d_type == 'int':
                            d_type3 = 'Optional(ParseInt()),' + d_type3
                        if d_type == 'date':
                            d_type4 = '''Optional(ParseDate("yyyy-MM-dd"))''' + d_type4

                    data_type_check = d_type1 + d_type2 + d_type3 + d_type4

                    # temp_trans_aggregation queries
                    temp_trans_aggregation_queries = table_names + '.json'

                    #Sum of Duplicates
                    sum_of_dup = '"sum_of_dup":"""select sum(num_of_times) from flowfile""",'

                    #unique_record_same_id
                    unique_record_same_id = '"unique_record_same_id":"""insert into '+table_names+'_temp('+clmn+'ff_uuid) select '+clmn+' ff_uuid from (select ' +clmn+ 'ff_uuid, count(*) over (partition by ' +columns_check_id+'ff_uuid) as rn  from '+table_names+'_staging_2)as a where a.rn=1""",'

                    #stg_1_to_stg_2_qry
                    stg_1_to_stg_2_qry = '" stg_1_to_stg_2_qry ":"""insert into '+table_names+ '_staging_2('+clmn+'ff_uuid) select ' +clmn+ 'ff_uuid from ' +table_names+ '_staging_1""",'

                    #save_null_tb_name
                    save_null_tb_name ='"save_null_tb_name":"""'+table_names+'_null_col""",'

                    #check_same_records
                    check_same_records = '"check_same_records":"""SELECT ' +clmn+ 'ff_uuid,count(*)-1 num_of_times FROM '+table_names+ '_staging_1 GROUP BY '+clmn+'ff_uuid HAVING  COUNT(*) > 1""",'

                    #count_null_value
                    count_null_value = ''
                    for num in (null_validation_columns):
                        query4 = ''
                        if null_validation_columns.index(num) == 0:
                            query4 = '"count_null_value":"""(select '
                        if null_validation_columns.index(num) == len(null_validation_columns) - 1:
                            query5 = 'SUM(CASE when '+num+' IS NULL THEN 1 ELSE 0 END) AS count_null_'+num+ ' from '+table_names+'_staging_1)""",'
                        else:
                            query5 ='SUM(CASE when '+num+' IS NULL THEN 1 ELSE 0 END) AS count_null_'+num+','
                        final = query4 + query5
                        count_null_value = count_null_value + final

                    # unique_records_same_records
                    unique_records_same_records = '"unique_records_same_records":"""insert into '+table_names+'_staging_2(' +clmn+ 'ff_uuid) select '+clmn+'ff_uuid) select '+clmn+'ff_uuid from ( SELECT '+clmn+'ff_uuid, row_number() over (partition by '+clmn+ 'ff_uuid) as rn from '+table_names+'_staging_1) sq Where rn =1""",'
                    validation_queries = check_if_null_query + save_dup + delete_null_values_qry + queries_filename+ staging_1_tb_name+ null_to_log_db + stg_2_to_temp_query + check_same_id_qry + normalize +data_type_check+temp_trans_aggregation_queries+sum_of_dup + unique_record_same_id + stg_1_to_stg_2_qry + save_null_tb_name + check_same_records + count_null_value + unique_records_same_records

            elif 'aggre' in row[0]:
                df_agg = pd.DataFrame(mycsv)
                df_agg.replace("", float("NaN"), inplace=True)
                df_agg.dropna(how='all', inplace=True)
                new_header = df_agg.iloc[0].str.strip().str.lower()
                df_agg.columns = new_header
                df_agg = df_agg[1:]

                if df_agg.empty:
                    del df_agg
                else:
                    select_column = df_agg['select_column'].dropna().unique()
                    # jolt_spec_district
                    qu1 = ''
                    qu = '"jolt_spec_district":"""[{"operation": "shift","spec": {"*": {"district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","percentage": "data.[&1].percentage","district_latitude": "data.[&1].district_latitude","district_longitude": "data.[&1].district_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'\

                    for sel_col in select_column:
                        if sel_col!='school_id':
                            qu1 += '"'+sel_col+'": "data.[&1].'+sel_col+'",'
                    qu2 ='"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools",''"'+table_names+'_count": "allDistrictsFooter.'+table_names+'[]","total_schools": "allDistrictsFooter.schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    district_jolt = qu+qu1+qu2

                    # exception_block_jolt_spec
                    qu4 = ''
                    qu6 = ''
                    qu8 = ''
                    qu3 = '"exception_block_jolt_spec":"""[{"operation": "shift","spec": {"*": {"block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col!='school_id':
                            qu4 += '"'+sel_col+'": "data.[&1].'+sel_col+'",'
                    qu5 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "footer.@(1,district_id).total_schools_with_missing_data"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}}},{"operation": "shift","spec": {"data": {"*": {"block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col!='school_id':
                            qu6 += '"'+sel_col+'": "data.[&1].'+sel_col+'",'
                    qu7 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "allBlocksFooter.total_schools_with_missing_data[]","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data","semester": "data.[&1].semester"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}},{"operation": "shift","spec": {"data": {"*": {"block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col!='school_id':
                            qu8 += '"'+sel_col+'": "data.[&1].'+sel_col+'",'
                    qu9 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"footer": "&","allBlocksFooter": "&"}}]""",'
                    exception_block_jolt_spec = qu3+qu4+qu5+qu6+qu7+qu8+qu9

                    # school_timeseries_jolt_spec
                    school_timeseries_jolt_spec  = '"school_timeseries_jolt_spec":"""[{"operation":"modify-overwrite-beta","spec":{"*":{"cluster_id":["=toString",null]}}},{"operation":"shift","spec":{"*":{"school_id":"data.[&1].school_id","school_name":"data.[&1].school_name","cluster_id":"data.[&1].cluster_id","cluster_name":"data.[&1].cluster_name","crc_name":"data.[&1].crc_name","district_id":"data.[&1].district_id","district_name":"data.[&1].district_name","block_id":"data.[&1].block_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","school_latitude":"data.[&1].school_latitude","school_longitude":"data.[&1].school_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"footer.@(1,cluster_id).'+table_names+'[]","total_schools":"footer.@(1,cluster_id).schools[]"}}},{"operation":"modify-overwrite-beta","spec":{"footer":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}},{"operation":"shift","spec":{"data":{"*":{"school_id":"data.[&1].school_id","school_name":"data.[&1].school_name","cluster_id":"data.[&1].cluster_id","cluster_name":"data.[&1].cluster_name","crc_name":"data.[&1].crc_name","district_id":"data.[&1].district_id","district_name":"data.[&1].district_name","block_id":"data.[&1].block_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","school_latitude":"data.[&1].school_latitude","school_longitude":"data.[&1].school_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"allSchoolsFooter.students[]","total_schools":"allSchoolsFooter.schools[]"}},"footer":"&"}},{"operation":"modify-overwrite-beta","spec":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}]""",'

                    #raw_district_jolt_spec
                    raw_district_jolt_spec ='"raw_district_jolt_spec":"""[{"operation":"shift","spec":{"*":{"district_id":"[&1].District ID","district_name":"[&1].District Name","academic_year":"[&1].Academic Year","'+table_names+'_percent_june":"[&1].'+table_names+' (%) June","'+table_names+'_count_june":"[&1].Total '+table_names+' June","total_schools_june":"[&1].Total Schools June","'+table_names+'_percent_july":"[&1].'+table_names+' (%) July","'+table_names+'_count_july":"[&1].Total '+table_names+' July","total_schools_july":"[&1].Total Schools July","'+table_names+'_percent_august":"[&1].'+table_names+' (%) August","'+table_names+'_count_august":"[&1].Total '+table_names+' August","total_schools_august":"[&1].Total Schools August","'+table_names+'_percent_september":"[&1].'+table_names+' (%) September","'+table_names+'_count_september":"[&1].Total '+table_names+' September","total_schools_september":"[&1].Total Schools September","'+table_names+'_percent_october":"[&1].'+table_names+' (%) October","'+table_names+'_count_october":"[&1].Total '+table_names+' October","total_schools_october":"[&1].Total Schools October","'+table_names+'_percent_november":"[&1].'+table_names+' (%) November","'+table_names+'_count_november":"[&1].Total '+table_names+' November","total_schools_november":"[&1].Total Schools November","'+table_names+'_percent_december":"[&1].'+table_names+' (%) December","'+table_names+'_count_december":"[&1].Total '+table_names+' December","total_schools_december":"[&1].Total Schools December","'+table_names+'_percent_january":"[&1].'+table_names+' (%) January","'+table_names+'_count_january":"[&1].Total '+table_names+' January","total_schools_january":"[&1].Total Schools January","'+table_names+'_percent_february":"[&1].'+table_names+' (%) February","'+table_names+'_count_february":"[&1].Total '+table_names+' February","total_schools_february":"[&1].Total Schools February","'+table_names+'_percent_march":"[&1].'+table_names+' (%) March","'+table_names+'_count_march":"[&1].Total '+table_names+' March","total_schools_march":"[&1].Total Schools March","'+table_names+'_percent_april":"[&1].'+table_names+' (%) April","'+table_names+'_count_april":"[&1].Total '+table_names+' April","total_schools_april":"[&1].Total Schools April","'+table_names+'_percent_may":"[&1].'+table_names+' (%) May","'+table_names+'_count_may":"[&1].Total '+table_names+' May","total_schools_may":"[&1].Total Schools May"}}}]""",'

                    #jolt_line_chart_state
                    jolt_line_chart_state = '"jolt_line_chart_state":"""[{"operation":"shift","spec":{"*":{"percentage":"'+table_names+'.[&1].'+table_names+'_percentage","'+table_names+'_count":"'+table_names+'.[&1].'+table_names+'_count","total_schools":"'+table_names+'.[&1].total_schools","month":"'+table_names+'.[&1].month","year":"'+table_names+'.[&1].year"}}},{"operation":"shift","spec":{"'+table_names+'":{"*":{"@":"@(1,year)[]"}}}}]""",'

                    # jolt_spec_cluster
                    qur1 = ''
                    qur3 = ''
                    qur = '"jolt_spec_cluster":"""[{"operation": "shift","spec": {"*": {"cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur1 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur2 ='"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,block_id).'+table_names+'[]","total_schools": "footer.@(1,block_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}},{"operation": "shift","spec": {"data": {"*": {"cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur3 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur4 ='"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allClustersFooter.'+table_names+'[]","total_schools": "allClustersFooter.schools[]"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    jolt_spec_cluster = qur+qur1+qur2+qur3+qur4

                    #raw_school_jolt_spec
                    raw_school_jolt_spec ='"raw_school_jolt_spec":"""[{"operation": "shift","spec": {"*": {"school_id": "[&1].Schools ID","school_name": "[&1].Schools Name","cluster_id": "[&1].Cluster ID","cluster_name": "[&1].Cluster Name","block_id": "[&1].Block ID","block_name": "[&1].Block Name","district_id": "[&1].District ID","district_name": "[&1].District Name","academic_year": "[&1].Academic Year","'+table_names+'_percent_june": "[&1].'+table_names+' (%) June","'+table_names+'_count_june": "[&1].Total '+table_names+' June","total_schools_june": "[&1].Total Schools June","'+table_names+'_percent_july": "[&1].'+table_names+' (%) July","'+table_names+'_count_july": "[&1].Total '+table_names+' July","total_schools_july": "[&1].Total Schools July","'+table_names+'_percent_august": "[&1].'+table_names+' (%) August","'+table_names+'_count_august": "[&1].Total '+table_names+' August","total_schools_august": "[&1].Total Schools August","'+table_names+'_percent_september": "[&1].'+table_names+' (%) September","'+table_names+'_count_september": "[&1].Total '+table_names+' September","total_schools_september": "[&1].Total Schools September","'+table_names+'_percent_october": "[&1].'+table_names+' (%) October","'+table_names+'_count_october": "[&1].Total '+table_names+' October","total_schools_october": "[&1].Total Schools October","'+table_names+'_percent_november": "[&1].'+table_names+' (%) November","'+table_names+'_count_november": "[&1].Total '+table_names+' November","total_schools_november": "[&1].Total Schools November","'+table_names+'_percent_december": "[&1].'+table_names+' (%) December","'+table_names+'_count_december": "[&1].Total '+table_names+' December","total_schools_december": "[&1].Total Schools December","'+table_names+'_percent_january": "[&1].'+table_names+' (%) January","'+table_names+'_count_january": "[&1].Total '+table_names+' January","total_schools_january": "[&1].Total Schools January","'+table_names+'_percent_february": "[&1].'+table_names+' (%) February","'+table_names+'_count_february": "[&1].Total '+table_names+' February","total_schools_february": "[&1].Total Schools February","'+table_names+'_percent_march": "[&1].'+table_names+' (%) March","'+table_names+'_count_march": "[&1].Total '+table_names+' March","total_schools_march": "[&1].Total Schools March","'+table_names+'_percent_april": "[&1].'+table_names+' (%) April","'+table_names+'_count_april": "[&1].Total '+table_names+' April","total_schools_april": "[&1].Total Schools April","'+table_names+'_percent_may": "[&1].'+table_names+' (%) May","'+table_names+'_count_may": "[&1].Total '+table_names+' May","total_schools_may": "[&1].Total Schools May"}}}]""",'

                    #jolt_line_chart_block
                    qur6 =''
                    qur5 = '"jolt_line_chart_block":"""[{"operation": "shift","spec": {"*": {"block_id": "[&1].block_id","block_name": "[&1].block_name","percentage": "[&1].'+table_names+'.'+table_names+'_percentage",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur6 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur7 = '"'+table_names+'_count": "[&1].'+table_names+'.'+table_names+'_count","total_schools": "[&1].'+table_names+'.total_schools"}}}, {"operation": "shift","spec": {"*": {"@block_name": "@(1,block_id).block_name[]","@'+table_names+'": "@(1,block_id).'+table_names+'[]"}}}]""",'
                    jolt_line_chart_block =qur5+qur6+qur7

                    #jolt_line_chart_district
                    qur9 =''
                    qur8 = '"jolt_line_chart_district":"""[{"operation": "shift","spec": {"*": {"district_id": "[&1].district_id","district_name": "[&1].district_name","percentage": "[&1].'+table_names+'.'+table_names+'_percentage",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur9 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur10 = '"'+table_names+'_count": "[&1].'+table_names+'.'+table_names+'_count","total_schools": "[&1].'+table_names+'.total_schools"}}}, {"operation": "shift","spec": {"*": {"@district_name": "@(1,district_id).district_name[]","@'+table_names+'": "@(1,district_id).'+table_names+'[]"}}}]""",'
                    jolt_line_chart_district = qur8+qur9+qur10

                    # transform_district_wise
                    qur12 = ''
                    qur11 = '"transform_district_wise":"""[{"operation": "shift","spec": {"*": {"district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","percentage": "data.[&1].percentage","district_latitude": "data.[&1].district_latitude","district_longitude": "data.[&1].district_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur12 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur13 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allDistrictsFooter.'+table_names+'[]","total_schools": "allDistrictsFooter.schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    transform_district_wise = qur11+qur12+qur13

                    #jolt_line_chart_school
                    qur15 =''
                    qur14 = '"jolt_line_chart_school":"""[{"operation": "modify-overwrite-beta","spec": {"*": {"school_id": ["=toString", null]}},{"operation": "shift","spec": {"*": {"school_id": "[&1].school_id","school_name": "[&1].school_name","percentage": "[&1].'+table_names+'.'+table_names+'_percentage",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur15 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur16 = '"'+table_names+'_count": "[&1].'+table_names+'.'+table_names+'_count"}}}, {"operation": "shift","spec": {"*": {"@school_name": "@(1,school_id).school_name[]","@'+table_names+'": "@(1,school_id).'+table_names+'[]"}}}]""",'
                    jolt_line_chart_school = qur14+qur15+qur16

                    # jolt_spec_school_management_category_meta
                    jolt_spec_school_management_category_meta = '"jolt_spec_school_management_category_meta":"""[{"operation": "shift","spec": {"*": {"@type": "@(1,category)"}}}]""",'

                    # jolt_spec_school
                    qur18 = ''
                    qur20 = ''
                    qur17 = '"jolt_spec_school":"""[{"operation": "modify-overwrite-beta","spec": {"*": {"cluster_id": ["=toString", null]}}},{"operation": "shift","spec": {"*": {"school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","crc_name": "data.[&1].crc_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur18 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur19 = '"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,cluster_id).'+table_names+'[]","total_schools": "footer.@(1,cluster_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}}, {"operation": "shift","spec": {"data": {"*": {"school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","crc_name": "data.[&1].crc_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur20 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur21= '"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allSchoolsFooter.'+table_names+'[]","total_schools": "allSchoolsFooter.schools[]"}},"footer": "&"}}, {"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    jolt_spec_school = qur17+qur18+qur19+qur20+qur21

                    #exception_district_jolt_spec
                    qur23 = ''
                    qur25 = ''
                    qur22 = '"exception_district_jolt_spec":"""[{"operation": "shift","spec": {"*": {"district_latitude": "data.[&1].district_latitude","district_longitude": "data.[&1].district_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur23 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur24 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "allDistrictsFooter.total_schools_with_missing_data[]"}}},{"operation": "modify-overwrite-beta","spec": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}},{"operation": "shift","spec": {"data": {"*": {"district_latitude": "data.[&1].district_latitude","district_longitude": "data.[&1].district_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur25 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur26 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"allDistrictsFooter": "&"}}]""",'
                    exception_district_jolt_spec =qur22+qur23+qur24+qur25+qur26

                    # cluster_timeseries_jolt_spec
                    cluster_timeseries_jolt_spec = '"cluster_timeseries_jolt_spec":"""[{"operation":"shift","spec":{"*":{"cluster_id":"data.[&1].cluster_id","cluster_name":"data.[&1].cluster_name","district_id":"data.[&1].district_id","district_name":"data.[&1].district_name","block_id":"data.[&1].block_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","cluster_latitude":"data.[&1].cluster_latitude","cluster_longitude":"data.[&1].cluster_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"footer.@(1,block_id).'+table_names+'[]","total_schools":"footer.@(1,block_id).schools[]"}}},{"operation":"modify-overwrite-beta","spec":{"footer":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}},{"operation":"shift","spec":{"data":{"*":{"cluster_id":"data.[&1].cluster_id","cluster_name":"data.[&1].cluster_name","district_id":"data.[&1].district_id","district_name":"data.[&1].district_name","block_id":"data.[&1].block_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","cluster_latitude":"data.[&1].cluster_latitude","cluster_longitude":"data.[&1].cluster_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"allClustersFooter.'+table_names+'[]","total_schools":"allClustersFooter.schools[]"}},"footer":"&"}},{"operation":"modify-overwrite-beta","spec":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}]""",'

                    # exception_school_jolt_spec
                    qur28 = ''
                    qur30 = ''
                    qur32 = ''
                    qur27 ='"exception_school_jolt_spec":"""[{"operation": "modify-overwrite-beta","spec": {"*": {"cluster_id": ["=toString",null]}}},{"operation": "shift","spec": {"*": {"school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur28 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur29 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "footer.@(1,cluster_id).total_schools_with_missing_data"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}}},{"operation": "shift","spec": {"data": {"*": {"school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur30 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur31 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "allSchoolsFooter.total_schools_with_missing_data[]","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}},{"operation": "shift","spec": {"data": {"*": {"school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur32 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur33 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"footer": "&","allSchoolsFooter": "&"}}]""",'
                    exception_school_jolt_spec = qur27+qur28+qur29+qur30+qur31+qur32+qur33

                    # transform_cluster_wise
                    qur35 = ''
                    qur37 = ''
                    qur34 = '"transform_cluster_wise":"""[{"operation": "shift","spec": {"*": {"cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur35 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur36 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,block_id).'+table_names+'[]","total_schools": "footer.@(1,block_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}},{"operation": "shift","spec": {"data": {"*": {"cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur37 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur38 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allClustersFooter.'+table_names+'[]","total_schools": "allClustersFooter.schools[]"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    transform_cluster_wise = qur34+qur35+qur36+qur37+qur38

                    # raw_cluster_jolt_spec
                    raw_cluster_jolt_spec = '"raw_cluster_jolt_spec":"""[{"operation":"shift","spec":{"*":{"cluster_id":"[&1].Cluster ID","cluster_name":"[&1].Cluster Name","block_id":"[&1].Block ID","block_name":"[&1].Block Name","district_id":"[&1].District ID","district_name":"[&1].District Name","academic_year":"[&1].Academic Year","'+table_names+'_percent_june":"[&1].'+table_names+' (%) June","'+table_names+'_count_june":"[&1].Total '+table_names+' June","total_schools_june":"[&1].Total Schools June","'+table_names+'_percent_july":"[&1].'+table_names+' (%) July","'+table_names+'_count_july":"[&1].Total '+table_names+' July","total_schools_july":"[&1].Total Schools July","'+table_names+'_percent_august":"[&1].'+table_names+' (%) August","'+table_names+'_count_august":"[&1].Total '+table_names+' August","total_schools_august":"[&1].Total Schools August","'+table_names+'_percent_september":"[&1].'+table_names+' (%) September","'+table_names+'_count_september":"[&1].Total '+table_names+' September","total_schools_september":"[&1].Total Schools September","'+table_names+'_percent_october":"[&1].'+table_names+' (%) October","'+table_names+'_count_october":"[&1].Total '+table_names+' October","total_schools_october":"[&1].Total Schools October","'+table_names+'_percent_november":"[&1].'+table_names+' (%) November","'+table_names+'_count_november":"[&1].Total '+table_names+' November","total_schools_november":"[&1].Total Schools November","'+table_names+'_percent_december":"[&1].'+table_names+' (%) December","'+table_names+'_count_december":"[&1].Total '+table_names+' December","total_schools_december":"[&1].Total Schools December","'+table_names+'_percent_january":"[&1].'+table_names+' (%) January","'+table_names+'_count_january":"[&1].Total '+table_names+' January","total_schools_january":"[&1].Total Schools January","'+table_names+'_percent_february":"[&1].'+table_names+' (%) February","'+table_names+'_count_february":"[&1].Total '+table_names+' February","total_schools_february":"[&1].Total Schools February","'+table_names+'_percent_march":"[&1].'+table_names+' (%) March","'+table_names+'_count_march":"[&1].Total '+table_names+' March","total_schools_march":"[&1].Total Schools March","'+table_names+'_percent_april":"[&1].'+table_names+' (%) April","'+table_names+'_count_april":"[&1].Total '+table_names+' April","total_schools_april":"[&1].Total Schools April","'+table_names+'_percent_may":"[&1].'+table_names+' (%) May","'+table_names+'_count_may":"[&1].Total '+table_names+' May","total_schools_may":"[&1].Total Schools May"}}}]""",'

                    #transform_school_wise
                    qur40 = ''
                    qur42 = ''
                    qur39 = '"transform_school_wise":"""[{"operation": "modify-overwrite-beta","spec": {"*": {"cluster_id": ["=toString", null]}}},{"operation": "shift","spec": {"*": {"school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","crc_name": "data.[&1].crc_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur40 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur41 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,cluster_id).'+table_names+'[]","total_schools": "footer.@(1,cluster_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}}, {"operation": "shift","spec": {"data": {"*": {"school_id": "data.[&1].school_id","school_name": "data.[&1].school_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","crc_name": "data.[&1].crc_name","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","school_latitude": "data.[&1].school_latitude","school_longitude": "data.[&1].school_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur42 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur43 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allSchoolsFooter.'+table_names+'[]","total_schools": "allSchoolsFooter.schools[]"}},"footer": "&"}}, {"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    transform_school_wise = qur39+qur40+qur41+qur42+qur43

                    #jolt_spec_block
                    qur45 = ''
                    qur47 = ''
                    qur44 = '"jolt_spec_block":"""[{"operation": "shift","spec": {"*": {"block_id": "data.[&1].block_id","district_name": "data.[&1].district_name","district_id": "data.[&1].district_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur45 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur46 = '"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,district_id).'+table_names+'[]","total_schools": "footer.@(1,district_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}},{"operation": "shift","spec": {"data": {"*": {"block_id": "data.[&1].block_id","district_name": "data.[&1].district_name","district_id": "data.[&1].district_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur47 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur48 = '"school_management_type": "data.[&1].school_management_type","school_category": "data.[&1].school_category","@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allBlocksFooter.'+table_names+'[]","total_schools": "allBlocksFooter.schools[]"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    jolt_spec_block = qur44+qur45+qur46+qur47+qur48

                    # transform_block_wise
                    qur50 = ''
                    qur52 = ''
                    qur49 = '"transform_block_wise":"""[{"operation": "shift","spec": {"*": {"block_id": "data.[&1].block_id","district_name": "data.[&1].district_name","district_id": "data.[&1].district_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur50 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur51 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "footer.@(1,district_id).'+table_names+'[]","total_schools": "footer.@(1,district_id).schools[]"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}},{"operation": "shift","spec": {"data": {"*": {"block_id": "data.[&1].block_id","district_name": "data.[&1].district_name","district_id": "data.[&1].district_id","block_name": "data.[&1].block_name","percentage": "data.[&1].percentage","block_latitude": "data.[&1].block_latitude","block_longitude": "data.[&1].block_longitude","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur52 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur53 = '"@'+table_names+'_count": "data.[&1].'+table_names+'_count","@total_schools": "data.[&1].total_schools","'+table_names+'_count": "allBlocksFooter.'+table_names+'[]","total_schools": "allBlocksFooter.schools[]"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"'+table_names+'": "=intSum(@(1,'+table_names+'))","schools": "=intSum(@(1,schools))"}}}]""",'
                    transform_block_wise = qur49+qur50+qur51+qur52+qur53

                    #district_timeseries_jolt_spec
                    district_timeseries_jolt_spec = '"district_timeseries_jolt_spec":"""[{"operation":"shift","spec":{"*":{"district_id":"data.[&1].district_id","district_name":"data.[&1].district_name","percentage":"data.[&1].percentage","district_latiitude":"data.[&1].district_latiitude","district_longitude":"data.[&1].district_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"allDistrictsFooter.'+table_names+'[]","total_schools":"allDistrictsFooter.schools[]"}}},{"operation":"modify-overwrite-beta","spec":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}]""",'

                    # block_time_series_jolt
                    block_time_series_jolt = '"block_timeseries_jolt_spec":"""[{"operation":"shift","spec":{"*":{"block_id":"data.[&1].block_id","district_name":"data.[&1].district_name","district_id":"data.[&1].district_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","block_latitude":"data.[&1].block_latitude","block_longitude":"data.[&1].block_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"footer.@(1,district_id).'+table_names+'[]","total_schools":"footer.@(1,district_id).schools[]"}}},{"operation":"modify-overwrite-beta","spec":{"footer":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}},{"operation":"shift","spec":{"data":{"*":{"block_id":"data.[&1].block_id","district_name":"data.[&1].district_name","district_id":"data.[&1].district_id","block_name":"data.[&1].block_name","percentage":"data.[&1].percentage","block_latitude":"data.[&1].block_latitude","block_longitude":"data.[&1].block_longitude","data_from_date":"data.[&1].data_from_date","data_upto_date":"data.[&1].data_upto_date","@'+table_names+'_count":"data.[&1].'+table_names+'_count","@total_schools":"data.[&1].total_schools","'+table_names+'_count":"allBlocksFooter.'+table_names+'[]","total_schools":"allBlocksFooter.schools[]"}},"footer":"&"}},{"operation":"modify-overwrite-beta","spec":{"*":{"'+table_names+'":"=intSum(@(1,'+table_names+'))","schools":"=intSum(@(1,schools))"}}}]""",'

                    #jolt_for_log_summary
                    qur55 = ''
                    qur54 = '"jolt_for_log_summary":"""[{"operation": "shift","spec": {"*": {"filename": "[&1].filename","ff_uuid": "[&1].ff_uuid","total_records": "[&1].total_records","blank_lines": "[&1].blank_lines","duplicate_records": "[&1].duplicate_records","datatype_mismatch": "[&1].datatype_mismatch","'+table_names+'_id": "[&1].records_with_null_value.'+table_names+'_id","'+table_names+'_id": "[&1].records_with_null_value.'+table_names+'_id","school_id": "[&1].records_with_null_value.school_id",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur55 += '"' + sel_col + '": "[&1].records_with_null_value.' + sel_col + '",'
                    qur56 = '"processed_records": "[&1].processed_records","process_start_time": "[&1].process_start_time","process_end_time": "[&1].process_end_time"}}}]""",'
                    jolt_for_log_summary = qur54+qur55+qur56

                    #exception cluster_jolt_spec
                    qur58 = ''
                    qur60 = ''
                    qur62 = ''
                    qur57 = '"exception_cluster_jolt_spec":"""[{"operation": "shift","spec": {"*": {"cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur58 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur59 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "footer.@(1,block_id).total_schools_with_missing_data"}}},{"operation": "modify-overwrite-beta","spec": {"footer": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}}},{"operation": "shift","spec": {"data": {"*": {"cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur60 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur61 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","@total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","total_schools_with_missing_data": "allClustersFooter.total_schools_with_missing_data[]","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"footer": "&"}},{"operation": "modify-overwrite-beta","spec": {"*": {"total_schools_with_missing_data": "=intSum(@(1,total_schools_with_missing_data))"}}},{"operation": "shift","spec": {"data": {"*": {"cluster_latitude": "data.[&1].cluster_latitude","cluster_longitude": "data.[&1].cluster_longitude","district_id": "data.[&1].district_id","district_name": "data.[&1].district_name","block_id": "data.[&1].block_id","block_name": "data.[&1].block_name","cluster_id": "data.[&1].cluster_id","cluster_name": "data.[&1].cluster_name","data_from_date": "data.[&1].data_from_date","data_upto_date": "data.[&1].data_upto_date",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur62 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur63 = '"school_management_type": "data.[&1].school_management_type","total_schools": "data.[&1].total_schools","total_schools_with_missing_data": "data.[&1].total_schools_with_missing_data","percentage_schools_with_missing_data": "data.[&1].percentage_schools_with_missing_data"}},"footer": "&","allClustersFooter": "&"}}]""",'
                    exception_cluster_jolt_spec = qur57+qur58+qur59+qur60+qur61+qur62+qur63

                    #jolt_line_chart_cluster
                    qur65 = ''
                    qur64 = '"jolt_line_chart_cluster":"""[{"operation": "modify-overwrite-beta","spec": {"*": {"cluster_id": ["=toString", null]}}},{"operation": "shift","spec": {"*": {"cluster_id": "[&1].cluster_id","cluster_name": "[&1].cluster_name","percentage": "[&1].'+table_names+'.'+table_names+'_percentage",'
                    for sel_col in select_column:
                        if sel_col != 'school_id':
                            qur65 += '"' + sel_col + '": "data.[&1].' + sel_col + '",'
                    qur66 = '"'+table_names+'_count": "[&1].'+table_names+'.'+table_names+'_count","total_schools": "[&1].'+table_names+'.total_schools"}}}, {"operation": "shift","spec": {"*": {"@cluster_name": "@(1,cluster_id).cluster_name[]","@'+table_names+'": "@(1,cluster_id).'+table_names+'[]"}}}]""",'
                    jolt_line_chart_cluster = qur64+qur65+qur66

                    # raw_block_jolt_spec
                    raw_block_jolt_spec = '"raw_block_jolt_spec":"""[{"operation":"shift","spec":{"*":{"block_id":"[&1].Block ID","block_name":"[&1].Block Name","district_id":"[&1].District ID","district_name":"[&1].District Name","academic_year":"[&1].Academic Year","'+table_names+'_percent_june":"[&1].'+table_names+' (%) June","'+table_names+'_count_june":"[&1].Total '+table_names+' June","total_schools_june":"[&1].Total Schools June","'+table_names+'_percent_july":"[&1].'+table_names+' (%) July","'+table_names+'_count_july":"[&1].Total '+table_names+' July","total_schools_july":"[&1].Total Schools July","'+table_names+'_percent_august":"[&1].'+table_names+' (%) August","'+table_names+'_count_august":"[&1].Total '+table_names+' August","total_schools_august":"[&1].Total Schools August","'+table_names+'_percent_september":"[&1].'+table_names+' (%) September","'+table_names+'_count_september":"[&1].Total '+table_names+' September","total_schools_september":"[&1].Total Schools September","'+table_names+'_percent_october":"[&1].'+table_names+' (%) October","'+table_names+'_count_october":"[&1].Total '+table_names+' October","total_schools_october":"[&1].Total Schools October","'+table_names+'_percent_november":"[&1].'+table_names+' (%) November","'+table_names+'_count_november":"[&1].Total '+table_names+' November","total_schools_november":"[&1].Total Schools November","'+table_names+'_percent_december":"[&1].'+table_names+' (%) December","'+table_names+'_count_december":"[&1].Total '+table_names+' December","total_schools_december":"[&1].Total Schools December","'+table_names+'_percent_january":"[&1].'+table_names+' (%) January","'+table_names+'_count_january":"[&1].Total '+table_names+' January","total_schools_january":"[&1].Total Schools January","'+table_names+'_percent_february":"[&1].'+table_names+' (%) February","'+table_names+'_count_february":"[&1].Total '+table_names+' February","total_schools_february":"[&1].Total Schools February","'+table_names+'_percent_march":"[&1].'+table_names+' (%) March","'+table_names+'_count_march":"[&1].Total '+table_names+' March","total_schools_march":"[&1].Total Schools March","'+table_names+'_percent_april":"[&1].'+table_names+' (%) April","'+table_names+'_count_april":"[&1].Total '+table_names+' April","total_schools_april":"[&1].Total Schools April","'+table_names+'_percent_may":"[&1].'+table_names+' (%) May","'+table_names+'_count_may":"[&1].Total '+table_names+' May","total_schools_may":"[&1].Total Schools May"}}}]""",'
                    all_param_queries += validation_queries+district_jolt+exception_block_jolt_spec+school_timeseries_jolt_spec+raw_district_jolt_spec+jolt_line_chart_state+jolt_spec_cluster+raw_school_jolt_spec+jolt_line_chart_block+jolt_line_chart_district+transform_district_wise+jolt_line_chart_school+jolt_spec_school_management_category_meta+jolt_spec_school+exception_district_jolt_spec+cluster_timeseries_jolt_spec+exception_school_jolt_spec+transform_cluster_wise+raw_cluster_jolt_spec+transform_school_wise+jolt_spec_block+transform_block_wise+district_timeseries_jolt_spec+block_time_series_jolt+jolt_for_log_summary+exception_cluster_jolt_spec+jolt_line_chart_cluster+raw_block_jolt_spec
            key_index += 1
            del mycsv[:]
            if key_index == len(keywords):
                break
            key = keywords[key_index]
        else:
            mycsv.append(row)


def create_table_queries():
    input_df = pd.read_csv(read_input())
    keywords = input_df['keywords'].dropna().tolist()
    mycsv = []
    key_index = 0
    global all_queries
    all_queries =''
    key = keywords[key_index]
    print(keywords)
    for row in csv.reader(read_input()):
        if row[0] == key:
            if 'trans' in row[0]:
                df = pd.DataFrame(mycsv)
                new_header = df.iloc[0].str.strip().str.lower()
                df.replace("", float("NaN"), inplace=True)
                df.dropna(how='all', inplace=True)
                df = df[1:]
                if df[2:].empty:
                    del df
                else:
                    df.columns = new_header
                    global table_names
                    table_names = df['table_name'].dropna().to_string(index=False)
                    tmp_columns = df['columns'].dropna().tolist()
                    columns = []
                    for col in tmp_columns:
                        x = col.replace(" ", "_")
                        columns.append(x)
                    data_types = df['data_type']
                    ref_table_df = df['ref_table'].dropna().to_list()
                    ref_col_df = df['ref_column'].dropna()
                    null_validation_df = df[df['null_validation_required'] == 'Yes']
                    null_validation_columns = null_validation_df['columns'].to_list()
                    no_of_columns = len(columns)
                    foriegn_key_df2 = df[df['constraints'] == 'foreign key']
                    f_k_columns_l = foriegn_key_df2['columns'].to_list()
                    f_k_columns = ','.join(f_k_columns_l)
                    for num in ('_staging1', '_staging2', '_temp'):
                        query1 = 'create table if not exists ' + table_names + num + '( ff_uuid text, '
                        iter2 = 0
                        for col, dt in zip(columns, data_types):
                            if iter2 <= no_of_columns:
                                if col in range(1, 31):
                                    query1 = query1 + 'day_' + col + " " + dt + ","
                                else:
                                    query1 = query1 + col + " " + dt + ","
                            iter2 = iter2 + 1
                        query1 = query1 + 'created_on  TIMESTAMP without time zone, updated_on  TIMESTAMP without time zone'
                        if foriegn_key_df2.empty:
                            staging_2_query = query1 + ');'
                        else:
                            iter = 0
                            no_of_tables = len(ref_table_df)
                            for fk_col, table, colms in zip(f_k_columns_l, ref_table_df, ref_col_df):
                                if iter <= no_of_tables:
                                    query1 = query1 + ' , foreign key (' + fk_col.replace(" ",
                                                                                          "_") + ') references ' + table + '(' + colms + ')'
                                iter = iter + 1
                            staging_2_query = query1 + ');'
                        all_queries = all_queries + staging_2_query +'\n'
                    primary_key_filter = df[df['constraints'] == 'primary key']

                    p_k_columns = primary_key_filter['columns'].to_list()
                    p_k_columns = ','.join(p_k_columns)
                    query2 = 'create table if not exists ' + table_names + '_trans( '
                    iter2 = 0
                    for col, dt in zip(columns, data_types):
                        if iter2 <= no_of_columns:
                            if col in range(1, 31):
                                query2 = query2 + 'day_' + col + " " + dt + ","

                            else:
                                query2 = query2 + col + " " + dt + ","
                        iter2 = iter2 + 1
                    trans_query = query2 + 'created_on  TIMESTAMP without time zone, updated_on  TIMESTAMP without time zone'
                    if len(p_k_columns) == 0 and f_k_columns_l.empty:
                        trans_query = trans_query + ');'
                    elif len(p_k_columns) > 0 and foriegn_key_df2.empty:
                        trans_query = trans_query + ' , primary key (' + p_k_columns.replace(" ", "_") + ')'
                    elif len(p_k_columns) == 0 and foriegn_key_df2.empty is False:
                        iter = 0
                        no_of_tables = len(ref_table_df)
                        for fk_col, table, colms in zip(f_k_columns_l, ref_table_df, ref_col_df):
                            if iter <= no_of_tables:
                                trans_query = trans_query + ' , foreign key (' + fk_col.replace(" ",
                                                                                                "_") + ') references ' + table + '(' + colms + ')'
                            iter = iter + 1
                        trans_query = trans_query + ');'
                    else:
                        trans_query = trans_query + ' , primary key (' + p_k_columns.replace(" ", "_")
                        iter = 0
                        no_of_tables = len(ref_table_df)
                        for fk_col, table, colms in zip(f_k_columns_l, ref_table_df, ref_col_df):
                            if iter <= no_of_tables:
                                trans_query = trans_query + ' , foreign key (' + fk_col.replace(" ",
                                                                                                "_") + ') references ' + table + '(' + colms + ')'
                            iter = iter + 1
                    trans_query = trans_query + ');'
                    global temp_to_trans
                    trans_insert = 'insert into ' + table_names + '_trans( '
                    exclude_col = ''
                    for elem in columns:
                        exclude_col += elem + '= excluded.' + elem + ','
                    columns_insert = ','.join(columns)
                    trans_insert += columns_insert + ',created_on,updated_on)  select ' + columns_insert + ',now(),now() from ' + table_names + '_temp' + ' on conflict('+ p_k_columns + ') do update set ' + exclude_col + 'updated_on=now();'
                    temp_to_trans = '\n' + '"temp_to_trans":"""' + trans_insert + '"""}'
                    all_queries = all_queries + trans_query

                    query3 = 'create table if not exists ' + table_names + '_dup( '
                    iter2 = 0
                    for col, dt in zip(columns, data_types):
                        if iter2 <= no_of_columns:
                            if col in range(1, 31):
                                query3 = query3 + 'day_' + col + " " + dt + ","
                            else:
                                query3 = query3 + col + " " + dt + ","
                        iter2 = iter2 + 1
                    dup_query = query3 + 'num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);'
                    all_queries = all_queries + '\n' + dup_query
                    nul_val_df = df[df['null_validation_required'] == 'Yes']
                    nul_val_cols = nul_val_df['columns'].to_list()
                    if len(nul_val_cols) > 0:
                        query4 = 'create table if not exists ' + table_names + '_null_col( filename varchar(200),'
                        iter2 = 0
                        for col in nul_val_cols:
                            if iter2 <= no_of_columns:
                                query4 = query4 + 'count_null_' + col + " int,"
                            iter2 = iter2 + 1
                        nul_col_query = query4 + 'ff_uuid varchar(200));'
                        all_queries = all_queries + '\n' + nul_col_query
            elif 'type_of_data' in row[0]:
                df_tod = pd.DataFrame(mycsv)
                df_tod.replace("", float("NaN"), inplace=True)
                df_tod.dropna(how='all', inplace=True, axis=1)
                new_header = df_tod.iloc[0].str.strip().str.lower()
                df_tod.columns = new_header
                df_tod = df_tod[1:]
                df_level_of_data = df_tod['level_of_data'].dropna().to_string()
                global df_filters_req
                df_filters_req = df_tod['filters_required'].dropna().to_list()
                global df_time_sel
                df_time_sel = df_tod['time_selections'].dropna().to_list()
                global date_col
                date_col = df_tod['date_column_to_filter'].dropna().to_string(index=False)
            elif df_level_of_data in df_filters_req and 'aggregation' not in keywords:
                query2 = 'create table if not exists ' + table_names + '_aggregation( '
                iter2 = 0
                for col, dt in zip(columns, data_types):
                    if iter2 <= no_of_columns:
                        if col in range(1, 31):
                            query2 = query2 + 'day_' + col + " " + dt + ","
                        else:
                            query2 = query2 + col + " " + dt + ","
                    iter2 = iter2 + 1
                aggregation_query = query2 + 'created_on  TIMESTAMP without time zone, updated_on  TIMESTAMP without time zone'
                if len(p_k_columns) == 0 and f_k_columns_l.empty:
                    aggregation_query = aggregation_query + ');'
                elif len(p_k_columns) > 0 and foriegn_key_df2.empty:
                    aggregation_query = aggregation_query + ' , primary key (' + p_k_columns.replace(" ", "_") + ')'
                elif len(p_k_columns) == 0 and foriegn_key_df2.empty is False:
                    iter = 0
                    no_of_tables = len(ref_table_df)
                    for fk_col, table, colms in zip(f_k_columns_l, ref_table_df, ref_col_df):
                        if iter <= no_of_tables:
                            aggregation_query = aggregation_query + ' , foreign key (' + fk_col.replace(" ",
                                                                                            "_") + ') references ' + table + '(' + colms + ')'
                        iter = iter + 1
                    aggregation_query = aggregation_query + ');'
                else:
                    aggregation_query = aggregation_query + ' , primary key (' + p_k_columns.replace(" ", "_")
                    iter = 0
                    no_of_tables = len(ref_table_df)
                    for fk_col, table, colms in zip(f_k_columns_l, ref_table_df, ref_col_df):
                        if iter <= no_of_tables:
                            aggregation_query = aggregation_query + ' , foreign key (' + fk_col.replace(" ",
                                                                                            "_") + ') references ' + table + '(' + colms + ')'
                        iter = iter + 1
                aggregation_query = aggregation_query + ');'
                all_queries = all_queries + '\n' + aggregation_query

            elif df_level_of_data not in df_filters_req and 'aggregation' in row[0]:
                df_agg = pd.DataFrame(mycsv)
                df_agg.replace("", float("NaN"), inplace=True)
                df_agg.dropna(how='all', inplace=True)
                new_header = df_agg.iloc[0].str.strip().str.lower()
                df_agg.columns = new_header
                df_agg = df_agg[1:]
                static_columns = 'school_name varchar(200),school_latitude double precision,school_longitude double precision,district_id bigint,district_name varchar(100),district_latitude  double precision,district_longitude  double precision,block_id  bigint,block_name varchar(100),block_latitude  double precision,block_longitude  double precision,cluster_id  bigint,cluster_name varchar(100),cluster_latitude  double precision,cluster_longitude  double precision'
                if df_agg.empty:
                    del df_agg
                else:
                    static_create_columns = 'school_name varchar(200),school_latitude double precision,school_longitude double precision,district_id bigint,district_name varchar(100),district_latitude  double precision,district_longitude  double precision,block_id  bigint,block_name varchar(100),block_latitude  double precision,block_longitude  double precision,cluster_id  bigint,cluster_name varchar(100),cluster_latitude  double precision,cluster_longitude  double precision'
                    df_agg_metric = df_agg['metric_type'].dropna().to_string(index=False)
                    select_cols = df_agg['select_column'].dropna().to_list()
                    reference_column = df_agg['ref_columns'].dropna().to_string(index=False)
                    global result_col
                    result_col = df_agg['result_metric'].dropna().to_string(index=False)
                    primary_key = df_agg['primary_key'].dropna().to_list()
                    p_k_columns = ','.join([str(elem) for elem in primary_key])
                    global select_columns
                    select_columns = df_agg['select_column'].dropna()
                    global condition
                    condition = df_agg['condition'].dropna()
                    if condition.empty is True:
                        condition = ''
                    else:
                        condition = df_agg['condition'].dropna().to_string(index=False)
                        condition = ' where ' + condition
                    global agg_column
                    create_cols = ''
                    for col in select_columns:
                        for create_col, dt in zip(columns, data_types):
                            if col == create_col:
                                create_cols = create_cols + col + " " + dt + ","
                            iter2 = iter2 + 1

                    if 'count' in df_agg_metric:
                        agg_column = 'count(' + reference_column + ')  as ' + result_col

                    aggregation_query = 'create table if not exists ' + table_names + '_aggregation(' + static_create_columns + ',' + create_cols + result_col + ' integer,created_on  TIMESTAMP without time zone ,updated_on  TIMESTAMP without time zone,primary key(' + p_k_columns + '));'
                    create_trans_to_aggregate_queries()
                    all_queries = all_queries + '\n' + aggregation_query + '\n'
            elif 'report' in row[0]:
                df_op = pd.DataFrame(mycsv)
                df_op.replace("", float("NaN"), inplace=True)
                df_op.dropna(how='all', inplace=True, axis=1)
                new_header = df_op.iloc[0].str.strip().str.lower()
                df_op.columns = new_header
                df_op = df_op[1:]
                global sel_col_op
                sel_col_op = df_op['select_column'].dropna()
                sel_col_op = ','.join([str(elem) for elem in sel_col_op])
                global metric_op
                metric_op = df_op['metric_type'].dropna().to_string(index=False)
                global ref_op_column
                ref_op_column = df_op['ref_columns'].dropna().to_string(index=False)
                global result_col_op
                result_col_op = df_op['result_metric'].dropna().to_string(index=False)
                global metric_rep
                if 'sum' in metric_op:
                    metric_rep = 'sum(' + ref_op_column + ')  as ' + result_col_op
                global group_by_op
                group_by_op = df_op['group_by_columns'].dropna().to_string(index=False)
            elif 'visualization' in row[0]:
                df_vis = pd.DataFrame(mycsv)
                df_vis.replace("", float("NaN"), inplace=True)
                df.dropna(how='all', inplace=True, axis=1)
                new_header = df_vis.iloc[0].str.strip().str.lower()
                df_vis = df_vis[1:]
                if df_vis[1:].empty:
                    del df_vis
                else:
                    df_vis.columns = new_header
                    datasourcenames = df_vis['data_source_name'].dropna().to_string(index=False).split()
                    tmp_columns = df_vis['report_type'].dropna().tolist()
                    description = df_vis['description'].dropna().tolist()
                    create_table_query = ' '
                    create_table_query = 'create table if not exists configurable_datasource_properties (report_name varchar(50),report_type varchar(20),description text,status boolean);'
                    insert_query = ''
                    for d, r, info in zip(datasourcenames, tmp_columns, description):
                        insert_query = insert_query + "insert into configurable_datasource_properties values('" + d + "','" + r + "','" + info + "',False) ;";
                    all_queries = all_queries + '\n' + create_table_query + '\n' + insert_query
            key_index += 1
            del mycsv[:]
            if key_index == len(keywords):
                break
            key = keywords[key_index]
        else:
            mycsv.append(row)

def create_trans_to_aggregate_queries():
    global all_param_queries_1
    all_param_queries_1 = ''
    select_col = ','.join([str(elem) for elem in select_columns])
    print(select_col)
    inner_query = '(select '+ select_col + ',' + agg_column + ' from' + table_names +'_trans' + condition + ' group by ' + select_col + ') as a'
    inner_query_cols = ''
    for elem in select_columns:
        inner_query_cols = inner_query_cols + 'a.'+str(elem) +','
    inner_query_cols = inner_query_cols + result_col
    static_query =  '(select shd.school_id,school_name,school_latitude,school_longitude,shd.cluster_id,cluster_name,cluster_latitude,cluster_longitude,shd.block_id,block_name,block_latitude,block_longitude,shd.district_id,district_name,district_latitude,district_longitude from school_hierarchy_details shd inner join school_geo_master sgm  on shd.school_id=sgm.school_id)as sch'
    stat = 'insert into '+table_names +'_aggregation('+ select_col + ',' + result_col + ',school_name,school_latitude,school_longitude,cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,block_latitude,block_longitude,district_id,district_name,district_latitude,district_longitude)' +' ' 'select '+ inner_query_cols + ',school_name,school_latitude,school_longitude,cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,block_latitude,block_longitude,district_id,district_name,district_latitude,district_longitude' +' from '+inner_query + ' join '+  static_query + ' on a.school_id=sch.school_id;'
    global to_parameters
    to_parameters = '\n' +  '"trans_to_agg":"""'+stat +'""",'
    all_param_queries_1 = all_param_queries_1 + to_parameters
    print(all_param_queries_1)

def create_dml_timeline_queries():
    school_ = ' school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name'
    cluster_ = ' cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name'
    block_ = ' block_id,block_name,block_latitude,block_longitude,district_id,district_name'
    district_ = ' district_id,district_name,district_latitude,district_longitude'
    week = "extract('day' from date_trunc('week'," + date_col + ") -date_trunc('week', date_trunc('month'," + date_col +" ))) / 7 + 1 as week"
    daily_filter = ' where '+ date_col + " in (select (generate_series(now()::date-'30day'::interval,(now()::date-'1day'::interval)::date,'1day'::interval)::date) as day) "
    weekly_filter = ' where '+ date_col + " in (select (generate_series(now()::date-'100day'::interval,(now()::date-'1day'::interval)::date,'1day'::interval)::date) as day) "
    last_30_day_filter = ' where ' + date_col + " in (select (generate_series(now()::date-'30day'::interval,(now()::date-'1day'::interval)::date,'1day'::interval)::date) as day) "
    last_7_day_filter = ' where ' + date_col + " in (select (generate_series(now()::date-'7day'::interval,(now()::date-'1day'::interval)::date,'1day'::interval)::date) as day) "
    global dml_queries
    dml_queries = '[' + '\n'

    if 'daily' in df_time_sel:
        school_daily = '{ "school_daily":"select month,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +','+sel_col_op + ',week,month"},'
        cluster_daily = '{ "cluster_daily":"select month,'+ week + ','  +cluster_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +','+sel_col_op+ ',week,month"},'
        block_daily = '{ "block_daily":"select month,'+ week + ','  + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',' + sel_col_op +',week,month"},'
        district_daily = '{"district_daily":"select month,'+ week + ','  + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',' + sel_col_op +',week,month"},'
        school_mgmt_daily = '{"school_management_daily":"select month,'+ week + ','  +school_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +',school_management_type,'+sel_col_op + ',week,month"},'
        cluster_mgmt_daily = '{"cluster_management_daily":"select month,'+ week + ','  +cluster_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +',school_management_type,'+sel_col_op + ',week,month"},'
        block_mgmt_daily = '{"block_management_daily":"select month,'+ week + ','  + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',school_management_type,' + sel_col_op + ',week,month"},'
        district_mgmt_daily = '{"district_management_daily":"select month,'+ week + ','  + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',school_management_type,' + sel_col_op + ',week,month"},'
        dml_queries = dml_queries +'\n' + school_daily + '\n' + cluster_daily +'\n' + block_daily + '\n' + district_daily + '\n'+ school_mgmt_daily + '\n' + cluster_mgmt_daily + '\n' + block_mgmt_daily + '\n' + district_mgmt_daily

    if 'weekly' in df_time_sel:
        school_weekly = '{"school_weekly":"select month,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + weekly_filter + 'group by ' + school_ +','+sel_col_op+',week,month'+'"},'
        cluster_weekly = '{"cluster_weekly":"select month,'+ week + ',' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op+',week,month'+'"},'
        block_weekly = '{"block_weekly":"select month' + week + ',' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,month' + '"},'
        district_weekly = '{"district_weekly":"select month,' + week + ',' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,month' + '"},'
        school_mgmt_weekly = '{"school_management_weekly":"select month,' + week + ',' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + school_ + ',' + sel_col_op + ',week,school_management_type,month' + '"},'
        cluster_mgmt_weekly = '{"cluster_management_weekly":"select month,' + week + ',' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op + ',week,school_management_type,month' + '"},'
        block_mgmt_weekly = '{"block_management_weekly":"select month,' + week + ',' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,school_management_type,month' + '"},'
        district_mgmt_weekly = '{"district_management_weekly":"select month,' + week + ',' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,school_management_type,month' + '"},'
        dml_queries = dml_queries + '\n' + school_weekly + '\n' + cluster_weekly + '\n' + block_weekly + '\n' + district_weekly + '\n' + school_mgmt_weekly + '\n' + cluster_mgmt_weekly + '\n' + block_mgmt_weekly + '\n' + district_mgmt_weekly

    if 'monthly' in df_time_sel:
        school_monthly = '{"school_by_month_year":"select month,' + school_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + ',month,' + sel_col_op +'"},'
        cluster_monthly = '{"cluster_by_month_year":"select month,' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',month,' + sel_col_op + '"},'
        block_monthly = '{"block_by_month_year":"select month,' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + ',month,' + sel_col_op + '"},'
        district_monthly = '{"district_by_month_year":"select month,' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + ',month,' + sel_col_op + '"},'
        school_mgmt_monthly = '{"school_management_by_month_year":"select month,' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + ',' + sel_col_op + ',school_management_type,month' + '"},'
        cluster_mgmt_monthly = '{"cluster_management_by_month_year":"select month,' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',' + sel_col_op + ',school_management_type,month' + '"},'
        block_mgmt_monthly = '{"block_management_by_month_year":"select month,' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + ',' + sel_col_op + ',school_management_type,month' + '"},'
        district_mgmt_monthly = '{"district_management_by_month_year":"select month,' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + ',' + sel_col_op + ',school_management_type,month' + '"},'
        dml_queries = dml_queries + '\n' + school_monthly + '\n' + cluster_monthly + '\n' + block_monthly + '\n' + district_monthly + '\n' + school_mgmt_monthly + '\n' + cluster_mgmt_monthly + '\n' + block_mgmt_monthly + '\n' + district_mgmt_monthly

    if 'overall' in df_time_sel:
        school_all = '{"school_overall":"select ' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + '"},'
        cluster_all = '{"cluster_overall":"select ' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + '"},'
        block_all = '{"block_overall":"select ' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + '"},'
        district_all = '{"district_overall":"select ' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + '"},'
        school_mgmt_all = '{"school_management_overall":"select ' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ +  ',school_management_type' + '"},'
        cluster_mgmt_all = '{"cluster_management_overall":"select ' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',school_management_type' + '"},'
        block_mgmt_all = '{"block_management_overall":"select ' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ +  ',school_management_type' + '"},'
        district_mgmt_all = '{"district_management_overall":"select ' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ +  ',school_management_type' + '"},'
        dml_queries = dml_queries + '\n' + school_all + '\n' + cluster_all + '\n' + block_all + '\n' + district_all + '\n' + school_mgmt_all + '\n' + cluster_mgmt_all + '\n' + block_mgmt_all + '\n' + district_mgmt_all

    if 'last_30_days' in df_time_sel:
        school_last_30 = '{"school_last_30":"select ' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + school_ + '"},'
        cluster_last_30 = '{"cluster_last_30":"select ' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + cluster_ + '"},'
        block_last_30 = '{"block_last_30":"select ' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter +'group by ' + block_ + '"},'
        district_last_30 = '{"district_last_30":"select ' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_30_day_filter+ 'group by ' + district_ + '"},'
        school_mgmt_last_30 = '{"school_management_last_30":"select ' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + school_ +  ',school_management_type' + '"},'
        cluster_mgmt_last_30 = '{"cluster_management_last_30":"select ' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + cluster_ + ',school_management_type' + '"},'
        block_mgmt_last_30 = '{"block_management_last_30":"select ' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + block_ +  ',school_management_type' + '"},'
        district_mgmt_last_30 = '{"district_management_last_30":"select ' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by ' + district_ +  ',school_management_type' + '"},'
        dml_queries = dml_queries + '\n' + school_last_30 + '\n' + cluster_last_30 + '\n' + block_last_30 + '\n' + district_last_30 + '\n' + school_mgmt_last_30 + '\n' + cluster_mgmt_last_30 + '\n' + block_mgmt_last_30 + '\n' + district_mgmt_last_30

    if 'last_7_days' in df_time_sel:
        school_last_7 = '{"school_last_7":"select ' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + school_ + '"},'
        cluster_last_7 = '{"cluster_last_7":"select ' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + cluster_ + '"},'
        block_last_7 = '{"block_last_7":"select ' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter +'group by ' + block_ + '"},'
        district_last_7 = '{"district_last_7":"select ' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_7_day_filter+ 'group by ' + district_ + '"},'
        school_mgmt_last_7 = '{"school_management_last_7":"select ' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + school_ +  ',school_management_type' + '"},'
        cluster_mgmt_last_7 = '{"cluster_management_last_7":"select ' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + cluster_ + ',school_management_type' + '"},'
        block_mgmt_last_7 = '{"block_management_last_7":"select ' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + block_ +  ',school_management_type' + '"},'
        district_mgmt_last_7 = '{"district_management_last_7":"select ' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by ' + district_ +  ',school_management_type' + '"},'
        dml_queries = dml_queries + '\n' + school_last_7 + '\n' + cluster_last_7 + '\n' + block_last_7 + '\n' + district_last_7 + '\n' + school_mgmt_last_7 + '\n' + cluster_mgmt_last_7 + '\n' + block_mgmt_last_7 + '\n' + district_mgmt_last_7

# Grade level queries
    if 'grade' in df_filters_req:
        if 'daily' in df_time_sel:
            school_grade_daily = '{ "school_grade_daily":"select month,grade,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +','+sel_col_op + ',week,month,grade"},'
            cluster_grade_daily = '{ "cluster_grade_daily":"select month,grade,'+ week + ','  +cluster_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +','+sel_col_op+ ',week,month,grade"},'
            block_grade_daily = '{ "block_grade_daily":"select month,grade,'+ week + ','  + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',' + sel_col_op +',week,month,grade"},'
            district_grade_daily = '{"district_grade_daily":"select month,grade,'+ week + ','  + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',' + sel_col_op +',week,month,grade"},'
            school_mgmt_grade_daily = '{"school_management_grade_daily":"select month,grade,'+ week + ','  +school_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +',school_management_type,'+sel_col_op + ',week,month,grade"},'
            cluster_mgmt_grade_daily = '{"cluster_management_grade_daily":"select month,grade,'+ week + ','  +cluster_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +',school_management_type,'+sel_col_op + ',week,month,grade"},'
            block_mgmt_grade_daily = '{"block_management_grade_daily":"select month,grade,'+ week + ','  + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',school_management_type,' + sel_col_op + ',week,month,grade"},'
            district_mgmt_grade_daily = '{"district_management_grade_daily":"select month,grade,'+ week + ','  + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',school_management_type,' + sel_col_op + ',week,month,grade"},'
            dml_queries = dml_queries + '\n' + school_grade_daily + '\n' + cluster_grade_daily + '\n' + block_grade_daily + '\n' + district_grade_daily + '\n' + school_mgmt_grade_daily + '\n' + cluster_mgmt_grade_daily + '\n' + block_mgmt_grade_daily + '\n' + district_mgmt_grade_daily

        if 'weekly' in df_time_sel:
            school_grade_weekly = '{"school_grade_weekly":"select month,grade,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + weekly_filter + 'group by ' + school_ +','+sel_col_op+',week,month,grade'+'"},'
            cluster_grade_weekly = '{"cluster_grade_weekly":"select month,grade,'+ week + ',' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op+',week,month,grade'+'"},'
            block_grade_weekly = '{"block_grade_weekly":"select month,grade,' + week + ',' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,month,grade' + '"},'
            district_grade_weekly = '{"district_grade_weekly":"select month,grade,' + week + ',' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,month,grade' + '"},'
            school_mgmt_grade_weekly = '{"school_management_grade__weekly":"select month,grade,' + week + ',' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + school_ + ',' + sel_col_op + ',week,school_management_type,month,grade' + '"},'
            cluster_mgmt_grade_weekly = '{"cluster_management_grade_weekly":"select month,grade,' + week + ',' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op + ',week,school_management_type,month,grade' + '"},'
            block_mgmt_grade_weekly = '{"block_management_grade_weekly":"select month,grade,' + week + ',' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,school_management_type,month,grade' + '"},'
            district_mgmt_grade_weekly = '{"district_management_grade_weekly":"select month,grade,' + week + ',' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,school_management_type,month,grade' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_weekly + '\n' + cluster_grade_weekly + '\n' + block_grade_weekly + '\n' + district_grade_weekly + '\n' + school_mgmt_grade_weekly + '\n' + cluster_mgmt_grade_weekly + '\n' + block_mgmt_grade_weekly + '\n' + district_mgmt_grade_weekly

        if 'monthly' in df_time_sel:
            school_grade_monthly = '{"school_grade_by_month_year":"select month,grade,' + school_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + ',month,grade,' + sel_col_op +'"},'
            cluster_grade_monthly = '{"cluster_grade_by_month_year":"select month,grade,' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',month,grade,' + sel_col_op + '"},'
            block_grade_monthly = '{"block_grade_by_month_year":"select month,grade,' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + ',month,grade,' + sel_col_op + '"},'
            district_grade_monthly = '{"district_grade_by_month_year":"select month,grade,' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + ',month,grade,' + sel_col_op + '"},'
            school_mgmt_grade_monthly = '{"school_management_grade_by_month_year":"select month,grade,' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            cluster_mgmt_grade_monthly = '{"cluster_management_grade_by_month_year":"select month,grade,' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            block_mgmt_grade_monthly = '{"block_management_grade_by_month_year":"select month,grade,' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            district_mgmt_grade_monthly = '{"district_management_grade_by_month_year":"select month,grade,' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_monthly + '\n' + cluster_grade_monthly + '\n' + block_grade_monthly + '\n' + district_grade_monthly + '\n' + school_mgmt_grade_monthly + '\n' + cluster_mgmt_grade_monthly + '\n' + block_mgmt_grade_monthly + '\n' + district_mgmt_grade_monthly

        if 'overall' in df_time_sel:
            school_grade_all = '{"school_grade_overall":"select grade,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,' + school_ + '"},'
            cluster_grade_all = '{"cluster_grade_overall":"select grade,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,' + cluster_ + '"},'
            block_grade_all = '{"block_grade_overall":"select grade,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,' + block_ + '"},'
            district_grade_all = '{"district_grade_overall":"select grade,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,' + district_ + '"},'
            school_mgmt_grade_all = '{"school_management_grade_overall":"select grade,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ +  ',school_management_type,grade' + '"},'
            cluster_mgmt_grade_all = '{"cluster_management_grade_overall":"select grade,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',school_management_type,grade' + '"},'
            block_mgmt_grade_all = '{"block_management_grade_overall":"select grade,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ +  ',school_management_type,grade' + '"},'
            district_mgmt_grade_all = '{"district_management_grade_overall":"select grade,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ +  ',school_management_type,grade' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_all + '\n' + cluster_grade_all + '\n' + block_grade_all + '\n' + district_grade_all + '\n' + school_mgmt_grade_all+ '\n' + cluster_mgmt_grade_all + '\n' + block_mgmt_grade_all + '\n' + district_mgmt_grade_all

        if 'last_30_days' in df_time_sel:
            school_grade_last_30 = '{"school_grade_last_30":"select grade,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,' + school_ + '"},'
            cluster_grade_last_30 = '{"cluster_grade_last_30":"select grade,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,' + cluster_ + '"},'
            block_grade_last_30 = '{"block_grade_last_30":"select grade,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter +'group by grade,' + block_ + '"},'
            district_grade_last_30 = '{"district_grade_last_30":"select grade,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_30_day_filter+ 'group by grade,' + district_ + '"},'
            school_mgmt_grade_last_30 = '{"school_management_grade_last_30":"select grade,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,' + school_ +  ',school_management_type' + '"},'
            cluster_mgmt_grade_last_30 = '{"cluster_management_grade_last_30":"select grade,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,' + cluster_ + ',school_management_type' + '"},'
            block_mgmt_grade_last_30 = '{"block_management_grade_last_30":"select grade,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,' + block_ +  ',school_management_type' + '"},'
            district_mgmt_grade_last_30 = '{"district_management_grade_last_30":"select grade,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade, ' + district_ +  ',school_management_type' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_last_30 + '\n' + cluster_grade_last_30 + '\n' + block_grade_last_30 + '\n' + district_grade_last_30 + '\n' + school_mgmt_grade_last_30 + '\n' + cluster_mgmt_grade_last_30 + '\n' + block_mgmt_grade_last_30 + '\n' + district_mgmt_grade_last_30

        if 'last_7_days' in df_time_sel:
            school_grade_last_7 = '{"school_grade_last_7":"select grade,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + school_ + '"},'
            cluster_grade_last_7 = '{"cluster_grade_last_7":"select grade,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + cluster_ + '"},'
            block_grade_last_7 = '{"block_grade_last_7":"select grade,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter +'group by grade,' + block_ + '"},'
            district_grade_last_7 = '{"district_grade_last_7":"select grade,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_7_day_filter+ 'group by grade,' + district_ + '"},'
            school_mgmt_grade_last_7 = '{"school_management_grade_last_7":"select grade,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + school_ +  ',school_management_type' + '"},'
            cluster_mgmt_grade_last_7 = '{"school_management_grade_last_7":"select grade,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + cluster_ + ',school_management_type' + '"},'
            block_mgmt_grade_last_7 = '{"school_management_grade_last_7":"select grade,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + block_ +  ',school_management_type' + '"},'
            district_mgmt_grade_last_7 = '{"school_management_grade_last_7":"select grade,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,' + district_ +  ',school_management_type' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_last_7 + '\n' + cluster_grade_last_7 + '\n' + block_grade_last_7 + '\n' + district_grade_last_7 + '\n' + school_mgmt_grade_last_7 + '\n' + cluster_mgmt_grade_last_7 + '\n' + block_mgmt_grade_last_7 + '\n' + district_mgmt_grade_last_7

# Grade and Subject level queries
    if 'subject' in df_filters_req:
        if 'daily' in df_time_sel:
            school_grade_subject_daily = '{ "school_grade_subject_daily":"select month,grade,subject,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +','+sel_col_op + ',week,month,grade,subject"},'
            cluster_grade_subject_daily = '{ "cluster_grade_subject_daily":"select month,grade,subject,'+ week + ','  +cluster_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +','+sel_col_op+ ',week,month,grade,subject"},'
            block_grade_subject_daily = '{ "block_grade_subject_daily":"select month,grade,subject,'+ week + ','  + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',' + sel_col_op +',week,month,grade,subject"},'
            district_grade_subject_daily = '{"district_grade_subject_daily":"select month,grade,subject,'+ week + ','  + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',' + sel_col_op +',week,month,grade,subject"},'
            school_mgmt_grade_subject_daily = '{"school_management_grade_subject_daily":"select month,grade,subject,'+ week + ','  +school_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + school_ +',school_management_type,'+sel_col_op + ',week,month,grade,subject"},'
            cluster_mgmt_grade_subject_daily = '{"cluster_management_grade_subject_daily":"select month,grade,subject,'+ week + ','  +cluster_ + ',school_management_type,' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + daily_filter +  'group by ' + cluster_ +',school_management_type,'+sel_col_op + ',week,month,grade,subject"},'
            block_mgmt_grade_subject_daily = '{"block_management_grade_subject_daily":"select month,grade,subject,'+ week + ','  + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + block_ + ',school_management_type,' + sel_col_op + ',week,month,grade,subject"},'
            district_mgmt_grade_subject_daily = '{"district_management_grade_subject_daily":"select month,grade,subject,'+ week + ','  + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + daily_filter +  'group by ' + district_ + ',school_management_type,' + sel_col_op + ',week,month,grade,subject"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_daily + '\n' + cluster_grade_subject_daily + '\n' + block_grade_subject_daily + '\n' + district_grade_subject_daily + '\n' + school_mgmt_grade_subject_daily + '\n' + cluster_mgmt_grade_subject_daily + '\n' + block_mgmt_grade_subject_daily + '\n' + district_mgmt_grade_subject_daily

        if 'weekly' in df_time_sel:
            school_grade_subject_weekly = '{"school_grade_subject_weekly":"select month,grade,subject,'+ week + ',' +school_ + ',' +sel_col_op + ','+ metric_rep + ' from '+ table_names +'_aggregation ' + weekly_filter + 'group by ' + school_ +','+sel_col_op+',week,month,grade,subject'+'"},'
            cluster_grade_subject_weekly = '{"cluster_grade_subject_weekly":"select month,grade,subject,'+ week + ',' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op+',week,month,grade,subject'+'"},'
            block_grade_subject_weekly = '{"block_grade_subject_weekly":"select month,grade,subject,' + week + ',' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,month,grade,subject' + '"},'
            district_grade_subject_weekly = '{"district_grade_subject_weekly":"select month,grade,subject,' + week + ',' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,month,grade,subject' + '"},'
            school_mgmt_grade_subject_weekly = '{"school_management_grade_subject_weekly":"select month,grade,subject,' + week + ',' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + school_ + ',' + sel_col_op + ',week,school_management_type,month,grade,subject' + '"},'
            cluster_mgmt_grade_subject_weekly = '{"cluster_management_grade_subject_weekly":"select month,grade,subject,' + week + ',' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + cluster_ + ',' + sel_col_op + ',week,school_management_type,month,grade,subject' + '"},'
            block_mgmt_grade_subject_weekly = '{"block_management_grade_subject_weekly":"select month,grade,subject,' + week + ',' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + block_ + ',' + sel_col_op + ',week,school_management_type,month,grade,subject' + '"},'
            district_mgmt_grade_subject_weekly = '{"district_management_grade_subject_weekly":"select month,grade,subject,' + week + ',' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + weekly_filter + 'group by ' + district_ + ',' + sel_col_op + ',week,school_management_type,month,grade,subject' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_weekly + '\n' + cluster_grade_subject_weekly + '\n' + block_grade_subject_weekly + '\n' + district_grade_subject_weekly + '\n' + school_mgmt_grade_subject_weekly + '\n' + cluster_mgmt_grade_subject_weekly + '\n' + block_mgmt_grade_subject_weekly + '\n' + district_mgmt_grade_subject_weekly

        if 'monthly' in df_time_sel:
            school_grade_subject_monthly = '{"school_grade_subject_by_month_year":"select month,grade,subject,' + school_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ + ',month,grade,subject,' + sel_col_op +'"},'
            cluster_grade_subject_monthly = '{"cluster_grade_subject_by_month_year":"select month,grade,subject,' + cluster_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',month,grade,subject,' + sel_col_op + '"},'
            block_grade_subject_monthly = '{"block_grade_subject_by_month_year":"select month,grade,subject,' + block_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ + ',month,grade,subject,' + sel_col_op + '"},'
            district_grade_subject_monthly = '{"district_grade_subject_by_month_year":"select month,grade,subject,' + district_ + ',' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ + ',month,grade,subject,' + sel_col_op + '"},'
            school_mgmt_grade_subject_monthly = '{"school_management_grade_subject_by_month_year":"select month,grade,subject,' + school_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by subject,' + school_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            cluster_mgmt_grade_subject_monthly = '{"cluster_management_grade_subject_by_month_year":"select month,grade,subject,' + cluster_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by subject,' + cluster_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            block_mgmt_grade_subject_monthly = '{"block_management_grade_subject_by_month_year":"select month,grade,subject,' + block_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by subject,' + block_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            district_mgmt_grade_subject_monthly = '{"district_management_grade_subject_by_month_year":"select month,grade,subject,' + district_ + ',school_management_type,' + sel_col_op + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by subject,' + district_ + ',' + sel_col_op + ',school_management_type,month,grade' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_monthly + '\n' + cluster_grade_subject_monthly + '\n' + block_grade_subject_monthly + '\n' + district_grade_subject_monthly + '\n' + school_mgmt_grade_subject_monthly + '\n' + cluster_mgmt_grade_subject_monthly + '\n' + block_mgmt_grade_subject_monthly + '\n' + district_mgmt_grade_subject_monthly

        if 'overall' in df_time_sel:
            school_grade_subject_all = '{"school_grade_subject_overall":"select grade,subject,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,subject,' + school_ + '"},'
            cluster_grade_subject_all = '{"cluster_grade_subject_overall":"select grade,subject,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,subject,' + cluster_ + '"},'
            block_grade_subject_all = '{"block_grade_subject_overall":"select grade,subject,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,subject,' + block_ + '"},'
            district_grade_subject_all = '{"district_grade_subject_overall":"select grade,subject,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by grade,subject,' + district_ + '"},'
            school_mgmt_grade_subject_all = '{"school_management_grade_subject_overall":"select grade,subject,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + school_ +  ',school_management_type,grade,subject' + '"},'
            cluster_mgmt_grade_subject_all = '{"cluster_management_grade_subject_overall":"select grade,subject,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + cluster_ + ',school_management_type,grade,subject' + '"},'
            block_mgmt_grade_subject_all = '{"block_management_grade_subject_overall":"select grade,subject,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + block_ +  ',school_management_type,grade,subject' + '"},'
            district_mgmt_grade_subject_all = '{"district_management_grade_subject_overall":"select grade,subject,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + 'group by ' + district_ +  ',school_management_type,grade,subject' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_all + '\n' + cluster_grade_subject_all + '\n' + block_grade_subject_all + '\n' + district_grade_subject_all + '\n' + school_mgmt_grade_subject_all + '\n' + cluster_mgmt_grade_subject_all + '\n' + block_mgmt_grade_subject_all + '\n' + district_mgmt_grade_subject_all

        if 'last_30_days' in df_time_sel:
            school_grade_subject_last_30 = '{"school_grade_subject_last_30":"select grade,subject,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject,' + school_ + '"},'
            cluster_grade_subject_last_30 = '{"cluster_grade_subject_last_30":"select grade,subject,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject,' + cluster_ + '"},'
            block_grade_subject_last_30 = '{"block_grade_subject_last_30":"select grade,subject,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter +'group by grade,subject,' + block_ + '"},'
            district_grade_subject_last_30 = '{"district_grade_subject_last_30":"select grade,subject,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_30_day_filter+ 'group by grade,subject,' + district_ + '"},'
            school_mgmt_grade_subject_last_30 = '{"school_management_grade_subject_last_30":"select grade,subject,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject,' + school_ +  ',school_management_type' + '"},'
            cluster_mgmt_grade_subject_last_30 = '{"cluster_management_grade_subject_last_30":"select grade,subject,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject,' + cluster_ + ',school_management_type' + '"},'
            block_mgmt_grade_subject_last_30 = '{"block_management_grade_subject_last_30":"select grade,subject,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject,' + block_ +  ',school_management_type' + '"},'
            district_mgmt_grade_subject_last_30 = '{"district_management_grade_subject_last_30":"select grade,subject,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_30_day_filter + 'group by grade,subject, ' + district_ +  ',school_management_type' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_last_30 + '\n' + cluster_grade_subject_last_30 + '\n' + block_grade_subject_last_30 + '\n' + district_grade_subject_last_30 + '\n' + school_mgmt_grade_subject_last_30 + '\n' + cluster_mgmt_grade_subject_last_30 + '\n' + block_mgmt_grade_subject_last_30 + '\n' + district_mgmt_grade_subject_last_30

        if 'last_7_days' in df_time_sel:
            school_grade_subject_last_7 = '{"school_grade_subject_last_7":"select grade,subject,' + school_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + school_ + '"},'
            cluster_grade_subject_last_7 = '{"cluster_grade_subject_last_7":"select grade,subject,' + cluster_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + cluster_ + '"},'
            block_grade_subject_last_7 = '{"block_grade_subject_last_7":"select grade,subject,' + block_ + ',' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter +'group by grade,subject,' + block_ + '"},'
            district_grade_subject_last_7 = '{"district_grade_subject_last_7":"select grade,subject,' + district_ + ','  + metric_rep + ' from ' + table_names + '_aggregation ' +last_7_day_filter+ 'group by grade,subject,' + district_ + '"},'
            school_mgmt_grade_subject_last_7 = '{"school_management_grade_subject_last_7":"select grade,subject,' + school_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + school_ +  ',school_management_type' + '"},'
            cluster_mgmt_grade_subject_last_7 = '{"school_management_grade_subject_last_7":"select grade,subject,' + cluster_ + ',school_management_type,'  + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + cluster_ + ',school_management_type' + '"},'
            block_mgmt_grade_subject_last_7 = '{"school_management_grade_subject_last_7":"select grade,subject,' + block_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + block_ +  ',school_management_type' + '"},'
            district_mgmt_grade_subject_last_7 = '{"school_management_grade_subject_last_7":"select grade,subject,' + district_ + ',school_management_type,' + metric_rep + ' from ' + table_names + '_aggregation ' + last_7_day_filter + 'group by grade,subject,' + district_ +  ',school_management_type' + '"},'
            dml_queries = dml_queries + '\n' + school_grade_subject_last_7 + '\n' + cluster_grade_subject_last_7 + '\n' + block_grade_subject_last_7 + '\n' + district_grade_subject_last_7 + '\n' + school_mgmt_grade_subject_last_7 + '\n' + cluster_mgmt_grade_subject_last_7 + '\n' + block_mgmt_grade_subject_last_7 + '\n' + district_mgmt_grade_subject_last_7

    dml_queries = dml_queries.rstrip(dml_queries[-1])
    dml_queries =dml_queries + '\n' + ']'

# def execute_sql():
#     with open('../../conf/base_config.yml') as f:
#         data = yaml.load(f, Loader=SafeLoader)
#         db_user = data['db_user']
#         db_name = data['db_name']
#         db_password = data['db_password']
#
#     #establishing the connection
#     conn = psycopg2.connect(
#     database=db_name, user=db_user, password=db_password, host='localhost', port= '5432')
#     if conn:
#         #Creating a cursor object using the cursor() method
#         cursor = conn.cursor()
#         cursor.execute(open(path + '/{}.sql'.format(file_name_sql),'r').read())
#         conn.commit()
#         conn.close()
#
# def write_files():
#     isExist = os.path.exists(path)
#     is_exist = os.path.exists(path +'/'+file_name_sql)
#     if not isExist:
#         os.makedirs(path)
#     if not is_exist:
#         os.makedirs(path + '/' + file_name_sql)
#     global query_file
#     query_file = open((path + '/{}.sql'.format(file_name_sql)), 'w')
#     query_file.write(all_queries)
#     query_file.close()
#     global parameter_file
#     param_file_queries =all_param_queries + all_param_queries_1 + temp_to_trans
#     param_file = open((path+ '/{}/parameters.txt'.format(file_name_sql)), 'w')
#     param_file.write(param_file_queries)
#     param_file.close()
#     global json_file
#     json_file = open((path+ '/{}/report_queries.json'.format(file_name_sql)), 'w')
#     json_file.write(dml_queries)
#     json_file.close()

if __name__ == "__main__":
    create_parameters_queries()
    # create_table_queries()
    # create_dml_timeline_queries()
    # write_files()
    # execute_sql()
