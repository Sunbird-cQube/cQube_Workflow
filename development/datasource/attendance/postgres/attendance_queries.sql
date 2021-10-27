/* drop view statements */

drop view if exists student_attendance_exception_data cascade;
drop view if exists student_attendance_exception_data_lastday cascade;
drop view if exists student_attendance_exception_data_last7 cascade;
drop view if exists student_attendance_exception_data_last30 cascade;
drop view if exists student_attendance_exception_data_overall cascade;
drop view if exists hc_student_attendance_state_mgmt_overall cascade;
drop view if exists hc_student_attendance_state_mgmt_last30 cascade;


create or replace function drop_view_attendance()
returns int as
$body$
begin
drop view if exists student_attendance_agg_last_1_day,student_attendance_agg_last_7_days,student_attendance_agg_last_30_days cascade;
return 1;
    exception 
    when others then
        return 0;
end;
$body$
language plpgsql;

select drop_view_attendance();

create or replace function drop_stud_mv()
returns int as
$body$
begin

drop materialized view if exists student_attendance_agg_last_1_day,student_attendance_agg_last_7_days,student_attendance_agg_last_30_days cascade;

  return 0;

    exception 
    when others then
        return 0;

end;
$body$
language plpgsql;

select drop_stud_mv();

/* Function to calculate Student attendance - Time series */

CREATE OR REPLACE FUNCTION student_attendance_agg_refresh(period text)
RETURNS text AS
$$
DECLARE
_col_sql text;
_query_res text;
two_month_query text;
cnt_query text;
_count int;
month int;
year int;
min_month int;
min_year int;
max_month int;
max_year int;
filter_query text;
max_filter_query text;
min_filter_query text;
_group_query text;
min_total_present text;
min_total_students text;
max_total_present text;
max_total_students text;
total_present text;
total_students text;
number_of_days text;
one_month_query text;
BEGIN
two_month_query:='select school_id,month,year,
sum(case when day_1 =1 then 1 else 0 end) as day_1_total_present,
sum(case when day_1 in (1,2) then 1 else 0 end) as day_1_total_students,
sum(case when day_2 =1 then 1 else 0 end) as day_2_total_present,
sum(case when day_2 in (1,2) then 1 else 0 end) as day_2_total_students, 
sum(case when day_3 =1 then 1 else 0 end) as day_3_total_present,
sum(case when day_3 in (1,2) then 1 else 0 end) as day_3_total_students,
sum(case when day_4 =1 then 1 else 0 end) as day_4_total_present,
sum(case when day_4 in (1,2) then 1 else 0 end) as day_4_total_students, 
sum(case when day_5 =1 then 1 else 0 end) as day_5_total_present,
sum(case when day_5 in (1,2) then 1 else 0 end) as day_5_total_students, 
sum(case when day_6 =1 then 1 else 0 end) as day_6_total_present,
sum(case when day_6 in (1,2) then 1 else 0 end) as day_6_total_students, 
sum(case when day_7 =1 then 1 else 0 end) as day_7_total_present,
sum(case when day_7 in (1,2) then 1 else 0 end) as day_7_total_students,
sum(case when day_8 =1 then 1 else 0 end) as day_8_total_present,
sum(case when day_8 in (1,2) then 1 else 0 end) as day_8_total_students, 
sum(case when day_9 =1 then 1 else 0 end) as day_9_total_present,
sum(case when day_9 in (1,2) then 1 else 0 end) as day_9_total_students,
sum(case when day_10 =1 then 1 else 0 end) as day_10_total_present,
sum(case when day_10 in (1,2) then 1 else 0 end) as day_10_total_students,
sum(case when day_11 =1 then 1 else 0 end) as day_11_total_present,
sum(case when day_11 in (1,2) then 1 else 0 end) as day_11_total_students, 
sum(case when day_12 =1 then 1 else 0 end) as day_12_total_present,
sum(case when day_12 in (1,2) then 1 else 0 end) as day_12_total_students,
sum(case when day_13 =1 then 1 else 0 end) as day_13_total_present,
sum(case when day_13 in (1,2) then 1 else 0 end) as day_13_total_students,
sum(case when day_14 =1 then 1 else 0 end) as day_14_total_present,
sum(case when day_14 in (1,2) then 1 else 0 end) as day_14_total_students,
sum(case when day_15 =1 then 1 else 0 end) as day_15_total_present,
sum(case when day_15 in (1,2) then 1 else 0 end) as day_15_total_students,
sum(case when day_16 =1 then 1 else 0 end) as day_16_total_present,
sum(case when day_16 in (1,2) then 1 else 0 end) as day_16_total_students,
sum(case when day_17 =1 then 1 else 0 end) as day_17_total_present,
sum(case when day_17 in (1,2) then 1 else 0 end) as day_17_total_students,
sum(case when day_18 =1 then 1 else 0 end) as day_18_total_present,
sum(case when day_18 in (1,2) then 1 else 0 end) as day_18_total_students,
sum(case when day_19 =1 then 1 else 0 end) as day_19_total_present,
sum(case when day_19 in (1,2) then 1 else 0 end) as day_19_total_students,
sum(case when day_20 =1 then 1 else 0 end) as day_20_total_present,
sum(case when day_20 in (1,2) then 1 else 0 end) as day_20_total_students,
sum(case when day_21 =1 then 1 else 0 end) as day_21_total_present,
sum(case when day_21 in (1,2) then 1 else 0 end) as day_21_total_students,
sum(case when day_22 =1 then 1 else 0 end) as day_22_total_present,
sum(case when day_22 in (1,2) then 1 else 0 end) as day_22_total_students,
sum(case when day_23 =1 then 1 else 0 end) as day_23_total_present,
sum(case when day_23 in (1,2) then 1 else 0 end) as day_23_total_students,
sum(case when day_24 =1 then 1 else 0 end) as day_24_total_present,
sum(case when day_24 in (1,2) then 1 else 0 end) as day_24_total_students,
sum(case when day_25 =1 then 1 else 0 end) as day_25_total_present,
sum(case when day_25 in (1,2) then 1 else 0 end) as day_25_total_students,
sum(case when day_26 =1 then 1 else 0 end) as day_26_total_present,
sum(case when day_26 in (1,2) then 1 else 0 end) as day_26_total_students,
sum(case when day_27 =1 then 1 else 0 end) as day_27_total_present,
sum(case when day_27 in (1,2) then 1 else 0 end) as day_27_total_students,
sum(case when day_28 =1 then 1 else 0 end) as day_28_total_present,
sum(case when day_28 in (1,2) then 1 else 0 end) as day_28_total_students,
sum(case when day_29 =1 then 1 else 0 end) as day_29_total_present,
sum(case when day_29 in (1,2) then 1 else 0 end) as day_29_total_students,
sum(case when day_30 =1 then 1 else 0 end) as day_30_total_present,
sum(case when day_30 in (1,2) then 1 else 0 end) as day_30_total_students,
sum(case when day_31 =1 then 1 else 0 end) as day_31_total_present,
sum(case when day_31 in (1,2) then 1 else 0 end) as day_31_total_students
from student_attendance_trans';
one_month_query:='select school_id,month,year,count(distinct student_id) as students_count,
sum(case when day_1 =1 then 1 else 0 end) as day_1_total_present,
sum(case when day_1 in (1,2) then 1 else 0 end) as day_1_total_students,
sum(case when day_2 =1 then 1 else 0 end) as day_2_total_present,
sum(case when day_2 in (1,2) then 1 else 0 end) as day_2_total_students, 
sum(case when day_3 =1 then 1 else 0 end) as day_3_total_present,
sum(case when day_3 in (1,2) then 1 else 0 end) as day_3_total_students,
sum(case when day_4 =1 then 1 else 0 end) as day_4_total_present,
sum(case when day_4 in (1,2) then 1 else 0 end) as day_4_total_students, 
sum(case when day_5 =1 then 1 else 0 end) as day_5_total_present,
sum(case when day_5 in (1,2) then 1 else 0 end) as day_5_total_students, 
sum(case when day_6 =1 then 1 else 0 end) as day_6_total_present,
sum(case when day_6 in (1,2) then 1 else 0 end) as day_6_total_students, 
sum(case when day_7 =1 then 1 else 0 end) as day_7_total_present,
sum(case when day_7 in (1,2) then 1 else 0 end) as day_7_total_students,
sum(case when day_8 =1 then 1 else 0 end) as day_8_total_present,
sum(case when day_8 in (1,2) then 1 else 0 end) as day_8_total_students, 
sum(case when day_9 =1 then 1 else 0 end) as day_9_total_present,
sum(case when day_9 in (1,2) then 1 else 0 end) as day_9_total_students,
sum(case when day_10 =1 then 1 else 0 end) as day_10_total_present,
sum(case when day_10 in (1,2) then 1 else 0 end) as day_10_total_students,
sum(case when day_11 =1 then 1 else 0 end) as day_11_total_present,
sum(case when day_11 in (1,2) then 1 else 0 end) as day_11_total_students, 
sum(case when day_12 =1 then 1 else 0 end) as day_12_total_present,
sum(case when day_12 in (1,2) then 1 else 0 end) as day_12_total_students,
sum(case when day_13 =1 then 1 else 0 end) as day_13_total_present,
sum(case when day_13 in (1,2) then 1 else 0 end) as day_13_total_students,
sum(case when day_14 =1 then 1 else 0 end) as day_14_total_present,
sum(case when day_14 in (1,2) then 1 else 0 end) as day_14_total_students,
sum(case when day_15 =1 then 1 else 0 end) as day_15_total_present,
sum(case when day_15 in (1,2) then 1 else 0 end) as day_15_total_students,
sum(case when day_16 =1 then 1 else 0 end) as day_16_total_present,
sum(case when day_16 in (1,2) then 1 else 0 end) as day_16_total_students,
sum(case when day_17 =1 then 1 else 0 end) as day_17_total_present,
sum(case when day_17 in (1,2) then 1 else 0 end) as day_17_total_students,
sum(case when day_18 =1 then 1 else 0 end) as day_18_total_present,
sum(case when day_18 in (1,2) then 1 else 0 end) as day_18_total_students,
sum(case when day_19 =1 then 1 else 0 end) as day_19_total_present,
sum(case when day_19 in (1,2) then 1 else 0 end) as day_19_total_students,
sum(case when day_20 =1 then 1 else 0 end) as day_20_total_present,
sum(case when day_20 in (1,2) then 1 else 0 end) as day_20_total_students,
sum(case when day_21 =1 then 1 else 0 end) as day_21_total_present,
sum(case when day_21 in (1,2) then 1 else 0 end) as day_21_total_students,
sum(case when day_22 =1 then 1 else 0 end) as day_22_total_present,
sum(case when day_22 in (1,2) then 1 else 0 end) as day_22_total_students,
sum(case when day_23 =1 then 1 else 0 end) as day_23_total_present,
sum(case when day_23 in (1,2) then 1 else 0 end) as day_23_total_students,
sum(case when day_24 =1 then 1 else 0 end) as day_24_total_present,
sum(case when day_24 in (1,2) then 1 else 0 end) as day_24_total_students,
sum(case when day_25 =1 then 1 else 0 end) as day_25_total_present,
sum(case when day_25 in (1,2) then 1 else 0 end) as day_25_total_students,
sum(case when day_26 =1 then 1 else 0 end) as day_26_total_present,
sum(case when day_26 in (1,2) then 1 else 0 end) as day_26_total_students,
sum(case when day_27 =1 then 1 else 0 end) as day_27_total_present,
sum(case when day_27 in (1,2) then 1 else 0 end) as day_27_total_students,
sum(case when day_28 =1 then 1 else 0 end) as day_28_total_present,
sum(case when day_28 in (1,2) then 1 else 0 end) as day_28_total_students,
sum(case when day_29 =1 then 1 else 0 end) as day_29_total_present,
sum(case when day_29 in (1,2) then 1 else 0 end) as day_29_total_students,
sum(case when day_30 =1 then 1 else 0 end) as day_30_total_present,
sum(case when day_30 in (1,2) then 1 else 0 end) as day_30_total_students,
sum(case when day_31 =1 then 1 else 0 end) as day_31_total_present,
sum(case when day_31 in (1,2) then 1 else 0 end) as day_31_total_students
from student_attendance_trans';
_group_query:='group by month,year,school_id';

IF period='last_1_day' THEN
number_of_days:='1day';
ELSE IF period='last_7_days' THEN
number_of_days:='7day';
ELSE IF period='last_30_days' THEN
number_of_days:='30day';
ELSE
return 0;
END IF;
END IF;
END IF;

cnt_query:='select count(distinct extract(month from days_in_period.day)) as cnt from (select (generate_series(now()::date-'''||number_of_days||'''::interval,(now()::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period';

EXECUTE cnt_query into _count;

IF _count > 1 THEN
select min(extract(month from min_day)) as min_month , min(extract(year from min_day)) as min_year , max(extract(month from max_day)) as max_month , 
max(extract(year from max_day)) as max_year from (select min(days_in_period.day) min_day ,max(days_in_period.day) max_day into min_month, min_year, max_month, max_year 
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period) as days_in_period;

max_filter_query:='where month='||max_month||' and year='||max_year;
min_filter_query:='where month='||min_month||' and year='||min_year;

select string_agg('day_'||date_part('day',days_in_period.day)||'_total_present','+') as total_present, 
string_agg('day_'||date_part('day',days_in_period.day)||'_total_students','+') as total_students into max_total_present,max_total_students
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day) =max_month 
and extract(year from days_in_period.day) =max_year;

select string_agg('day_'||date_part('day',days_in_period.day)||'_total_present','+') as max_total_present, 
string_agg('day_'||date_part('day',days_in_period.day)||'_total_students','+') as max_total_students into min_total_present,min_total_students
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day)=min_month 
and extract(year from days_in_period.day)=min_year;

_query_res:='create or replace view student_attendance_agg_'||period||' as 
select sch_res.school_id,cast(sch_res.total_present as bigint),cast(sch_res.total_students as bigint),cast(stn_cnt.students_count as bigint),
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category
from (
select school_id,sum(total_present) as total_present,sum(total_students) as total_students from 
(select school_id,'||max_total_present||' as total_present,'||max_total_students||' as total_students'||' from ('||two_month_query||' '||max_filter_query||' '||_group_query||') as max_temp
union all
select school_id,'||min_total_present||' as total_present,'||min_total_students||' as total_students'||' from ('||two_month_query||' '||min_filter_query||' '||_group_query||') as min_temp) as total_att 
group by school_id) sch_res inner join
(select a.school_id,a.school_name,b.school_latitude,b.school_longitude,a.cluster_id,a.cluster_name,b.cluster_latitude,b.cluster_longitude,
a.block_id,a.block_name,b.block_latitude,b.block_longitude,a.district_id,a.district_name,b.district_latitude,b.district_longitude,a.school_management_type,a.school_category
from school_hierarchy_details as a inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_name is not null and a.cluster_name is not null and b.school_latitude>0 and b.school_longitude>0 and b.cluster_latitude>0 and b.cluster_longitude>0
)as b on b.school_id=sch_res.school_id
left join (select school_id,count(distinct student_id) as students_count from student_attendance_trans where (month='||min_month||' and year='||min_year||') or (month='||max_month||' and year='||max_year||') group by school_id) as stn_cnt
on b.school_id=stn_cnt.school_id';

EXECUTE _query_res;
ELSE IF _count =1 THEN
select distinct extract(month from days_in_period.day) as month,extract(year from days_in_period.day) as year into month,year from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period;

filter_query:='where month='||month||' and year='||year;

select string_agg('day_'||date_part('day',days_in_period.day)||'_total_present','+') as total_present, 
string_agg('day_'||date_part('day',days_in_period.day)||'_total_students','+') as total_students into total_present, total_students
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day)=month 
and extract(year from days_in_period.day)=year;

_query_res:='create or replace view student_attendance_agg_'||period||' as 
select sch_res.school_id,cast(sch_res.total_present as bigint),cast(sch_res.total_students as bigint),cast(sch_res.students_count as bigint),
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category
   from (
select school_id,'||total_present||' as total_present,'||total_students||' as total_students'||',students_count from ('||one_month_query||' '||filter_query||' '||_group_query||') as att ) as sch_res
   inner join
(select a.school_id,a.school_name,b.school_latitude,b.school_longitude,a.cluster_id,a.cluster_name,b.cluster_latitude,b.cluster_longitude,
a.block_id,a.block_name,b.block_latitude,b.block_longitude,a.district_id,a.district_name,b.district_latitude,b.district_longitude,a.school_management_type,a.school_category
from school_hierarchy_details as a inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_name is not null and a.cluster_name is not null and b.school_latitude>0 and b.school_longitude>0 and b.cluster_latitude>0 and b.cluster_longitude>0
)as b on b.school_id=sch_res.school_id';
EXECUTE _query_res;
ELSE
   return 0;
END IF;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

select student_attendance_agg_refresh('last_1_day');
select student_attendance_agg_refresh('last_7_days');
select student_attendance_agg_refresh('last_30_days');

/* Student attendance - overall */
create materialized view if not exists student_attendance_agg_overall as 
(select sch_res.school_id,sch_res.total_present,sch_res.total_students,stn_cnt.students_count,
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date, 
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
from 
(select school_id ,sum(total_present) as total_present,sum(total_working_days) as total_students from school_student_total_attendance  group by school_id) as sch_res
   inner join
(select a.school_id,a.school_name,b.school_latitude,b.school_longitude,a.cluster_id,a.cluster_name,b.cluster_latitude,b.cluster_longitude,
a.block_id,a.block_name,b.block_latitude,b.block_longitude,a.district_id,a.district_name,b.district_latitude,b.district_longitude,a.school_management_type,a.school_category
from school_hierarchy_details as a inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_name is not null and a.cluster_name is not null and b.school_latitude>0 and b.school_longitude>0 and b.cluster_latitude>0 and b.cluster_longitude>0
)as b on b.school_id=sch_res.school_id
left join (select school_id,count(distinct student_id) as students_count from student_attendance_trans group by school_id) as stn_cnt
on b.school_id=stn_cnt.school_id) WITH NO DATA;

/* Student attendance Exception */

create or replace FUNCTION student_attendance_no_schools(month int,year int)
RETURNS text AS
$$
DECLARE
student_attendance_no_schools text;
BEGIN
student_attendance_no_schools = 'create or replace view student_attendance_exception_data as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,'|| month ||' as month,'|| year ||' as year,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_id!=9999 AND a.school_id not in 
(select distinct e.x_axis as school_id from (
SELECT school_id AS x_axis,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,INITCAP(crc_name)AS crc_name, 
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS x_value,''latitude'' AS y_axis,school_latitude AS y_value,''longitude'' AS z_axis,school_longitude AS z_value,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select Data_from_date(Min(year),min(month)) from school_student_total_attendance where year = (select min(year) from school_student_total_attendance) group by year), 
  (select Data_upto_date(Max(year),max(month)) from school_student_total_attendance where year = (select max(year) from school_student_total_attendance) group by year),
year,month 
FROM school_student_total_attendance WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND month = '|| month ||' AND year = '|| year ||'
AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0 
GROUP BY school_id,school_name,crc_name,school_latitude,school_longitude,year,month,cluster_id,cluster_name,crc_name,block_id,block_name,district_id,district_name,year,month,school_management_type)as e)
and cluster_name is not null';
Execute student_attendance_no_schools;
return 0;
END;
$$LANGUAGE plpgsql;


/* Student attendance exception timeseries */

create or replace FUNCTION student_attendance_no_schools_timeseries()
RETURNS text AS
$$
DECLARE
student_attendance_no_schools_overall text;
student_attendance_no_schools_lastday text;
student_attendance_no_schools_last7 text;
student_attendance_no_schools_last30 text;
BEGIN
student_attendance_no_schools_lastday = 'create or replace view student_attendance_exception_data_lastday as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id!=9999 AND  a.school_id not in(select distinct e.x_axis as school_id from
 (SELECT school_id AS x_axis,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,school_management_type,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS x_value,''latitude'' AS y_axis,school_latitude AS y_value,''longitude'' AS z_axis,school_longitude AS z_value,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from 
(select (generate_series(''now()''::date-''1days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from 
(select (generate_series(''now()''::date-''1days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_1_day WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0  
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type
)as e) and cluster_name is not null';

student_attendance_no_schools_last7 = 'create or replace view student_attendance_exception_data_last7 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id!=9999 AND a.school_management_type is not null and 
 a.school_id not in(select distinct e.x_axis as school_id from (SELECT school_id AS x_axis,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,school_management_type,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS x_value,''latitude'' AS y_axis,school_latitude AS y_value,''longitude'' AS z_axis,school_longitude AS z_value,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-''7days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-''7days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_7_days WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type
)as e) and cluster_name is not null';

student_attendance_no_schools_last30 = 'create or replace view student_attendance_exception_data_last30 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id!=9999 and a.school_management_type is not null AND a.school_id not in(select distinct e.x_axis as school_id from (SELECT school_id AS x_axis,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS x_value,''latitude'' AS y_axis,school_latitude AS y_value,''longitude'' AS z_axis,school_longitude AS z_value,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-''30days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-''30days''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type
)as e) and cluster_name is not null';

student_attendance_no_schools_overall = 'create or replace view student_attendance_exception_data_overall as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id and a.school_management_type is not null
where a.school_id!=9999 AND a.school_id not in(select distinct e.x_axis as school_id from (SELECT school_id AS x_axis,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,school_management_type,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS x_value,''latitude'' AS y_axis,school_latitude AS y_value,''longitude'' AS z_axis,school_longitude AS z_value,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),''DD-MM-YYYY'')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type
)as e) and cluster_name is not null';
Execute student_attendance_no_schools_lastday;
Execute student_attendance_no_schools_last7;
Execute student_attendance_no_schools_last30;
Execute student_attendance_no_schools_overall;
return 0;
END;
$$LANGUAGE plpgsql;


select student_attendance_no_schools_timeseries();


/* Download all months data in one Excel sheet at Student attendance report */
drop view if exists student_attendance_all_months_data_dist cascade;
drop view if exists student_attendance_all_months_data_block cascade;
drop view if exists student_attendance_all_months_data_cluster cascade;
drop view if exists student_attendance_all_months_data_school cascade;

/* district level */
create or replace view student_attendance_all_months_data_dist as 
select district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Students_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Students_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Students_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Students_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Students_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Students_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Students_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Students_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Students_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Students_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Students_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Students_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY district_id,academic_year)::int AS rn,att_res.academic_year,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.students_count,att_res.total_schools] from (SELECT district_id,INITCAP(district_name) AS district_name,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year, 
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS attendance_pct,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY district_id,district_latitude,district_longitude,district_name ,year,month) as att_res',
  'select m from generate_series(1,12) m'
) as (
  rn int,
  academic_year text,
  district_id bigint,
  district_name text,
  "t1" text[],
  "t2" text[],
  "t3" text[],
  "t4" text[],
  "t5" text[],
  "t6" text[],
  "t7" text[],
  "t8" text[],
  "t9" text[],
  "t10" text[],
  "t11" text[],
  "t12" text[]
) ) as temp;

/* block level */
create or replace view student_attendance_all_months_data_block as 
select block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Students_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Students_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Students_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Students_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Students_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Students_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Students_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Students_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Students_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Students_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Students_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Students_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY block_id,academic_year)::int AS rn,att_res.academic_year, att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.students_count,att_res.total_schools] from (SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS attendance_pct,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year  
FROM school_student_total_attendance WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY block_id,block_name,block_latitude,block_longitude,district_id,district_name,year,month) as att_res',
  'select m from generate_series(1,12) m'
) as (
  rn int,
  academic_year text,
  block_id bigint,block_name text,
  district_id bigint,
  district_name text,
  "t1" text[],
  "t2" text[],
  "t3" text[],
  "t4" text[],
  "t5" text[],
  "t6" text[],
  "t7" text[],
  "t8" text[],
  "t9" text[],
  "t10" text[],
  "t11" text[],
  "t12" text[]
) ) as temp;

/* cluster level */

create or replace view student_attendance_all_months_data_cluster as 
select cluster_id,cluster_name,block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Students_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Students_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Students_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Students_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Students_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Students_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Students_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Students_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Students_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Students_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Students_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Students_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY cluster_id,academic_year)::int AS rn,att_res.academic_year, att_res.cluster_id,att_res.cluster_name,att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.students_count,att_res.total_schools] from (SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS attendance_pct,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year   
FROM school_student_total_attendance WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name,year,month
) as att_res',
  'select m from generate_series(1,12) m'
) as (
  rn int,
  academic_year text,
  cluster_id bigint,cluster_name text,
  block_id bigint,block_name text,
  district_id bigint,
  district_name text,
  "t1" text[],
  "t2" text[],
  "t3" text[],
  "t4" text[],
  "t5" text[],
  "t6" text[],
  "t7" text[],
  "t8" text[],
  "t9" text[],
  "t10" text[],
  "t11" text[],
  "t12" text[]
) ) as temp;

/* school level */
create or replace view student_attendance_all_months_data_school as 
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Students_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Students_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Students_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Students_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Students_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Students_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Students_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Students_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Students_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Students_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Students_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Students_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY school_id,academic_year)::int AS rn,att_res.academic_year,att_res.school_id,att_res.school_name, att_res.cluster_id,att_res.cluster_name,att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.students_count,att_res.total_schools] from (SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS attendance_pct,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year
FROM school_student_total_attendance WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY school_id,school_name,crc_name,school_latitude,school_longitude,year,month,cluster_id,cluster_name,crc_name,block_id,block_name,district_id,district_name,year,month

) as att_res',
  'select m from generate_series(1,12) m'
) as (
  rn int,
  academic_year text,
  school_id bigint,school_name text,
  cluster_id bigint,cluster_name text,
  block_id bigint,block_name text,
  district_id bigint,
  district_name text,
  "t1" text[],
  "t2" text[],
  "t3" text[],
  "t4" text[],
  "t5" text[],
  "t6" text[],
  "t7" text[],
  "t8" text[],
  "t9" text[],
  "t10" text[],
  "t11" text[],
  "t12" text[]
) ) as temp;

/* health card time selection */
/* ---- student attendance --- */

/* health card attendance school - last 30 days */
create or replace view hc_student_attendance_school_last_30_days as 
SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name;


/* health card attendance school - overall */
create or replace view hc_student_attendance_school_overall as 
SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name;


/* Health card attendance cluster -last 30 days */

create or replace view hc_student_attendance_cluster_last_30_days as 
SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name;

/* health card attendance cluster - overall */

create or replace view hc_student_attendance_cluster_overall as 
SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name;

/* health card attendance block - last 30 days */

create or replace view hc_student_attendance_block_last_30_days as 
SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY block_id,block_name,block_latitude,block_longitude,district_id,district_name;

/* health card attendance block - overall */

create or replace view hc_student_attendance_block_overall as 
SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY block_id,block_name,block_latitude,block_longitude,district_id,district_name;

/* health card attendance district - last 30 days */
create or replace view hc_student_attendance_district_last_30_days as 
SELECT district_id,INITCAP(district_name) AS district_name, 
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY district_id,district_latitude,district_longitude,district_name;

/* health card attendance district - overall */
create or replace view hc_student_attendance_district_overall as 
SELECT district_id,INITCAP(district_name) AS district_name, 
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY district_id,district_latitude,district_longitude,district_name;

/* health card state queries */
/* overall */
create or replace view hc_student_attendance_state_overall as
SELECT Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE district_latitude > 0 AND district_longitude > 0 AND block_latitude > 0 AND block_longitude > 0 AND cluster_latitude > 0 AND cluster_longitude > 0 AND school_latitude >0 AND school_longitude >0 
AND school_name IS NOT NULL and cluster_name is NOT NULL AND block_name is NOT NULL AND district_name is NOT NULL and total_students>0;

/* last 30 days */
create or replace view hc_student_attendance_state_last30 as
SELECT Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE district_latitude > 0 AND district_longitude > 0 AND block_latitude > 0 AND block_longitude > 0 AND cluster_latitude > 0 AND cluster_longitude > 0 AND school_latitude >0 AND school_longitude >0 
AND school_name IS NOT NULL and cluster_name is NOT NULL AND block_name is NOT NULL AND district_name is NOT NULL and total_students>0;

/* health card time selection management */
/* ---- student attendance  management--- */

/* health card attendance school - last 30 days */
create or replace view hc_student_attendance_school_mgmt_last_30_days as 
SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type;


/* health card attendance school - overall */
create or replace view hc_student_attendance_school_mgmt_overall as 
SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name,Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type;


/* Health card attendance cluster -last 30 days */

create or replace view hc_student_attendance_cluster_mgmt_last_30_days as 
SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days 
WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 
AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name,school_management_type;

/* health card attendance cluster - overall */

create or replace view hc_student_attendance_cluster_mgmt_overall as 
SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY cluster_id,cluster_name,cluster_latitude,cluster_longitude,block_id,block_name,district_id,district_name,school_management_type;

/* health card attendance block - last 30 days */

create or replace view hc_student_attendance_block_mgmt_last_30_days as 
SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY block_id,block_name,block_latitude,block_longitude,district_id,district_name,school_management_type;

/* health card attendance block - overall */

create or replace view hc_student_attendance_block_mgmt_overall as 
SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall 
WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 AND cluster_latitude IS NOT NULL 
AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL 
and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY block_id,block_name,block_latitude,block_longitude,district_id,district_name,school_management_type;

/* health card attendance district - last 30 days */
create or replace view hc_student_attendance_district_mgmt_last_30_days as 
SELECT district_id,INITCAP(district_name) AS district_name, 
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
FROM student_attendance_agg_last_30_days WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0 and school_management_type is not null
GROUP BY district_id,district_latitude,district_longitude,district_name,school_management_type;

/* health card attendance district - overall */
create or replace view hc_student_attendance_district_mgmt_overall as 
SELECT district_id,INITCAP(district_name) AS district_name, 
Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,school_management_type,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL AND 
block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 and school_management_type is not null
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_students>0
GROUP BY district_id,district_latitude,district_longitude,district_name,school_management_type;

/* Health card - Student attendance state management overall */

create or replace view hc_student_attendance_state_mgmt_overall as 
SELECT round(((sum(total_present) * 100.0) / sum(total_students)), 1) AS attendance,
    sum(students_count) AS students_count,
    count(DISTINCT school_id) AS total_schools,
    school_management_type,
    ( SELECT data_from_date(min(year), min(month)) AS data_from_date
           FROM student_attendance_trans
          WHERE year = ( SELECT min(year) AS min
                   FROM student_attendance_trans )
          GROUP BY year) AS data_from_date,
    ( SELECT
                CASE
                    WHEN ((matt.year = date_part('year'::text, now())) AND (matt.month = date_part('month'::text, now()))) THEN to_char(now(), 'DD-MM-YYYY'::text)::character varying
                    ELSE data_upto_date(matt.year, matt.month)
                END AS data_upto_date
           FROM ( SELECT max(student_attendance_trans.month) AS month,
                    max(student_attendance_trans.year) AS year
                   FROM student_attendance_trans
                  WHERE (student_attendance_trans.year = ( SELECT max(year) AS max
                           FROM student_attendance_trans ))) matt) AS data_upto_date
   FROM student_attendance_agg_overall
  WHERE district_latitude > 0 AND district_longitude > 0 AND block_latitude > 0 AND block_longitude > 0 AND cluster_latitude > 0 AND cluster_longitude > 0 AND school_latitude > 0 AND school_longitude > 0 AND school_name IS NOT NULL AND cluster_name IS NOT NULL AND block_name IS NOT NULL AND district_name IS NOT NULL AND total_students > 0 AND school_management_type IS NOT NULL
  GROUP BY school_management_type;
  
/* Health card - Student attendance state management last30 */  
create or replace view hc_student_attendance_state_mgmt_last30 as 
   SELECT round(((sum(total_present) * 100.0) / sum(total_students)), 1) AS attendance,
    school_management_type,
    sum(students_count) AS students_count,
    count(DISTINCT school_id) AS total_schools,
    ( SELECT to_char((min(days_in_period.day))::timestamp with time zone, 'DD-MM-YYYY'::text) AS data_from_date
           FROM ( SELECT (generate_series((now()::date - '30 days'::interval), (((now()::date - '1 day'::interval))::date)::timestamp without time zone, '1 day'::interval))::date AS day) days_in_period) AS data_from_date,
    ( SELECT to_char((max(days_in_period.day))::timestamp with time zone, 'DD-MM-YYYY'::text) AS data_upto_date
           FROM ( SELECT (generate_series((now()::date - '30 days'::interval), (((now()::date - '1 day'::interval))::date)::timestamp without time zone, '1 day'::interval))::date AS day) days_in_period) AS data_upto_date
   FROM student_attendance_agg_last_30_days
  WHERE ((district_latitude > (0)::double precision) AND (district_longitude > (0)::double precision) AND (block_latitude > (0)::double precision) AND (block_longitude > (0)::double precision) AND (cluster_latitude > (0)::double precision) AND (cluster_longitude > (0)::double precision) AND (school_latitude > (0)::double precision) AND (school_longitude > (0)::double precision) AND (school_name IS NOT NULL) AND (cluster_name IS NOT NULL) AND (block_name IS NOT NULL) AND (district_name IS NOT NULL) AND (total_students > 0) AND (school_management_type IS NOT NULL))
  GROUP BY school_management_type;
