/* drop view statements */
drop view if exists composite_mgt_district;
drop view if exists composite_mgt_block;
drop view if exists composite_mgt_cluster;
drop view if exists composite_mgt_school;

/*Composite reports */

/*insert script for composite dynamic queries*/

/*district*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'district','select stat.district_id,stat.district_name',
		'from (select distinct(sh.district_id),initcap(sh.district_name)as district_name from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.district_id=sh.district_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'district','sa.student_attendance',
		'left join (SELECT district_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY district_id,year,month) as sa 
on stat.district_id=sa.district_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'district','pat.Periodic_exam_performance',
		'left join (select district_id,district_performance as Periodic_exam_performance from periodic_exam_district_all) as pat 
on stat.district_id=pat.district_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('diksha',true,'district','dik.Total_content_plays_textbook,
	dik.Total_content_plays_course,dik.Total_content_plays_all',
		'left join (select district_id,sum(textbook) as Total_content_plays_textbook,
sum(course) as Total_content_plays_course,sum(textbook+course)as Total_content_plays_all from 
(select district_id,(case when lower(collection_type)=''textbook'' then sum(total_count) else 0 end)as textbook,
	(case when lower(collection_type)=''course'' then sum(total_count) else 0 end)as course
	from diksha_total_content where user_login_type is not null and collection_type is not null
and user_login_type <> ''NA''and district_name is not null
and district_id is not null
group by district_id,collection_type
order by 1)as f group by district_id) as dik 
on stat.district_id=dik.district_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'district','semester_performance,semester_performance_grade_3,
	semester_performance_grade_4,semester_performance_grade_5,semester_performance_grade_6,semester_performance_grade_7,semester_performance_grade_8',
		'left join (	select a.district_id,a.semester_performance,
b.grade_3 as semester_performance_grade_3,b.grade_4 as semester_performance_grade_4,b.grade_5 as semester_performance_grade_5,
b.grade_6 as semester_performance_grade_6,b.grade_7 as semester_performance_grade_7,b.grade_8 as semester_performance_grade_8
from
(SELECT district_id, 
Round(Sum(case when subject_1_marks_scored is null then 0 else subject_1_marks_scored end + 
	case when subject_3_marks_scored is null then 0 else subject_3_marks_scored end+case when subject_2_marks_scored is null then 0 else subject_2_marks_scored end
	+case when subject_4_marks_scored is null then 0 else subject_4_marks_scored end+
	case when subject_5_marks_scored is null then 0 else subject_5_marks_scored end+case when subject_7_marks_scored is null then 0 else subject_7_marks_scored end
	+case when subject_6_marks_scored is null then 0 else subject_6_marks_scored end+case when subject_8_marks_scored is null then 0 else subject_8_marks_scored end
	)*100.0/
Sum(subject_1_total_marks+subject_3_total_marks+subject_2_total_marks+subject_4_total_marks+subject_5_total_marks+
	subject_7_total_marks+subject_6_total_marks+subject_8_total_marks),1)AS semester_performance
FROM school_student_subject_total_marks WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 and cluster_name is not null
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and school_id not in (select school_id from school_semester_no_data)
and semester = (select max(semester) from school_student_subject_total_marks)
GROUP BY district_id)as a
left join 
(select * from crosstab(
''select x_axis,grade,x_value from district_grade order by 1'',
''select distinct(grade) from district_grade order by 1'') as 
(district_id bigint,"grade_3" numeric,"grade_4" numeric,"grade_5" numeric,"grade_6" numeric
,"grade_7" numeric,"grade_8" numeric)) b
on a.district_id=b.district_id) as sem 
on stat.district_id=sem.district_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'district','left join udise_district_score
on stat.district_id=udise_district_score.district_id')
on conflict on constraint composite_config_pkey do nothing;

/*block*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'block',
	'select stat.block_id,stat.block_name,stat.district_id,stat.district_name',
		'from (select distinct(sh.block_id),initcap(sh.block_name)as block_name,sh.district_id,initcap(sh.district_name)as district_name from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.block_id=sh.block_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'block','sa.student_attendance',
		'left join (SELECT block_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY block_id,year,month) as sa 
on stat.block_id=sa.block_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'block','pat.Periodic_exam_performance',
		'left join (select block_id,block_performance as Periodic_exam_performance from periodic_exam_block_all) as pat 
on stat.block_id=pat.block_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'block','semester_performance,semester_performance_grade_3,
	semester_performance_grade_4,semester_performance_grade_5,semester_performance_grade_6,semester_performance_grade_7,semester_performance_grade_8',
		'left join (	select a.block_id,a.semester_performance,
b.grade_3 as semester_performance_grade_3,b.grade_4 as semester_performance_grade_4,b.grade_5 as semester_performance_grade_5,
b.grade_6 as semester_performance_grade_6,b.grade_7 as semester_performance_grade_7,b.grade_8 as semester_performance_grade_8
from
(SELECT block_id, 
Round(Sum(case when subject_1_marks_scored is null then 0 else subject_1_marks_scored end + 
	case when subject_3_marks_scored is null then 0 else subject_3_marks_scored end+case when subject_2_marks_scored is null then 0 else subject_2_marks_scored end
	+case when subject_4_marks_scored is null then 0 else subject_4_marks_scored end+
	case when subject_5_marks_scored is null then 0 else subject_5_marks_scored end+case when subject_7_marks_scored is null then 0 else subject_7_marks_scored end
	+case when subject_6_marks_scored is null then 0 else subject_6_marks_scored end+case when subject_8_marks_scored is null then 0 else subject_8_marks_scored end
	)*100.0/
Sum(subject_1_total_marks+subject_3_total_marks+subject_2_total_marks+subject_4_total_marks+subject_5_total_marks+
	subject_7_total_marks+subject_6_total_marks+subject_8_total_marks),1)AS semester_performance
FROM school_student_subject_total_marks WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 and cluster_name is not null
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and school_id not in (select school_id from school_semester_no_data)
and semester = (select max(semester) from school_student_subject_total_marks)
GROUP BY block_id)as a
left join 
(select * from crosstab(
''select x_axis,grade,x_value from block_grade order by 1'',
''select distinct(grade) from block_grade order by 1'') as 
(block_id bigint,"grade_3" numeric,"grade_4" numeric,"grade_5" numeric,"grade_6" numeric
,"grade_7" numeric,"grade_8" numeric)) b
on a.block_id=b.block_id) as sem 
on stat.block_id=sem.block_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'block','left join udise_block_score
on stat.block_id=udise_block_score.block_id')
on conflict on constraint composite_config_pkey do nothing;

/*cluster*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'cluster',
	'select stat.cluster_id,stat.cluster_name,stat.block_id,stat.block_name,stat.district_id,stat.district_name',
		'from (select distinct(sh.cluster_id),initcap(sh.cluster_name)as cluster_name,sh.block_id,initcap(sh.block_name)as block_name
		,sh.district_id,initcap(sh.district_name)as district_name from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.cluster_id=sh.cluster_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'cluster','sa.student_attendance',
		'left join (SELECT cluster_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY cluster_id,year,month) as sa 
on stat.cluster_id=sa.cluster_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'cluster','pat.Periodic_exam_performance',
		'left join (select cluster_id,cluster_performance as Periodic_exam_performance from periodic_exam_cluster_all) as pat 
on stat.cluster_id=pat.cluster_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'cluster','semester_performance,semester_performance_grade_3,
	semester_performance_grade_4,semester_performance_grade_5,semester_performance_grade_6,semester_performance_grade_7,semester_performance_grade_8',
		'left join (	select a.cluster_id,a.semester_performance,
b.grade_3 as semester_performance_grade_3,b.grade_4 as semester_performance_grade_4,b.grade_5 as semester_performance_grade_5,
b.grade_6 as semester_performance_grade_6,b.grade_7 as semester_performance_grade_7,b.grade_8 as semester_performance_grade_8
from
(SELECT cluster_id, 
Round(Sum(case when subject_1_marks_scored is null then 0 else subject_1_marks_scored end + 
	case when subject_3_marks_scored is null then 0 else subject_3_marks_scored end+case when subject_2_marks_scored is null then 0 else subject_2_marks_scored end
	+case when subject_4_marks_scored is null then 0 else subject_4_marks_scored end+
	case when subject_5_marks_scored is null then 0 else subject_5_marks_scored end+case when subject_7_marks_scored is null then 0 else subject_7_marks_scored end
	+case when subject_6_marks_scored is null then 0 else subject_6_marks_scored end+case when subject_8_marks_scored is null then 0 else subject_8_marks_scored end
	)*100.0/
Sum(subject_1_total_marks+subject_3_total_marks+subject_2_total_marks+subject_4_total_marks+subject_5_total_marks+
	subject_7_total_marks+subject_6_total_marks+subject_8_total_marks),1)AS semester_performance
FROM school_student_subject_total_marks WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 and cluster_name is not null
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and school_id not in (select school_id from school_semester_no_data)
and semester = (select max(semester) from school_student_subject_total_marks)
GROUP BY cluster_id)as a
left join 
(select * from crosstab(
''select x_axis,grade,x_value from cluster_grade order by 1'',
''select distinct(grade) from cluster_grade order by 1'') as 
(cluster_id bigint,"grade_3" numeric,"grade_4" numeric,"grade_5" numeric,"grade_6" numeric
,"grade_7" numeric,"grade_8" numeric)) b
on a.cluster_id=b.cluster_id) as sem 
on stat.cluster_id=sem.cluster_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'cluster','left join udise_cluster_score
on stat.cluster_id=udise_cluster_score.cluster_id')
on conflict on constraint composite_config_pkey do nothing;

/*school*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'school',
	'select stat.school_id,stat.school_name,stat.cluster_id,stat.cluster_name,stat.block_id,stat.block_name,stat.district_id,stat.district_name',
		'from (select distinct(sh.school_id),initcap(sh.school_name)as school_name,sh.cluster_id,initcap(sh.cluster_name)as cluster_name,
		sh.block_id,initcap(sh.block_name)as block_name,sh.district_id,initcap(sh.district_name)as district_name from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.school_id=sh.school_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'school','sa.student_attendance',
		'left join (SELECT school_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY school_id,year,month) as sa 
on stat.school_id=sa.school_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'school','pat.Periodic_exam_performance',
		'left join (select school_id,school_performance as Periodic_exam_performance from periodic_exam_school_all) as pat 
on stat.school_id=pat.school_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'school','semester_performance,semester_performance_grade_3,
	semester_performance_grade_4,semester_performance_grade_5,semester_performance_grade_6,semester_performance_grade_7,semester_performance_grade_8',
		'left join (	select a.school_id,a.semester_performance,
b.grade_3 as semester_performance_grade_3,b.grade_4 as semester_performance_grade_4,b.grade_5 as semester_performance_grade_5,
b.grade_6 as semester_performance_grade_6,b.grade_7 as semester_performance_grade_7,b.grade_8 as semester_performance_grade_8
from
(SELECT school_id, 
Round(Sum(case when subject_1_marks_scored is null then 0 else subject_1_marks_scored end + 
	case when subject_3_marks_scored is null then 0 else subject_3_marks_scored end+case when subject_2_marks_scored is null then 0 else subject_2_marks_scored end
	+case when subject_4_marks_scored is null then 0 else subject_4_marks_scored end+
	case when subject_5_marks_scored is null then 0 else subject_5_marks_scored end+case when subject_7_marks_scored is null then 0 else subject_7_marks_scored end
	+case when subject_6_marks_scored is null then 0 else subject_6_marks_scored end+case when subject_8_marks_scored is null then 0 else subject_8_marks_scored end
	)*100.0/
Sum(subject_1_total_marks+subject_3_total_marks+subject_2_total_marks+subject_4_total_marks+subject_5_total_marks+
	subject_7_total_marks+subject_6_total_marks+subject_8_total_marks),1)AS semester_performance
FROM school_student_subject_total_marks WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 and cluster_name is not null
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and school_id not in (select school_id from school_semester_no_data)
and semester = (select max(semester) from school_student_subject_total_marks)
GROUP BY school_id)as a
left join 
(select * from crosstab(
''select x_axis,grade,x_value from school_grade order by 1'',
''select distinct(grade) from school_grade order by 1'') as 
(school_id bigint,"grade_3" numeric,"grade_4" numeric,"grade_5" numeric,"grade_6" numeric
,"grade_7" numeric,"grade_8" numeric)) b
on a.school_id=b.school_id) as sem 
on stat.school_id=sem.school_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'school','left join udise_school_score
on stat.school_id=udise_school_score.udise_school_id')
on conflict on constraint composite_config_pkey do nothing;

update composite_config as uds set select_query= stg.select_query from 
(select string_agg(lower(column_name),',')||',infrastructure_score' as select_query from udise_config where type='indice' and status=true)as stg
where uds.template='udise';


update composite_config set status= false where lower(template) in (select lower(template) from nifi_template_info where status=false);

/*Function to create composite views*/

CREATE OR REPLACE FUNCTION composite_create_views()
RETURNS text AS
$$
DECLARE
select_query_dist text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''district'' order by id)as d';   
select_cols_dist text;
join_query_dist text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''district'' order by id)as d';
join_cols_dist text;
district_view text;
select_query_blk text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''block'' order by id)as d';   
select_cols_blk text;
join_query_blk text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''block'' order by id)as d';
join_cols_blk text;
block_view text;
select_query_cst text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''cluster'' order by id)as d';   
select_cols_cst text;
join_query_cst text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''cluster'' order by id)as d';
join_cols_cst text;
cluster_view text;
select_query_scl text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''school'' order by id)as d';   
select_cols_scl text;
join_query_scl text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''school'' order by id)as d';
join_cols_scl text;
school_view text;
BEGIN
Execute select_query_dist into select_cols_dist;
Execute join_query_dist into join_cols_dist;
Execute select_query_blk into select_cols_blk;
Execute join_query_blk into join_cols_blk;
Execute select_query_cst into select_cols_cst;
Execute join_query_cst into join_cols_cst;
Execute select_query_scl into select_cols_scl;
Execute join_query_scl into join_cols_scl;
district_view='create or replace view composite_district as 
'||select_cols_dist||' '||join_cols_dist||';
';
Execute district_view; 
block_view='create or replace view composite_block as 
'||select_cols_blk||' '||join_cols_blk||';
';
Execute block_view; 
cluster_view='create or replace view composite_cluster as 
'||select_cols_cst||' '||join_cols_cst||';
';
Execute cluster_view; 
school_view='create or replace view composite_school as 
'||select_cols_scl||' '||join_cols_scl||';
';
Execute school_view; 
return 0;
END;
$$LANGUAGE plpgsql;

drop view if exists composite_district;
drop view if exists composite_block;
drop view if exists composite_cluster;
drop view if exists composite_school;


/*select * from composite_create_views();*/

/* composite_jolt_spec */
create or replace function composite_jolt_spec()
    RETURNS text AS
    $$
    declare
comp text:='select string_agg(jolt_spec,'','') from composite_config where category=''district'' and status=true';
comp_cols text;
query text;
BEGIN
execute comp into comp_cols;
IF comp_cols <> '' THEN 
query = '
create or replace view composite_jolt_district as 
select ''
[
  {
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "[&1].district.id",
        "district_name": "[&1].district.value",
        "school_management_type": "[&1].school_management_type.value",
'||comp_cols||'
      }
    }
    }
  ]

''as jolt_spec;
create or replace view composite_jolt_block
as select ''
[
  {
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "[&1].district.id",
        "district_name": "[&1].district.value",
        "block_id": "[&1].block.id",
        "block_name": "[&1].block.value",
        "school_management_type": "[&1].school_management_type.value",
'||comp_cols||'
      }
    }
    }
  ]

'' as jolt_spec;
create or replace view composite_jolt_cluster
as select ''
[
  {
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "[&1].district.id",
        "district_name": "[&1].district.value",
        "block_id": "[&1].block.id",
        "block_name": "[&1].block.value",
        "cluster_id": "[&1].cluster.id",
        "cluster_name": "[&1].cluster.value",
        "school_management_type": "[&1].school_management_type.value",
'||comp_cols||'
      }
    }
    }
  ]

''as jolt_spec;
create or replace view composite_jolt_school
as select ''
[
  {
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "[&1].district.id",
        "district_name": "[&1].district.value",
        "block_id": "[&1].block.id",
        "block_name": "[&1].block.value",
        "cluster_id": "[&1].cluster.id",
        "cluster_name": "[&1].cluster.value",
        "school_id": "[&1].school.id",
        "school_management_type": "[&1].school_management_type.value",
        "school_name": "[&1].school.value",
'||comp_cols||'
      }
    }
    }
  ]
''as jolt_spec;
    ';
Execute query;
END IF;
return 0;
END;
$$
LANGUAGE plpgsql;


create or replace view school_semester_no_data as
select school_id,semester from school_student_subject_total_marks
WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL AND block_latitude <> 0 and cluster_name is not null
AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 AND school_latitude IS NOT NULL AND school_name IS NOT NULL
group by school_id,semester
having Sum(case when subject_1_marks_scored is null then 0 else subject_1_marks_scored end +
 case when subject_3_marks_scored is null then 0 else subject_3_marks_scored end+case when subject_2_marks_scored is null then 0 else subject_2_marks_scored end
 +case when subject_4_marks_scored is null then 0 else subject_4_marks_scored end+
 case when subject_5_marks_scored is null then 0 else subject_5_marks_scored end+case when subject_7_marks_scored is null then 0 else subject_7_marks_scored end
 +case when subject_6_marks_scored is null then 0 else subject_6_marks_scored end+case when subject_8_marks_scored is null then 0 else subject_8_marks_scored end
 ) = 0;
	
/* Composite Management Queries */

/*insert script for composite dynamic queries*/

/*district*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'district_mgt','select stat.district_id,stat.district_name,stat.school_management_type',
		'from (select distinct(sh.district_id),initcap(sh.district_name)as district_name,sh.school_management_type as school_management_type from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.district_id=sh.district_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null and school_management_type is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'district_mgt','sa.student_attendance',
		'left join (SELECT district_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance,school_management_type 
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0 and school_management_type is not null
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY district_id,year,month,school_management_type) as sa 
on stat.district_id=sa.district_id and stat.school_management_type=sa.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'district_mgt','pat.Periodic_exam_performance',
		'left join (select district_id,district_performance as Periodic_exam_performance,school_management_type from periodic_exam_district_mgmt_all where school_management_type is not null) as pat 
on stat.district_id=pat.district_id and stat.school_management_type=pat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('diksha',true,'district_mgt','dik.Total_content_plays_textbook,
	dik.Total_content_plays_course,dik.Total_content_plays_all',
		'left join (select district_id,sum(textbook) as Total_content_plays_textbook,
sum(course) as Total_content_plays_course,sum(textbook+course)as Total_content_plays_all from 
(select district_id,(case when lower(collection_type)=''textbook'' then sum(total_count) else 0 end)as textbook,
	(case when lower(collection_type)=''course'' then sum(total_count) else 0 end)as course
	from diksha_total_content where collection_type is not null
group by district_id,collection_type
order by 1)as f group by district_id) as dik 
on stat.district_id=dik.district_id')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'district_mgt','sat.Semester_exam_performance',
		'left join (select district_id,district_performance as Semester_exam_performance,school_management_type from semester_exam_district_mgmt_all where school_management_type is not null) as sat 
on stat.district_id=sat.district_id and stat.school_management_type=sat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;


insert into composite_config(template,status,category,table_join) values('udise',true,'district_mgt','left join udise_district_mgt_score
on stat.district_id=udise_district_mgt_score.district_id and stat.school_management_type=udise_district_mgt_score.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

/*block*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'block_mgt',
	'select stat.block_id,stat.block_name,stat.district_id,stat.district_name,stat.school_management_type',
		'from (select distinct(sh.block_id),initcap(sh.block_name)as block_name,sh.district_id,initcap(sh.district_name)as district_name,sh.school_management_type as school_management_type from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.block_id=sh.block_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null and school_management_type is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'block_mgt','sa.student_attendance',
		'left join (SELECT block_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance,school_management_type
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0 and school_management_type is not null
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY block_id,year,month,school_management_type) as sa 
on stat.block_id=sa.block_id and stat.school_management_type=sa.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'block_mgt','pat.Periodic_exam_performance',
		'left join (select block_id,block_performance as Periodic_exam_performance,school_management_type from periodic_exam_block_mgmt_all where school_management_type is not null) as pat 
on stat.block_id=pat.block_id and stat.school_management_type=pat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'block_mgt','sat.Semester_exam_performance',
		'left join (select block_id,block_performance as Semester_exam_performance,school_management_type from semester_exam_block_mgmt_all where school_management_type is not null) as sat 
on stat.block_id=sat.block_id and stat.school_management_type=sat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'block_mgt','left join udise_block_mgt_score
on stat.block_id=udise_block_mgt_score.block_id and stat.school_management_type=udise_block_mgt_score.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

/*cluster*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'cluster_mgt',
	'select stat.cluster_id,stat.cluster_name,stat.block_id,stat.block_name,stat.district_id,stat.district_name,stat.school_management_type',
		'from (select distinct(sh.cluster_id),initcap(sh.cluster_name)as cluster_name,sh.block_id,initcap(sh.block_name)as block_name
		,sh.district_id,initcap(sh.district_name)as district_name,sh.school_management_type as school_management_type from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.cluster_id=sh.cluster_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null and school_management_type is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'cluster_mgt','sa.student_attendance',
		'left join (SELECT cluster_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance,school_management_type
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0 and school_management_type is not null
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY cluster_id,year,month,school_management_type) as sa 
on stat.cluster_id=sa.cluster_id and stat.school_management_type=sa.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'cluster_mgt','pat.Periodic_exam_performance',
		'left join (select cluster_id,cluster_performance as Periodic_exam_performance,school_management_type from periodic_exam_cluster_mgmt_all where school_management_type is not null) as pat 
on stat.cluster_id=pat.cluster_id and stat.school_management_type=pat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'cluster_mgt','sat.semester_exam_performance',
		'left join (select cluster_id,cluster_performance as semester_exam_performance,school_management_type from semester_exam_cluster_mgmt_all where school_management_type is not null) as sat 
on stat.cluster_id=sat.cluster_id and stat.school_management_type=sat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,table_join) values('udise',true,'cluster_mgt','left join udise_cluster_mgt_score
on stat.cluster_id=udise_cluster_mgt_score.cluster_id and stat.school_management_type=udise_cluster_mgt_score.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

/*school*/

insert into composite_config(template,status,category,select_query,table_join) values('static',true,'school_mgt',
	'select stat.school_id,stat.school_name,stat.cluster_id,stat.cluster_name,stat.block_id,stat.block_name,stat.district_id,stat.district_name,stat.school_management_type',
		'from (select distinct(sh.school_id),initcap(sh.school_name)as school_name,sh.cluster_id,initcap(sh.cluster_name)as cluster_name,
		sh.block_id,initcap(sh.block_name)as block_name,sh.district_id,initcap(sh.district_name)as district_name,sh.school_management_type as school_management_type from
school_geo_master as sg 
left join 
school_hierarchy_details as sh on sg.school_id=sh.school_id
where school_latitude>0 and school_longitude>0 and cluster_latitude>0 and cluster_longitude>0 and school_name is not null and district_name is not null 
	and cluster_name is not null and block_name is not null and school_management_type is not null) as stat')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('attendance',true,'school_mgt','sa.student_attendance',
		'left join (SELECT school_id,
Round(Sum(total_present)*100.0/Sum(total_working_days),1)AS student_attendance,school_management_type
FROM school_student_total_attendance WHERE district_name IS NOT NULL AND block_latitude IS NOT NULL 
AND block_latitude <> 0 AND cluster_latitude IS NOT NULL AND cluster_latitude <> 0 AND school_latitude <>0 
AND school_latitude IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null and total_working_days>0 and school_management_type is not null
AND year =(select max(year) from school_student_total_attendance) AND
month= (select max(month) from school_student_total_attendance where year=(select max(year) from school_student_total_attendance))
GROUP BY school_id,year,month,school_management_type) as sa 
on stat.school_id=sa.school_id and stat.school_management_type=sa.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('pat',true,'school_mgt','pat.Periodic_exam_performance',
		'left join (select school_id,school_performance as Periodic_exam_performance,school_management_type from periodic_exam_school_mgmt_all where school_management_type is not null) as pat 
on stat.school_id=pat.school_id and stat.school_management_type=pat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

insert into composite_config(template,status,category,select_query,table_join) values('sat',true,'school_mgt','sat.Semester_exam_performance',
		'left join (select school_id,school_performance as semester_exam_performance,school_management_type from semester_exam_school_mgmt_all where school_management_type is not null) as sat 
on stat.school_id=sat.school_id and stat.school_management_type=sat.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

/* updating semester composite to sat report */

update composite_config set select_query='sat.Semester_exam_performance',table_join='left join (select district_id,district_performance as Semester_exam_performance from semester_exam_district_all) as sat 
on stat.district_id=sat.district_id' where template='sat' and category='district'; 

update composite_config set select_query='sat.Semester_exam_performance',table_join='left join (select block_id,block_performance as Semester_exam_performance from semester_exam_block_all) as sat 
on stat.block_id=sat.block_id' where template='sat' and category='block'; 

update composite_config set select_query='sat.Semester_exam_performance',table_join='left join (select cluster_id,cluster_performance as semester_exam_performance from semester_exam_cluster_all) as sat 
on stat.cluster_id=sat.cluster_id' where template='sat' and category='cluster'; 

update composite_config set select_query='sat.Semester_exam_performance',table_join='left join (select school_id,school_performance as semester_exam_performance from semester_exam_school_all) as sat 
on stat.school_id=sat.school_id' where template='sat' and category='school'; 

insert into composite_config(template,status,category,table_join) values('udise',true,'school_mgt','left join udise_school_mgt_score
on stat.school_id=udise_school_mgt_score.udise_school_id and stat.school_management_type=udise_school_mgt_score.school_management_type')
on conflict on constraint composite_config_pkey do nothing;

update composite_config as uds set select_query= stg.select_query from 
(select string_agg(lower(column_name),',')||',infrastructure_score' as select_query from udise_config where type='indice' and status=true)as stg
where uds.template='udise';

update composite_config as uds set jolt_spec=stg.jolt_spec from 
(select string_agg(cols,',')||',"infrastructure_score": "[&1].Infrastructure Score(%).percent"' as jolt_spec from 
(select case when column_name like '%_Index' then string_agg('"'||lower(column_name)||'": "[&1].'||replace(split_part(column_name,'_Index',1),'_',' ')||
	'(%).percent"',',') else
string_agg('"'||lower(column_name)||'": "[&1].'||replace(column_name,'_',' ')||'(%).percent"',',') end as cols
from udise_config where status = '1' and type='indice' group by column_name)as a)as stg
where uds.template='udise';


update composite_config set status= false where lower(template) in (select lower(template) from nifi_template_info where status=false);

/*Composite jolt spec*/

update composite_config as uds set jolt_spec=stg.jolt_spec from 
(select string_agg(cols,',')||',"infrastructure_score": "[&1].Infrastructure Score(%).percent"' as jolt_spec from 
(select case when column_name like '%_Index' then string_agg('"'||lower(column_name)||'": "[&1].'||replace(split_part(column_name,'_Index',1),'_',' ')||
	'(%).percent"',',') else
string_agg('"'||lower(column_name)||'": "[&1].'||replace(column_name,'_',' ')||'(%).percent"',',') end as cols
from udise_config where status = '1' and type='indice' group by column_name)as a)as stg
where uds.template='udise';

update composite_config as uds set jolt_spec='"student_attendance": "[&1].Student Attendance(%).percent"' where uds.template='attendance';

        
update composite_config as uds set jolt_spec='"periodic_exam_performance": "[&1].Periodic Exam Performance(%).percent"' where uds.template='pat';        

update composite_config as uds set jolt_spec=
	 '"total_content_plays_textbook": "[&1].Total Content Plays-Textbook.value",
        "total_content_plays_course": "[&1].Total Content Plays-Course.value",
        "total_content_plays_all": "[&1].Total Content Plays-All.value"'
         where uds.template='diksha';        	
        
update composite_config as uds set jolt_spec=
	 '"semester_performance": "[&1].Semester Performance(%).percent",
	 "semester_exam_performance": "[&1].SAT Performance(%).percent",
        "semester_performance_grade_3": "[&1].Semester Performance Grade-3(%).percent",
        "semester_performance_grade_4": "[&1].Semester Performance Grade-4(%).percent",
        "semester_performance_grade_5": "[&1].Semester Performance Grade-5(%).percent",
        "semester_performance_grade_6": "[&1].Semester Performance Grade-6(%).percent",
        "semester_performance_grade_7": "[&1].Semester Performance Grade-7(%).percent",
        "semester_performance_grade_8": "[&1].Semester Performance Grade-8(%).percent"'
         where uds.template='sat';

/*Function to create composite management views*/

CREATE OR REPLACE FUNCTION composite_create_mgt_views()
RETURNS text AS
$$
DECLARE
select_query_dist text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''district_mgt'' order by id)as d';   
select_cols_dist text;
join_query_dist text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''district_mgt'' order by id)as d';
join_cols_dist text;
district_view text;
select_query_blk text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''block_mgt'' order by id)as d';   
select_cols_blk text;
join_query_blk text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''block_mgt'' order by id)as d';
join_cols_blk text;
block_view text;
select_query_cst text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''cluster_mgt'' order by id)as d';   
select_cols_cst text;
join_query_cst text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''cluster_mgt'' order by id)as d';
join_cols_cst text;
cluster_view text;
select_query_scl text:='select string_agg(col,'','') from (select concat(select_query)as col from composite_config where status=''true'' and category=''school_mgt'' order by id)as d';   
select_cols_scl text;
join_query_scl text:='select string_agg(col,'' '') from (select concat(table_join)as col from composite_config where status=''true'' and category=''school_mgt'' order by id)as d';
join_cols_scl text;
school_view text;
BEGIN
Execute select_query_dist into select_cols_dist;
Execute join_query_dist into join_cols_dist;
Execute select_query_blk into select_cols_blk;
Execute join_query_blk into join_cols_blk;
Execute select_query_cst into select_cols_cst;
Execute join_query_cst into join_cols_cst;
Execute select_query_scl into select_cols_scl;
Execute join_query_scl into join_cols_scl;
district_view='create or replace view composite_mgt_district as 
'||select_cols_dist||' '||join_cols_dist||';
';
Execute district_view; 
block_view='create or replace view composite_mgt_block as 
'||select_cols_blk||' '||join_cols_blk||';
';
Execute block_view; 
cluster_view='create or replace view composite_mgt_cluster as 
'||select_cols_cst||' '||join_cols_cst||';
';
Execute cluster_view; 
school_view='create or replace view composite_mgt_school as 
'||select_cols_scl||' '||join_cols_scl||';
';
Execute school_view; 
return 0;
END;
$$LANGUAGE plpgsql;

delete from composite_config where template='semester';

select composite_create_views();
select composite_create_mgt_views();
select composite_jolt_spec();
