/* Drop views */

drop view if exists insert_diksha_trans_view;

/* Function to insert data into diksha content trans table */

CREATE OR REPLACE FUNCTION insert_diksha_trans()
RETURNS text AS
$$
DECLARE
transaction_insert text;
BEGIN
transaction_insert='insert into diksha_content_trans(content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,content_medium,content_gradelevel,content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,total_time_spent,dimensions_mode,dimensions_type,object_type,created_on,updated_on) 
select data.*,now(),now() from
((select content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,
content_medium,content_gradelevel,content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,
case WHEN lower(derived_loc_district) not in (select distinct lower(shd.district_name) from school_hierarchy_details shd) THEN ''others''
       else derived_loc_district end as derived_loc_district,
user_signin_type,user_login_type,
collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,
total_time_spent,dimensions_mode,dimensions_type,object_type from diksha_content_temp )
 except (select content_view_date,dimensions_pdata_id,
	dimensions_pdata_pid,content_name,content_board,content_mimetype,content_medium,content_gradelevel,
	content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,
collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,
total_time_spent,dimensions_mode,dimensions_type,object_type from diksha_content_trans))as data';
Execute transaction_insert; 
return 0;
END;
$$LANGUAGE plpgsql;

/* Function to insert data into diksha total content aggregation table */
CREATE OR REPLACE FUNCTION insert_diksha_agg()
RETURNS text AS
$$
DECLARE
diksha_view text;
agg_insert text;
BEGIN
diksha_view='create or replace view insert_diksha_trans_view as
select b.district_id,b.district_latitude,b.district_longitude,Initcap(b.district_name) as district_name,
	   a.content_view_date,a.dimensions_pdata_id,a.dimensions_pdata_pid,a.content_name,a.content_board,a.content_mimetype,a.content_medium,
	   ltrim(rtrim(a.content_gradelevel)) as content_gradelevel,regexp_replace(ltrim(rtrim(a.content_subject)),
	   ''([a-z])([A-Z])'', ''\1 \2'',''g'') as content_subject,
	   a.content_created_for,a.object_id,a.object_rollup_l1,a.derived_loc_state,a.derived_loc_district,a.user_signin_type,a.user_login_type,
	   case when a.collection_name is null then ''Other'' else a.collection_name end as collection_name,
	   a.collection_board,
	   a.collection_type,a.collection_medium,a.collection_gradelevel,a.collection_subject,a.collection_created_for,a.total_count,a.total_time_spent,a.dimensions_mode,a.dimensions_type,a.object_type
        from (select derived_loc_district as district_name,
content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,
case when content_medium like ''[%'' then ''Multi Medium'' else initcap(ltrim(rtrim(content_medium))) end as content_medium,
case when content_gradelevel like ''[%'' then ''Multi Grade'' else initcap(ltrim(rtrim(content_gradelevel))) end as content_gradelevel,
case when content_subject like ''[%'' then ''Multi Subject'' when initcap(ltrim(rtrim(content_subject)))=''Maths'' then ''Mathematics''
else initcap(ltrim(rtrim(content_subject))) end as content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,total_time_spent,dimensions_mode,dimensions_type,object_type
from diksha_content_trans where dimensions_mode=''play'' ) as a 
inner join
        (select distinct a.district_id,a.district_name,b.district_latitude,b.district_longitude from
(select district_id,district_name from school_hierarchy_details
group by district_id,district_name
) as a left join school_geo_master as b on a.district_id=b.district_id) as b on lower(a.district_name)=lower(b.district_name)
where a.district_name is not null and b.district_id is not null';
Execute diksha_view;
agg_insert='insert into diksha_total_content(district_id,district_latitude,district_longitude,district_name,
content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,content_medium,content_gradelevel,content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,total_time_spent,object_type,dimensions_type,created_on,updated_on
) select data.*,now(),now() from
((select district_id,district_latitude,district_longitude,district_name,
content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,content_medium,content_gradelevel,content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,
total_time_spent,object_type,dimensions_type
from insert_diksha_trans_view) 
except (select district_id,district_latitude,district_longitude,district_name,
content_view_date,dimensions_pdata_id,dimensions_pdata_pid,content_name,content_board,content_mimetype,content_medium,content_gradelevel,content_subject,
content_created_for,object_id,object_rollup_l1,derived_loc_state,derived_loc_district,user_signin_type,user_login_type,collection_name,collection_board,
collection_type,collection_medium,collection_gradelevel,collection_subject,collection_created_for,total_count,total_time_spent,object_type,dimensions_type
from diksha_total_content))as data';
Execute agg_insert; 
return 0;
END;
$$LANGUAGE plpgsql;

/* Funtion to insert data into diksha tpd trans table */
CREATE OR REPLACE FUNCTION insert_diksha_tpd_trans()
RETURNS text AS
$$
DECLARE
transaction_insert text;
BEGIN
transaction_insert=
'insert into diksha_tpd_trans(collection_id,collection_name,batch_id,batch_name,uuid,state,org_name,school_id,enrolment_date,
completion_date,progress,certificate_status,total_score,nested_collection_progress,assessment_score,created_on,updated_on) 
(select collection_id,collection_name,batch_id,batch_name,tpd_temp.uuid,tpd_temp.state,
org_name,CASE WHEN cr_mapping.school_id is NULL THEN 9999 ELSE cr_mapping.school_id END,enrolment_date,
completion_date,progress,certificate_status,total_score,nested_collection_progress,assessment_score,now(),now()
from diksha_tpd_content_temp as tpd_temp left join (select dtm.uuid,CASE WHEN dtm.school_id not in (select shd.school_id from school_hierarchy_details shd) 
THEN 9999 ELSE dtm.school_id END from diksha_tpd_mapping dtm) as cr_mapping 
on tpd_temp.uuid=cr_mapping.uuid)
on conflict(collection_id,uuid,batch_id) do update
set collection_id=excluded.collection_id,collection_name=excluded.collection_name,batch_id=excluded.batch_id,
batch_name=excluded.batch_name,uuid=excluded.uuid,state=excluded.state,org_name=excluded.org_name,school_id=excluded.school_id,
enrolment_date=excluded.enrolment_date,completion_date=excluded.completion_date,progress=excluded.progress,
certificate_status=excluded.certificate_status,total_score=excluded.total_score,
nested_collection_progress=excluded.nested_collection_progress,assessment_score=excluded.assessment_score,updated_on=now()';
Execute transaction_insert; 
return 0;
END;
$$LANGUAGE plpgsql;

/* views for calculating total teachers count and tecahers enrolled */
drop view if exists school_teachers_count cascade;

create or replace view school_teachers_count as 
select tch_cnt.school_id,count(distinct(uuid)) as total_teachers,clust_id,blk_id,dist_id from diksha_tpd_mapping as tch_cnt 
inner join 
(select school_id ,cluster_id as clust_id,block_id as blk_id,district_id as dist_id from school_hierarchy_details 
  where school_name is not null and cluster_name is not null
and block_name is not null and district_name is not null) as scl on tch_cnt.school_id=scl.school_id 
group by tch_cnt.school_id,clust_id,blk_id,dist_id;

create or replace view school_diksha_enrolled as 
select a.*,cnt.total_teachers from
(select collection_id,collection_name,
count(distinct(uuid)) as total_enrolled,'Last_Day' as time_range,  
tpd.school_id,cluster_id,block_id,district_id from diksha_tpd_trans as tpd inner join (
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details
where school_name is not null and district_name is not null and cluster_name is not null and block_name is not null) as scl_hry on tpd.school_id=scl_hry.school_id
where collection_name is not null and enrolment_date = (select now()::DATE)
group by collection_id,collection_name,tpd.school_id,cluster_id,block_id,district_id
union
select collection_id,collection_name,
count(distinct(uuid)) as total_enrolled,'Last_7_Day' as time_range,  
tpd.school_id,cluster_id,block_id,district_id from diksha_tpd_trans as tpd inner join (
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details
where school_name is not null and district_name is not null and cluster_name is not null and block_name is not null) as scl_hry on tpd.school_id=scl_hry.school_id
where collection_name is not null and enrolment_date between (select ((now()::Date)-INTERVAL '7 DAY')::Date) and 
(select (now()::Date))
group by collection_id,collection_name,tpd.school_id,cluster_id,block_id,district_id
union
select collection_id,collection_name,
count(distinct(uuid)) as total_enrolled,'Last_30_Day' as time_range,  
tpd.school_id,cluster_id,block_id,district_id from diksha_tpd_trans as tpd inner join (
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details
where school_name is not null and district_name is not null and cluster_name is not null and block_name is not null) as scl_hry on tpd.school_id=scl_hry.school_id
where collection_name is not null and enrolment_date between (select ((now()::Date)-INTERVAL '30 DAY')::Date) and 
(select (now()::Date))
group by collection_id,collection_name,tpd.school_id,cluster_id,block_id,district_id
union
select collection_id,collection_name,
count(distinct(uuid)) as total_enrolled,'All' as time_range,  
tpd.school_id,cluster_id,block_id,district_id from diksha_tpd_trans as tpd inner join (
select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details
where school_name is not null and district_name is not null and cluster_name is not null and block_name is not null) as scl_hry on tpd.school_id=scl_hry.school_id
where collection_name is not null 
group by collection_id,collection_name,tpd.school_id,cluster_id,block_id,district_id) as a
left join school_teachers_count as cnt on a.school_id=cnt.school_id;


/* Month wise refresh aggregation table */
create or replace function insert_diksha_year_month()
returns int as
$body$
declare
cnt_query text:='select count(*) from diksha_total_content_year_month limit 10';
_count bigint;
begin
EXECUTE cnt_query into _count;
IF _count = 0 THEN  
   EXECUTE 'insert into diksha_total_content_year_month
    select nextval(''diksha_total_content_year_month_id_seq''::regclass),district_id,district_name,date_part(''month'',content_view_date),date_part(''year'',content_view_date),content_name,content_medium,content_gradelevel,content_subject,object_id,collection_name,collection_type,collection_medium,collection_gradelevel,sum(total_count),sum(total_time_spent) 
    from diksha_total_content where dimensions_type=''content''
group by district_id,district_name,date_part(''month'',content_view_date),date_part(''year'',content_view_date),content_name,content_medium,content_gradelevel,content_subject,object_id,collection_name,collection_type,collection_medium,collection_gradelevel';
ELSE

delete from diksha_total_content_year_month dt using diksha_refresh dr where dt.month=date_part('month',dr.content_view_date) and dt.year=date_part('year',dr.content_view_date);

insert into diksha_total_content_year_month
select nextval('diksha_total_content_year_month_id_seq'::regclass),district_id,district_name,date_part('month',content_view_date),date_part('year',content_view_date),content_name,content_medium,content_gradelevel,content_subject,object_id,collection_name,collection_type,collection_medium,collection_gradelevel,sum(total_count),sum(total_time_spent) 
from diksha_total_content 
where content_view_date BETWEEN
(select (date_trunc('month',(select min(content_view_date) from diksha_refresh))::date))
and (select (date_trunc('month',(select max(content_view_date) from diksha_refresh))+'1month'::interval-'1day'::interval)::date)  and dimensions_type='content'
group by district_id,district_name,date_part('month',content_view_date),date_part('year',content_view_date),content_name,content_medium,content_gradelevel,content_subject,object_id,collection_name,collection_type,collection_medium,collection_gradelevel;
END IF;
  return 0;

   exception 
   when others then
       return 1;

end;
$body$
language plpgsql;

/* function for loading the expected enrollment data into master table */

CREATE OR REPLACE FUNCTION insert_diksha_expected_enrolment()
 RETURNS int 
 LANGUAGE plpgsql
AS $function$
DECLARE
course_details_available text;
program_details_available text;
program_course_available text;
BEGIN
if EXISTS (select * from diksha_course_expected_temp) and not exists (select * from diksha_program_expected_temp) then
course_details_available = 'insert into diksha_tpd_expected_enrollment(program_id,program_name,collection_id,course_start_date,course_end_date,district_id,expected_enrollment,created_on,updated_on)
select program_id,program_name,a.collection_id,course_start_date,course_end_date,district_id,expected_enrollment,now(),now() from
 (select pct.program_id,pct.program_name,case when pct.collection_id is null then dce.collection_id else pct.collection_id end as collection_id,dce.course_start_date,dce.course_end_date from diksha_program_course_details_temp pct full join diksha_course_details_temp dce on pct.collection_id=dce.collection_id where program_name is not null) as a
 left join 
 (select collection_id,district_id,expected_enrollment from diksha_course_expected_temp) as exp_enrol on a.collection_id=exp_enrol.collection_id 
 on conflict(program_id,collection_id,district_id) do update 
 set program_id=excluded.program_id,program_name=excluded.program_name,collection_id=excluded.collection_id,course_start_date=excluded.course_start_date,course_end_date=excluded.course_end_date,
 district_id=excluded.district_id,expected_enrollment=excluded.expected_enrollment,updated_on=now();';

EXECUTE course_details_available;

elseif EXISTS (select * from diksha_program_expected_temp) and not exists (select * from diksha_course_expected_temp) then
 program_details_available = 'insert into diksha_tpd_expected_enrollment(program_id,program_name,collection_id,course_start_date,course_end_date,district_id,program_expected_enrollment,created_on,updated_on)
 select  a.program_id,a.program_name,collection_id,a.course_start_date,a.course_end_date,COALESCE(district_id,0) as district_id,program_expected_enrollment,now(),now()
 from  (select pct.program_id,pct.program_name,case when pct.collection_id is null then dce.collection_id else pct.collection_id end as collection_id,dce.course_start_date,dce.course_end_date from diksha_program_course_details_temp pct full join diksha_course_details_temp dce on pct.collection_id=dce.collection_id where program_name is not null) as a
 left join  (select program_name,district_id,expected_enrollments as program_expected_enrollment from diksha_program_expected_temp) as b on lower(a.program_name)=lower(b.program_name) 
 on conflict(program_id,collection_id,district_id) do update 
 set program_id=excluded.program_id,program_name=excluded.program_name,collection_id=excluded.collection_id,course_start_date=excluded.course_start_date,course_end_date=excluded.course_end_date,
 district_id=excluded.district_id,program_expected_enrollment = excluded.program_expected_enrollment,updated_on=now();';
 
EXECUTE program_details_available;

else 
program_course_available = 'insert into diksha_tpd_expected_enrollment(program_id,program_name,collection_id,course_start_date,course_end_date,district_id,expected_enrollment,program_expected_enrollment,created_on,updated_on)
 select  COALESCE(a.program_id,0),a.program_name,a.collection_id,a.course_start_date,a.course_end_date,district_id,expected_enrollment,program_expected_enrollment,now(),now()
 from ( select pr.program_id,pr.program_name,pr.collection_id,pr.course_start_date,pr.course_end_date,pr.district_id,pr.program_expected_enrollment,expected_enrollment from (select program_id,a.program_name,collection_id,course_start_date,course_end_date,district_id,program_expected_enrollment from (select pct.program_id,pct.program_name,case when pct.collection_id is null then dce.collection_id else pct.collection_id end as collection_id,dce.course_start_date,dce.course_end_date from diksha_program_course_details_temp pct full join diksha_course_details_temp dce on pct.collection_id=dce.collection_id ) as a
 left join  (select program_name,district_id,expected_enrollments as program_expected_enrollment from diksha_program_expected_temp) as b on lower(a.program_name)=lower(b.program_name)) as pr 
 full join (select collection_id,district_id,expected_enrollment from diksha_course_expected_temp) as exp_enrol on pr.collection_id=exp_enrol.collection_id  and pr.district_id=exp_enrol.district_id) as a
 on conflict(program_id,collection_id,district_id) do update 
 set program_id=excluded.program_id, program_name=excluded.program_name,collection_id=excluded.collection_id,course_start_date=excluded.course_start_date,course_end_date=excluded.course_end_date,
 district_id=excluded.district_id,expected_enrollment=excluded.expected_enrollment,program_expected_enrollment = excluded.program_expected_enrollment,updated_on=now();';
 
EXECUTE program_course_available;
end IF;
return 1;
END;
$function$;



