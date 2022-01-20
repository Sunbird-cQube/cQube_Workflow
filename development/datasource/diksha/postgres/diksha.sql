/*Diksha*/
/* master table */

create table IF NOT EXISTS diksha_content_staging(
  ff_uuid text,
  content_view_date date,
  dimensions_pdata_id text,
  dimensions_pdata_pid text,
  content_name text,
  content_board text,
  content_mimetype text,
  content_medium text,
  content_gradelevel text,
  content_subject text,
  content_created_for text,
  object_id text,
  object_rollup_l1 text,
  derived_loc_state text,
  derived_loc_district text,
  user_signin_type text,
  user_login_type text,
  collection_name text,
  collection_board text,
  collection_type text,
  collection_medium text,
  collection_gradelevel text,
  collection_subject text,
  collection_created_for text,
  total_count int,
  total_time_spent double precision,
  created_on TIMESTAMP without time zone,
  updated_on TIMESTAMP without time zone 
  );

Alter table diksha_content_staging
drop column if exists collection_id,
Add column if not exists collection_name text,
drop column if exists batch_id,
drop column if exists batch_name,
drop column if exists uuid ,
drop column if exists district,
drop column if exists state,
drop column if exists org_name,
drop column if exists school_id,
drop column if exists declared_board,
drop column if exists school_name,
drop column if exists block_name,
drop column if exists enrolment_date,
drop column if exists completion_date,
drop column if exists progress,
drop column if exists certificate_status,
drop column if exists total_score,
Add column if not exists created_on timestamp without time zone,
Add column if not exists updated_on timestamp without time zone;

alter table diksha_content_staging alter COLUMN content_created_for type text;
alter table diksha_content_staging alter COLUMN collection_created_for type text;

create table IF NOT EXISTS diksha_content_temp(
  ff_uuid text,
  content_view_date date,
  dimensions_pdata_id text,
  dimensions_pdata_pid text,
  content_name text,
  content_board text,
  content_mimetype text,
  content_medium text,
  content_gradelevel text,
  content_subject text,
  content_created_for text,
  object_id text,
  object_rollup_l1 text,
  derived_loc_state text,
  derived_loc_district text,
  user_signin_type text,
  user_login_type text,
  collection_name text,
  collection_board text,
  collection_type text,
  collection_medium text,
  collection_gradelevel text,
  collection_subject text,
  collection_created_for text,
  total_count int,
  total_time_spent double precision,
  created_on TIMESTAMP without time zone,
  updated_on TIMESTAMP without time zone 
  );

alter table diksha_content_temp alter COLUMN content_created_for type text;
alter table diksha_content_temp alter COLUMN collection_created_for type text;

/* Transanction table */
/* diksha_content_trans*/

  create table IF NOT EXISTS diksha_content_trans(
  ff_uuid text,
  content_view_date date,
  dimensions_pdata_id text,
  dimensions_pdata_pid text,
  content_name text,
  content_board text,
  content_mimetype text,
  content_medium text,
  content_gradelevel text,
  content_subject text,
  content_created_for text,
  object_id text,
  object_rollup_l1 text,
  derived_loc_state text,
  derived_loc_district text,
  user_signin_type text,
  user_login_type text,
  collection_name text,
  collection_board text,
  collection_type text,
  collection_medium text,
  collection_gradelevel text,
  collection_subject text,
  collection_created_for text,
  total_count int,
  total_time_spent double precision,
  created_on TIMESTAMP without time zone,
  updated_on TIMESTAMP without time zone 
  );

drop view if exists insert_diksha_trans_view;

alter table diksha_content_trans alter COLUMN content_created_for type text;
alter table diksha_content_trans alter COLUMN collection_created_for type text;

/* Aggregation table*/
/* diksha_total_content*/

  create table IF NOT EXISTS diksha_total_content(
  id serial,
  district_id int,
  district_name text,
  district_latitude double precision,
  district_longitude double precision,
  content_view_date date,
  dimensions_pdata_id text,
  dimensions_pdata_pid text,
  content_name text,
  content_board text,
  content_mimetype text,
  content_medium text,
  content_gradelevel text,
  content_subject text,
  content_created_for text,
  object_id text,
  object_rollup_l1 text,
  derived_loc_state text,
  derived_loc_district text,
  user_signin_type text,
  user_login_type text,
  collection_name text,
  collection_board text,
  collection_type text,
  collection_medium text,
  collection_gradelevel text,
  collection_subject text,
  collection_created_for text,
  total_count int,
  total_time_spent double precision,
  created_on TIMESTAMP without time zone,
  updated_on TIMESTAMP without time zone 
  );

alter table diksha_total_content alter COLUMN content_created_for type text;
alter table diksha_total_content alter COLUMN collection_created_for type text;


/* null check*/
/* diksha_null_col*/

  create table if not exists diksha_null_col
    (
  filename varchar(200),
  ff_uuid varchar(200),
  count_null_content_view_date int,
  count_null_dimensions_pdata_id int,
  count_null_dimensions_pdata_pid int,
  count_null_content_name int,
  count_null_content_board int,
  count_null_content_mimetype int,
  count_null_content_medium int,
  count_null_content_gradelevel int,
  count_null_content_subject int,
  count_null_content_created_for int,
  count_null_object_id int,
  count_null_object_rollup_l1 int,
  count_null_derived_loc_state int,
  count_null_derived_loc_district int,
  count_null_user_signin_type int,
  count_null_user_login_type int,
  count_null_collection_type int,
  count_null_collection_created_for int,
  count_null_total_count int,
  count_null_total_time_spent  int
  );
  
  
/* Duplicate check*/
/* diksha_dup*/

  create table if not exists diksha_dup
    (
  content_view_date date,
  dimensions_pdata_id text,
  dimensions_pdata_pid text,
  content_name text,
  content_board text,
  content_mimetype text,
  content_medium text,
  content_gradelevel text,
  content_subject text,
  content_created_for text,
  object_id text,
  object_rollup_l1 text,
  derived_loc_state text,
  derived_loc_district text,
  user_signin_type text,
  user_login_type text,
  collection_name text,
  collection_board text,
  collection_type text,
  collection_medium text,
  collection_gradelevel text,
  collection_subject text,
  collection_created_for text,
  total_count int,
  total_time_spent double precision,
  num_of_times int,
  ff_uuid varchar(255),
  created_on_file_process  TIMESTAMP without time zone default current_timestamp
  ); 
  
alter table diksha_dup alter COLUMN content_created_for type text;
alter table diksha_dup alter COLUMN collection_created_for type text;

/*diksha content trans*/
alter table diksha_content_trans add COLUMN if not exists ff_uuid text;


Alter table diksha_null_col
Add column if not exists count_null_collection_id int,
Add column if not exists count_null_uuid int,
Add column if not exists count_null_school_id int;

create table IF NOT EXISTS diksha_tpd_dup(
 ff_uuid text,
 collection_id text,
 collection_name text,
 batch_id text,
 batch_name text,
 uuid text,
 state text,
 org_name text,
 school_id bigint,
 enrolment_date date,
 completion_date date,
 progress double precision,
 certificate_status text,
 total_score double precision,
 nested_collection_progress	jsonb,
assessment_score	jsonb,
 created_on timestamp without time zone,
 updated_on timestamp without time zone);


create table IF NOT EXISTS diksha_tpd_content_temp(
ff_uuid text,
 collection_id text,
 collection_name text,
 batch_id text,
 batch_name text,
 uuid text,
 state text,
 org_name text,
 school_id bigint,
 enrolment_date date,
 completion_date date,
 progress double precision,
 certificate_status text,
 total_score double precision,
nested_collection_progress	jsonb,
assessment_score	jsonb,
 created_on timestamp without time zone,
 updated_on timestamp without time zone);

create table IF NOT EXISTS diksha_tpd_trans(
collection_id	text,
collection_name	text,
batch_id	text,
batch_name	text,
uuid	text,
state	text,
org_name	text,
school_id	bigint,
enrolment_date	date,
completion_date	date,
progress	double precision,
certificate_status	text,
total_score	double precision,
nested_collection_progress	jsonb,
assessment_score	jsonb,
created_on	TIMESTAMP without time zone,
updated_on	TIMESTAMP without time zone,
primary key(collection_id,uuid,school_id,enrolment_date,batch_id)
  );

alter table diksha_tpd_trans drop constraint if exists diksha_tpd_trans_pkey;
alter table diksha_tpd_trans add primary key(collection_id,uuid,batch_id);

create table IF NOT EXISTS diksha_tpd_agg(
collection_id	text,
collection_name	text,
collection_progress	double precision,
enrolled_date date,
school_id	bigint,
school_name  varchar(200),
district_id  bigint,
district_name  varchar(100),
block_id  bigint,
block_name  varchar(100),
cluster_id  bigint,
cluster_name  varchar(100),
created_on	TIMESTAMP without time zone,
updated_on	TIMESTAMP without time zone,
primary key(collection_id,enrolled_date,school_id,collection_name)
  );

alter table diksha_tpd_agg add column IF NOT EXISTS total_enrolled int;
alter table diksha_tpd_agg add column IF NOT EXISTS total_completed int;
alter table diksha_tpd_agg drop column IF EXISTS percentage_teachers;

create table  if not exists diksha_api_meta (request_id text,encryption_key text,batch_id text,channel_id text,from_date date,to_date date,request_status text,
cqube_process_status text,expiry_time timestamp,requested_on timestamp,dataset text,request_channel text, ff_uuid text primary key);

ALTER TABLE diksha_api_meta add column IF NOT EXISTS updated_on TIMESTAMP without time zone;
ALTER TABLE diksha_api_meta add column IF NOT EXISTS tag text;

create table if not exists diksha_api_summary_roll_up (date date,file_url text,expiry_time timestamp,cqube_process_status text,created_on timestamp,updated_on timestamp, primary key(date));

create table if not exists diksha_tpd_mapping_temp
  (
    ff_uuid text,
    uuid text,
    state text,
    district_name text,
    school_name text,
    school_id bigint,
    status text,
    created_on TIMESTAMP without time zone,
    updated_on TIMESTAMP without time zone
    );


create table if not exists diksha_tpd_mapping
  (
    uuid text,
    state text,
    district_name text,
    school_name text,
    school_id bigint,
    status text,
    created_on TIMESTAMP without time zone,
    updated_on TIMESTAMP without time zone,
    primary key(uuid,school_id)
    );

create table IF NOT EXISTS diksha_tpd_staging(
  ff_uuid text,
  collection_id text,
  collection_name text,
  state text,
  enrolment_date date,
  batch_id text,
  batch_name text,
  completion_date date,
  certificate_status text,
  org_name text,
  progress double precision,
  total_score double precision,
  uuid text,
  created_on TIMESTAMP without time zone,
  updated_on TIMESTAMP without time zone 
  );

alter table diksha_api_meta add column if not exists total_files int, add column if not exists files_processed int,add column if not exists files_emitted int;
alter table diksha_content_staging add column if not exists dimensions_mode text, add column if not exists dimensions_type text;
alter table diksha_dup add column if not exists dimensions_mode text, add column if not exists dimensions_type text;
alter table diksha_content_temp add column if not exists dimensions_mode text, add column if not exists dimensions_type text;
alter table diksha_content_trans add column if not exists dimensions_mode text, add column if not exists dimensions_type text;

/* Diksha Summary Rollup month wise */

 create table IF NOT EXISTS diksha_total_content_year_month(
 id serial,
 district_id integer,
 district_name text,
 month integer,
 year integer,
 content_name text,
 content_medium text,
 content_gradelevel text,
 content_subject text,
 object_id text,
 collection_name text,
 collection_type text,
 collection_medium text,
 collection_gradelevel text,
 total_count integer,
 total_time_spent double precision,
 created_on timestamp without time zone,
 updated_on timestamp without time zone
  );

create index IF NOT EXISTS diksha_total_content_year_month_month_year_idx on diksha_total_content_year_month (month,year);

create table IF NOT EXISTS diksha_refresh (content_view_date date);

alter table diksha_content_temp add column if not exists object_type text;
alter table diksha_content_staging add column if not exists object_type text;
alter table diksha_content_trans add column if not exists object_type text;
alter table diksha_total_content add column if not exists object_type text;
alter table diksha_total_content add column if not exists dimensions_type text;

/* color codes for pie chart */
create table if not exists  color_codes(id serial,color_code text);

insert into color_codes(color_code) values('516BEB'),('A13333'),('EDD2F3'),('84DFFF'),('B3541E'),('22577E'),('95D1CC'),('5584AC'),('064635'),('519259'),('F0BB62'),('DD4A48'),('4F091D'),('161853'),
('FFAFAF'),('EBE645'),('9A0680'),('79018C'),('160040'),('6E3CBC'),('D47AE8'),('A8ECE7'),('FFCC1D'),
('F3950D'),('CD1818'),('FFF323'),('396EB0'),('009DAE'),('FF7800'),('FFBC97'),('71DFE7'),('AE431E'),
('8A8635'),('66806A'),('F58840'),('B85252'),('533535'),('AE4CCF'),('FF6D6D'),('753188'),('FFAB4C'),
('142F43'),('B983FF'),('94B3FD'),('94DAFF'),('B4FE98'),('17D7A0'),('544179'),('C85C5C'),('F9975D'),
('E5890A'),('9D5C0D'),('AA14F0'),('2F86A6'),('34BE82'),('630000'),('B91646'),('864879'),('3F3351'),
('1F1D36'),('E9A6A6'),('105652'),('9C19E0'),('FF5DA2'),('161E54'),('88E0EF'),('FF5151'),('49FF00'),
('FF9300'),('87AAAA'),('A9333A'),('E1578A'),('3E7C17'),('F4A442')
except (select color_code from color_codes);

alter table diksha_tpd_agg add column if not exists certificate_count integer;

/* diksha temp tables for program course enrollment details */

create table if not exists diksha_program_course_details_temp(
 program_id bigint,
 program_name text,
 collection_id text,
 expected_enrollment bigint,
primary key(program_id,collection_id) );

create table if not exists diksha_course_details_temp(
collection_id text,
course_start_date date not null,
course_end_date date,
primary key(collection_id));
 
create table if not exists diksha_course_expected_temp(
 collection_id text,
 district_id bigint,
 expected_enrollment bigint,
 primary key(collection_id,district_id));

create table if not exists diksha_program_expected_temp(
 program_name text not NULL,
 district_id bigint not NULL,
 expected_enrollment bigint,
 primary key(program_name,district_id));

/* Diksha static table for expected enrollments */ 

create table IF NOT EXISTS diksha_tpd_expected_enrollment(
program_id int,
program_name text,
 collection_id text,
 collection_name text,
 course_start_date date,
 course_end_date date,
 District_id bigint,
 District character varying(100),
 expected_enrollment bigint,
 program_expected_enrollment bigint,
 created_on timestamp without time zone,
 updated_on timestamp without time zone);

create table if not exists diksha_etb_expected_enrolment(
academic_year text not null,
district_id bigint,
expected_etb_users bigint,
primary key(academic_year,district_id));

/* dup and null tables */
create table if not exists diksha_program_course_details_dup(
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp,
program_id bigint,
program_name text,
course_id text,
expected_enrollment bigint,
num_of_times bigint);
  
create table if not exists diksha_course_expected_dup(
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp,
course_id text,
district_id bigint,
expected_enrollment bigint,
num_of_times bigint);

create table if not exists diksha_program_expected_dup(
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp,
program_name text,
district_id bigint,
expected_enrollment bigint,
num_of_times bigint);
 
create table if not exists diksha_course_details_dup(
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp,
collection_id text,
course_start_date date,
course_end_date date,
num_of_times bigint);

create table if not exists diksha_etb_expected_enrolment_dup(
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp,
academic_year text not null,
district_id bigint,
expected_etb_users bigint,
num_of_times bigint);

create table if not exists diksha_program_course_details_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_program_name int,
count_null_course_id int);

create table if not exists diksha_course_details_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_course_id int,
count_null_course_start_date int);


create table if not exists diksha_course_enrolment_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_course_id int,
count_null_district_id int);

create table if not exists diksha_etb_enrolment_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_academic_year int,
count_null_district_id int,
count_null_expected_etb_users int);

create table if not exists diksha_program_details_null_col(
filename varchar(200),
ff_uuid varchar(200),
count_null_district_id int,
count_null_program_name int);

alter table diksha_program_course_details_temp drop column if exists expected_enrollment;
alter table diksha_program_course_details_dup drop column if exists expected_enrollment;

CREATE UNIQUE INDEX if not exists  diksha_tpd_expected_enrollment_idx ON diksha_tpd_expected_enrollment (program_id,collection_id,district_id);

alter table diksha_program_expected_temp drop column if exists expected_enrollment;
alter table diksha_program_expected_temp add column if not exists expected_enrollments bigint;
alter table diksha_program_expected_dup drop column if exists expected_enrollment;
alter table diksha_program_expected_dup add column if not exists expected_enrollments bigint;

alter table diksha_null_col add column if not exists count_of_null_rows int;

alter table diksha_course_details_null_col add column if not exists count_of_null_rows int;
alter table diksha_course_enrolment_null_col add column if not exists count_of_null_rows int;
alter table diksha_program_course_details_null_col add column if not exists count_of_null_rows int;
alter table diksha_program_details_null_col add column if not exists count_of_null_rows int;
alter table diksha_etb_enrolment_null_col add column if not exists count_of_null_rows int;

