
/* teacher_hierarchy_details */

create table if not exists teacher_hierarchy_details
  (
    teacher_id bigint primary key not null,
    school_id bigint,
    year int,
    teacher_designation varchar(100),
    nature_of_employment varchar(50),
    date_of_joining date,
    created_on TIMESTAMP without time zone,
    updated_on TIMESTAMP without time zone
    -- ,foreign key (school_id) references school_hierarchy_details(school_id)
    );

create index if not exists teacher_hierarchy_details_id on teacher_hierarchy_details(school_id,nature_of_employment);

/*teacher_attendance_trans*/

create table if not exists teacher_attendance_trans
(
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone,
primary key(school_id,month,teacher_id,year)
);

alter table teacher_attendance_trans drop column if exists attendance_id;
alter table teacher_attendance_trans drop constraint if exists teacher_attendance_trans_pkey;
alter table teacher_attendance_trans add primary key(school_id,month,teacher_id,year);

create table if not exists teacher_attendance_temp
(
ff_uuid text,
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
created_on timestamp without time zone,
updated_on timestamp without time zone
);

create table if not exists teacher_attendance_dup
(
ff_uuid text,
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
created_on timestamp without time zone,
updated_on timestamp without time zone
);


create table if not exists teacher_attendance_staging_1
(
ff_uuid text,
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
created_on timestamp without time zone,
updated_on timestamp without time zone
);

create table if not exists teacher_attendance_staging_2
(
ff_uuid text,
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
created_on timestamp without time zone,
updated_on timestamp without time zone
);

/*school_teacher_total_attendance*/

create table if not exists school_teacher_total_attendance
(
id  serial,
year  int,
month  smallint,
school_id  bigint,
school_name varchar(200),
school_latitude  double precision,
school_longitude  double precision,
district_id  bigint,
district_name varchar(100),
district_latitude  double precision,
district_longitude  double precision,
block_id  bigint,
block_name varchar(100),
brc_name varchar(100),
block_latitude  double precision,
block_longitude  double precision,
cluster_id  bigint,
cluster_name varchar(100),
crc_name varchar(100),
cluster_latitude  double precision,
cluster_longitude  double precision,
total_present  double precision,
total_working_days  int,
teachers_count bigint,
created_on  TIMESTAMP without time zone ,   
updated_on  TIMESTAMP without time zone,
primary key(school_id,month,year)
);


alter table school_teacher_total_attendance add column if not exists school_management_type varchar(100);
alter table school_teacher_total_attendance add column if not exists school_category varchar(100);

create index if not exists school_teacher_total_attendance_id on school_teacher_total_attendance(month,school_id,block_id,cluster_id);

Drop view if exists teacher_attendance_exception_data cascade;

drop view if exists teacher_attendance_agg_last_1_day cascade;
drop view if exists teacher_attendance_agg_last_30_days cascade;
drop view if exists teacher_attendance_agg_last_7_days cascade;
drop view if exists teacher_attendance_agg_overall cascade;


alter table school_teacher_total_attendance drop constraint if exists school_teacher_total_attendance_pkey;
alter table school_teacher_total_attendance add primary key(school_id,month,year);
alter table school_teacher_total_attendance drop COLUMN if exists total_training;
alter table school_teacher_total_attendance drop COLUMN if exists total_halfday;
alter table school_teacher_total_attendance alter COLUMN total_present type double precision;



create table if not exists teacher_attendance_dup
(
teacher_id  bigint,
school_id  bigint,
year  int,
month  int,
day_1  smallint,
day_2  smallint,
day_3  smallint,
day_4  smallint,
day_5  smallint,
day_6  smallint,
day_7  smallint,
day_8  smallint,
day_9  smallint,
day_10  smallint,
day_11  smallint,
day_12  smallint,
day_13  smallint,
day_14  smallint,
day_15  smallint,
day_16  smallint,
day_17  smallint,
day_18  smallint,
day_19  smallint,
day_20  smallint,
day_21  smallint,
day_22  smallint,
day_23  smallint,
day_24  smallint,
day_25  smallint,
day_26  smallint,
day_27  smallint,
day_28  smallint,
day_29  smallint,
day_30  smallint,
day_31  smallint,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process timestamp default current_timestamp
);

create table if not exists tch_att_null_col (filename text,ff_uuid text,count_null_teacherid int,
  count_null_schoolid int, count_null_AcademicYear int,count_null_Month int, created_on TIMESTAMP without time zone);

create table IF NOT EXISTS teacher_attendance_meta
(
day_1 boolean,day_2 boolean,day_3 boolean,day_4 boolean,day_5 boolean,day_6 boolean,day_7 boolean,day_8 boolean,day_9 boolean,day_10 boolean,
day_11 boolean,day_12 boolean,day_13 boolean,day_14 boolean,day_15 boolean,day_16 boolean,day_17 boolean,day_18 boolean,day_19 boolean,day_20 boolean,
day_21 boolean,day_22 boolean,day_23 boolean,day_24 boolean,day_25 boolean,day_26 boolean,day_27 boolean,day_28 boolean,day_29 boolean,day_30 boolean,
day_31 boolean,month int,year int,primary key(month,year)
);

CREATE OR REPLACE FUNCTION teacher_attendance_refresh(year int,month int)
RETURNS text AS
$$
DECLARE
_col_sql text :='select string_agg(column_name,'','') from (select ''day_1'' as column_name from teacher_attendance_meta where day_1 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_2'' as column_name from teacher_attendance_meta where day_2 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_3'' as column_name from teacher_attendance_meta where day_3 = True and month= '||month||' and year = '||year||' 
UNION 
select ''day_4'' as column_name from teacher_attendance_meta where day_4 = True and month= '||month||' and year = '||year||' 
UNION 
select ''day_5'' as column_name from teacher_attendance_meta where day_5 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_6'' as column_name from teacher_attendance_meta where day_6 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_7'' as column_name from teacher_attendance_meta where day_7 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_8'' as column_name from teacher_attendance_meta where day_8 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_9'' as column_name from teacher_attendance_meta where day_9 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_10'' as column_name from teacher_attendance_meta where day_10 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_11'' as column_name from teacher_attendance_meta where day_11 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_12'' as column_name from teacher_attendance_meta where day_12 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_13'' as column_name from teacher_attendance_meta where day_13 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_14'' as column_name from teacher_attendance_meta where day_14 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_15'' as column_name from teacher_attendance_meta where day_15 = True and month= '||month||' and year = '||year||' 
UNION 
select ''day_16'' as column_name from teacher_attendance_meta where day_16 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_17'' as column_name from teacher_attendance_meta where day_17 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_18'' as column_name from teacher_attendance_meta where day_18 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_19'' as column_name from teacher_attendance_meta where day_19 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_20'' as column_name from teacher_attendance_meta where day_20 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_21'' as column_name from teacher_attendance_meta where day_21 = True and month=  '||month||' and year = '||year||'
UNION 
select ''day_22'' as column_name from teacher_attendance_meta where day_22 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_23'' as column_name from teacher_attendance_meta where day_23 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_24'' as column_name from teacher_attendance_meta where day_24 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_25'' as column_name from teacher_attendance_meta where day_25 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_26'' as column_name from teacher_attendance_meta where day_26 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_27'' as column_name from teacher_attendance_meta where day_27 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_28'' as column_name from teacher_attendance_meta where day_28 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_29'' as column_name from teacher_attendance_meta where day_29 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_30'' as column_name from teacher_attendance_meta where day_30 = True and month= '||month||' and year = '||year||'
UNION 
select ''day_31'' as column_name from teacher_attendance_meta where day_31 = True and month= '||month||' and year = '||year||') as col_tab;';

_column text :='';
_sql text:='';

_start_date text:='select (cast('||year||' as varchar)'||'||'||'''-'''||'||'||'cast('||month||' as varchar)'||'||'||'''-01'''||')::date';
start_date date;
l_query text;
r_query text;
c_query text;
d_query text;
res text;
u_query text;
m_query text;
update_query text;
_cols text:='select string_agg(days_to_be_processed'||'||''  ''||'''||'boolean'''||','','') from teacher_attendance_meta_temp where month='||month||' and year='||year;
col_name text;
d_meta text;
us_query text;
cnt_query text;
_count int;
rec_query text;
rec_exists boolean;
error_msg text;
validation text;
validation_res boolean;
BEGIN
validation:='select case when '||year||'>date_part(''year'',CURRENT_DATE) then True ELSE case when '||year||'=date_part(''year'',CURRENT_DATE) and '||month||'>date_part(''month'',CURRENT_DATE) then True else false END END';
EXECUTE validation into validation_res;
IF validation_res=True THEN
    return 'Data emitted is future data - it has the data for month '||month||' and year '||year||'';
END IF;

cnt_query:='select count(*) from teacher_attendance_meta where month='||month||' and year='||year;
rec_query:='select EXISTS(select 1 from teacher_attendance_temp where month= '||month||' and year = '||year||')';
EXECUTE rec_query into rec_exists;
EXECUTE cnt_query into _count;
IF rec_exists=False THEN
error_msg:='teacher_attendance_temp table has no records for the month '||month||' and year '||year;  
RAISE log 'teacher_attendance_temp table has no records for the month % and year %',month,year;
return error_msg;
END IF;
IF _count = 0 THEN  
   EXECUTE 'INSERT INTO teacher_attendance_meta(month,year) values('||month||','||year||')';
END IF;

EXECUTE _start_date into start_date;

l_query:='select '||'days_in_a_month.day '||'as processed_date'||','||month||'as month'||','||year||'as year'||', '||'''day_'''||'||'||'date_part('||'''day'''||',days_in_a_month.day) as days_to_be_processed,True as to_run from (select (generate_series('''||start_date||'''::date,('''||start_date||'''::date+'||'''1month'''||'::interval-'||'''1day'''||'::interval)::date,'||'''1day'''||'::interval)::date) as day) as days_in_a_month';

d_query:='drop table if exists teacher_attendance_meta_temp';

EXECUTE d_query;

c_query:='create table if not exists teacher_attendance_meta_temp as '||l_query;


EXECUTE c_query;


m_query:='update teacher_attendance_meta_temp set to_run=False where (extract(dow from processed_date)=0 and month='||month||' and year='||year||')';
update_query:='update teacher_attendance_meta_temp set to_run=False where (processed_date>CURRENT_DATE and month='||month||' and year='||year||')';
EXECUTE m_query;
EXECUTE update_query;
EXECUTE _cols into col_name;
d_meta:='drop table if exists teacher_attendance_meta_stg';
EXECUTE d_meta;
res :='create table if not exists teacher_attendance_meta_stg as select * from crosstab('''||'select month,year,days_to_be_processed,to_run from teacher_attendance_meta_temp order by 1,2'||''','''||'select days_to_be_processed from teacher_attendance_meta_temp'||''') as t('||'month int,year int,'||col_name||')';

EXECUTE res;

u_query:='UPDATE teacher_attendance_meta sam
     set day_1 = CASE WHEN day_1 = False THEN
    False
    ELSE (select day_1 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_2 = CASE WHEN day_2 = False THEN
    False
    ELSE (select day_2 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_3 = CASE WHEN day_3 = False THEN
    False
    ELSE (select day_3 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_4 = CASE WHEN day_4 = False THEN
    False
    ELSE (select day_4 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_5 = CASE WHEN day_5 = False THEN
    False
    ELSE (select day_5 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_6 = CASE WHEN day_6 = False THEN
    False
    ELSE (select day_6 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_7 = CASE WHEN day_7 = False THEN
    False
    ELSE (select day_7 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_8 = CASE WHEN day_8 = False THEN
    False
    ELSE (select day_8 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_9 = CASE WHEN day_9 = False THEN
    False
    ELSE (select day_9 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
    ,day_10 = CASE WHEN day_10 = False THEN
    False
    ELSE (select day_10 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
    ,day_11 = CASE WHEN day_11 = False THEN
    False
    ELSE (select day_11 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_12 = CASE WHEN day_12 = False THEN
    False
    ELSE (select day_12 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_13 = CASE WHEN day_13 = False THEN
    False
    ELSE (select day_13 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_14 = CASE WHEN day_14 = False THEN
    False
    ELSE (select day_14 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_15 = CASE WHEN day_15 = False THEN
    False
    ELSE (select day_15 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_16 = CASE WHEN day_16 = False THEN
    False
    ELSE (select day_16 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_17 = CASE WHEN day_17 = False THEN
    False
    ELSE (select day_17 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_18 = CASE WHEN day_18 = False THEN
    False
    ELSE (select day_18 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_19 = CASE WHEN day_19 = False THEN
    False
    ELSE (select day_19 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
    ,day_20 = CASE WHEN day_20 = False THEN
    False
    ELSE (select day_20 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
    ,day_21 = CASE WHEN day_21 = False THEN
    False
    ELSE (select day_21 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_22 = CASE WHEN day_22 = False THEN
    False
    ELSE (select day_22 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_23 = CASE WHEN day_23 = False THEN
    False
    ELSE (select day_23 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_24 = CASE WHEN day_24 = False THEN
    False
    ELSE (select day_24 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_25 = CASE WHEN day_25 = False THEN
    False
    ELSE (select day_25 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_26 = CASE WHEN day_26 = False THEN
    False
    ELSE (select day_26 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_27 = CASE WHEN day_27 = False THEN
    False
    ELSE (select day_27 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_28 = CASE WHEN day_28 = False THEN
    False
    ELSE (select day_28 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_29 = CASE WHEN day_29 = False THEN
    False
    ELSE (select day_29 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_30 = CASE WHEN day_30 = False THEN
    False
    ELSE (select day_30 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
   ,day_31 = CASE WHEN day_31 = False THEN
    False
    ELSE (select day_31 from teacher_attendance_meta_stg where month='||month||' and year='||year||')
  END
  where 
   month = '||month||' and
   year = '||year;

EXECUTE u_query;
EXECUTE _col_sql into _column;

_sql :=
      'WITH s AS (select * from teacher_attendance_temp where teacher_attendance_temp.month='||month||'
 and teacher_attendance_temp.year='||year||'),
upd AS (
UPDATE teacher_attendance_trans
     set day_1 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_1 = True and month='||month||' and year='||year||') THEN
   s.day_1
   ELSE teacher_attendance_trans.day_1
  END
  ,day_2 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_2 = True and month='||month||' and year='||year||') THEN
   s.day_2
   ELSE teacher_attendance_trans.day_2
  END
  ,day_3 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_3 = True and month='||month||' and year='||year||') THEN
   s.day_3
   ELSE teacher_attendance_trans.day_3
  END
  ,day_4 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_4 = True and month='||month||' and year='||year||') THEN
   s.day_4
   ELSE teacher_attendance_trans.day_4
  END
  ,day_5 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_5 = True and month='||month||' and year='||year||') THEN
   s.day_5
   ELSE teacher_attendance_trans.day_5
  END
  ,day_6 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_6 = True and month='||month||' and year='||year||') THEN
   s.day_6
   ELSE teacher_attendance_trans.day_6
  END
  ,day_7 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_7 = True and month='||month||' and year='||year||') THEN
   s.day_7
   ELSE teacher_attendance_trans.day_7
  END
  ,day_8 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_8 = True and month='||month||' and year='||year||') THEN
   s.day_8
   ELSE teacher_attendance_trans.day_8
  END
  ,day_9 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_9 = True and month='||month||' and year='||year||') THEN
   s.day_9
   ELSE teacher_attendance_trans.day_9
  END
  ,day_10 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_10 = True and month='||month||' and year='||year||') THEN
   s.day_10
   ELSE teacher_attendance_trans.day_10
  END
  ,day_11 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_11 = True and month='||month||' and year='||year||') THEN
   s.day_11
   ELSE teacher_attendance_trans.day_11
  END
  ,day_12 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_12 = True and month='||month||' and year='||year||') THEN
   s.day_12
   ELSE teacher_attendance_trans.day_12
  END
  ,day_13 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_13 = True and month='||month||' and year='||year||') THEN
   s.day_13
   ELSE teacher_attendance_trans.day_13
  END
  ,day_14 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_14 = True and month='||month||' and year='||year||') THEN
   s.day_4
   ELSE teacher_attendance_trans.day_14
  END
  ,day_15 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_15 = True and month='||month||' and year='||year||') THEN
   s.day_15
   ELSE teacher_attendance_trans.day_15
  END
  ,day_16 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_16 = True and month='||month||' and year='||year||') THEN
   s.day_16
   ELSE teacher_attendance_trans.day_16
  END
  ,day_17 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_17 = True and month='||month||' and year='||year||') THEN
   s.day_17
   ELSE teacher_attendance_trans.day_17
  END
  ,day_18 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_18 = True and month='||month||' and year='||year||') THEN
   s.day_18
   ELSE teacher_attendance_trans.day_18
  END
  ,day_19 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_19 = True and month='||month||' and year='||year||') THEN
   s.day_19
   ELSE teacher_attendance_trans.day_19
  END
  ,day_20 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_20 = True and month='||month||' and year='||year||') THEN
   s.day_20
   ELSE teacher_attendance_trans.day_20
  END
  ,day_21 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_21 = True and month='||month||' and year='||year||') THEN
   s.day_21
   ELSE teacher_attendance_trans.day_21
  END
  ,day_22 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_22 = True and month='||month||' and year='||year||') THEN
   s.day_22
   ELSE teacher_attendance_trans.day_22
  END
  ,day_23 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_23 = True and month='||month||' and year='||year||') THEN
   s.day_23
   ELSE teacher_attendance_trans.day_23
  END
  ,day_24 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_24 = True and month='||month||' and year='||year||') THEN
   s.day_24
   ELSE teacher_attendance_trans.day_24
  END
  ,day_25 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_25 = True and month='||month||' and year='||year||') THEN
   s.day_25
   ELSE teacher_attendance_trans.day_25
  END
  ,day_26 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_26 = True and month='||month||' and year='||year||') THEN
   s.day_26
   ELSE teacher_attendance_trans.day_26
  END
  ,day_27 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_27 = True and month='||month||' and year='||year||') THEN
   s.day_27
   ELSE teacher_attendance_trans.day_27
  END
  ,day_28 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_28 = True and month='||month||' and year='||year||') THEN
   s.day_28
   ELSE teacher_attendance_trans.day_28
  END
  ,day_29 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_29 = True and month='||month||' and year='||year||') THEN
   s.day_29
   ELSE teacher_attendance_trans.day_29
  END
  ,day_30 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_30 = True and month='||month||' and year='||year||') THEN
   s.day_30
   ELSE teacher_attendance_trans.day_30
  END
  ,day_31 = CASE WHEN EXISTS (select 1 from teacher_attendance_meta where day_31 = True and month='||month||' and year='||year||') THEN
   s.day_31
   ELSE teacher_attendance_trans.day_31
  END
     FROM   s
     WHERE  teacher_attendance_trans.teacher_id = s.teacher_id
        and teacher_attendance_trans.month='||month||'
 and teacher_attendance_trans.year='||year||'
     RETURNING teacher_attendance_trans.teacher_id
) INSERT INTO teacher_attendance_trans(teacher_id,school_id,year,month,'||_column||',created_on,updated_on)
       select s.teacher_id,s.school_id,s.year,s.month,'||_column ||',created_on,updated_on
       from s
       where s.teacher_id not in (select teacher_id from upd)';

us_query := 'UPDATE teacher_attendance_meta sam
     set day_1 = CASE WHEN day_1 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_1 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_1
  END
   ,day_2 = CASE WHEN day_2 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_2 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_2
  END
   ,day_3 = CASE WHEN day_3 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_3 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_3
  END
   ,day_4 = CASE WHEN day_4 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_4 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_4
  END
   ,day_5 = CASE WHEN day_5 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_5 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_5
  END
   ,day_6 = CASE WHEN day_6 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_6 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_6
  END
   ,day_7 = CASE WHEN day_7 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_7 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_7
  END
   ,day_8 = CASE WHEN day_8 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_8 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_8
  END
   ,day_9 = CASE WHEN day_9 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_9 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_9
  END
    ,day_10 = CASE WHEN day_10 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_10 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_10
  END
    ,day_11 = CASE WHEN day_11 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_11 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_11
  END
   ,day_12 = CASE WHEN day_12 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_12 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_12
  END
   ,day_13 = CASE WHEN day_13 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_13 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_13
  END
   ,day_14 = CASE WHEN day_14 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_14 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_14
  END
   ,day_15 = CASE WHEN day_15 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_15 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_15
  END
   ,day_16 = CASE WHEN day_16 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_16 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_16
  END
   ,day_17 = CASE WHEN day_17 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_17 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_17
  END
   ,day_18 = CASE WHEN day_18 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_18 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_18
  END
   ,day_19 = CASE WHEN day_19 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_19 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_19
  END
    ,day_20 = CASE WHEN day_20 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_20 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_20
  END
    ,day_21 = CASE WHEN day_21 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_21 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_21
  END
   ,day_22 = CASE WHEN day_22 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_22 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_22
  END
   ,day_23 = CASE WHEN day_23 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_23 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_23
  END
   ,day_24 = CASE WHEN day_24 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_24 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_24
  END
   ,day_25 = CASE WHEN day_25 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_25 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_25
  END
   ,day_26 = CASE WHEN day_26 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_26 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_26
  END
   ,day_27 = CASE WHEN day_27 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_27 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_27
  END
   ,day_28 = CASE WHEN day_28 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_28 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_28
  END
   ,day_29 = CASE WHEN day_29 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_29 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_29
  END
   ,day_30 = CASE WHEN day_30 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_30 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_30
  END
   ,day_31 = CASE WHEN day_31 = False THEN
    False
    WHEN EXISTS (select 1 from teacher_attendance_trans where day_31 is not null and month='||month||' and year='||year||' limit 1) THEN
   False
   ELSE sam.day_31
  END
  where 
   month = '||month||' and
   year = '||year;

   IF _column <> '' THEN  
 EXECUTE _sql;
 EXECUTE us_query;
   END IF;


return 0;
END;
$$  LANGUAGE plpgsql;

/* Exception tables */
create table if not exists teacher_attendance_exception_agg
  (
	    school_id bigint,
	    year int,
	    month int,
	    school_name varchar(300),
	    block_id bigint,
	    block_name varchar(100),
	    district_id bigint,
	    district_name varchar(100),
	    cluster_id bigint,
	    cluster_name varchar(100),
	school_latitude  double precision,
	school_longitude  double precision,
	district_latitude  double precision,
	district_longitude  double precision,
	block_latitude  double precision,
	block_longitude  double precision,
	cluster_latitude  double precision,
	cluster_longitude  double precision,
	created_on TIMESTAMP without time zone,
	updated_on TIMESTAMP without time zone,
primary key(school_id,month,year));

alter table teacher_attendance_exception_agg add column if not exists school_management_type varchar(100);
alter table teacher_attendance_exception_agg add column if not exists school_category varchar(100);

alter table tch_att_null_col add column if not exists count_of_null_rows int;
