/* drop view statements */

drop view if exists teacher_attendance_exception_data cascade;
drop view if exists teacher_attendance_exception_last_1_day cascade;
drop view if exists teacher_attendance_exception_last_30_days cascade;
drop view if exists teacher_attendance_exception_last_7_days cascade;
drop view if exists teacher_attendance_exception_overall cascade;

/*Function for Teacher attendance Time series */

CREATE OR REPLACE FUNCTION teacher_attendance_agg_refresh(period text)
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
min_total_teachers text;
max_total_present text;
max_total_teachers text;
total_present text;
total_teachers text;
number_of_days text;
one_month_query text;
BEGIN
two_month_query:='select school_id,month,year,
sum(case when day_1 in (1,6,7) then 1 when day_1 =3 then 0.5 else 0 end) as day_1_total_present,
sum(case when day_1 in (2,1,3,4,6,7) then 1 else 0 end) as day_1_total_teachers,
sum(case when day_2 in (1,6,7) then 1 when day_2 =3 then 0.5 else 0 end) as day_2_total_present,
sum(case when day_2 in (2,1,3,4,6,7) then 1 else 0 end) as day_2_total_teachers, 
sum(case when day_3 in (1,6,7) then 1 when day_3 =3 then 0.5 else 0 end) as day_3_total_present,
sum(case when day_3 in (2,1,3,4,6,7) then 1 else 0 end) as day_3_total_teachers,
sum(case when day_4 in (1,6,7) then 1 when day_4 =3 then 0.5 else 0 end) as day_4_total_present,
sum(case when day_4 in (2,1,3,4,6,7) then 1 else 0 end) as day_4_total_teachers, 
sum(case when day_5 in (1,6,7) then 1 when day_5 =3 then 0.5 else 0 end) as day_5_total_present,
sum(case when day_5 in (2,1,3,4,6,7) then 1 else 0 end) as day_5_total_teachers, 
sum(case when day_6 in (1,6,7) then 1 when day_6 =3 then 0.5 else 0 end) as day_6_total_present,
sum(case when day_6 in (2,1,3,4,6,7) then 1 else 0 end) as day_6_total_teachers, 
sum(case when day_7 in (1,6,7) then 1 when day_7 =3 then 0.5 else 0 end) as day_7_total_present,
sum(case when day_7 in (2,1,3,4,6,7) then 1 else 0 end) as day_7_total_teachers,
sum(case when day_8 in (1,6,7) then 1 when day_8 =3 then 0.5 else 0 end) as day_8_total_present,
sum(case when day_8 in (2,1,3,4,6,7) then 1 else 0 end) as day_8_total_teachers, 
sum(case when day_9 in (1,6,7) then 1 when day_9 =3 then 0.5 else 0 end) as day_9_total_present,
sum(case when day_9 in (2,1,3,4,6,7) then 1 else 0 end) as day_9_total_teachers,
sum(case when day_10 in (1,6,7) then 1 when day_10 =3 then 0.5 else 0 end) as day_10_total_present,
sum(case when day_10 in (2,1,3,4,6,7) then 1 else 0 end) as day_10_total_teachers,
sum(case when day_11 in (1,6,7) then 1 when day_11 =3 then 0.5 else 0 end) as day_11_total_present,
sum(case when day_11 in (2,1,3,4,6,7) then 1 else 0 end) as day_11_total_teachers, 
sum(case when day_12 in (1,6,7) then 1 when day_12 =3 then 0.5 else 0 end) as day_12_total_present,
sum(case when day_12 in (2,1,3,4,6,7) then 1 else 0 end) as day_12_total_teachers,
sum(case when day_13 in (1,6,7) then 1 when day_13 =3 then 0.5 else 0 end) as day_13_total_present,
sum(case when day_13 in (2,1,3,4,6,7) then 1 else 0 end) as day_13_total_teachers,
sum(case when day_14 in (1,6,7) then 1 when day_14 =3 then 0.5 else 0 end) as day_14_total_present,
sum(case when day_14 in (2,1,3,4,6,7) then 1 else 0 end) as day_14_total_teachers,
sum(case when day_15 in (1,6,7) then 1 when day_15 =3 then 0.5 else 0 end) as day_15_total_present,
sum(case when day_15 in (2,1,3,4,6,7) then 1 else 0 end) as day_15_total_teachers,
sum(case when day_16 in (1,6,7) then 1 when day_16 =3 then 0.5 else 0 end) as day_16_total_present,
sum(case when day_16 in (2,1,3,4,6,7) then 1 else 0 end) as day_16_total_teachers,
sum(case when day_17 in (1,6,7) then 1 when day_17 =3 then 0.5 else 0 end) as day_17_total_present,
sum(case when day_17 in (2,1,3,4,6,7) then 1 else 0 end) as day_17_total_teachers,
sum(case when day_18 in (1,6,7) then 1 when day_18 =3 then 0.5 else 0 end) as day_18_total_present,
sum(case when day_18 in (2,1,3,4,6,7) then 1 else 0 end) as day_18_total_teachers,
sum(case when day_19 in (1,6,7) then 1 when day_19 =3 then 0.5 else 0 end) as day_19_total_present,
sum(case when day_19 in (2,1,3,4,6,7) then 1 else 0 end) as day_19_total_teachers,
sum(case when day_20 in (1,6,7) then 1 when day_20 =3 then 0.5 else 0 end) as day_20_total_present,
sum(case when day_20 in (2,1,3,4,6,7) then 1 else 0 end) as day_20_total_teachers,
sum(case when day_21 in (1,6,7) then 1 when day_21 =3 then 0.5 else 0 end) as day_21_total_present,
sum(case when day_21 in (2,1,3,4,6,7) then 1 else 0 end) as day_21_total_teachers,
sum(case when day_22 in (1,6,7) then 1 when day_22 =3 then 0.5 else 0 end) as day_22_total_present,
sum(case when day_22 in (2,1,3,4,6,7) then 1 else 0 end) as day_22_total_teachers,
sum(case when day_23 in (1,6,7) then 1 when day_23 =3 then 0.5 else 0 end) as day_23_total_present,
sum(case when day_23 in (2,1,3,4,6,7) then 1 else 0 end) as day_23_total_teachers,
sum(case when day_24 in (1,6,7) then 1 when day_24 =3 then 0.5 else 0 end) as day_24_total_present,
sum(case when day_24 in (2,1,3,4,6,7) then 1 else 0 end) as day_24_total_teachers,
sum(case when day_25 in (1,6,7) then 1 when day_25 =3 then 0.5 else 0 end) as day_25_total_present,
sum(case when day_25 in (2,1,3,4,6,7) then 1 else 0 end) as day_25_total_teachers,
sum(case when day_26 in (1,6,7) then 1 when day_26 =3 then 0.5 else 0 end) as day_26_total_present,
sum(case when day_26 in (2,1,3,4,6,7) then 1 else 0 end) as day_26_total_teachers,
sum(case when day_27 in (1,6,7) then 1 when day_27 =3 then 0.5 else 0 end) as day_27_total_present,
sum(case when day_27 in (2,1,3,4,6,7) then 1 else 0 end) as day_27_total_teachers,
sum(case when day_28 in (1,6,7) then 1 when day_28 =3 then 0.5 else 0 end) as day_28_total_present,
sum(case when day_28 in (2,1,3,4,6,7) then 1 else 0 end) as day_28_total_teachers,
sum(case when day_29 in (1,6,7) then 1 when day_29 =3 then 0.5 else 0 end) as day_29_total_present,
sum(case when day_29 in (2,1,3,4,6,7) then 1 else 0 end) as day_29_total_teachers,
sum(case when day_30 in (1,6,7) then 1 when day_30 =3 then 0.5 else 0 end) as day_30_total_present,
sum(case when day_30 in (2,1,3,4,6,7) then 1 else 0 end) as day_30_total_teachers,
sum(case when day_31 in (1,6,7) then 1 when day_31 =3 then 0.5 else 0 end) as day_31_total_present,
sum(case when day_31 in (2,1,3,4,6,7) then 1 else 0 end) as day_31_total_teachers
from teacher_attendance_trans';
one_month_query:='select school_id,month,year,count(distinct teacher_id) as teachers_count,
sum(case when day_1 in (1,6,7) then 1 when day_1 =3 then 0.5 else 0 end) as day_1_total_present,
sum(case when day_1 in (2,1,3,4,6,7) then 1 else 0 end) as day_1_total_teachers,
sum(case when day_2 in (1,6,7) then 1 when day_2 =3 then 0.5 else 0 end) as day_2_total_present,
sum(case when day_2 in (2,1,3,4,6,7) then 1 else 0 end) as day_2_total_teachers, 
sum(case when day_3 in (1,6,7) then 1 when day_3 =3 then 0.5 else 0 end) as day_3_total_present,
sum(case when day_3 in (2,1,3,4,6,7) then 1 else 0 end) as day_3_total_teachers,
sum(case when day_4 in (1,6,7) then 1 when day_4 =3 then 0.5 else 0 end) as day_4_total_present,
sum(case when day_4 in (2,1,3,4,6,7) then 1 else 0 end) as day_4_total_teachers, 
sum(case when day_5 in (1,6,7) then 1 when day_5 =3 then 0.5 else 0 end) as day_5_total_present,
sum(case when day_5 in (2,1,3,4,6,7) then 1 else 0 end) as day_5_total_teachers, 
sum(case when day_6 in (1,6,7) then 1 when day_6 =3 then 0.5 else 0 end) as day_6_total_present,
sum(case when day_6 in (2,1,3,4,6,7) then 1 else 0 end) as day_6_total_teachers, 
sum(case when day_7 in (1,6,7) then 1 when day_7 =3 then 0.5 else 0 end) as day_7_total_present,
sum(case when day_7 in (2,1,3,4,6,7) then 1 else 0 end) as day_7_total_teachers,
sum(case when day_8 in (1,6,7) then 1 when day_8 =3 then 0.5 else 0 end) as day_8_total_present,
sum(case when day_8 in (2,1,3,4,6,7) then 1 else 0 end) as day_8_total_teachers, 
sum(case when day_9 in (1,6,7) then 1 when day_9 =3 then 0.5 else 0 end) as day_9_total_present,
sum(case when day_9 in (2,1,3,4,6,7) then 1 else 0 end) as day_9_total_teachers,
sum(case when day_10 in (1,6,7) then 1 when day_10=3 then 0.5 else 0 end) as day_10_total_present,
sum(case when day_10 in (2,1,3,4,6,7) then 1 else 0 end) as day_10_total_teachers,
sum(case when day_11 in (1,6,7) then 1 when day_11=3 then 0.5 else 0 end) as day_11_total_present,
sum(case when day_11 in (2,1,3,4,6,7) then 1 else 0 end) as day_11_total_teachers, 
sum(case when day_12 in (1,6,7) then 1 when day_12=3 then 0.5 else 0 end) as day_12_total_present,
sum(case when day_12 in (2,1,3,4,6,7) then 1 else 0 end) as day_12_total_teachers,
sum(case when day_13 in (1,6,7) then 1 when day_13=3 then 0.5 else 0 end) as day_13_total_present,
sum(case when day_13 in (2,1,3,4,6,7) then 1 else 0 end) as day_13_total_teachers,
sum(case when day_14 in (1,6,7) then 1 when day_14=3 then 0.5 else 0 end) as day_14_total_present,
sum(case when day_14 in (2,1,3,4,6,7) then 1 else 0 end) as day_14_total_teachers,
sum(case when day_15 in (1,6,7) then 1 when day_15=3 then 0.5 else 0 end) as day_15_total_present,
sum(case when day_15 in (2,1,3,4,6,7) then 1 else 0 end) as day_15_total_teachers,
sum(case when day_16 in (1,6,7) then 1 when day_16=3 then 0.5 else 0 end) as day_16_total_present,
sum(case when day_16 in (2,1,3,4,6,7) then 1 else 0 end) as day_16_total_teachers,
sum(case when day_17 in (1,6,7) then 1 when day_17=3 then 0.5 else 0 end) as day_17_total_present,
sum(case when day_17 in (2,1,3,4,6,7) then 1 else 0 end) as day_17_total_teachers,
sum(case when day_18 in (1,6,7) then 1 when day_18=3 then 0.5 else 0 end) as day_18_total_present,
sum(case when day_18 in (2,1,3,4,6,7) then 1 else 0 end) as day_18_total_teachers,
sum(case when day_19 in (1,6,7) then 1 when day_19=3 then 0.5 else 0 end) as day_19_total_present,
sum(case when day_19 in (2,1,3,4,6,7) then 1 else 0 end) as day_19_total_teachers,
sum(case when day_20 in (1,6,7) then 1 when day_20=3 then 0.5 else 0 end) as day_20_total_present,
sum(case when day_20 in (2,1,3,4,6,7) then 1 else 0 end) as day_20_total_teachers,
sum(case when day_21 in (1,6,7) then 1 when day_21=3 then 0.5 else 0 end) as day_21_total_present,
sum(case when day_21 in (2,1,3,4,6,7) then 1 else 0 end) as day_21_total_teachers,
sum(case when day_22 in (1,6,7) then 1 when day_22=3 then 0.5 else 0 end) as day_22_total_present,
sum(case when day_22 in (2,1,3,4,6,7) then 1 else 0 end) as day_22_total_teachers,
sum(case when day_23 in (1,6,7) then 1 when day_23=3 then 0.5 else 0 end) as day_23_total_present,
sum(case when day_23 in (2,1,3,4,6,7) then 1 else 0 end) as day_23_total_teachers,
sum(case when day_24 in (1,6,7) then 1 when day_24=3 then 0.5 else 0 end) as day_24_total_present,
sum(case when day_24 in (2,1,3,4,6,7) then 1 else 0 end) as day_24_total_teachers,
sum(case when day_25 in (1,6,7) then 1 when day_25=3 then 0.5 else 0 end) as day_25_total_present,
sum(case when day_25 in (2,1,3,4,6,7) then 1 else 0 end) as day_25_total_teachers,
sum(case when day_26 in (1,6,7) then 1 when day_26=3 then 0.5 else 0 end) as day_26_total_present,
sum(case when day_26 in (2,1,3,4,6,7) then 1 else 0 end) as day_26_total_teachers,
sum(case when day_27 in (1,6,7) then 1 when day_27=3 then 0.5 else 0 end) as day_27_total_present,
sum(case when day_27 in (2,1,3,4,6,7) then 1 else 0 end) as day_27_total_teachers,
sum(case when day_28 in (1,6,7) then 1 when day_28=3 then 0.5 else 0 end) as day_28_total_present,
sum(case when day_28 in (2,1,3,4,6,7) then 1 else 0 end) as day_28_total_teachers,
sum(case when day_29 in (1,6,7) then 1 when day_29=3 then 0.5 else 0 end) as day_29_total_present,
sum(case when day_29 in (2,1,3,4,6,7) then 1 else 0 end) as day_29_total_teachers,
sum(case when day_30 in (1,6,7) then 1 when day_30=3 then 0.5 else 0 end) as day_30_total_present,
sum(case when day_30 in (2,1,3,4,6,7) then 1 else 0 end) as day_30_total_teachers,
sum(case when day_31 in (1,6,7) then 1 when day_31=3 then 0.5 else 0 end) as day_31_total_present,
sum(case when day_31 in (2,1,3,4,6,7) then 1 else 0 end) as day_31_total_teachers
from teacher_attendance_trans';
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
string_agg('day_'||date_part('day',days_in_period.day)||'_total_teachers','+') as total_teachers into max_total_present,max_total_teachers
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day) =max_month 
and extract(year from days_in_period.day) =max_year;

select string_agg('day_'||date_part('day',days_in_period.day)||'_total_present','+') as max_total_present, 
string_agg('day_'||date_part('day',days_in_period.day)||'_total_teachers','+') as max_total_teachers into min_total_present,min_total_teachers
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day)=min_month 
and extract(year from days_in_period.day)=min_year;

_query_res:='create or replace view teacher_attendance_agg_'||period||' as select sch_res.school_id,sch_res.total_present,cast(sch_res.total_teachers as bigint),cast(stn_cnt.teachers_count as bigint),
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category
from (
select school_id,sum(total_present) as total_present,sum(total_teachers) as total_teachers from 
(select school_id,'||max_total_present||' as total_present,'||max_total_teachers||' as total_teachers'||' from ('||two_month_query||' '||max_filter_query||' '||_group_query||') as max_temp
union all
select school_id,'||min_total_present||' as total_present,'||min_total_teachers||' as total_teachers'||' from ('||two_month_query||' '||min_filter_query||' '||_group_query||') as min_temp) as total_att 
group by school_id) sch_res inner join
(select a.school_id,a.school_name,b.school_latitude,b.school_longitude,a.cluster_id,a.cluster_name,b.cluster_latitude,b.cluster_longitude,
a.block_id,a.block_name,b.block_latitude,b.block_longitude,a.district_id,a.district_name,b.district_latitude,b.district_longitude,a.school_management_type,a.school_category
from school_hierarchy_details as a inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_name is not null and a.cluster_name is not null and b.school_latitude>0 and b.school_longitude>0 and b.cluster_latitude>0 and b.cluster_longitude>0
)as b on b.school_id=sch_res.school_id
left join (select school_id,count(distinct teacher_id) as teachers_count from teacher_attendance_trans where (month='||min_month||' and year='||min_year||') or (month='||max_month||' and year='||max_year||') group by school_id) as stn_cnt
on b.school_id=stn_cnt.school_id';

EXECUTE _query_res;
ELSE IF _count =1 THEN
select distinct extract(month from days_in_period.day) as month,extract(year from days_in_period.day) as year into month,year from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period;

filter_query:='where month='||month||' and year='||year;

select string_agg('day_'||date_part('day',days_in_period.day)||'_total_present','+') as total_present, 
string_agg('day_'||date_part('day',days_in_period.day)||'_total_teachers','+') as total_teachers into total_present, total_teachers
from (select (generate_series('now()'::date-number_of_days::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period 
where extract(month from days_in_period.day)=month 
and extract(year from days_in_period.day)=year;

_query_res:='create or replace view teacher_attendance_agg_'||period||' as select sch_res.school_id,sch_res.total_present,cast(sch_res.total_teachers as bigint),cast(sch_res.teachers_count as bigint),
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category
   from (
select school_id,'||total_present||' as total_present,'||total_teachers||' as total_teachers'||',teachers_count from ('||one_month_query||' '||filter_query||' '||_group_query||') as att ) as sch_res
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
$$ LANGUAGE plpgsql;

drop view if exists teacher_attendance_agg_last_1_day cascade;
drop view if exists teacher_attendance_agg_last_30_days cascade;
drop view if exists teacher_attendance_agg_last_7_days cascade;
drop view if exists teacher_attendance_agg_overall cascade;


select teacher_attendance_agg_refresh('last_1_day');
select teacher_attendance_agg_refresh('last_7_days');
select teacher_attendance_agg_refresh('last_30_days');

/* Teacher attendance overall */

create or replace view teacher_attendance_agg_overall as select tch_res.school_id,cast(tch_res.total_present as numeric),tch_res.total_teachers,tch_cnt.teachers_count,
b.school_name,b.school_latitude,b.school_longitude,b.cluster_id,b.cluster_name,b.cluster_latitude,b.cluster_longitude,
b.block_id,b.block_name,b.block_latitude,b.block_longitude,b.district_id,b.district_name,b.district_latitude,b.district_longitude,b.school_management_type,b.school_category
from 
(select school_id ,sum(total_present) as total_present,sum(total_working_days) as total_teachers from school_teacher_total_attendance  group by school_id) as tch_res
   inner join
(select a.school_id,a.school_name,b.school_latitude,b.school_longitude,a.cluster_id,a.cluster_name,b.cluster_latitude,b.cluster_longitude,
a.block_id,a.block_name,b.block_latitude,b.block_longitude,a.district_id,a.district_name,b.district_latitude,b.district_longitude,a.school_management_type,a.school_category
from school_hierarchy_details as a inner join school_geo_master as b on a.school_id=b.school_id 
where a.school_name is not null and a.cluster_name is not null and b.school_latitude>0 and b.school_longitude>0 and b.cluster_latitude>0 and b.cluster_longitude>0
)as b on b.school_id=tch_res.school_id
left join (select school_id,count(distinct teacher_id) as teachers_count from teacher_attendance_trans group by school_id) as tch_cnt
on b.school_id=tch_cnt.school_id;


/* Teacher attendance Exception */

create or replace FUNCTION teacher_attendance_no_schools(month int,year int)
RETURNS text AS
$$
DECLARE
teacher_attendance_no_schools text;
BEGIN
teacher_attendance_no_schools = 'create or replace view teacher_attendance_exception_data as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,'|| month ||' as month,'|| year ||' as year,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id!=9999 AND a.school_id not in 
(select distinct e.x_axis as school_id from (SELECT school_id AS x_axis,year,month,school_management_type 
FROM school_teacher_total_attendance WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND month = '|| month ||' AND year = '|| year ||'
AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY school_id,school_name,crc_name,school_latitude,school_longitude,year,month,cluster_id,cluster_name,crc_name,block_id,block_name,district_id,district_name,year,month,school_management_type)as e)
and cluster_name is not null';
Execute teacher_attendance_no_schools;
return 0;
END;
$$LANGUAGE plpgsql;


create or replace FUNCTION teacher_attendance_exception_time_selection(period text)
RETURNS text AS
$$
DECLARE
teacher_attendance_no_schools_time_selection text;
number_of_days text;
BEGIN
IF period='last_1_day' THEN
number_of_days:='1day';
ELSE IF period='last_7_days' THEN
number_of_days:='7day';
ELSE IF period='last_30_days' THEN
number_of_days:='30day';
ELSE IF period='overall' THEN
number_of_days:='overall';
ELSE
return 0;
END IF;
END IF;
END IF;
END IF;

teacher_attendance_no_schools_time_selection := 'create or replace view teacher_attendance_exception_'||period||' as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id!=9999 AND a.school_id not in 
(select distinct e.x_axis as school_id from (SELECT school_id AS x_axis 
FROM teacher_attendance_agg_'||period||'  WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL 
AND school_name IS NOT NULL and cluster_name is not null
GROUP BY school_id,school_name,school_latitude,school_longitude,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type)as e)
and cluster_name is not null';
Execute teacher_attendance_no_schools_time_selection;
return 0;
END;
$$LANGUAGE plpgsql;


select teacher_attendance_exception_time_selection('last_1_day');
select teacher_attendance_exception_time_selection('last_7_days');
select teacher_attendance_exception_time_selection('last_30_days');
select teacher_attendance_exception_time_selection('overall');


/* Download all months data in one Excel sheet at Teacher attendance report */

drop view if exists teacher_attendance_all_months_data_dist cascade;
drop view if exists teacher_attendance_all_months_data_block cascade;
drop view if exists teacher_attendance_all_months_data_cluster cascade;
drop view if exists teacher_attendance_all_months_data_school cascade;

/* district level */
create or replace view teacher_attendance_all_months_data_dist as 
select district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Teachers_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Teachers_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Teachers_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Teachers_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Teachers_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Teachers_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Teachers_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Teachers_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Teachers_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Teachers_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Teachers_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Teachers_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY district_id,academic_year)::int AS rn,att_res.academic_year,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.teachers_count,att_res.total_schools] from (
SELECT district_id,INITCAP(district_name) AS district_name, 
round(cast(Sum(total_present)*100.0/Sum(total_working_days) as numeric),1)AS attendance_pct,
Sum(teachers_count) AS teachers_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year  
FROM school_teacher_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
GROUP BY district_id,district_latitude,district_longitude,district_name ,year,month

) as att_res',
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
create or replace view teacher_attendance_all_months_data_block as 
select block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Teachers_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Teachers_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Teachers_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Teachers_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Teachers_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Teachers_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Teachers_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Teachers_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Teachers_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Teachers_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Teachers_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Teachers_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY block_id,academic_year)::int AS rn,att_res.academic_year, att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.Teachers_count,att_res.total_schools] from (SELECT block_id,INITCAP(block_name) AS block_name,district_id,INITCAP(district_name) AS district_name,
round(cast(Sum(total_present)*100.0/Sum(total_working_days) as numeric),1)AS attendance_pct,
Sum(teachers_count) AS teachers_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year
FROM school_teacher_total_attendance WHERE block_name IS NOT NULL AND block_latitude IS NOT NULL 
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

create or replace view teacher_attendance_all_months_data_cluster as 
select cluster_id,cluster_name,block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Teachers_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Teachers_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Teachers_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Teachers_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Teachers_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Teachers_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Teachers_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Teachers_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Teachers_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Teachers_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Teachers_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Teachers_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY cluster_id,academic_year)::int AS rn,att_res.academic_year, att_res.cluster_id,att_res.cluster_name,att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.Teachers_count,att_res.total_schools] from (SELECT cluster_id,INITCAP(cluster_name) AS cluster_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name) AS block_name,
round(cast(Sum(total_present)*100.0/Sum(total_working_days) as numeric),1)AS attendance_pct,
Sum(teachers_count) AS teachers_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year
FROM school_teacher_total_attendance WHERE cluster_latitude IS NOT NULL AND block_latitude IS NOT NULL 
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

create or replace view teacher_attendance_all_months_data_school as 
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,academic_year,t1[1] as Attendance_Percent_January,t1[2] as Teachers_Count_January,t1[3] as Total_Schools_January,t2[1] as Attendance_Percent_February,t2[2] as Teachers_Count_February,t2[3] as Total_Schools_February,t3[1] as Attendance_Percent_March,t3[2] as Teachers_Count_March,t3[3] as Total_Schools_March,t4[1] as Attendance_Percent_April,t4[2] as Teachers_Count_April,t4[3] as Total_Schools_April,t5[1] as Attendance_Percent_May,t5[2] as Teachers_Count_May,t5[3] as Total_Schools_May,t6[1] as Attendance_Percent_June,t6[2] as Teachers_Count_June,t6[3] as Total_Schools_June,t7[1] as Attendance_Percent_July,t7[2] as Teachers_Count_July,t7[3] as Total_Schools_July,t8[1] as Attendance_Percent_August,t8[2] as Teachers_Count_August,t8[3] as Total_Schools_August,t9[1] as Attendance_Percent_September,t9[2] as Teachers_Count_September,t9[3] as Total_Schools_September,t10[1] as Attendance_Percent_October,t10[2] as Teachers_Count_October,t10[3] as Total_Schools_October,t11[1] as Attendance_Percent_November,t11[2] as Teachers_Count_November,t11[3] as Total_Schools_November,t12[1] as Attendance_Percent_December,t12[2] as Teachers_Count_December,t12[3] as Total_Schools_December
 from (select * from crosstab(
  'select rank() OVER (ORDER BY school_id,academic_year)::int AS rn,att_res.academic_year,att_res.school_id,att_res.school_name, att_res.cluster_id,att_res.cluster_name,att_res.block_id,att_res.block_name,att_res.district_id,att_res.district_name,att_res.month,array[att_res.attendance_pct,att_res.Teachers_count,att_res.total_schools] from (SELECT school_id,INITCAP(school_name) AS school_name,district_id,INITCAP(district_name) AS district_name,block_id,INITCAP(block_name)AS block_name,cluster_id,
INITCAP(cluster_name) AS cluster_name, 
round(cast(Sum(total_present)*100.0/Sum(total_working_days) as numeric),1)AS attendance_pct,
Sum(teachers_count) AS teachers_count,Count(DISTINCT(school_id)) AS total_schools,month,case when month in (6,7,8,9,10,11,12) then (year ||''-''|| substring(cast((year+1) as text),3,2)) else ((year-1) || ''-'' || substring(cast(year as text),3,2)) end as academic_year 
FROM school_teacher_total_attendance WHERE block_latitude IS NOT NULL AND block_latitude <> 0 
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

