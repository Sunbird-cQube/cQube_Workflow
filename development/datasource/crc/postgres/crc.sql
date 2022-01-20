/* Transaction table - crc_inspection_trans */

create table if not exists crc_inspection_trans
(
crc_inspection_id bigint primary key not null,
crc_id bigint,
crc_name varchar(100),
school_id  bigint,
lowest_class smallint,
highest_class smallint,
visit_start_time TIME without time zone,
visit_end_time TIME without time zone,
total_class_rooms smallint,
actual_class_rooms smallint,
total_suggestion_last_month smallint,
resolved_from_that smallint,
is_inspection smallint,
reason_type varchar(100),
reason_desc text,
total_score double precision,
score double precision,
is_offline boolean,
created_on  TIMESTAMP without time zone, /* created_on field will come from source data*/
updated_on  TIMESTAMP without time zone
-- ,foreign key (school_id) references school_hierarchy_details(school_id)
);

create index if not exists crc_inspection_trans_id on crc_inspection_trans(school_id,crc_id);

/* Transaction table - crc_location_trans */

create table if not exists crc_location_trans
(
crc_location_id bigint primary key not null,
crc_id bigint,
inspection_id  bigint,
school_id  bigint ,
latitude  double precision,
longitude  double precision,
in_school_location  boolean,
year int,
month int,
created_on  TIMESTAMP without time zone, 
updated_on  TIMESTAMP without time zone
-- ,foreign key (school_id) references school_hierarchy_details(school_id),
-- foreign key (inspection_id) references crc_inspection_trans(crc_inspection_id)
);

create index if not exists crc_location_trans_id on crc_location_trans(school_id,crc_id);


/* crc_visits_frequency */

create table if not exists crc_visits_frequency
(
school_id  bigint,
school_name varchar(100),
district_id  bigint,
district_name varchar(100),
block_id  bigint,
block_name varchar(100),
cluster_id  bigint,
cluster_name varchar(100),
crc_name varchar(100),
visit_count int,
missed_visit_count int,
month int,
year int,
created_on  TIMESTAMP without time zone,
updated_on  TIMESTAMP without time zone,
primary key(school_id,month,year)
);

create index if not exists crc_visits_frequency_id on crc_visits_frequency(school_id,block_id,cluster_id,district_id);


/* Table name: crc_loc_null_col */

create table if not exists crc_loc_null_col (filename varchar(200),
     ff_uuid varchar(200),            
     count_null_schoolid  int, 
      count_null_inspectionid int,
      inschoolloc int,
       count_null_createdon int,
      count_latitude int,
       count_longitude int);

/* Table name: crc_inspec_null_col */

create table if not exists crc_inspec_null_col(filename varchar(200),
ff_uuid varchar(200),
count_null_schoolid int,
 count_null_inspectionid int,
 count_null_createdon int);

/*crc_inspection_trans*/
alter table crc_inspection_trans alter COLUMN total_score type double precision;


create table if not exists crc_location_dup
(
crc_location_id bigint  not null,
crc_id bigint,
inspection_id  bigint,
school_id  bigint ,
latitude  double precision,
longitude  double precision,
in_school_location  boolean,
num_of_times int,
ff_uuid varchar(255),
created_on  TIMESTAMP without time zone  ,
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

create table if not exists crc_inspection_dup
(
crc_inspection_id bigint  not null,
crc_id bigint,
crc_name varchar(100),
school_id  bigint,
lowest_class smallint,
highest_class smallint,
visit_start_time TIME without time zone,
visit_end_time TIME without time zone,
total_class_rooms smallint,
actual_class_rooms smallint,
total_suggestion_last_month smallint,
resolved_from_that smallint,
is_inspection smallint,
reason_type varchar(100),
reason_desc text,
total_score double precision,
score double precision,
is_offline boolean,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

alter table crc_inspection_dup add column  IF NOT EXISTS visit_date date;

alter table crc_inspection_trans add column  IF NOT EXISTS visit_date date;
alter table crc_inspection_dup add column  IF NOT EXISTS visit_date date;


/* crc_inspection_temp */

create table if not exists crc_inspection_temp
(
crc_inspection_id bigint primary key not null,
crc_id bigint,
crc_name varchar(100),
school_id  bigint,
lowest_class smallint,
highest_class smallint,
visit_start_time TIME without time zone,
visit_end_time TIME without time zone,
total_class_rooms smallint,
actual_class_rooms smallint,
total_suggestion_last_month smallint,
resolved_from_that smallint,
is_inspection smallint,
reason_type varchar(100),
reason_desc text,
total_score double precision,
score double precision,
is_offline boolean,
ff_uuid text,
created_on  TIMESTAMP without time zone, 
updated_on  TIMESTAMP without time zone
-- ,foreign key (school_id) references school_hierarchy_details(school_id)
);


/* crc_location_temp */

create table if not exists crc_location_temp
(
crc_location_id bigint primary key not null,
crc_id bigint,
inspection_id  bigint,
school_id  bigint ,
latitude  double precision,
longitude  double precision,
in_school_location  boolean,
year int,
month int,
ff_uuid text,
created_on  TIMESTAMP without time zone, 
updated_on  TIMESTAMP without time zone
-- ,foreign key (school_id) references school_hierarchy_details(school_id),
-- foreign key (inspection_id) references crc_inspection_trans(crc_inspection_id)
);


alter table crc_inspection_temp add column IF NOT EXISTS visit_date date;

alter table crc_visits_frequency add column if not exists school_management_type varchar(100);
alter table crc_visits_frequency add column if not exists school_category varchar(100);

drop view if exists crc_trans_to_aggregate cascade;

alter table crc_loc_null_col add column if not exists  count_null_userlocmasterid int;
alter table crc_loc_null_col add column if not exists count_null_usermasterid int;

alter table crc_inspec_null_col add column if not exists count_null_observerid int;

alter table crc_inspec_null_col add column if not exists count_of_null_rows int;
alter table crc_loc_null_col add column if not exists count_of_null_rows int;

