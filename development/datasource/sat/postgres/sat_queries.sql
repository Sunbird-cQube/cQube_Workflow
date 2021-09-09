/*Drop functions if exists*/

drop function IF exists semester_no_schools;
drop view if exists sat_exception_data_all  cascade;
drop view if exists sat_exception_data_last7  cascade;
drop view if exists sat_exception_data_last30  cascade;
drop view if exists sat_exception_grade_data_all cascade;
drop view if exists sat_exception_grade_data_last7 cascade;
drop view if exists sat_exception_grade_data_last30 cascade;	
drop view if exists hc_sat_state_mgmt_overall cascade;
drop view if exists hc_sat_state_mgmt_last30 cascade;

create or replace function drop_view_sat()
returns int as
$body$
begin
drop view if exists semester_exam_district_all cascade;
drop view if exists semester_exam_block_all cascade;
drop view if exists semester_exam_cluster_all cascade;
drop view if exists semester_exam_school_all cascade;

drop view if exists semester_exam_district_last30 cascade;
drop view if exists semester_exam_block_last30 cascade;
drop view if exists semester_exam_cluster_last30 cascade;
drop view if exists semester_exam_school_last30 cascade;

drop view if exists semester_exam_district_last7 cascade;
drop view if exists semester_exam_block_last7 cascade;
drop view if exists semester_exam_cluster_last7 cascade;
drop view if exists semester_exam_school_last7 cascade;

drop view if exists semester_exam_district_mgmt_all cascade;
drop view if exists semester_exam_block_mgmt_all cascade;
drop view if exists semester_exam_cluster_mgmt_all cascade;
drop view if exists semester_exam_school_mgmt_all cascade;

drop view if exists semester_exam_district_mgmt_last30 cascade;
drop view if exists semester_exam_block_mgmt_last30 cascade;
drop view if exists semester_exam_cluster_mgmt_last30 cascade;
drop view if exists semester_exam_school_mgmt_last30 cascade;

drop view if exists semester_exam_district_mgmt_last7 cascade;
drop view if exists semester_exam_block_mgmt_last7 cascade;
drop view if exists semester_exam_cluster_mgmt_last7 cascade;
drop view if exists semester_exam_school_mgmt_last7 cascade;

  return 0;

    exception 
    when others then
        return 0;

end;
$body$
language plpgsql;

select drop_view_sat();

drop MATERIALIZED VIEW if exists sat_mgmt_lo_p1_indicator_all cascade;
drop MATERIALIZED VIEW if exists sat_mgmt_lo_p1_indicator_district cascade;
drop MATERIALIZED VIEW if exists sat_mgmt_lo_p1_indicator_block cascade;
drop MATERIALIZED VIEW if exists sat_mgmt_lo_p1_indicator_cluster cascade;
drop MATERIALIZED VIEW if exists sat_lo_p1_indicator_all cascade;
drop MATERIALIZED VIEW if exists sat_lo_p1_indicator_district cascade;
drop MATERIALIZED VIEW if exists sat_lo_p1_indicator_block cascade;
drop MATERIALIZED VIEW if exists sat_lo_p1_indicator_cluster cascade;

/*SAT views*/

/*daterange*/

create or replace view sat_date_range as 
(select exam_code,'last30days' as date_range from semester_exam_mst where exam_date between 
(select ((now()::Date)-INTERVAL '30 DAY')::Date) and (select now()::DATE) )
union
(select exam_code,'last7days' as date_range from semester_exam_mst where exam_date between 
(select ((now()::Date)-INTERVAL '7 DAY')::Date) and (select now()::DATE) );

/*   SAT materialized views */

/* last 30 days */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district_last30 AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by district_id,grade)
     WITH NO DATA ;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block_last30 AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by block_id,grade)
     WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster_last30 AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by cluster_id,grade)
     WITH NO DATA ;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school_last30 AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days')) 
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* management views */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by block_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days')) 
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;

/* last 7 days */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district_last7 AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by district_id,grade)
     WITH NO DATA ;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block_last7 AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by block_id,grade)
     WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster_last7 AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by cluster_id,grade)
     WITH NO DATA ;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school_last7 AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days')) 
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* management views */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by block_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days'))
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days'))
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;

/*------------------------Over all-------------------------------------------------*/

/* semester exam district*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as district_performance
from semester_exam_school_result group by academic_year,semester,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,
district_id from
(select academic_year,cast('Grade '||grade as text)as grade,
district_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
district_id)as a
group by district_id,academic_year,semester)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester)as c
left join 
(
select academic_year,district_id,semester,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,district_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from

((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,
district_id,semester order by grade desc,subject_name))as b
group by academic_year,district_id,grade,semester)as d
group by academic_year,district_id,semester
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.semester=d.semester) WITH NO DATA;

/*semester exam block*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_block_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as block_performance
from semester_exam_school_result group by academic_year,semester,
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,
block_id from
(select academic_year,cast('Grade '||grade as text)as grade,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
block_id)as a
group by block_id,academic_year,semester)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester)as c
left join 
(
select academic_year,semester,block_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,block_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
block_id order by grade desc,subject_name)) as a
group by academic_year,block_id,grade,semester)as d
group by academic_year,block_id,semester
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.semester=d.semester) WITH NO DATA;

/*semester exam cluster*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as cluster_performance
from semester_exam_school_result group by academic_year,semester,
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,
semester,cluster_id from
(select academic_year,cast('Grade '||grade as text)as grade,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
cluster_id)as a
group by cluster_id,academic_year,semester)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester)as c
left join 
(
select academic_year,cluster_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,semester from
(select academic_year,cluster_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
cluster_id order by grade desc,subject_name)) as a
group by academic_year,cluster_id,grade,semester)as d
group by academic_year,cluster_id,semester
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.semester=d.semester) WITH NO DATA;

/*semester exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_all as
(select d.* from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as school_performance
from semester_exam_school_result group by academic_year,semester,
school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,
school_id from
(select academic_year,cast('Grade '||grade as text)as grade,
school_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
school_id)as a
group by school_id,academic_year,semester)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester)as c
left join 
(select academic_year,semester,school_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,school_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
school_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
school_id order by grade desc,subject_name)) as a
group by academic_year,school_id,grade,semester)as d
group by academic_year,school_id,semester
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.semester=d.semester)as d) WITH NO DATA;


/*----------------------------------------------------------- sat grade subject wise*/

/* district - grade */

create or replace view semester_grade_district_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_all)as a
left join
(select academic_year,district_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
district_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
district_id order by 3,grade))as a
group by district_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester;


/*--- block - grade*/

create or replace view semester_grade_block_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance from semester_exam_block_all)as a
left join
(select academic_year,block_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
block_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
block_id order by 3,grade))as a
group by block_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester;

/*--- cluster - grade*/

create or replace view semester_grade_cluster_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_all)as a
left join
(select academic_year,cluster_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
cluster_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
cluster_id order by 3,grade))as a
group by cluster_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester;

/*--- school - grade*/

create or replace view semester_grade_school_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from semester_exam_school_all)as a
left join
(select academic_year,school_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,subject,semester,
school_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by academic_year,grade,semester,
school_id order by 3,grade))as a
group by school_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester;

/*------------------------last 30 days--------------------------------------------------------------------------------------------------------*/


/* materialized views */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_mgmt_last30 as
(select c.school_id,c.cluster_id,c.block_id,c.district_id,academic_year,semester,c.school_management_type,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from (select sem.school_id,student_uid,academic_year,sem.semester,school_management_type
from semester_exam_result_trans sert join semester_exam_school_result sem on sert.school_id=sem.school_id  
and sert.exam_code=sem.exam_code where sem.exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by sem.school_id,student_uid,academic_year,sem.semester,school_management_type) as a
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.school_id,academic_year,semester,c.school_management_type) WITH NO DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30 as
(select grade,academic_year,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,count(distinct school_id) as total_schools,semester from (
select concat('Grade ',studying_class) as grade,academic_year,
pert.school_id,cluster_id,block_id,district_id,student_uid,sem.semester,school_management_type from semester_exam_result_trans pert  join semester_exam_school_result sem on pert.school_id=sem.school_id  
and pert.exam_code=sem.exam_code
where sem.exam_code in (select exam_code from sat_date_range where date_range='last30days')) as a
group by school_id,cluster_id,block_id,district_id,grade,semester,academic_year,school_management_type) WITH NO DATA;

/*------------------------last 30 days--------------------------------------------------------------------------------------------------------*/

/* semester exam district*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by academic_year,semester,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, district_id,
								  semester) as b
join (select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_district_last30  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.district_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, subject, district_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade,semester
							, district_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join
 sat_school_grade_enrolment_district_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.district_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id)as d
left join 
 (select district_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 group by district_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days')) group by district_id) tot_stud
on d.district_id=tot_stud.district_id) WITH NO DATA; 


/* semester exam block*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_block_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,
block_id,initcap(block_name)as block_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by academic_year,semester,district_id,district_name,
block_id,block_name,block_latitude,block_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, block_id,
								  semester) as b
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_block_last30  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.block_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, subject, block_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade,semester
							, block_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join  sat_school_grade_enrolment_block_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.block_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id)as d
left join (select block_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 group by block_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days')) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA ; 


/* semester exam cluster*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by academic_year,semester,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, cluster_id,
								  semester) as b
join (select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_cluster_last30  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.cluster_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, subject, cluster_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade,semester
							, cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join
 sat_school_grade_enrolment_cluster_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id)as d
left join 
 (select cluster_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 group by cluster_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details
where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last30days')) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id)  WITH NO DATA; 


/* semester exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by academic_year,semester,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
school_id,school_name,school_latitude,school_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.school_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, school_id,
								  semester) as b
join sat_stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_school_last30  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.school_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade, subject, school_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                                  GROUP BY academic_year, grade,semester
							, school_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
sat_stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join  sat_school_grade_enrolment_school_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.school_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id)as d
left join 
sat_stud_count_school_mgmt_last30 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.semester=b.semester
   left join
 (select sum(students_count) as total_students,school_id from school_grade_enrolment  where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last30days')) group by school_id) tot_stud
on d.school_id=tot_stud.school_id) WITH NO DATA; 

/* school */
CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_school_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,school_performance from semester_exam_school_last30)as a
left join
(select academic_year,school_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
max(students_count) as total_students,max(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,
school_id order by 3,grade)as a
join sat_stud_count_school_grade_mgmt_last30 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade  and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_school_last30 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_school_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade
left join
sat_stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_cluster_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name)as cluster_name,
cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_last30)as a
left join
(select academic_year,cluster_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade  and a.academic_year=sa.academic_year and a.semester=sa.semester
left join sat_school_grade_enrolment_cluster_last30 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_cluster_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade
join
(select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_block_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from semester_exam_block_last30)as a
left join
(select academic_year,block_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,
block_id order by 3,grade)as a
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_block_last30 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_block_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade
join
(select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester) WITH NO DATA;


/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_district_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_last30)as a
left join
(select academic_year,district_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days')
 group by academic_year,grade,subject,semester,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days')
 group by academic_year,grade,semester,
district_id order by 3,grade)as a
join (select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade  and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_district_last30 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_district_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade
join
(select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/*------------------------last 7 days--------------------------------------------------------------------------------------------------------*/


/* materialized views */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_mgmt_last7 as
(select c.school_id,c.cluster_id,c.block_id,c.district_id,academic_year,semester,c.school_management_type,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from (select sem.school_id,student_uid,academic_year,sem.semester,school_management_type
from semester_exam_result_trans sert join semester_exam_school_result sem on sert.school_id=sem.school_id  
and sert.exam_code=sem.exam_code where sem.exam_code in (select exam_code from sat_date_range where date_range='last7days')
group by sem.school_id,student_uid,academic_year,sem.semester,school_management_type) as a
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.school_id,academic_year,semester,c.school_management_type) WITH NO DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_grade_mgmt_last7 as
(select grade,academic_year,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,count(distinct school_id) as total_schools,semester from (
select concat('Grade ',studying_class) as grade,academic_year,
pert.school_id,cluster_id,block_id,district_id,student_uid,sem.semester,school_management_type from semester_exam_result_trans pert  join semester_exam_school_result sem on pert.school_id=sem.school_id  
and pert.exam_code=sem.exam_code
where sem.exam_code in (select exam_code from sat_date_range where date_range='last7days')) as a
group by school_id,cluster_id,block_id,district_id,grade,semester,academic_year,school_management_type) WITH NO DATA;


/* semester exam district*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last7days')
group by academic_year,semester,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, district_id,
								  semester) as b
join (select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_district_last7  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.district_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, subject, district_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    district_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade,semester
							, district_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join
 sat_school_grade_enrolment_district_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.district_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id)as d
left join 
 (select district_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 group by district_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days')) group by district_id) tot_stud
on d.district_id=tot_stud.district_id)  WITH NO DATA; 


/* semester exam block*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_block_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,
block_id,initcap(block_name)as block_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last7days')
group by academic_year,semester,district_id,district_name,
block_id,block_name,block_latitude,block_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, block_id,
								  semester) as b
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_block_last7  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.block_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, subject, block_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    block_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade,semester
							, block_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join  sat_school_grade_enrolment_block_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.block_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id)as d
left join (select block_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 group by block_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days')) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA; 


/* semester exam cluster*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last7days')
group by academic_year,semester,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, cluster_id,
								  semester) as b
join (select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_cluster_last7  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.cluster_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, subject, cluster_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    cluster_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade,semester
							, cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join
 sat_school_grade_enrolment_cluster_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id)as d
left join 
 (select cluster_id,semester,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 group by cluster_id,semester,academic_year)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.semester=b.semester
   left join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details
where school_id in (select school_id from semester_exam_school_result where exam_code in  (select exam_code from sat_date_range where date_range='last7days')) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id) WITH NO DATA; 


/* semester exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last7days')
group by academic_year,semester,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
school_id,school_name,school_latitude,school_longitude) as a
left join 
(SELECT a_1.academic_year,semester,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.school_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage   
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, school_id,
								  semester) as b
join sat_stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year
left join
sat_school_grade_enrolment_school_last7  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year,a_1.semester)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id)as c
left join 
(SELECT d_2.academic_year,d_2.semester,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,b_1.semester,
                            b_1.school_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade, subject, school_id,semester
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    school_id,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
                                  GROUP BY academic_year, grade,semester
							, school_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
sat_stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year
left join  sat_school_grade_enrolment_school_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.school_id,d_2.semester
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id)as d
left join 
sat_stud_count_school_mgmt_last7 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.semester=b.semester
   left join
 (select sum(students_count) as total_students,school_id from school_grade_enrolment  where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last7days')) group by school_id) tot_stud
on d.school_id=tot_stud.school_id) WITH NO DATA; 

/* school */
CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_school_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,school_performance from semester_exam_school_last7)as a
left join
(select academic_year,school_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
max(students_count) as total_students,max(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,
school_id order by 3,grade)as a
join sat_stud_count_school_grade_mgmt_last7 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade  and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_school_last7 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_school_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade
left join
sat_stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_cluster_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name)as cluster_name,
cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_last7)as a
left join
(select academic_year,cluster_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade  and a.academic_year=sa.academic_year and a.semester=sa.semester
left join sat_school_grade_enrolment_cluster_last7 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_cluster_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade
join
(select cluster_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_block_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from semester_exam_block_last7)as a
left join
(select academic_year,block_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,
block_id order by 3,grade)as a
join (select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_block_last7 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_block_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade
join
(select block_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester) WITH NO DATA;


/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_district_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_last7)as a
left join
(select academic_year,district_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days')
 group by academic_year,grade,subject,semester,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days')
 group by academic_year,grade,semester,
district_id order by 3,grade)as a
join (select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade  and a.semester=sa.semester and a.academic_year=sa.academic_year
left join sat_school_grade_enrolment_district_last7 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester
left join
 sat_school_grade_enrolment_district_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade
join
(select district_id,grade,semester,academic_year,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.semester=c.semester and b.academic_year=c.academic_year) WITH NO DATA;

/*------Over all-----Management queries--------------------------------------------*/

/* semester exam district*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_district_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as district_performance,school_management_type
from semester_exam_school_result where school_management_type is not null and total_marks > 0group by academic_year,semester,school_management_type,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,school_management_type,
district_id from
(select academic_year,cast('Grade '||grade as text)as grade,
district_id,semester,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result where school_management_type is not null and total_marks > 0group by academic_year,grade,semester,school_management_type,
district_id)as a
group by district_id,academic_year,semester,school_management_type)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,district_id,semester,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,school_management_type from
(select academic_year,district_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,school_management_type from

((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null and total_marks > 0 group by academic_year,grade,subject,semester,school_management_type,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null and total_marks > 0 group by academic_year,grade,school_management_type,
district_id,semester order by grade desc,subject_name))as b
group by academic_year,district_id,grade,semester,school_management_type)as d
group by academic_year,district_id,semester,school_management_type
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.semester=d.semester and c.school_management_type=d.school_management_type
where c.school_management_type is not null)  WITH NO DATA;

/*semester exam block*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_block_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,semester,school_management_type,
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,
block_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,school_management_type
from semester_exam_school_result group by academic_year,grade,semester,school_management_type,
block_id)as a
group by block_id,academic_year,semester,school_management_type)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,semester,block_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,school_management_type from
(select academic_year,block_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,school_management_type from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,school_management_type
from semester_exam_school_result  where school_management_type is not null group by academic_year,grade,subject,semester,school_management_type,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
block_id order by grade desc,subject_name)) as a
group by academic_year,block_id,grade,semester,school_management_type)as d
group by academic_year,block_id,semester,school_management_type
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.semester=d.semester and c.school_management_type=d.school_management_type
where d.school_management_type is not null) WITH NO DATA;

/*semester exam cluster*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_cluster_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,school_management_type
from semester_exam_school_result  where school_management_type is not null group by academic_year,semester,school_management_type,
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,
semester,cluster_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
cluster_id)as a
group by cluster_id,academic_year,semester,school_management_type)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,cluster_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,semester,school_management_type from
(select academic_year,cluster_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,school_management_type from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,subject,semester,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
cluster_id order by grade desc,subject_name)) as a
group by academic_year,cluster_id,grade,semester,school_management_type)as d
group by academic_year,cluster_id,semester,school_management_type
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.semester=d.semester and c.school_management_type=d.school_management_type
 where  d.school_management_type is not null) WITH NO DATA;

/*semester exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_exam_school_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select academic_year,semester,
school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,semester,school_management_type,
school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select academic_year,semester,json_object_agg(grade,percentage) as grade_wise_performance,
school_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
school_id,semester,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
school_id)as a
group by school_id,academic_year,semester,school_management_type)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,semester,school_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,school_management_type from
(select academic_year,school_id,semester,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,school_management_type from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,subject,semester,school_management_type,
school_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
school_id order by grade desc,subject_name)) as a
group by academic_year,school_id,grade,semester,school_management_type)as d
group by academic_year,school_id,semester,school_management_type
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.semester=d.semester and c.school_management_type=d.school_management_type
where d.school_management_type is not null) WITH NO DATA;

/*----------------------------------------------------------- sat grade subject wise*/
/* district - grade */

create or replace view semester_grade_district_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,school_management_type
 from semester_exam_district_mgmt_all)as a
left join
(select academic_year,district_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects,school_management_type
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null 
group by academic_year,grade,subject,semester,district_id,school_management_type order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null 
group by academic_year,grade,semester,district_id,school_management_type order by 3,grade))as a
group by district_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester and a.school_management_type=b.school_management_type;


/*--- block - grade*/

create or replace view semester_grade_block_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance,school_management_type from semester_exam_block_mgmt_all)as a
left join
(select academic_year,block_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects,school_management_type
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null  group by academic_year,grade,subject,semester,school_management_type,
block_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
block_id order by 3,grade))as a
group by block_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester and a.school_management_type=b.school_management_type;

/*--- cluster - grade*/

create or replace view semester_grade_cluster_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance,school_management_type from semester_exam_cluster_mgmt_all)as a
left join
(select academic_year,cluster_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects,school_management_type
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,subject,semester,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
cluster_id order by 3,grade))as a
group by cluster_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester and a.school_management_type=b.school_management_type;

/*--- school - grade*/

create or replace view semester_grade_school_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,semester,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from semester_exam_school_mgmt_all)as a
left join
(select academic_year,school_id,grade,semester,
json_object_agg(subject_name,percentage order by subject_name) as subjects,school_management_type
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,subject,semester,school_management_type,
school_id order by grade desc,subject_name)
union
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where school_management_type is not null group by academic_year,grade,semester,school_management_type,
school_id order by 3,grade))as a
group by school_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester and a.school_management_type=b.school_management_type;


/*------------------------last 30 days--------------------------------------------------------------------------------------------------------*/
/* dist*/

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_mgmt_last30 as
(	select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,
	district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last30days')
	group by academic_year,school_management_type,semester,
	district_id,district_name,district_latitude,district_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.district_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade, semester,district_id,school_management_type) as b
	join (select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year,school_management_type) as c
	on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_district_mgmt_last30  tot_stud
	on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.district_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.district_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.district_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, semester,grade, subject, district_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, district_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by district_id,grade,semester,academic_year,school_management_type) as c
	on b.district_id=c.district_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_district_mgmt_last30 tot_stud
	on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.district_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select district_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 where school_management_type is not null group by district_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,district_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last30days'))group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/* block */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_block_mgmt_last30 as
	(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,
	block_id,initcap(block_name)as block_name,block_latitude,block_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last30days')
	group by academic_year,school_management_type,semester,district_id,district_name,
	block_id,block_name,block_latitude,block_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.block_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade, semester,block_id,school_management_type) as b
	join (select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year,school_management_type) as c
	on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_block_mgmt_last30  tot_stud
	on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.block_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.block_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.block_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, semester,grade, subject, block_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, block_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by block_id,grade,semester,academic_year,school_management_type) as c
	on b.block_id=c.block_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_block_mgmt_last30 tot_stud
	on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.block_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select block_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 where school_management_type is not null group by block_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,block_id from school_hierarchy_details 
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last30days')) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type  where d.school_management_type is not null) WITH NO DATA;  

/* cluster */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_mgmt_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
	cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last30days')
	group by academic_year,school_management_type,semester,district_id,district_name,block_id,block_name,
	cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.cluster_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade, semester,cluster_id,school_management_type) as b
	join (select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year,school_management_type) as c
	on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_cluster_mgmt_last30  tot_stud
	on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.cluster_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.cluster_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.cluster_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, semester,grade, subject, cluster_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, cluster_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 group by cluster_id,grade,semester,academic_year,school_management_type) as c
	on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_cluster_mgmt_last30 tot_stud
	on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select cluster_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last30 where school_management_type is not null group by cluster_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,cluster_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last30days')) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/* school */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_mgmt_last30 as
(	select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
	school_id,initcap(school_name)as school_name,school_latitude,school_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last30days')
	group by academic_year,school_management_type,semester,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
	school_id,school_name,school_latitude,school_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.school_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade, semester,school_id,school_management_type) as b
	join sat_stud_count_school_grade_mgmt_last30 as c
	on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_school_mgmt_last30  tot_stud
	on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.school_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.school_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.school_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, semester,grade, subject, school_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, school_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	sat_stud_count_school_grade_mgmt_last30 as c
	on b.school_id=c.school_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_school_mgmt_last30 tot_stud
	on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.school_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
sat_stud_count_school_mgmt_last30 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,school_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last30days')) group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/*----------------------------------------------------------- sat grade subject wise*/

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_district_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_mgmt_last30)as a
left join
(select academic_year,district_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,school_management_type,
district_id order by 3,grade)as a
	join (select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by district_id,grade,semester,academic_year,school_management_type) as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_district_mgmt_last30 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester and a.school_management_type =b.school_management_type
join
(select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by district_id,grade,semester,academic_year,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_district_mgmt_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_block_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from semester_exam_block_mgmt_last30)as a
left join
(select academic_year,block_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,school_management_type,
block_id order by 3,grade)as a
	join (select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by block_id,grade,semester,academic_year,school_management_type)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_block_mgmt_last30 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester and a.school_management_type =b.school_management_type
join
(select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by block_id,grade,semester,academic_year,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_block_mgmt_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_cluster_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_mgmt_last30)as a
left join
(select academic_year,cluster_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,subject,semester,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,school_management_type,
cluster_id order by 3,grade)as a
	join (select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by cluster_id,grade,semester,academic_year,school_management_type)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_cluster_mgmt_last30 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester and a.school_management_type =b.school_management_type
left join
 sat_school_grade_enrolment_cluster_mgmt_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
join
(select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last30 where school_management_type is not null group by cluster_id,grade,semester,academic_year,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type)
 WITH NO DATA;

/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_school_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name)as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,school_performance from semester_exam_school_mgmt_last30)as a
left join
(select academic_year,school_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') 
group by academic_year,grade,subject,semester,school_management_type,school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days') group by academic_year,grade,semester,school_management_type,
school_id order by 3,grade)as a
	join sat_stud_count_school_grade_mgmt_last30 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_school_mgmt_last30 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by a.school_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester and a.school_management_type =b.school_management_type
left join
 sat_school_grade_enrolment_school_mgmt_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
left join
sat_stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type)
 WITH NO DATA;

/*------------------------last 7 days--------------------------------------------------------------------------------------------------------*/

/* dist*/

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_mgmt_last7 as
(	select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,
	district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last7days')
	group by academic_year,school_management_type,semester,
	district_id,district_name,district_latitude,district_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.district_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade, semester,district_id,school_management_type) as b
	join (select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year,school_management_type) as c
	on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_district_mgmt_last7  tot_stud
	on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.district_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.district_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.district_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, semester,grade, subject, district_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										district_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, district_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by district_id,grade,semester,academic_year,school_management_type) as c
	on b.district_id=c.district_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_district_mgmt_last7 tot_stud
	on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.district_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select district_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 where school_management_type is not null group by district_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,district_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last7days'))group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/* block */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_block_mgmt_last7 as
	(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,
	block_id,initcap(block_name)as block_name,block_latitude,block_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last7days')
	group by academic_year,school_management_type,semester,district_id,district_name,
	block_id,block_name,block_latitude,block_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.block_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade, semester,block_id,school_management_type) as b
	join (select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year,school_management_type) as c
	on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_block_mgmt_last7  tot_stud
	on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.block_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.block_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.block_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, semester,grade, subject, block_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										block_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, block_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by block_id,grade,semester,academic_year,school_management_type) as c
	on b.block_id=c.block_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_block_mgmt_last7 tot_stud
	on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.block_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select block_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 where school_management_type is not null group by block_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,block_id from school_hierarchy_details 
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last7days')) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type  where d.school_management_type is not null) WITH NO DATA;  

/* cluster */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_mgmt_last7 as
	(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
	cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last7days')
	group by academic_year,school_management_type,semester,district_id,district_name,block_id,block_name,
	cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.cluster_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade, semester,cluster_id,school_management_type) as b
	join (select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year,school_management_type) as c
	on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_cluster_mgmt_last7  tot_stud
	on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.cluster_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.cluster_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.cluster_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, semester,grade, subject, cluster_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										cluster_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, cluster_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	(select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 group by cluster_id,grade,semester,academic_year,school_management_type) as c
	on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_cluster_mgmt_last7 tot_stud
	on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
 (select cluster_id,semester,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
 from sat_stud_count_school_mgmt_last7 where school_management_type is not null group by cluster_id,semester,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,cluster_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last7days')) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/* school */

	CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_mgmt_last7 as
	(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
	(select c.*,d.subject_wise_performance from
	(select a.*,b.grade_wise_performance from
	(select academic_year,semester,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
	school_id,initcap(school_name)as school_name,school_latitude,school_longitude,
	round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,school_management_type
	from semester_exam_school_result 
	where exam_code in (select exam_code from sat_date_range where date_range='last7days')
	group by academic_year,school_management_type,semester,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
	school_id,school_name,school_latitude,school_longitude) as a
	left join 
	(SELECT a_1.academic_year,semester,
								json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
								a_1.school_id,school_management_type
							   FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
	school_management_type									
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade, semester,school_id,school_management_type) as b
	join sat_stud_count_school_grade_mgmt_last7 as c
	on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	sat_school_grade_enrolment_school_mgmt_last7  tot_stud
	on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
	GROUP BY a_1.school_id, a_1.academic_year,school_management_type,semester)as b
	on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type and a.semester=b.semester)as c
	left join 
	(SELECT d_2.academic_year,d_2.semester,
						d_2.school_id,
						json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,school_management_type
					   FROM (SELECT b_1.academic_year,b_1.semester,
								b_1.school_id,
								grade,
								json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
								'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance,school_management_type
							   FROM (( SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										subject AS subject_name,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,school_management_type,
										sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, semester,grade, subject, school_id,school_management_type
									  ORDER BY ('Grade '::text || grade) DESC, subject)
									UNION
									( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,semester,
										'Grade '::text || grade AS grade,
										'Grade Performance'::text AS subject_name,
										school_id,
										round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
										school_management_type
									   FROM semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last7days')
									  GROUP BY academic_year, grade,school_management_type,semester
								, school_id
									  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
	join
	sat_stud_count_school_grade_mgmt_last7 as c
	on b.school_id=c.school_id and b.grade=c.grade  and b.school_management_type=c.school_management_type and b.semester=c.semester
	left join
	 sat_school_grade_enrolment_school_mgmt_last7 tot_stud
	on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type )) b_1
							  GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.school_management_type,b_1.semester) d_2
					  GROUP BY d_2.academic_year, d_2.school_id,d_2.school_management_type,d_2.semester
	)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.school_management_type=d.school_management_type and c.semester=d.semester)as d
left join 
sat_stud_count_school_mgmt_last7 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.semester=b.semester and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_management_type,school_id from  school_hierarchy_details
 where school_id in (select school_id from semester_exam_school_result where exam_code in 
 (select exam_code from sat_date_range where date_range='last7days')) group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA; 


/*----------------------------------------------------------- sat grade subject wise*/

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_district_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_mgmt_last7)as a
left join
(select academic_year,district_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,school_management_type,
district_id order by 3,grade)as a
	join (select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by district_id,grade,semester,academic_year,school_management_type) as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_district_mgmt_last7 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester and a.school_management_type =b.school_management_type
join
(select district_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by district_id,grade,semester,academic_year,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_district_mgmt_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_block_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from semester_exam_block_mgmt_last7)as a
left join
(select academic_year,block_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,school_management_type,
block_id order by 3,grade)as a
	join (select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by block_id,grade,semester,academic_year,school_management_type)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_block_mgmt_last7 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester and a.school_management_type =b.school_management_type
join
(select block_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by block_id,grade,semester,academic_year,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_block_mgmt_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_cluster_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_mgmt_last7)as a
left join
(select academic_year,cluster_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,subject,semester,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,school_management_type,
cluster_id order by 3,grade)as a
	join (select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by cluster_id,grade,semester,academic_year,school_management_type)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_cluster_mgmt_last7 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester and a.school_management_type =b.school_management_type
left join
 sat_school_grade_enrolment_cluster_mgmt_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
join
(select cluster_id,grade,semester,academic_year,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_last7 where school_management_type is not null group by cluster_id,grade,semester,academic_year,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type)
 WITH NO DATA;

/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_grade_school_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_management_type,semester,district_id,initcap(district_name)as district_name,block_id,initcap(block_name)as block_name,cluster_id,initcap(cluster_name)as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude,school_performance from semester_exam_school_mgmt_last7)as a
left join
(select academic_year,school_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,semester,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') 
group by academic_year,grade,subject,semester,school_management_type,school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,semester,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage,count(distinct school_id) as total_schools
from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last7days') group by academic_year,grade,semester,school_management_type,
school_id order by 3,grade)as a
	join sat_stud_count_school_grade_mgmt_last7 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.semester=sa.semester and a.academic_year=sa.academic_year and a.school_management_type=sa.school_management_type
left join sat_school_grade_enrolment_school_mgmt_last7 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by a.school_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester and a.school_management_type =b.school_management_type
left join
 sat_school_grade_enrolment_school_mgmt_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
left join
sat_stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade and b.semester=c.semester and b.academic_year=c.academic_year and b.school_management_type=c.school_management_type) WITH NO DATA;

/* SAT Exception no schools */

CREATE OR REPLACE FUNCTION sat_no_schools()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
sat_no_schools_all text;
sat_no_schools_last7 text;
sat_no_schools_last30 text;
BEGIN
sat_no_schools_all= 'create or replace view sat_exception_data_all as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,d.semester,
 b.district_latitude,b.district_longitude from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select school_id,pem.semester from school_hierarchy_details cross join (select semester from semester_exam_mst  
where semester in (select semester from semester_exam_school_result)) pem
 except select school_id,semester from semester_exam_school_result) as d on a.school_id=d.school_id 
 where  a.school_id<>9999';


sat_no_schools_last7= 'create or replace view sat_exception_data_last7 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,d.semester,
 b.district_latitude,b.district_longitude from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select school_id,pem.semester from school_hierarchy_details cross join (select semester from semester_exam_mst  
where semester in (select semester from semester_exam_school_result where  exam_code in  (select sat_date_range.exam_code from sat_date_range where sat_date_range.date_range=''last7days''::text)))  pem
 except select school_id,semester from semester_exam_school_result 
 where exam_code in  (select sat_date_range.exam_code from sat_date_range where sat_date_range.date_range=''last7days''::text)) as d on a.school_id=d.school_id 
 where  a.school_id<>9999';


sat_no_schools_last30= 'create or replace view sat_exception_data_last30 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,d.semester,
 b.district_latitude,b.district_longitude from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select school_id,pem.semester from school_hierarchy_details cross join (select semester from semester_exam_mst  
where semester in (select semester from semester_exam_school_result where  exam_code in  (select sat_date_range.exam_code from sat_date_range where sat_date_range.date_range=''last30days''::text)))  pem
 except select school_id,semester from semester_exam_school_result 
 where exam_code in  (select sat_date_range.exam_code from sat_date_range where sat_date_range.date_range=''last30days''::text)) as d on a.school_id=d.school_id 
 where  a.school_id<>9999';

Execute sat_no_schools_all;
Execute sat_no_schools_last7;
Execute sat_no_schools_last30;
return 0;
END;
$function$;

select sat_no_schools();

/* SAT Exception no grades of school */
CREATE OR REPLACE FUNCTION sat_no_schools_grade()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
sat_grade_no_schools_all text;
sat_grade_no_schools_last7 text;
sat_grade_no_schools_last30 text;
BEGIN
sat_grade_no_schools_all = 'create or replace view sat_exception_grade_data_all as
 select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''1'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=1
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard where semester=1
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=1) as d on a.school_id = d.school_id where semester=1
 and  exists (select school_id from semester_exam_school_result where semester=1)
 union 
  select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''2'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=2
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard where semester=1
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=2) as d on a.school_id = d.school_id where semester=2 and 
 exists (select school_id from semester_exam_school_result where semester=2)';

sat_grade_no_schools_last7 = 'create or replace view sat_exception_grade_data_last7 as
 select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''1'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from sat_date_range where date_range=''last7days'')
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=1
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard 
where semester=1 and exam_code in(select exam_code from sat_date_range where date_range=''last7days'')
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=1) as d on a.school_id = d.school_id where semester=1
 and  exists (select school_id from semester_exam_school_result where semester=1 and exam_code in(select exam_code from sat_date_range where date_range=''last7days'') )
 union 
 select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''2'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from sat_date_range where date_range=''last7days'')
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=2
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard 
where semester=2 and exam_code in(select exam_code from sat_date_range where date_range=''last7days'')
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=2) as d on a.school_id = d.school_id where semester=2
 and  exists (select school_id from semester_exam_school_result where semester=2 and exam_code in(select exam_code from sat_date_range where date_range=''last7days'') )';

sat_grade_no_schools_last30 = 'create or replace view sat_exception_grade_data_last30 as
  select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''1'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from sat_date_range where date_range=''last30days'')
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=1
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard 
where semester=1 and exam_code in(select exam_code from sat_date_range where date_range=''last30days'')
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=1) as d on a.school_id = d.school_id where semester=1
 and  exists (select school_id from semester_exam_school_result where semester=1 and exam_code in(select exam_code from sat_date_range where date_range=''last30days'') )
 union 
 select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,''2'' as semester,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject,semester from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join semester_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from sat_date_range where date_range=''last30days'')
 except select school_id,grade,subject,semester from semester_exam_school_result where semester=2
union
select distinct sma.*,''grade'' as subject,semester from (select school_id,grade from school_grade_enrolment) sma inner join semester_exam_mst  pm on sma.grade=pm.standard 
where semester=2 and exam_code in(select exam_code from sat_date_range where date_range=''last30days'')
 except select school_id,grade,''grade'' as subject,semester from semester_exam_school_result where semester=2) as d on a.school_id = d.school_id where semester=2
 and  exists (select school_id from semester_exam_school_result where semester=2 and exam_code in(select exam_code from sat_date_range where date_range=''last30days'') )';

Execute sat_grade_no_schools_all;
Execute sat_grade_no_schools_last7;
Execute sat_grade_no_schools_last30;

return 0;
END;
$function$;

select sat_no_schools_grade();

/* SAT indexes */

create index  IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last30_district_id_idx ON sat_school_grade_enrolment_district_mgmt_last30 (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last30_grade_idx on sat_school_grade_enrolment_district_mgmt_last30(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last30_school_management_type_idx on sat_school_grade_enrolment_district_mgmt_last30(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last30_block_id_idx ON sat_school_grade_enrolment_block_mgmt_last30 (block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last30_grade_idx on sat_school_grade_enrolment_block_mgmt_last30(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last30_school_management_type_idx on sat_school_grade_enrolment_block_mgmt_last30(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last30_cluster_id_idx ON sat_school_grade_enrolment_cluster_mgmt_last30 (cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last30_grade_idx on sat_school_grade_enrolment_cluster_mgmt_last30(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last30_school_management_type_idx on sat_school_grade_enrolment_cluster_mgmt_last30(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last30_cluster_id_idx ON sat_school_grade_enrolment_school_mgmt_last30 (school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last30_grade_idx on sat_school_grade_enrolment_school_mgmt_last30(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last30_school_management_type_idx on sat_school_grade_enrolment_school_mgmt_last30(school_management_type);


create index  IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last7_district_id_idx ON sat_school_grade_enrolment_district_mgmt_last7 (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last7_grade_idx on sat_school_grade_enrolment_district_mgmt_last7(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_last7_school_management_type_idx on sat_school_grade_enrolment_district_mgmt_last7(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last7_block_id_idx ON sat_school_grade_enrolment_block_mgmt_last7 (block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last7_grade_idx on sat_school_grade_enrolment_block_mgmt_last7(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_last7_school_management_type_idx on sat_school_grade_enrolment_block_mgmt_last7(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last7_cluster_id_idx ON sat_school_grade_enrolment_cluster_mgmt_last7 (cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last7_grade_idx on sat_school_grade_enrolment_cluster_mgmt_last7(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_last7_school_management_type_idx on sat_school_grade_enrolment_cluster_mgmt_last7(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last7_cluster_id_idx ON sat_school_grade_enrolment_school_mgmt_last7 (school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last7_grade_idx on sat_school_grade_enrolment_school_mgmt_last7(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_last7_school_management_type_idx on sat_school_grade_enrolment_school_mgmt_last7(school_management_type);

create index  IF NOT EXISTS sat_school_grade_enrolment_district_last30_district_id_idx ON sat_school_grade_enrolment_district_last30 (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_last30_grade_idx on sat_school_grade_enrolment_district_last30(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_block_last30_block_id_idx ON sat_school_grade_enrolment_block_last30 (block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_last30_grade_idx on sat_school_grade_enrolment_block_last30(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_cluster_last30_cluster_id_idx ON sat_school_grade_enrolment_cluster_last30 (cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_last30_grade_idx on sat_school_grade_enrolment_cluster_last30(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_school_last30_cluster_id_idx ON sat_school_grade_enrolment_school_last30 (school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_last30_grade_idx on sat_school_grade_enrolment_school_last30(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_district_last7_district_id_idx ON sat_school_grade_enrolment_district_last7 (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_last7_grade_idx on sat_school_grade_enrolment_district_last7(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_block_last7_block_id_idx ON sat_school_grade_enrolment_block_last7 (block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_last7_grade_idx on sat_school_grade_enrolment_block_last7(grade);

create index  IF NOT EXISTS sat_school_grade_enrolment_cluster_last7_cluster_id_idx ON sat_school_grade_enrolment_cluster_last7 (cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_last7_grade_idx on sat_school_grade_enrolment_cluster_last7(grade);

create index IF NOT EXISTS sat_school_grade_enrolment_school_last7_cluster_id_idx ON sat_school_grade_enrolment_school_last7 (school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_last7_grade_idx on sat_school_grade_enrolment_school_last7(grade);

create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30_school_id_idx ON sat_stud_count_school_grade_mgmt_last30 (school_id);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30_grade_idx on sat_stud_count_school_grade_mgmt_last30(grade);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30_semester_idx on sat_stud_count_school_grade_mgmt_last30(semester);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30_school_mgmt_type_idx on sat_stud_count_school_grade_mgmt_last30(school_management_type);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_last30_academic_year_idx on sat_stud_count_school_grade_mgmt_last30(academic_year);


/* SAT MGMT overall */
create or replace view hc_sat_state_mgmt_overall as 
select sp.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance
        FROM (
                SELECT (
                        'grade '::text || semester_exam_school_result.grade
                    ) AS grade,
                    round(
                        (
                            (
                                COALESCE(
                                    sum(semester_exam_school_result.obtained_marks),
                                    (0)::numeric
                                ) * 100.0
                            ) / COALESCE(
                                sum(semester_exam_school_result.total_marks),
                                (0)::numeric
                            )
                        ),
                        1
                    ) AS percentage,
                    school_management_type
                FROM semester_exam_school_result where school_management_type is not null 
                GROUP BY grade,school_management_type
            ) a_1 group by school_management_type) smt
     LEFT JOIN   (SELECT round(
                (
                    (
                        COALESCE(
                            sum(obtained_marks),
                            (0)::numeric
                        ) * 100.0
                    ) / COALESCE(
                        sum(total_marks),
                        (0)::numeric
                    )
                ),
                1
            ) AS school_performance,
            school_management_type
        FROM semester_exam_school_result where school_management_type is not null group by school_management_type) sp on sp.school_management_type=smt.school_management_type
     LEFT JOIN ( SELECT 
            count(DISTINCT a.student_uid) AS students_count,
            count(DISTINCT a.school_id) AS total_schools,
            c.school_management_type
           FROM ( SELECT exam_id,school_id,student_uid
                   FROM semester_exam_result_trans
                  WHERE (school_id IN ( SELECT school_id
                           FROM semester_exam_school_result
                          WHERE school_management_type IS NOT NULL))
                  GROUP BY exam_id, school_id, student_uid) a
             LEFT JOIN ( SELECT exam_id,
                    date_part('year'::text, exam_date)::text AS assessment_year
                   FROM semester_exam_mst) b_1 ON a.exam_id = b_1.exam_id
             LEFT JOIN school_hierarchy_details c ON a.school_id = c.school_id where c.school_management_type is not null
          GROUP BY c.school_management_type) b ON smt.school_management_type::text = b.school_management_type::text;

/* SAT MGMT last 30 days */
create or replace view hc_sat_state_mgmt_last30 as 
select sp.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance
        FROM (
                SELECT (
                        'grade '::text || semester_exam_school_result.grade
                    ) AS grade,
                    round(
                        (
                            (
                                COALESCE(
                                    sum(semester_exam_school_result.obtained_marks),
                                    (0)::numeric
                                ) * 100.0
                            ) / COALESCE(
                                sum(semester_exam_school_result.total_marks),
                                (0)::numeric
                            )
                        ),
                        1
                    ) AS percentage,
                    school_management_type
                FROM semester_exam_school_result where school_management_type is not null AND (exam_code::text IN ( SELECT exam_code
                           FROM sat_date_range
                          WHERE sat_date_range.date_range = 'last30days'::text))
                GROUP BY grade,school_management_type
            ) a_1 group by school_management_type) smt
     LEFT JOIN   (SELECT round(
                (
                    (
                        COALESCE(
                            sum(obtained_marks),
                            (0)::numeric
                        ) * 100.0
                    ) / COALESCE(
                        sum(total_marks),
                        (0)::numeric
                    )
                ),
                1
            ) AS school_performance,
            school_management_type
        FROM semester_exam_school_result where school_management_type is not null AND (exam_code::text IN ( SELECT sat_date_range.exam_code
                           FROM sat_date_range
                          WHERE sat_date_range.date_range = 'last30days'::text))
                 group by school_management_type) sp on sp.school_management_type=smt.school_management_type
     LEFT JOIN ( SELECT 
            count(DISTINCT a.student_uid) AS students_count,
            count(DISTINCT a.school_id) AS total_schools,
            c.school_management_type
           FROM ( SELECT exam_id,school_id,student_uid
                   FROM semester_exam_result_trans
                  WHERE (school_id IN ( SELECT school_id
                           FROM semester_exam_school_result
                          WHERE school_management_type IS NOT NULL)) AND (exam_code::text IN ( SELECT sat_date_range.exam_code
                           FROM sat_date_range
                          WHERE sat_date_range.date_range = 'last30days'::text))
                  GROUP BY exam_id, school_id, student_uid) a
             LEFT JOIN ( SELECT exam_id,
                    date_part('year'::text, exam_date)::text AS assessment_year
                   FROM semester_exam_mst) b_1 ON a.exam_id = b_1.exam_id
             LEFT JOIN school_hierarchy_details c ON a.school_id = c.school_id where c.school_management_type is not null
          GROUP BY c.school_management_type) b ON smt.school_management_type::text = b.school_management_type::text;

/* HC Semester School Management views */
create or replace view hc_semester_exam_school_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days') and school_management_type is not null
group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
school_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_id,school_management_type)as a
group by school_id,school_management_type)as b
on a.school_id=b.school_id and a.school_management_type=b.school_management_type)as c
left join 
(
select school_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select school_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days') and school_management_type is not null
group by grade,subject,school_management_type,
school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,
school_id order by grade desc,subject_name)) as a
group by school_id,grade,school_management_type)as d
group by school_id,school_management_type
)as d on c.school_id=d.school_id and c.school_management_type=d.school_management_type)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_id,school_id,student_uid
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result where school_management_type is not null)
and exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id,school_management_type)as b
 on d.school_id=b.school_id and d.school_management_type=b.school_management_type;


/* HC semester exam school overall*/

create or replace view hc_semester_exam_school_mgmt_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from semester_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from semester_exam_school_result where  school_management_type is not null
 group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
school_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where  school_management_type is not null
group by grade,school_id,school_management_type)as a
group by school_id,school_management_type)as b
on a.school_id=b.school_id and a.school_management_type=b.school_management_type)as c
left join 
(
select school_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select school_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where  school_management_type is not null 
group by grade,subject,school_management_type,school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from semester_exam_school_result where  school_management_type is not null group by grade,school_management_type,
school_id order by grade desc,subject_name)) as a
group by school_id,grade,school_management_type)as d
group by school_id,school_management_type
)as d on c.school_id=d.school_id and c.school_management_type=d.school_management_type)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count where school_id in (select school_id from semester_exam_school_result where  school_management_type is not null)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id ,school_management_type)as b
 on d.school_id=b.school_id and d.school_management_type=b.school_management_type;
 
/* health card state last 30 days */ 

create or replace view hc_sat_state_last30 as
 select (select round(((coalesce(sum(semester_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(semester_exam_school_result.total_marks), (1)::numeric)), 1) as school_performance
        from semester_exam_school_result  where exam_code in (select exam_code from sat_date_range where date_range='last30days')),
        (select json_object_agg(a_1.grade, a_1.percentage) as grade_wise_performance
                   from ( select ('grade '::text || semester_exam_school_result.grade) as grade,
                            round(((coalesce(sum(semester_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(semester_exam_school_result.total_marks), (1)::numeric)), 1) as percentage
                           from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')
                          group by semester_exam_school_result.grade) a_1),
        (select sum(students_count) as students_count from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days')),
        (select count(distinct school_id) as total_schools from semester_exam_school_result where exam_code in (select exam_code from sat_date_range where date_range='last30days'));
        
/* health card state overall */ 
create or replace view hc_sat_state_overall as
 select (select round(((coalesce(sum(semester_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(semester_exam_school_result.total_marks), (0)::numeric)), 1) as school_performance
        from semester_exam_school_result),
        (select json_object_agg(a_1.grade, a_1.percentage) as grade_wise_performance
                   from ( select ('grade '::text || semester_exam_school_result.grade) as grade,
                            round(((coalesce(sum(semester_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(semester_exam_school_result.total_marks), (0)::numeric)), 1) as percentage
                           from semester_exam_school_result
                          group by semester_exam_school_result.grade) a_1),
        (select sum(students_count) as students_count from (select a.school_id,b.assessment_year as academic_year,b.semester,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year,semester from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
where b.assessment_year is not null
group by a.school_id,b.assessment_year,semester )as a ),
        (select sum(total_schools) as total_schools from (select a.school_id,b.assessment_year as academic_year,b.semester,
	count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year,semester from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
where b.assessment_year is not null
group by a.school_id,b.assessment_year,semester )as b);

/* sat heatchart queries */

create materialized view if not exists sat_mgmt_lo_p1_indicator_all as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students,school_management_type from semester_exam_school_ind_result  where school_management_type is not null group by academic_year,grade,subject,exam_date,district_id,district_name,indicator,school_management_type) with no data; 

create materialized view if not exists sat_mgmt_lo_p1_indicator_district as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students,school_management_type from semester_exam_school_ind_result  where school_management_type is not null group by academic_year,grade,subject,exam_date,block_id,block_name,district_id,district_name,indicator,school_management_type) with no data;

create materialized view if not exists sat_mgmt_lo_p1_indicator_block as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,cluster_id,cluster_name,district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students,school_management_type from semester_exam_school_ind_result  where school_management_type is not null group by academic_year,grade,subject,exam_date,block_id,block_name,cluster_id,cluster_name,school_management_type, district_id,district_name,indicator) with no data ;

create materialized view if not exists sat_mgmt_lo_p1_indicator_cluster as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,cluster_id,cluster_name,school_id,school_name,district_id,district_name,indicator,sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students,school_management_type from semester_exam_school_ind_result  where school_management_type is not null group by academic_year,grade,subject,exam_date,block_id,block_name,cluster_id,cluster_name,school_id,school_name,school_management_type, district_id,district_name,indicator ) with no data;

create materialized view if not exists sat_lo_p1_indicator_all as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students from semester_exam_school_ind_result group by academic_year,grade,subject,exam_date,district_id,district_name,indicator) with no data ;

create materialized view if not exists sat_lo_p1_indicator_district as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students from semester_exam_school_ind_result group by academic_year,grade,subject,exam_date,block_id,block_name,district_id,district_name,indicator) with no data;

create materialized view if not exists sat_lo_p1_indicator_block as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,cluster_id,cluster_name,district_id,district_name,indicator, sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students from semester_exam_school_ind_result group by academic_year,grade,subject,exam_date,block_id,block_name,cluster_id,cluster_name, district_id,district_name,indicator) with no data;

create materialized view if not exists sat_lo_p1_indicator_cluster as (select academic_year,grade,subject as subject_name,to_char(cast(exam_date as text)::DATE,'dd-mm-yyyy')as exam_date, block_id,block_name,cluster_id,cluster_name,school_id,school_name,district_id,district_name,indicator,sum(students_attended) as students_attended, rtrim(ltrim(TO_CHAR( TO_TIMESTAMP (date_part('month',exam_date)::text, 'MM'), 'Month' )))as month, round(coalesce(sum(obtained_marks),0)/nullif(coalesce(sum(total_marks),0),0),1)as marks, round(coalesce((sum(obtained_marks)*100),0)/nullif(coalesce(sum(total_marks),0),0),1)as percentage, count(school_id)as total_schools,sum(total_students) as total_students from semester_exam_school_ind_result group by academic_year,grade,subject,exam_date,block_id,block_name,cluster_id,cluster_name,school_id,school_name, district_id,district_name,indicator) with no data;



/* Materialized views for calculating total_students */
/* year month */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result)
 group by district_id,grade)
     WITH NO DATA ;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result)
 group by block_id,grade)
     WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result)
 group by cluster_id,grade)
     WITH NO DATA ;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from semester_exam_school_result)
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* management views */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_district_mgmt AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result) and school_management_type is not NULL
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_block_mgmt AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result) and school_management_type is not NULL
 group by block_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from semester_exam_school_result) and school_management_type is not NULL
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_school_grade_enrolment_school_mgmt AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from semester_exam_school_result) and school_management_type is not NULL
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;


/* SAT year and semester */

CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_mgmt_year_semester as
(select a.school_id,c.cluster_id,c.block_id,c.district_id,b.assessment_year as academic_year,b.semester,school_management_type,
    count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count 
group by exam_code,school_id,student_uid) as a
left join (select exam_code,assessment_year, semester from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id,b.assessment_year,semester,school_management_type,cluster_id,block_id,district_id) WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester as
(select grade,semester,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,
case when month in (6,7,8,9,10,11,12) then 
(year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,
count(distinct school_id) as total_schools from (select concat('Grade ',studying_class) as grade,cast (substring (pert.exam_code,10,2) as integer) as month ,  
cast (right(pert.exam_code,4)as integer) as year,pert.school_id,cluster_id,block_id,district_id,semester,
school_management_type,student_uid from semester_exam_stud_grade_count pert  join school_hierarchy_details shd on pert.school_id=shd.school_id join semester_exam_mst sem on pert.exam_code=sem.exam_code ) as a	
group by school_id,semester,grade,academic_year,school_management_type,cluster_id,block_id,district_id) WITH NO DATA;



/* District */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_year_semester AS
 (SELECT d.academic_year,
    d.district_id,
    d.district_name,
    d.district_latitude,
    d.district_longitude,
    d.district_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
            c.district_id,
            c.district_name,
            c.district_latitude,
            c.district_longitude,
            c.district_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM (SELECT a.academic_year,
                    a.district_id,
                    a.district_name,
                    a.district_latitude,
                    a.district_longitude,
                    a.district_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,
                            semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,
                            semester_exam_school_result.district_latitude,
                            semester_exam_school_result.district_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS district_performance                           FROM semester_exam_school_result
                          GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester,semester_exam_school_result.district_id, semester_exam_school_result.district_name, semester_exam_school_result.district_latitude, semester_exam_school_result.district_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.district_id,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.district_id) as b
join (select district_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
sat_school_grade_enrolment_district  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year, a_1.semester) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.district_id = b_1.district_id AND a.semester = b_1.semester) c
 
             LEFT JOIN (SELECT d_2.academic_year,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.district_id,semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result
								   	GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.subject,semester_exam_school_result.semester, semester_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.district_id,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,
								  semester_exam_school_result.semester, semester_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_district tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade, b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.district_id, d_2.semester) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.district_id = d_1.district_id AND c.semester = d_1.semester) d
     LEFT JOIN (select district_id,academic_year,semester,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by district_id,academic_year,semester) b ON d.academic_year::text = b.academic_year::text AND d.district_id = b.district_id AND d.semester = b.semester
left join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) group by district_id) tot_stud
on d.district_id=tot_stud.district_id) WITH NO DATA;		  

/* Block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_block_year_semester AS
 (SELECT d.academic_year,
	d.district_id,
	d.district_name,
    d.block_id,
    d.block_name,
    d.block_latitude,
    d.block_longitude,
    d.block_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
			c.district_id,
			c.district_name,
            c.block_id,
            c.block_name,
            c.block_latitude,
            c.block_longitude,
            c.block_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM (SELECT a.academic_year,
					a.district_id,
					a.district_name,
                    a.block_id,
                    a.block_name,
                    a.block_latitude,
                    a.block_longitude,
                    a.block_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,
				            semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,
                            semester_exam_school_result.block_id,
                            initcap(semester_exam_school_result.block_name::text) AS block_name,
                            semester_exam_school_result.block_latitude,
                            semester_exam_school_result.block_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS block_performance                           FROM semester_exam_school_result
							 GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester,
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.block_id, semester_exam_school_result.block_name, semester_exam_school_result.block_latitude, semester_exam_school_result.block_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.block_id,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.block_id) as b
join (select block_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
sat_school_grade_enrolment_block  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year, a_1.semester) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.block_id = b_1.block_id AND a.semester = b_1.semester) c
 
             LEFT JOIN (SELECT d_2.academic_year,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.block_id,semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result
								   	GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.subject,semester_exam_school_result.semester, semester_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.block_id,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,
								  semester_exam_school_result.semester, semester_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_block tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade, b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.block_id, d_2.semester) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.block_id = d_1.block_id AND c.semester = d_1.semester) d
     LEFT JOIN (select block_id,academic_year,semester,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by block_id,academic_year,semester) b ON d.academic_year::text = b.academic_year::text AND d.block_id = b.block_id AND d.semester = b.semester
left join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA;		  



CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_year_semester AS
 (SELECT d.academic_year,
	d.district_id,
	d.district_name,
	d.block_id,
	d.block_name,
    d.cluster_id,
    d.cluster_name,
    d.cluster_latitude,
    d.cluster_longitude,
    d.cluster_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
			c.district_id,
			c.district_name,
		    c.block_id,
			c.block_name,
            c.cluster_id,
            c.cluster_name,
            c.cluster_latitude,
            c.cluster_longitude,
            c.cluster_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM (SELECT a.academic_year,
					a.district_id,
					a.district_name,
					a.block_id,
					a.block_name,
                    a.cluster_id,
                    a.cluster_name,
                    a.cluster_latitude,
                    a.cluster_longitude,
                    a.cluster_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,
				            semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,
							semester_exam_school_result.block_id,
							initcap(semester_exam_school_result.block_name::text) AS block_name,
                            semester_exam_school_result.cluster_id,
                            initcap(semester_exam_school_result.cluster_name::text) AS cluster_name,
                            semester_exam_school_result.cluster_latitude,
                            semester_exam_school_result.cluster_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS cluster_performance                           FROM semester_exam_school_result
                          GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester,
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.block_id, semester_exam_school_result.block_name,
						  semester_exam_school_result.cluster_id, semester_exam_school_result.cluster_name, semester_exam_school_result.cluster_latitude, semester_exam_school_result.cluster_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.cluster_id,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.cluster_id) as b
join (select cluster_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
sat_school_grade_enrolment_cluster  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year, a_1.semester) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.cluster_id = b_1.cluster_id AND a.semester = b_1.semester) c
 
             LEFT JOIN (SELECT d_2.academic_year,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.cluster_id,semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result
								   	GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.subject,semester_exam_school_result.semester, semester_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.cluster_id,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,
								  semester_exam_school_result.semester, semester_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_cluster tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade, b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id, d_2.semester) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.cluster_id = d_1.cluster_id AND c.semester = d_1.semester) d
     LEFT JOIN (select cluster_id,academic_year,semester,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by cluster_id,academic_year,semester) b ON d.academic_year::text = b.academic_year::text AND d.cluster_id = b.cluster_id AND d.semester = b.semester
left join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id) WITH NO DATA;		  



CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_year_semester AS
 (SELECT d.academic_year,
	d.district_id,
	d.district_name,
	d.block_id,
	d.block_name,
	d.cluster_id,
	d.cluster_name,
    d.school_id,
    d.school_name,
    d.school_latitude,
    d.school_longitude,
    d.school_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
			c.district_id,
			c.district_name,
		    c.block_id,
			c.block_name,
			c.cluster_id,
			c.cluster_name,
            c.school_id,
            c.school_name,
            c.school_latitude,
            c.school_longitude,
            c.school_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM (SELECT a.academic_year,
					a.district_id,
					a.district_name,
					a.block_id,
					a.block_name,
					a.cluster_id,
					a.cluster_name,
                    a.school_id,
                    a.school_name,
                    a.school_latitude,
                    a.school_longitude,
                    a.school_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,
				            semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,
							semester_exam_school_result.block_id,
							initcap(semester_exam_school_result.block_name::text) AS block_name,
							semester_exam_school_result.cluster_id,
 						    initcap(semester_exam_school_result.cluster_name::text) AS cluster_name,
                            semester_exam_school_result.school_id,
                            initcap(semester_exam_school_result.school_name::text) AS school_name,
                            semester_exam_school_result.school_latitude,
                            semester_exam_school_result.school_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS school_performance                           FROM semester_exam_school_result
                          GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester,
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.block_id, semester_exam_school_result.block_name,
						  semester_exam_school_result.cluster_id,semester_exam_school_result.cluster_name,
						  semester_exam_school_result.school_id, semester_exam_school_result.school_name, semester_exam_school_result.school_latitude, semester_exam_school_result.school_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.school_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.school_id,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.school_id) as b
join (select school_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by school_id,grade,academic_year,semester) as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
sat_school_grade_enrolment_school  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year, a_1.semester) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.school_id = b_1.school_id AND a.semester = b_1.semester) c
 
             LEFT JOIN (SELECT d_2.academic_year,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.school_id,semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result
								   	GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.subject,semester_exam_school_result.semester, semester_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.school_id,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,
								  semester_exam_school_result.semester, semester_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select school_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by school_id,grade,academic_year,semester) as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_school tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade, b_1.semester) d_2
                  GROUP BY d_2.academic_year, d_2.school_id, d_2.semester) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.school_id = d_1.school_id AND c.semester = d_1.semester) d
     LEFT JOIN (select school_id,academic_year,semester,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by school_id,academic_year,semester) b ON d.academic_year::text = b.academic_year::text AND d.school_id = b.school_id AND d.semester = b.semester
left join
 (select sum(total_students) as total_students,school_id from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) group by school_id) tot_stud
on d.school_id=tot_stud.school_id) WITH NO DATA;		  



/* sat year and semester */
/* grade filter */
/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_district_year_semester as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from semester_exam_district_year_semester)as a
left join
(select academic_year,district_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result 
group by academic_year,grade,subject,semester,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools
from semester_exam_school_result 
group by academic_year,grade,semester,
district_id order by 3,grade)as a
join (select district_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,academic_year,semester)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester
join sat_school_grade_enrolment_district tot_stud
 on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester
join
(select district_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_district tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade) WITH NO DATA;



/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_block_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance from semester_exam_block_year_semester)as a
left join
(select academic_year,block_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result 
group by academic_year,grade,subject,semester,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,count(distinct school_id) as total_schools
from semester_exam_school_result 
group by academic_year,grade,semester,
block_id order by 3,grade)as a
join (select block_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,academic_year,semester)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester
join  sat_school_grade_enrolment_block tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade ))as a
group by block_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester
join
(select block_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_block tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade) WITH NO DATA;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_cluster_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance from semester_exam_cluster_year_semester)as a
left join
(select academic_year,cluster_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result 
group by academic_year,grade,subject,semester,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,count(distinct school_id) as total_schools
from semester_exam_school_result 
group by academic_year,grade,semester,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,academic_year,semester)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester
join sat_school_grade_enrolment_cluster tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester
join
(select cluster_id,grade,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_cluster tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade) WITH NO DATA;


/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_school_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from semester_exam_school_year_semester)as a
left join
(select academic_year,school_id,grade,semester,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from semester_exam_school_result 
group by academic_year,grade,subject,semester,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,count(distinct school_id) as total_schools
from semester_exam_school_result 
group by academic_year,grade,semester,
school_id order by 3,grade)as a
join sat_stud_count_school_grade_mgmt_year_semester as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester
join
 sat_school_grade_enrolment_school tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year,semester
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester
join
sat_stud_count_school_grade_mgmt_year_semester as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
 sat_school_grade_enrolment_school tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade) WITH NO DATA;


/* with management */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_district_mgmt_year_semester AS
 (SELECT d.academic_year,
	d.district_id,
	d.district_name,
	d.school_management_type,
    d.district_latitude,
    d.district_longitude,
    d.district_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
					c.district_id,
					c.district_name,
					c.school_management_type,
            c.district_latitude,
            c.district_longitude,
            c.district_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.school_management_type,
                    a.district_name,
                    a.district_latitude,
                    a.district_longitude,
                    a.district_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,
							         semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,        
							semester_exam_school_result.school_management_type,
                            semester_exam_school_result.district_latitude,
                            semester_exam_school_result.district_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS district_performance,
                            semester_exam_school_result.semester
                           FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not null
                          GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.school_management_type, 
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.semester,
						   semester_exam_school_result.district_latitude, semester_exam_school_result.district_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.district_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.district_id,semester_exam_school_result.school_management_type,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									semester
                                   FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not null
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.district_id,semester_exam_school_result.school_management_type) as b
join (select district_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester where school_management_type is not null 
group by district_id,grade,school_management_type,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
sat_school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.district_id, a_1.academic_year, a_1.semester,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.district_id = b_1.district_id AND a.semester = b_1.semester and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN (SELECT d_2.academic_year,
                    d_2.district_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,b_1.school_management_type,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.district_id,semester_exam_school_result.school_management_type,semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not null
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.school_management_type,
								  semester_exam_school_result.subject,semester_exam_school_result.semester, semester_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.district_id,semester_exam_school_result.school_management_type,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not null
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,semester_exam_school_result.school_management_type,
								  semester_exam_school_result.semester, semester_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester where school_management_type is not null group by district_id,grade,school_management_type,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade, b_1.semester,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.district_id, d_2.semester,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.district_id = d_1.district_id AND c.semester = d_1.semester
				  and c.school_management_type=d_1.school_management_type) d
left join
 (select district_id,academic_year,semester,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester where school_management_type is not NULL group by district_id,academic_year,semester,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.semester=b.semester and trim(d.school_management_type)=trim(b.school_management_type)
        join
 (select sum(total_students) as total_students,district_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM semester_exam_school_result) group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and trim(d.school_management_type)=trim(tot_stud.school_management_type) where d.school_management_type is not null) WITH NO DATA;

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_block_mgmt_year_semester AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.school_management_type,
	d.block_name,
    d.block_latitude,
    d.block_longitude,
    d.block_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM (SELECT c.academic_year,
					c.district_id,
					c.district_name,
					c.block_id,
					c.block_name,
			c.school_management_type,
            c.block_latitude,
            c.block_longitude,
            c.block_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM (SELECT a.academic_year,
					a.district_id,
					a.district_name,
                    a.block_id,
					a.school_management_type,
                    a.block_name,
                    a.block_latitude,
                    a.block_longitude,
                    a.block_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM ( SELECT semester_exam_school_result.academic_year,
							         semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,        					
                            semester_exam_school_result.block_id,
							semester_exam_school_result.school_management_type,
                            initcap(semester_exam_school_result.block_name::text) AS block_name,
                            semester_exam_school_result.block_latitude,
                            semester_exam_school_result.block_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS block_performance,
                            semester_exam_school_result.semester
                           FROM semester_exam_school_result 
						   where  semester_exam_school_result.school_management_type is not NULL
                          GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.school_management_type, semester_exam_school_result.semester,
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.block_id, semester_exam_school_result.block_name,
						  semester_exam_school_result.block_latitude, semester_exam_school_result.block_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.block_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.block_id,semester_exam_school_result.school_management_type,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    semester_exam_school_result.semester
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester,
								  semester_exam_school_result.block_id,semester_exam_school_result.school_management_type) as b
join (select block_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,school_management_type,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
sat_school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.block_id, a_1.academic_year, a_1.semester,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.block_id = b_1.block_id AND a.semester = b_1.semester and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.block_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,b_1.school_management_type,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.block_id,semester_exam_school_result.school_management_type,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.school_management_type,
								  semester_exam_school_result.subject, semester_exam_school_result.semester, semester_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.block_id,semester_exam_school_result.school_management_type,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not null
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,semester_exam_school_result.school_management_type,
								  semester_exam_school_result.semester, semester_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,school_management_type,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade, b_1.semester,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.block_id, d_2.semester,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.block_id = d_1.block_id AND c.semester = d_1.semester
				  and c.school_management_type=d_1.school_management_type) d
left join
 (select block_id,academic_year,semester,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by block_id,academic_year,semester,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.semester=b.semester and d.school_management_type=b.school_management_type
       join
 (select sum(total_students) as total_students,block_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM semester_exam_school_result) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_cluster_mgmt_year_semester AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.block_name,
	d.cluster_id,
	d.school_management_type,
	d.cluster_name,
    d.cluster_latitude,
    d.cluster_longitude,
    d.cluster_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
					c.district_id,
					c.district_name,
					c.block_id,
					c.block_name,
            c.cluster_id,
			c.school_management_type,
            c.cluster_name,
            c.cluster_latitude,
            c.cluster_longitude,
            c.cluster_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.district_name,
					a.block_id,
					a.block_name,
                    a.cluster_id,
					a.school_management_type,
                    a.cluster_name,
                    a.cluster_latitude,
                    a.cluster_longitude,
                    a.cluster_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM ( SELECT academic_year,
							         district_id,
                            initcap(district_name::text) AS district_name,        
                            block_id,
                            initcap(block_name::text) AS block_name,							
                            cluster_id,
							school_management_type,
                            initcap(cluster_name::text) AS cluster_name,
                            cluster_latitude,
                            cluster_longitude,
                            round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS cluster_performance,
                            semester_exam_school_result.semester
                           FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                          GROUP BY academic_year,school_management_type,semester,district_id, district_name,block_id, block_name,cluster_id, cluster_name, cluster_latitude, cluster_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.cluster_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    cluster_id,school_management_type,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
                                    semester_exam_school_result.semester
                                   FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY academic_year, grade, semester, cluster_id,school_management_type) as b
join (select cluster_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,school_management_type,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
sat_school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.cluster_id, a_1.academic_year, a_1.semester,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.cluster_id = b_1.cluster_id AND a.semester = b_1.semester and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.cluster_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,b_1.school_management_type,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    cluster_id,school_management_type,semester,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY academic_year, grade, school_management_type,
								  subject,semester, cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    cluster_id,school_management_type,semester,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY academic_year, grade,school_management_type,
								  semester, cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,school_management_type,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade, b_1.semester,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id, d_2.semester,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.cluster_id = d_1.cluster_id AND c.semester = d_1.semester
				  and c.school_management_type=d_1.school_management_type) d
       join
 (select sum(total_students) as total_students,cluster_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM semester_exam_school_result) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type 
 left join
 (select cluster_id,academic_year,semester,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from sat_stud_count_school_mgmt_year_semester group by cluster_id,semester,academic_year,school_management_type) as b 
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.semester=b.semester and d.school_management_type=b.school_management_type where d.school_management_type is not null) WITH NO DATA;



/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_school_mgmt_year_semester AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.block_name,
	d.cluster_id,
	d.cluster_name,
	d.school_id,
	d.school_management_type,
	d.school_name,
    d.school_latitude,
    d.school_longitude,
    d.school_performance,
    d.semester,
    d.grade_wise_performance,
    d.subject_wise_performance,
    b.total_schools,
    b.students_count as students_attended,
	total_students
   FROM ( SELECT c.academic_year,
					c.district_id,
					c.district_name,
					c.block_id,
					c.block_name,
					c.cluster_id,
					c.cluster_name,
            c.school_id,
			c.school_management_type,
            c.school_name,
            c.school_latitude,
            c.school_longitude,
            c.school_performance,
            c.semester,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.district_name,
					a.block_id,
					a.block_name,
					a.cluster_id,
					a.cluster_name,
                    a.school_id,
					a.school_management_type,
                    a.school_name,
                    a.school_latitude,
                    a.school_longitude,
                    a.school_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM ( SELECT semester_exam_school_result.academic_year,
							         semester_exam_school_result.district_id,
                            initcap(semester_exam_school_result.district_name::text) AS district_name,        
                            semester_exam_school_result.block_id,
                            initcap(semester_exam_school_result.block_name::text) AS block_name,							
							semester_exam_school_result.cluster_id,
							initcap(semester_exam_school_result.cluster_name) as cluster_name,
                            semester_exam_school_result.school_id,
                            initcap(semester_exam_school_result.school_name::text) AS school_name,
							semester_exam_school_result.school_management_type,
                            semester_exam_school_result.school_latitude,
                            semester_exam_school_result.school_longitude,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS school_performance,
                            semester_exam_school_result.semester
                           FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                          GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.semester,
						  semester_exam_school_result.district_id, semester_exam_school_result.district_name,semester_exam_school_result.block_id, semester_exam_school_result.block_name,
						  semester_exam_school_result.cluster_id, semester_exam_school_result.cluster_name,semester_exam_school_result.school_id, semester_exam_school_result.school_name, semester_exam_school_result.school_latitude, semester_exam_school_result.school_longitude,
						  semester_exam_school_result.school_management_type) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,
                            a_1.school_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.school_id,semester_exam_school_result.school_management_type,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    semester_exam_school_result.semester
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not null 
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester, semester_exam_school_result.school_id,semester_exam_school_result.school_management_type) as b
join sat_stud_count_school_grade_mgmt_year_semester as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
sat_school_grade_enrolment_school_mgmt  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.school_id, a_1.academic_year, a_1.semester,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.school_id = b_1.school_id AND a.semester = b_1.semester 
and a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.school_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.semester
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,b_1.school_management_type,
                            b_1.semester,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    semester_exam_school_result.subject AS subject_name,
                                    semester_exam_school_result.school_id,semester_exam_school_result.school_management_type,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.school_management_type,
								  semester_exam_school_result.subject, semester_exam_school_result.semester, semester_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, semester_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    semester_exam_school_result.school_id,semester_exam_school_result.school_management_type,
                                    semester_exam_school_result.semester,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM semester_exam_school_result where  semester_exam_school_result.school_management_type is not NULL
                                  GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade,semester_exam_school_result.school_management_type,
								  semester, semester_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || semester_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
sat_stud_count_school_grade_mgmt_year_semester as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_school_mgmt tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade, b_1.semester,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.school_id, d_2.semester,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.school_id = d_1.school_id AND c.semester = d_1.semester
				  and c.school_management_type=d_1.school_management_type) d
LEFT JOIN sat_stud_count_school_mgmt_year_semester b ON d.academic_year::text = b.academic_year::text AND d.school_id = b.school_id AND d.semester = b.semester 
and d.school_management_type = b.school_management_type
 join
 (select sum(total_students) as total_students,school_id,school_management_type from school_hierarchy_details group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;



/* sat grade subject wise -Year and semester*/

/* district - grade */
CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_district_mgmt_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,
	district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,school_management_type from semester_exam_district_mgmt_year_semester)as a
left join
(select academic_year,district_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not null  group by academic_year,grade,subject,semester,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,count(distinct school_id) as total_schools
FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not null  group by academic_year,grade,semester,school_management_type,
district_id order by 3,grade)as a
join (select district_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,school_management_type,academic_year,semester)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester and a.school_management_type=sa.school_management_type
join sat_school_grade_enrolment_district_mgmt tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by district_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.semester=b.semester and a.school_management_type=b.school_management_type
join
(select district_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by district_id,grade,school_management_type,academic_year,semester) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_block_mgmt_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance,school_management_type from semester_exam_block_mgmt_year_semester)as a
left join
(select academic_year,block_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM semester_exam_school_result where  school_management_type is not null 
group by academic_year,grade,subject,semester,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
semester,count(distinct school_id) as total_schools
FROM semester_exam_school_result where  school_management_type is not NULL group by academic_year,grade,semester,school_management_type,
block_id order by 3,grade)as a
join (select block_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,school_management_type,academic_year,semester)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester and a.school_management_type=sa.school_management_type
join  sat_school_grade_enrolment_block_mgmt tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by block_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.semester=b.semester and a.school_management_type=b.school_management_type
join
(select block_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by block_id,grade,school_management_type,academic_year,semester) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_cluster_mgmt_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance,school_management_type from semester_exam_cluster_mgmt_year_semester)as a
left join
(select academic_year,cluster_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM semester_exam_school_result where  school_management_type is not NULL group by academic_year,grade,subject,semester,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools
FROM semester_exam_school_result where  school_management_type is not null group by academic_year,grade,semester,school_management_type,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,school_management_type,academic_year,semester)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester and a.school_management_type=sa.school_management_type
join sat_school_grade_enrolment_cluster_mgmt tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by cluster_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.semester=b.semester and a.school_management_type=b.school_management_type
left join
 sat_school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
left join
(select cluster_id,grade,school_management_type,academic_year,semester,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from sat_stud_count_school_grade_mgmt_year_semester group by cluster_id,grade,school_management_type,academic_year,semester) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type) WITH NO DATA;


/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  semester_grade_school_mgmt_year_semester as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,semester,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from semester_exam_school_mgmt_year_semester)as a
left join
(select academic_year,school_id,grade,semester,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM semester_exam_school_result where  school_management_type is not NULL group by academic_year,grade,subject,semester,school_management_type,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,semester,count(distinct school_id) as total_schools
FROM semester_exam_school_result where  school_management_type is not NULL group by academic_year,grade,semester,school_management_type,
school_id order by 3,grade)as a
join sat_stud_count_school_grade_mgmt_year_semester as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.semester=sa.semester and a.school_management_type=sa.school_management_type
join sat_school_grade_enrolment_school_mgmt tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade  and a.school_management_type=tot_stud.school_management_type))as a
group by school_id,grade,academic_year,semester,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.semester=b.semester and a.school_management_type=b.school_management_type
left join
sat_stud_count_school_grade_mgmt_year_semester as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
 sat_school_grade_enrolment_school_mgmt tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade  and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* trend line chart query */

CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_state_trendline AS
 (SELECT d.academic_year,
    d.state_performance,
    d.semester,
    d.grade_wise_performance,
    d.total_schools,
    d.students_count as students_attended,
	(select sum(total_students) as total_students from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) ) total_students
   FROM ( SELECT c.academic_year,
            c.state_performance,
            c.semester,
            c.grade_wise_performance,
			b.students_count,
			b.total_schools
           FROM (SELECT a.academic_year,
                    a.state_performance,
                    a.semester,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS state_performance                           FROM semester_exam_school_result
							GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester
                                   FROM semester_exam_school_result
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester) as b
join (select count(distinct student_uid) as students_attended,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,semester,grade,
count(distinct school_id) as total_schools from (select concat('Grade ',studying_class) as grade,cast (substring (pert.exam_code,10,2) as integer) as month ,  
cast (right(pert.exam_code,4)as integer) as year,pert.school_id,cluster_id,block_id,district_id,semester,
school_management_type,student_uid from semester_exam_stud_grade_count pert  join school_hierarchy_details shd on pert.school_id=shd.school_id join semester_exam_mst sem on pert.exam_code=sem.exam_code) as a	
group by semester,grade,academic_year) as c
on b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester
left join
(select grade,sum(total_students) as total_students from sat_school_grade_enrolment_district  group by grade) as tot_stud
 on b.grade=tot_stud.grade)a_1
GROUP BY a_1.academic_year, a_1.semester) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.semester = b_1.semester) c
     LEFT JOIN (select b.assessment_year as academic_year,b.semester,
    count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count 
group by exam_code,school_id,student_uid) as a
left join (select exam_code,assessment_year, semester from semester_exam_mst) as b on a.exam_code=b.exam_code
group by b.assessment_year,semester) b ON c.academic_year::text = b.academic_year::text AND c.semester = b.semester)as d
)WITH NO DATA;		



CREATE MATERIALIZED VIEW IF NOT EXISTS semester_exam_state_mgmt_trendline AS
 (SELECT d.academic_year,
    d.state_performance,
    d.semester,
	d.school_management_type,
    d.grade_wise_performance,
	d.total_schools,
	d.students_attended,
	(select sum(total_students) as total_students from school_hierarchy_details shd 
 where school_id in (select school_id from semester_exam_school_result) ) total_students
   FROM (SELECT c.academic_year,
            c.state_performance,
            c.semester,
			c.school_management_type,
			b.total_schools,
			b.students_count as students_attended,
            c.grade_wise_performance
           FROM (SELECT a.academic_year,
                    a.state_performance,
                    a.semester,
					a.school_management_type,
                    b_1.grade_wise_performance
                   FROM (SELECT semester_exam_school_result.academic_year,semester_exam_school_result.semester,semester_exam_school_result.school_management_type,
                            round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS state_performance                           FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not NULL
							GROUP BY semester_exam_school_result.academic_year,semester_exam_school_result.semester,semester_exam_school_result.school_management_type) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('semester',a_1.semester,'percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,
                            a_1.semester,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT semester_exam_school_result.academic_year,
                                    'Grade '::text || semester_exam_school_result.grade AS grade,
                                    round(COALESCE(sum(semester_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(semester_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                     semester_exam_school_result.semester,school_management_type
                                   FROM semester_exam_school_result where semester_exam_school_result.school_management_type is not NULL
								   GROUP BY semester_exam_school_result.academic_year, semester_exam_school_result.grade, semester_exam_school_result.semester,school_management_type) as b
join (select count(distinct student_uid) as students_attended,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,semester,school_management_type,grade,
count(distinct school_id) as total_schools from (select concat('Grade ',studying_class) as grade,cast (substring (pert.exam_code,10,2) as integer) as month ,  
cast (right(pert.exam_code,4)as integer) as year,pert.school_id,cluster_id,block_id,district_id,semester,
school_management_type,student_uid from semester_exam_stud_grade_count pert  join school_hierarchy_details shd on pert.school_id=shd.school_id join semester_exam_mst sem on pert.exam_code=sem.exam_code) as a	
group by semester,grade,academic_year,school_management_type) as c
on b.grade=c.grade and b.academic_year=c.academic_year and b.semester=c.semester and b.school_management_type=c.school_management_type
left join
(select grade,school_management_type,sum(total_students) as total_students from sat_school_grade_enrolment_district_mgmt  group by grade,school_management_type) as tot_stud
 on b.grade=tot_stud.grade and b.school_management_type= tot_stud.school_management_type)a_1
GROUP BY a_1.academic_year, a_1.semester,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.semester = b_1.semester and a.school_management_type=b_1.school_management_type) c
      LEFT JOIN (select b.assessment_year as academic_year,b.semester,school_management_type,
    count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,pert.school_id,student_uid,school_management_type
from semester_exam_stud_grade_count pert  join school_hierarchy_details shd on pert.school_id=shd.school_id
where school_management_type is not NULL
group by exam_code,pert.school_id,student_uid,school_management_type) as a
left join (select exam_code,assessment_year, semester from semester_exam_mst) as b on a.exam_code=b.exam_code
group by b.assessment_year,semester,school_management_type) b ON c.academic_year::text = b.academic_year::text AND c.semester = b.semester and c.school_management_type=b.school_management_type) as d
)WITH NO DATA;		



/* creating index */
create index  IF NOT EXISTS sat_school_grade_enrolment_district_district_id_idx ON sat_school_grade_enrolment_district (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_grade_idx on sat_school_grade_enrolment_district(grade);

create index IF NOT EXISTS sat_school_grade_enrolment_block_block_id_idx on sat_school_grade_enrolment_block(block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_grade_idx on sat_school_grade_enrolment_block(grade);

create index IF NOT EXISTS sat_school_grade_enrolment_cluster_cluster_id_idx on sat_school_grade_enrolment_cluster(cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_grade_idx on sat_school_grade_enrolment_cluster(grade);

create index IF NOT EXISTS sat_school_grade_enrolment_school_school_id_idx on sat_school_grade_enrolment_school (school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_grade_idx on sat_school_grade_enrolment_school (grade);

create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_block_id_idx on sat_stud_count_school_grade_mgmt_year_semester(block_id);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_grade_idx on sat_stud_count_school_grade_mgmt_year_semester(grade);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_academic_year_idx on sat_stud_count_school_grade_mgmt_year_semester(academic_year);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_semester_idx on sat_stud_count_school_grade_mgmt_year_semester(semester);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_school_management_type_idx on sat_stud_count_school_grade_mgmt_year_semester(school_management_type);
create index IF NOT EXISTS sat_stud_count_school_grade_mgmt_year_semester_school_id_idx on sat_stud_count_school_grade_mgmt_year_semester(school_id);


create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_district_id_idx on sat_school_grade_enrolment_district_mgmt (district_id);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_grade_idx on sat_school_grade_enrolment_district_mgmt (grade);
create index IF NOT EXISTS sat_school_grade_enrolment_district_mgmt_school_management_type_idx on sat_school_grade_enrolment_district_mgmt (school_management_type);

create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_block_id_idx on sat_school_grade_enrolment_block_mgmt(block_id);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_grade_idx on sat_school_grade_enrolment_block_mgmt(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_block_mgmt_school_management_type_idx on sat_school_grade_enrolment_block_mgmt (school_management_type);

create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_cluster_id_idx on sat_school_grade_enrolment_cluster_mgmt(cluster_id);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_grade_idx on sat_school_grade_enrolment_cluster_mgmt(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_cluster_mgmt_school_management_type_idx on sat_school_grade_enrolment_cluster_mgmt (school_management_type);

create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_school_id_idx on sat_school_grade_enrolment_school_mgmt(school_id);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_grade_idx on sat_school_grade_enrolment_school_mgmt(grade);
create index IF NOT EXISTS sat_school_grade_enrolment_school_mgmt_school_management_type_idx on sat_school_grade_enrolment_school_mgmt (school_management_type);



