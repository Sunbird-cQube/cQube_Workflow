NIFI_IP =               # Nifi url
NIFI_PORT =             # Nifi Port number
# Nifi templates local directory path ending with /
NIFI_TEMPLATE_PATH = 
# Nifi parameters[created by ansible using config file] local directory path ending with /
NIFI_PARAMETER_DIRECTORY_PATH =
NIFI_STATIC_PARAMETER_DIRECTORY_PATH =
NIFI_INPUT_OUTPUT_PORTS = {
    'static_data_transformer':[
                               {'OUTPUT_PORT': 'static_split_file_wait','INPUT_PORT': 'split_wait'},
                               {'OUTPUT_PORT': 'static_split_success','INPUT_PORT': 'split_file_process_success'},
                               {'OUTPUT_PORT': 'static_split_failure','INPUT_PORT': 'split_file_failure'},
                               {'OUTPUT_PORT': 'store_s3_output_port','INPUT_PORT': 'store_s3_input_port'},
                               {'OUTPUT_PORT': 'store_school_mgt_s3_output_port','INPUT_PORT': 'store_school_mgt_s3_input_port'},
                               {'OUTPUT_PORT': 'store_school_mgt_s3_output_port2','INPUT_PORT': 'store_school_mgt_s3_input_port2'},
                               {'OUTPUT_PORT': 'static_store_output_dir_output_port','INPUT_PORT': 'static_store_output_dir_input_port'},
                               {'OUTPUT_PORT': 'static_s3_school_management_output_port','INPUT_PORT': 'static_s3_school_management_input_port'},
                               {'OUTPUT_PORT': 'static_data_emission_file','INPUT_PORT':'DS_emission_file'}
                              ],
    'crc_transformer': [
                        {'OUTPUT_PORT': 'crc_wait_original', 'INPUT_PORT': 'split_wait'},
                        {'OUTPUT_PORT': 'crc_split_success','INPUT_PORT': 'split_file_process_success'},
                        {'OUTPUT_PORT': 'crc_split_failure','INPUT_PORT': 'split_file_failure'},
                        {'OUTPUT_PORT': 'crc_output_files_OP','INPUT_PORT': 'crc_output_files_IP_DS'},
                        {'OUTPUT_PORT': 'crc_emission_file','INPUT_PORT':'DS_emission_file'}
                       ],
    'udise_transformer': [
                          {'OUTPUT_PORT': 'split_wait_output', 'INPUT_PORT': 'split_wait'},
                          {'OUTPUT_PORT': 'split_file_success','INPUT_PORT': 'split_file_process_success'},
                          {'OUTPUT_PORT': 'split_file_failure','INPUT_PORT': 'split_file_failure'},
                          {'OUTPUT_PORT': 'udise_output_files_OP','INPUT_PORT': 'udise_output_files_IP_DS'},
                          {'OUTPUT_PORT': 'udise_emission_file','INPUT_PORT':'DS_emission_file'}
                         ],
    'diksha_transformer': [
                           {'OUTPUT_PORT': 'diksha_split_wait', 'INPUT_PORT': 'split_wait'},
                           {'OUTPUT_PORT': 'diksha_split_success','INPUT_PORT': 'split_file_process_success'},
                           {'OUTPUT_PORT': 'diksha_split_failure','INPUT_PORT': 'split_file_failure'},
                           {'OUTPUT_PORT': 'diksha_api_output', 'INPUT_PORT': 'diksha_api_output_IP_DS'},
                           {'OUTPUT_PORT': 'diksha_api_output_emission', 'INPUT_PORT': 'diksha_api_output_emission_IP_DS'},
                           {'OUTPUT_PORT': 'diksha_output_files_OP', 'INPUT_PORT': 'diksha_output_files_IP_DS'},
                           {'OUTPUT_PORT': 'diksha_emission_file','INPUT_PORT':'DS_emission_file'},
                           {'OUTPUT_PORT': 'diksha_tpd_emission_op','INPUT_PORT':'diksha_tpd_emission_ip'},
                           {'OUTPUT_PORT': 'diksha_tpd_emission_after_select_columns_op','INPUT_PORT':'diksha_tpd_emission_after_select_columns_ip'},
                           {'OUTPUT_PORT': 'diksha_emission_etb_op','INPUT_PORT':'diksha_emission_etb_ip_DS'},
                           {'OUTPUT_PORT': 'diksha_emission_etb_s3_op','INPUT_PORT':'diksha_emission_etb_s3_op_DS'}
                          ],
    'diksha_transformer_custom': [
                                  {'OUTPUT_PORT': 'diksha_split_wait_custom', 'INPUT_PORT': 'split_wait'},
                                  {'OUTPUT_PORT': 'diksha_split_success_custom','INPUT_PORT': 'split_file_process_success'},
                                  {'OUTPUT_PORT': 'diksha_split_failure_custom','INPUT_PORT': 'split_file_failure'},
                                  {'OUTPUT_PORT': 'diksha_api_output_custom','INPUT_PORT': 'diksha_api_output_IP_DS'},
                                  {'OUTPUT_PORT': 'diksha_api_output_emission_custom','INPUT_PORT': 'diksha_api_output_emission_IP_DS'},
                                  {'OUTPUT_PORT': 'diksha_output_files_OP_custom','INPUT_PORT': 'diksha_output_files_IP_DS'}
                                 ],
    'student_attendance_transformer': [
                                       {'OUTPUT_PORT': 'student_attendance_split_wait', 'INPUT_PORT': 'split_wait'},
                                       {'OUTPUT_PORT': 'student_attendance_split_success','INPUT_PORT': 'split_file_process_success'},
                                       {'OUTPUT_PORT': 'student_attendance_split_failure','INPUT_PORT': 'split_file_failure'},
                                       {'OUTPUT_PORT': 'S3-student_attendance_output_port','INPUT_PORT': 'S3-student_attendance_input_port'},
                                       {'OUTPUT_PORT': 'S3_on_premise-student_attendance_partition_output_port','INPUT_PORT': 'S3_on_premise-student_attendance_partition_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_save-s3-log_summary_output_port','INPUT_PORT': 'stud_att_save-s3-log_summary_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_S3_trends_output_port','INPUT_PORT': 'stud_att_S3_trends_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_year_month_overall_management_vs_category_output_port','INPUT_PORT': 'stud_att_s3_year_month_overall_management_vs_category_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_time_range_overall_category_vs_management_output_port','INPUT_PORT': 'stud_att_s3_time_range_overall_category_vs_management_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_time_range_overall_category_vs_management_partition_output_port','INPUT_PORT': 'stud_att_s3_time_range_overall_category_vs_management_partition_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_time_range_overall_management_vs_category_output_port','INPUT_PORT': 'stud_att_s3_time_range_overall_management_vs_category_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_year_month_overall_category_vs_management_output_port','INPUT_PORT': 'stud_att_s3_year_month_overall_category_vs_management_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_s3_year_month_overall_category_vs_management_partition_output_port','INPUT_PORT': 'stud_att_s3_year_month_overall_category_vs_management_partition_input_port'},
                                       {'OUTPUT_PORT': 'stud_att_emission_file','INPUT_PORT':'DS_emission_file'}
                                      ],
    'teacher_attendance_transformer': [ 
                                        {'OUTPUT_PORT': 'teacher_attendance_split_wait', 'INPUT_PORT': 'split_wait'},
                                        {'OUTPUT_PORT': 'teacher_attendance_split_success','INPUT_PORT': 'split_file_process_success'},
                                        {'OUTPUT_PORT': 'teacher_attendance_split_failure','INPUT_PORT': 'split_file_failure'},
                                        {'OUTPUT_PORT': 'tch_att_output_files_OP','INPUT_PORT': 'tch_att_output_files_IP_DS'},
                                        {'OUTPUT_PORT': 'tch_att_output_files_OP_ym_mgmt','INPUT_PORT': 'tch_att_output_files_IP_DS_ym_mgmt'},
                                        {'OUTPUT_PORT': 'tch_att_output_files_OP_ym_cat','INPUT_PORT': 'tch_att_output_files_IP_DS_ym_cat'},
                                        {'OUTPUT_PORT': 'tch_att_output_files_OP_time_range_mgmt','INPUT_PORT': 'tch_att_output_files_IP_DS_time_range_mgmt'},
                                        {'OUTPUT_PORT': 'tch_att_output_files_OP_time_range_cat','INPUT_PORT': 'tch_att_output_files_IP_DS_time_range_cat'},
                                        {'OUTPUT_PORT': 'tch_att_emission_file','INPUT_PORT':'DS_emission_file'}
                                       ],
      'pat_transformer': [ 
                           {'OUTPUT_PORT': 'pat_split_wait', 'INPUT_PORT': 'split_wait'},
                           {'OUTPUT_PORT': 'pat_split_file_success','INPUT_PORT': 'split_file_process_success'},
                           {'OUTPUT_PORT': 'pat_split_file_failure','INPUT_PORT': 'split_file_failure'}, 
                           {'OUTPUT_PORT': 'pat_s3_time_range_overall_category_vs_management_output_port','INPUT_PORT': 'pat_s3_time_range_overall_category_vs_management_input_port'},
                           {'OUTPUT_PORT': 'pat_s3_time_range_overall_category_vs_management_output_port2','INPUT_PORT': 'pat_s3_time_range_overall_category_vs_management_input_port2'},
                           {'OUTPUT_PORT': 'pat_save_output_s3_output_port','INPUT_PORT': 'pat_save_output_s3_input_port'},
                           {'OUTPUT_PORT': 'pat_save_output_s3_output_port2','INPUT_PORT': 'pat_save_output_s3_input_port2'},
                           {'OUTPUT_PORT': 'pat_s3_save_output_empty_files_output_port','INPUT_PORT': 'pat_s3_save_output_empty_files_input_port'},
                           {'OUTPUT_PORT': 'pat_save-s3-log_summary_output_port','INPUT_PORT': 'pat_save-s3-log_summary_input_port'},
                           {'OUTPUT_PORT': 'pat_emission_file','INPUT_PORT':'DS_emission_file'}
                         ],
       'sat_transformer': [ 
                            {'OUTPUT_PORT': 'sat_split_wait', 'INPUT_PORT': 'split_wait'},
                            {'OUTPUT_PORT': 'sat_split_file_success','INPUT_PORT': 'split_file_process_success'},
                            {'OUTPUT_PORT': 'sat_split_file_failure','INPUT_PORT': 'split_file_failure'},
                            {'OUTPUT_PORT': 'sat_s3_time_range_overall_category_vs_management_output_port','INPUT_PORT': 'sat_s3_time_range_overall_category_vs_management_input_port'},
                            {'OUTPUT_PORT': 'sat_s3_time_range_overall_category_vs_management_output_port2','INPUT_PORT': 'sat_s3_time_range_overall_category_vs_management_input_port2'},
                            {'OUTPUT_PORT': 'sat_save_output_s3_output_port','INPUT_PORT': 'sat_save_output_s3_input_port'},
                            {'OUTPUT_PORT': 'sat_save_output_s3_output_port2','INPUT_PORT': 'sat_save_output_s3_input_port2'},
                            {'OUTPUT_PORT': 'sat_save-s3-log_summary_output_port','INPUT_PORT': 'sat_save-s3-log_summary_input_port'},
                            {'OUTPUT_PORT': 'sat_s3_trends_output_port','INPUT_PORT': 'sat_s3_trends_input_port'},
                            {'OUTPUT_PORT': 'sat_emission_file','INPUT_PORT':'DS_emission_file'}
                          ],
       'infra_transformer': [  
                             {'OUTPUT_PORT': 'infra_s3_on_premise_output_port', 'INPUT_PORT': 'infra_s3_on_premise_input_port'},
                             {'OUTPUT_PORT': 'infra_save_log_summary_output_port','INPUT_PORT': 'infra_save_log_summary_input_port'},
                             {'OUTPUT_PORT': 'infra_emission_file','INPUT_PORT':'DS_emission_file'}
                            ],      
       'data_replay_transformer': [
                                   {'OUTPUT_PORT': 'data_replay_retention_OP', 'INPUT_PORT': 'data_replay_retention_IP_DS'},
                                   {'OUTPUT_PORT': 'data_replay_emission_file','INPUT_PORT':'DS_emission_file'}
                                  ],
       'cqube_telemetry_transformer': [
                                       {'OUTPUT_PORT': 'cqube_telemetry_split_wait', 'INPUT_PORT': 'split_wait'},
                                       {'OUTPUT_PORT': 's3_cqube_telemetry_output_port', 'INPUT_PORT': 's3_cqube_telemetry_input_port'},
                                       {'OUTPUT_PORT': 's3_cqube_telemetry_output_port2', 'INPUT_PORT': 's3_cqube_telemetry_input_port2'},
                                       {'OUTPUT_PORT': 'save-s3-log_summary_output_port', 'INPUT_PORT': 'save-s3-log_summary_input_port'},                                       
                                       {'OUTPUT_PORT': 'cqube_telemetry_save-s3-log_summary_output_port', 'INPUT_PORT': 'cqube_telemetry_save-s3-log_summary_input_port'},
                                       {'OUTPUT_PORT': 'cqube_telemetry_split_failure', 'INPUT_PORT': 'split_file_failure'},
                                       {'OUTPUT_PORT': 'cqube_telemetry_split_success', 'INPUT_PORT': 'split_file_process_success'},
                                       {'OUTPUT_PORT': 'cqube_telemetry_emission_file','INPUT_PORT':'DS_emission_file'}
                                      ],
       'progress_card_transformer': [{'OUTPUT_PORT': 'progress_card_save_output_output_port', 'INPUT_PORT': 'progress_card_save_output_input_port'}        
                                    ],   
       'composite_transformer': [{'OUTPUT_PORT': 'comp_save_output_output_port', 'INPUT_PORT': 'comp_save_output_input_port'}
                                ],
    'configurable_datasource':[{'OUTPUT_PORT': 'config_datasource_listfile_DS_OP', 'INPUT_PORT': 'DS_emission_file'},
                                {'OUTPUT_PORT': 'UI_configurable_property', 'INPUT_PORT': 'UI_configurable_property_input_port'}
                               ],
    'validate_datasource': [{'OUTPUT_PORT': 'emission_file', 'INPUT_PORT': 'DS_emission_file'},
                            {'OUTPUT_PORT': 'split_wait', 'INPUT_PORT': 'split_wait'},
                            {'OUTPUT_PORT': 'split_failure', 'INPUT_PORT': 'split_file_failure'},
                            {'OUTPUT_PORT': 'split_success', 'INPUT_PORT': 'split_file_process_success'}
                            ],
'transaction_and_aggregation': [
    {'OUTPUT_PORT': 'S3-config_datasource_output_port','INPUT_PORT': 'config_datsource_S3_input_port'},
    {'OUTPUT_PORT': 'S3_on_premise-config_partition_output_port','INPUT_PORT': 'S3_on_premise-config_partition_input_port'},
    {'OUTPUT_PORT': 'Config_datasource_save-s3-log_summary_output_port','INPUT_PORT': 'config_datasource_save-s3-log_summary_input_port'},
    {'OUTPUT_PORT': 'config_datasource_management_output_port','INPUT_PORT': 'config_datasource_management_input_port'}],

    'cQube_data_storage': {
                           'static_data_transformer': [{'OUTPUT_PORT': 'static_files', 'INPUT_PORT': 'static_data_input'}
                                                      ],
                           'crc_transformer': [
                                              {'OUTPUT_PORT': 'crc_zip_output', 'INPUT_PORT': 'crc_zip_wait'},
                                              {'OUTPUT_PORT': 'crc_files','INPUT_PORT': 'crc_input_files'},
                                              {'OUTPUT_PORT': 'crc_output_files_IP_success_DS','INPUT_PORT': 'crc_output_files_IP'}
                                              ],
                           'udise_transformer': [
                                                 {'OUTPUT_PORT': 'udise_zip_output', 'INPUT_PORT': 'udise_zip_wait_success_in'},
                                                 {'OUTPUT_PORT': 'udise_files','INPUT_PORT': 'udise_input'},
                                                 {'OUTPUT_PORT': 'udise_output_files_IP_success_DS','INPUT_PORT': 'udise_output_files_IP_DS'}
                                                ],
                           'diksha_transformer': [
                                                  {'OUTPUT_PORT': 'diksha_zip_output', 'INPUT_PORT': 'diksha_wait_zip'},
                                                  {'OUTPUT_PORT': 'diksha_files','INPUT_PORT': 'diksha_input'},
                                                  {'OUTPUT_PORT': 'diksha_api_output_emission_DS', 'INPUT_PORT': 'diksha_api_output_IP_DS'},
                                                  {'OUTPUT_PORT': 'diksha_output_files_IP_success_DS', 'INPUT_PORT': 'diksha_output_files_IP_DS'},
                                                  {'OUTPUT_PORT': 'diksha_emission_validation_op', 'INPUT_PORT': 'diksha_emission_validation_ip'},
                                                  {'OUTPUT_PORT': 'diksha_emission_etb_op_DS','INPUT_PORT':'diksha_emission_etb_ip'},
                                                  {'OUTPUT_PORT': 'diksha_emission_etb_s3_op_DS','INPUT_PORT':'diksha_emission_etb_s3_ip'}
                                                 ],
                           'diksha_transformer_custom': [
                                                         {'OUTPUT_PORT': 'diksha_zip_output_custom', 'INPUT_PORT': 'diksha_wait_zip_custom'},
                                                         {'OUTPUT_PORT': 'diksha_files_custom','INPUT_PORT': 'diksha_input_custom'},
                                                         {'OUTPUT_PORT': 'diksha_api_output_emission_DS_custom', 'INPUT_PORT': 'diksha_api_output_IP_DS_custom'},
                                                         {'OUTPUT_PORT': 'diksha_output_files_IP_success_DS_custom', 'INPUT_PORT': 'diksha_output_files_IP_DS_custom'}
                                                        ],
                           'student_attendance_transformer': [
                                                              {'OUTPUT_PORT': 'student_attendance_zip_output', 'INPUT_PORT': 'student_wait_zip'},
                                                              {'OUTPUT_PORT': 'student_attendance_file','INPUT_PORT': 'student_attendance_input'},
                                                              {'OUTPUT_PORT': 'S3-stud_att_success_output_port','INPUT_PORT': 'S3-stud_att_success_input_port'}
                                                             ],
                          'teacher_attendance_transformer': [
                                                             {'OUTPUT_PORT': 'tch_att_zip_output', 'INPUT_PORT': 'teacher_attendance_wait_zip'},
                                                             {'OUTPUT_PORT': 'tch_att_files','INPUT_PORT': 'teacher_attendance_input'},
                                                             {'OUTPUT_PORT': 'tch_att_output_files_IP_success_DS','INPUT_PORT': 'tch_att_output_files_IP_DS'}
                                                            ],
                          'pat_transformer': [
                                              {'OUTPUT_PORT': 'pat_wait_file_success_output', 'INPUT_PORT': 'pat_wait_file_success_input'},
                                              {'OUTPUT_PORT': 'pat_files','INPUT_PORT': 'pat_input'},
                                              {'OUTPUT_PORT': 'pat_s3_save_output_empty_files_success_output_port','INPUT_PORT': 'pat_s3_save_output_empty_files_success_input_port'},
                                              {'OUTPUT_PORT': 'pat_save_output_s3_success_output_port','INPUT_PORT': 'pat_save_output_s3_sucess_input_port'}
                                             ],
                          'sat_transformer': [
                                              {'OUTPUT_PORT': 'sat_wait_file_success_output', 'INPUT_PORT': 'sat_wait_file_success_input'},
                                              {'OUTPUT_PORT': 'sat_files','INPUT_PORT': 'sat_input'},
                                              {'OUTPUT_PORT': 'sat_save_output_s3_success_output_port','INPUT_PORT': 'sat_save_output_s3_success_input_port'}
                                             ],
                          'infra_transformer': [
                                                {'OUTPUT_PORT': 'infra_s3_on_premise_success_output_port', 'INPUT_PORT': 'infra_s3_on_premise_success_input_port'},
                                                {'OUTPUT_PORT': 'infra_files','INPUT_PORT': 'infra_input'}
                                               ],
                          'data_replay_transformer': [
                                                      {'OUTPUT_PORT': 'data_replay_retention_files','INPUT_PORT': 'data_replay_retention_input'}
                                                     ],
                          'cqube_telemetry_transformer': [
                                                          {'OUTPUT_PORT': 'cqube_telemetry_file','INPUT_PORT': 'cqube_telemetry_input'},
                                                          {'OUTPUT_PORT': 's3_cqube_telemetry_success_output_port','INPUT_PORT': 's3_cqube_telemetry_success_input_port'},
                                                          {'OUTPUT_PORT': 's3_cqube_telemetry_success_output_port2','INPUT_PORT': 's3_cqube_telemetry_success_input_port2'}
                                                         ],
                            'configurable_datasource' :[{'OUTPUT_PORT': 'configure_files','INPUT_PORT': 'config_datasource_input'}],
                            'validate_datasource': [{'OUTPUT_PORT': 'configure_datasource','INPUT_PORT': 'file_input'}],
                        'transaction_and_aggregation':[{'OUTPUT_PORT': 'config_file_zip_output_port', 'INPUT_PORT': 'config_datasource_wait_zip'},
                                                        {'OUTPUT_PORT': 'configure_datasource_S3-success_output_port', 'INPUT_PORT': 'configure_datasource_S3-success_input_port'}]
                          }
    }
