/* tablefunc */

CREATE EXTENSION IF NOT EXISTS tablefunc;

/* manifest datasource */

create table IF NOT EXISTS manifest_datasource(
file_id int,
emission_time text,
folder_name text,
is_zip boolean,
total_files_in_zip_file int ,
relative_file_path text,
total_number_of_records_manifest int,
total_number_of_columns int,
total_number_of_records_csv int,
primary key(emission_time)
);

/* nifi metadata table */

CREATE TABLE IF NOT EXISTS zip_files_processing (
 zip_file_name varchar(255), 
 ff_uuid varchar(255), 
 ingestion_date timestamp DEFAULT current_timestamp, 
 storage_date timestamp, 
 number_files integer, 
 number_files_OK integer, 
 number_files_KO integer, 
 status varchar(15) 
);

CREATE TABLE IF NOT EXISTS files_ingestion ( 
 zip_file_name varchar(255), 
 file_name varchar(255), 
 ff_uuid text, 
 storage_date timestamp, 
 storage_name varchar(255), 
 status varchar(15),
 primary key(ff_uuid) 
);

/* role and user based auth tables */

CREATE TABLE IF NOT EXISTS role_master
(
role_id  smallint primary key,
role_name  varchar(100),
role_validity_start_date  date, /* now() */
role_validity_end_date  date,  /* date_trunc('day', NOW() + interval '2 year') for 2 years validity */
role_status smallint,
created_on  date,       /* now()*/
created_by  int,
updated_on  date,       /* now()*/ 
updated_by  int
);

CREATE TABLE IF NOT EXISTS users_authentication
(
user_id  int primary key,
first_name    varchar(30),
middle_name  varchar(30),
last_name  varchar(30),
user_email  varchar(100),
gender  text,
user_designation  varchar(100),
user_status  smallint,
role_id  int,
password  varchar(256),
user_validity_start_date  date,   /* now()*/
user_validity_end_date  date,     /* date_trunc('day', NOW() + interval '6 month') for 6 months validity */
created_on  date,                 /* now()*/
created_by  int,
updated_on  date,                 /* now()*/
updated_by  int,
foreign key (role_id) references role_master(role_id)
);

/* Data from date  function*/

CREATE OR REPLACE FUNCTION data_upto_date(year integer,month integer) returns varchar(10) as $$
declare data varchar;
begin
SELECT left(to_char((date_trunc('MONTH', ( concat(year,0,month) ||'01')::date) + INTERVAL '1 MONTH - 1 day')::DATE,'DD-MM-YYYY'),10) into data;
return data;
END; $$
LANGUAGE PLPGSQL;

/* Data upto date  function*/

CREATE OR REPLACE FUNCTION data_from_date(year integer,month integer) returns varchar(10) as $$
declare data varchar;
begin
SELECT left(to_char((date_trunc('MONTH', ( concat(year,0,month) ||'01')::date))::DATE,'DD-MM-YYYY'),10) into data;
return data;
END; $$
LANGUAGE PLPGSQL;

/* temperory table */

create table if not exists cluster_tmp
  (
cluster_id  bigint primary key not null,
cluster_name varchar(250),
block_id  bigint,
district_id  bigint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

create table if not exists block_tmp
  (
block_id  bigint primary key not null,
block_name varchar(250),
district_id  bigint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

create table if not exists district_tmp
  (
district_id  bigint primary key not null,
district_name varchar(250),
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

create table if not exists school_tmp
  (
school_id  bigint primary key not null,
school_name varchar(250),
school_lowest_class  int,
school_highest_class  int,
school_management_type_id int ,
school_category_id  int ,
school_medium_id  int ,
state_id bigint,
district_id bigint,
block_id bigint,
cluster_id bigint,
latitude double precision,
longitude double precision,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);


/* mst tables */

create table if not exists cluster_mst
  (
cluster_id  bigint primary key not null,
cluster_name varchar(250),
block_id  bigint,
district_id  bigint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

create table if not exists block_mst
  (
block_id  bigint primary key not null,
block_name varchar(250),
district_id  bigint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

create table if not exists district_mst
  (
district_id  bigint primary key not null,
district_name varchar(250),
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

/*school_master*/

create table if not exists school_master
  (
school_id  bigint primary key not null,
school_name varchar(250),
school_lowest_class  int,
school_highest_class  int,
school_management_type_id int ,
school_category_id  int ,
school_medium_id  int ,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
);

/*school_management_master*/

create table if not exists school_management_master
  (
school_management_type_id int primary key not null,
school_management_type varchar(100),
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
-- ,foreign key (school_management_type_id) references school_master(school_management_type_id)
);

/*school_category_master*/

create table if not exists school_category_master
  (
school_category_id int primary key not null,
school_category varchar(100),
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
-- ,foreign key (school_category_id) references school_master(school_category_id)
);

/*school_medium_master*/

create table if not exists school_medium_master
  (
school_medium_id int primary key not null,
medium_of_school varchar(100),
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
-- ,foreign key (school_medium_id) references school_master(school_medium_id)
);

/*school_geo_master*/

create table if not exists school_geo_master
(
school_id  bigint primary key not null,
school_latitude  double precision,
school_longitude  double precision,
district_id  bigint,
district_latitude  double precision,
district_longitude  double precision,
block_id  bigint,
block_latitude  double precision,
block_longitude  double precision,
cluster_id  bigint,
cluster_latitude  double precision,
cluster_longitude  double precision,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
-- ,foreign key (school_id) references school_master(school_id)
);  

/* school_hierarchy_details */

create table if not exists school_hierarchy_details
  (
    school_id bigint primary key not null,
    year int,
    school_name varchar(300),
    board_id bigint,
    board_name varchar(200),
    block_id bigint,
    block_name varchar(100),
    brc_name varchar(100),
    district_id bigint,
    district_name varchar(100),
    cluster_id bigint,
    cluster_name varchar(100),
    crc_name varchar(100),
    created_on TIMESTAMP without time zone,
    updated_on TIMESTAMP without time zone
    -- ,foreign key (school_id) references school_geo_master(school_id)
    );

create index if not exists school_hierarchy_details_id on school_hierarchy_details(block_id,district_id,cluster_id);

/* student_hierarchy_details */

create table if not exists student_hierarchy_details
  (
    student_id bigint primary key not null,
    school_id bigint,
    year int,
    student_class int,
    stream_of_student varchar(50),
    created_on TIMESTAMP without time zone,
    updated_on TIMESTAMP without time zone
    -- ,foreign key (school_id) references school_hierarchy_details(school_id)
    );

create index if not exists student_hierarchy_details_id on student_hierarchy_details(school_id,student_class,stream_of_student);


/* Table name:log_summary */

create table if not exists log_summary(
filename varchar(200),
ff_uuid varchar(200),
total_records bigint,
blank_lines int,
duplicate_records int,
datatype_mismatch int,
attendance_id bigint,
student_id bigint,
school_id bigint,
year bigint,
month int,
semester int,
grade int,
inspection_id bigint,
in_school_location bigint,
created_on bigint,
school_name bigint,
cluster_name bigint,
block_name bigint,
district_name bigint,
cluster_id bigint,
block_id bigint,
district_id bigint,
latitude int,
longitude int,
  content_view_date int,
  dimensions_pdata_id int,
  dimensions_pdata_pid int,
  content_name int,
  content_board int,
  content_mimetype int,
  content_medium int,
  content_gradelevel int,
  content_subject int,
  content_created_for int,
  object_id int,
  object_rollup_l1 int,
  derived_loc_state int,
  derived_loc_district int,
  user_signin_type int,
  user_login_type int,
  collection_name int,
  collection_board int,
  collection_type int,
  collection_medium int,
  collection_gradelevel int,
  collection_subject int,
  collection_created_for int,
  total_count int,
  total_time_spent int,
processed_records int,
process_start_time timestamp ,
process_end_time timestamp
);

/* Table name : dist_null_col */

create table if not exists dist_null_col( filename varchar(200),
 ff_uuid varchar(200),
 count_null_districtid int,
  Count_null_district  int);

/*Table name: cluster_null_col*/

create table if not exists cluster_null_col( filename varchar(200),
 ff_uuid varchar(200),
count_null_clusterid int,
count_null_cluster int,
 count_null_districtid int,
 count_null_block int,
 count_null_blockid  int);

/*Table name: block_null_col*/

create table if not exists block_null_col( filename varchar(200),
 ff_uuid varchar(200),
count_null_districtid int,
count_null_block int,
 count_null_blockid int);

/*Table name: school_null_col*/

create table if not exists school_null_col( filename varchar(200),
 ff_uuid varchar(200),
count_null_school int,
count_null_latitude int,
count_null_longitude int);

create table if not exists district_dup
  (
district_id  bigint  not null,
district_name varchar(250),
created_on  TIMESTAMP without time zone ,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

create table if not exists block_dup
  (
block_id  bigint  not null,
block_name varchar(250),
district_id  bigint,
num_of_times int,
ff_uuid varchar(255),
created_on  TIMESTAMP without time zone ,
created_on_file_process  TIMESTAMP without time zone default current_timestamp

);


create table if not exists cluster_dup
  (
cluster_id  bigint  not null,
cluster_name varchar(250),
block_id  bigint,
district_id  bigint,
num_of_times int,
ff_uuid varchar(255),
created_on  TIMESTAMP without time zone ,
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);


create table if not exists school_dup
  (
school_id  bigint  not null,
school_name varchar(250),
school_lowest_class  int,
school_highest_class  int,
school_management_type_id int ,
school_category_id  int ,
school_medium_id  int ,
school_latitude  double precision,
school_longitude  double precision,
district_id  bigint,
block_id bigint,
cluster_id bigint,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);


create table if not exists school_invalid_data
  (
    ff_uuid text,
    exception_type text,
    school_id bigint ,
    school_name varchar(300),
    block_id bigint,
    district_id bigint,
    cluster_id bigint,
    school_latitude double precision,
    school_longitude double precision,
    created_on TIMESTAMP without time zone
    -- ,foreign key (school_id) references school_geo_master(school_id)
    );
	

/*Telemetry*/

create table if not exists emission_files_details
    (
  filename text,
  ff_uuid text,
  s3_bucket text,
  last_modified_time TIMESTAMP without time zone,
  processed_status boolean,
  created_on TIMESTAMP without time zone default current_timestamp
  );

create table if not exists telemetry_data
    (
  pageid text,
  uid text,
  event text,
  level text,
  locationid bigint,
  locationname text,
  lat double precision,
  lng double precision,
  download int,
  created_on TIMESTAMP without time zone default current_timestamp
  );

 create table if not exists telemetry_views_data
    (
  uid text,
  eventtype text,
  reportid text,
  click_time TIMESTAMP without time zone,
  created_on TIMESTAMP without time zone default current_timestamp
  );

/*Upgrade scripts*/

/*files_ingestion table*/
alter table files_ingestion alter COLUMN ff_uuid type text;
alter table files_ingestion drop constraint if exists files_ingestion_pkey;
alter table files_ingestion add primary key(ff_uuid);

/*school_master*/
alter table school_master drop COLUMN if exists school_address;
alter table school_master drop COLUMN if exists school_zipcode;
alter table school_master drop COLUMN if exists school_contact_number;
alter table school_master drop COLUMN if exists school_email_contact;
alter table school_master drop COLUMN if exists school_website;

/*log summary*/
alter table log_summary add COLUMN if not exists datatype_mismatch int;
alter table log_summary add COLUMN if not exists content_view_date int;
alter table log_summary add COLUMN if not exists dimensions_pdata_pid int;
alter table log_summary add COLUMN if not exists dimensions_pdata_id int;
alter table log_summary add COLUMN if not exists content_name int;
alter table log_summary add COLUMN if not exists content_board int;
alter table log_summary add COLUMN if not exists content_mimetype int;
alter table log_summary add COLUMN if not exists content_medium int;
alter table log_summary add COLUMN if not exists content_gradelevel int;
alter table log_summary add COLUMN if not exists content_subject int;
alter table log_summary add COLUMN if not exists content_created_for int;
alter table log_summary add COLUMN if not exists object_id int;
alter table log_summary add COLUMN if not exists object_rollup_l1 int;
alter table log_summary add COLUMN if not exists derived_loc_state int;
alter table log_summary add COLUMN if not exists derived_loc_district int;
alter table log_summary add COLUMN if not exists user_signin_type int;
alter table log_summary add COLUMN if not exists user_login_type int;
alter table log_summary add COLUMN if not exists collection_name int;
alter table log_summary add COLUMN if not exists collection_board int;
alter table log_summary add COLUMN if not exists collection_type int;
alter table log_summary add COLUMN if not exists collection_medium int;
alter table log_summary add COLUMN if not exists collection_gradelevel int;
alter table log_summary add COLUMN if not exists collection_subject int;
alter table log_summary add COLUMN if not exists collection_created_for int;
alter table log_summary add COLUMN if not exists total_count int;
alter table log_summary add COLUMN if not exists total_time_spent int;


/*log summary*/
alter table log_summary add COLUMN if not exists udise_sch_code int;
alter table log_summary add COLUMN if not exists sector_no int;
alter table log_summary add COLUMN if not exists item_id int;
alter table log_summary add COLUMN if not exists class_type_id int;
alter table log_summary add COLUMN if not exists stream_id int;
alter table log_summary add COLUMN if not exists grade_pri_upr int;
alter table log_summary add COLUMN if not exists incentive_type int;
alter table log_summary add COLUMN if not exists caste_id int;
alter table log_summary add COLUMN if not exists disability_type int;
alter table log_summary add COLUMN if not exists medinstr_seq int;
alter table log_summary add COLUMN if not exists age_id int;
alter table log_summary add COLUMN if not exists item_group int;
alter table log_summary add COLUMN if not exists tch_code int;
alter table log_summary add COLUMN if not exists marks_range_id int;
alter table log_summary add COLUMN if not exists nsqf_faculty_id int;

/*log summary*/

alter table log_summary add COLUMN if not exists exam_id int;
alter table log_summary add COLUMN if not exists question_id  int;
alter table log_summary add COLUMN if not exists assessment_year int;
alter table log_summary add COLUMN if not exists medium int;
alter table log_summary add COLUMN if not exists standard int;
alter table log_summary add COLUMN if not exists subject_id int;
alter table log_summary add COLUMN if not exists subject_name int;
alter table log_summary add COLUMN if not exists exam_type_id int;
alter table log_summary add COLUMN if not exists exam_type int;
alter table log_summary add COLUMN if not exists exam_code int;
alter table log_summary add COLUMN if not exists exam_date int;
alter table log_summary add COLUMN if not exists total_questions int;
alter table log_summary add COLUMN if not exists total_marks int;
alter table log_summary add COLUMN if not exists question_title int;
alter table log_summary add COLUMN if not exists question int;
alter table log_summary add COLUMN if not exists question_marks int;
alter table log_summary add COLUMN if not exists id  int;
alter table log_summary add COLUMN if not exists school_id int;
alter table log_summary add COLUMN if not exists student_uid int;
alter table log_summary add COLUMN if not exists studying_class int;
alter table log_summary add COLUMN if not exists obtained_marks int;


alter table log_summary add COLUMN if not exists udise_sch_code int;
alter table log_summary add COLUMN if not exists sector_no  int;
alter table log_summary add COLUMN if not exists item_id int;
alter table log_summary add COLUMN if not exists class_type_id int;
alter table log_summary add COLUMN if not exists stream_id int;
alter table log_summary add COLUMN if not exists grade_pri_upr int;
alter table log_summary add COLUMN if not exists incentive_type int;
alter table log_summary add COLUMN if not exists caste_id int;
alter table log_summary add COLUMN if not exists disability_type int;
alter table log_summary add COLUMN if not exists medinstr_seq int;
alter table log_summary add COLUMN if not exists age_id int;
alter table log_summary add COLUMN if not exists item_group int;
alter table log_summary add COLUMN if not exists tch_code int;
alter table log_summary add COLUMN if not exists marks_range_id int;
alter table log_summary add COLUMN if not exists nsqf_faculty_id int;

/* composite nifi template info */

CREATE TABLE IF NOT EXISTS nifi_template_info ( 
 id serial,
 template text, 
 status boolean
);

alter table log_summary add column IF NOT EXISTS collection_id int;
alter table log_summary add column IF NOT EXISTS uuid int;

ALTER TABLE school_tmp ALTER COLUMN created_on DROP NOT NULL;
ALTER TABLE school_tmp ALTER COLUMN updated_on DROP NOT NULL;
ALTER TABLE school_master ALTER COLUMN created_on DROP NOT NULL;
ALTER TABLE school_master ALTER COLUMN updated_on DROP NOT NULL;
ALTER TABLE school_management_master ALTER COLUMN created_on DROP NOT NULL;
ALTER TABLE school_management_master ALTER COLUMN updated_on DROP NOT NULL;
ALTER TABLE school_category_master ALTER COLUMN created_on DROP NOT NULL;
ALTER TABLE school_category_master ALTER COLUMN updated_on DROP NOT NULL;
ALTER TABLE school_medium_master ALTER COLUMN created_on DROP NOT NULL;
ALTER TABLE school_medium_master ALTER COLUMN updated_on DROP NOT NULL;

alter table log_summary add column IF NOT EXISTS teacher_id bigint;

-- Data replay

create table if not exists del_data_source_details (data_source text,params text,table_name text,order_of_execution int, primary key(data_source,table_name));

--Tables related to student_attendance

insert into del_data_source_details values('student_attendance','month,year','student_attendance_meta',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('student_attendance','month,year','student_attendance_staging_1',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('student_attendance','month,year','student_attendance_staging_2',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('student_attendance','month,year','student_attendance_temp',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('student_attendance','month,year','student_attendance_trans',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('student_attendance','month,year','school_student_total_attendance',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to teacher_attendance

insert into del_data_source_details values('teacher_attendance','month,year','teacher_attendance_meta',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('teacher_attendance','month,year','teacher_attendance_staging_1',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('teacher_attendance','month,year','teacher_attendance_staging_2',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('teacher_attendance','month,year','teacher_attendance_temp',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('teacher_attendance','month,year','teacher_attendance_trans',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('teacher_attendance','month,year','school_teacher_total_attendance',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to crc

insert into del_data_source_details values('crc','month,year','crc_location_trans',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('crc','month,year','crc_inspection_trans',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('crc','month,year','crc_visits_frequency',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to periodic_assessment_test

insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_mst',8) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_qst_mst',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_result_staging_1',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_result_staging_2',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_result_temp',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_result_trans',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_school_qst_result',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_school_result',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('periodic_assessment_test','exam_code','periodic_exam_stud_grade_count',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to semester_assessment_test

insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_mst',8) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_qst_mst',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_result_staging_1',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_result_staging_2',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_result_temp',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_result_trans',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_school_qst_result',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_school_result',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('semester_assessment_test','exam_code','semester_exam_stud_grade_count',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to diksha_tpd

insert into del_data_source_details values('diksha_tpd','batch_id','diksha_tpd_staging',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_tpd','batch_id','diksha_tpd_content_temp',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_tpd','batch_id','diksha_tpd_trans',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_tpd','batch_id','diksha_tpd_agg',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to diksha_summary_rollup

insert into del_data_source_details values('diksha_summary_rollup','batch_id','diksha_content_staging',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_summary_rollup','batch_id','diksha_content_temp',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_summary_rollup','batch_id','diksha_content_trans',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('diksha_summary_rollup','batch_id','diksha_total_content',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to static

insert into del_data_source_details values('static','all','block_tmp',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','block_mst',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','district_tmp',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','district_mst',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','cluster_tmp',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','cluster_mst',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','school_master',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','school_tmp',8) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','school_hierarchy_details',9) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('static','all','school_geo_master',10) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to infrastructure

insert into del_data_source_details values('infrastructure','all','infrastructure_temp',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('infrastructure','all','infrastructure_trans',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;

--Tables related to udise

insert into del_data_source_details values('udise','all','udise_sch_incen_cwsn',1) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_plcmnt_c12',2) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_reptr',3) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_basic_info',4) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_incentives',5) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_trng_prov',6) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmmarks_c10',7) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_class_cond',8) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_school_metrics_trans',9) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmmarks_c12',10) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_pgi_details',11) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_enr_caste',12) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_age',13) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmres_c10',14) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_profile',15) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_enr_sub_sec',16) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_by_stream',17) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmres_c12',18) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_recp_exp',19) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_exmres_c10',20) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_cwsn',21) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmres_c5',22) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_safety',23) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_exmres_c12',24) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_fresh',25) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_exmres_c8',26) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_staff_posn',27) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_faculty',28) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_medinstr',29) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_facility',30) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_tch_profile',31) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_nsqf_plcmnt_c10',32) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing;
insert into del_data_source_details values('udise','all','udise_sch_enr_newadm',33) on conflict  ON CONSTRAINT del_data_source_details_pkey do nothing; 


create table  if not exists data_replay_meta(
filename text not null,
ff_uuid text,
cqube_process_status text,
data_source text,
batch_id text,
from_date date,
to_date date,
exam_code text,
semesters text,
academic_year text,
selection varchar(3),
year int,
months text,
created_on timestamp default current_timestamp,
updated_on timestamp,
primary key(ff_uuid));


alter table school_hierarchy_details add column if not exists school_management_type varchar(100);
alter table school_hierarchy_details add column if not exists school_category varchar(100);
alter table school_hierarchy_details add column if not exists total_students bigint;


create table if not exists school_category_null_col( filename varchar(200),
ff_uuid varchar(200),
count_null_school_category_id int,
count_null_school_category  int);

create table if not exists school_management_null_col( filename varchar(200),
ff_uuid varchar(200),
count_null_school_management_type_id int,
count_null_school_management_type  int);

create table if not exists school_category_dup( 
school_category_id int,
school_category  varchar(100),
num_of_times int,
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp);

create table if not exists school_management_dup( 
school_management_type_id int,
school_management_type  varchar(100),
num_of_times int,
default_option boolean,
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp);

create table IF NOT EXISTS school_grade_enrolment(
  school_id bigint,
  grade int,
  students_count int,
  primary key(school_id,grade)
);

create table IF NOT EXISTS subject_details(
  subject_id int,
  grade int,
  subject varchar(100),
  primary key(subject_id,grade)
);

alter table log_summary add column if not exists school_category_id int,add column if not exists school_category int, add column if not exists school_management_type_id int,
add column if not exists school_management_type int;


alter table school_master add column if not exists state_id bigint,add column if not exists district_id bigint,add column if not exists block_id bigint,add column if not exists cluster_id bigint,add column if not exists latitude double precision,add column if not exists longitude double precision;

alter table school_management_master add column if not exists default_option boolean;

alter table data_replay_meta add column if not exists retention_period integer;

insert into school_hierarchy_details values(9999,NULL,'others',NULL,NULL,9999,'others',NULL,9999,'others',9999,'others',NULL,now(),now()) on conflict  ON CONSTRAINT school_hierarchy_details_pkey do nothing;

create table if not exists progress_card_config(id serial,	data_source varchar(100),select_query text,join_query text,status boolean,category varchar(100),time_period varchar(100),primary key(data_source,category,time_period));

create table if not exists  progress_card_category_config(categories text ,value_from int,value_to int);
truncate progress_card_category_config;


alter table log_summary add COLUMN if not exists user_location_master_id int;
alter table log_summary add COLUMN if not exists user_master_id int;
alter table log_summary add COLUMN if not exists observer_id int;
alter table log_summary add column if not exists count_of_null_rows integer;

alter table log_summary add column if not exists program_name integer;
alter table log_summary add column if not exists course_id integer;
alter table log_summary add column if not exists course_start_date integer;
alter table log_summary add column if not exists expected_etb_users integer;
alter table log_summary add column if not exists academic_year integer;

alter table dist_null_col add column if not exists count_of_null_rows int;
alter table block_null_col add column if not exists count_of_null_rows int;
alter table cluster_null_col add column if not exists count_of_null_rows int;
alter table school_null_col add column if not exists count_of_null_rows int;
alter table school_management_null_col add column if not exists count_of_null_rows int;
alter table school_category_null_col add column if not exists count_of_null_rows int;

/* duplicate tables */

create table if not exists subject_details_dup(subject_id int,subject varchar(100),grade smallint,num_of_times int,
ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

create table if not exists school_grade_enrolment_dup(school_id bigint,grade smallint,students_count int,num_of_times int,
ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

