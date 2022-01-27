/* Drop views */
	
drop view if exists pat_exception_data_all  cascade;
drop view if exists pat_exception_data_last7  cascade;
drop view if exists pat_exception_data_last30  cascade;
drop view if exists pat_exception_grade_data_all cascade;
drop view if exists pat_exception_grade_data_last7 cascade;
drop view if exists pat_exception_grade_data_last30 cascade;
drop view if exists hc_periodic_exam_school_last30 cascade;
drop view if exists hc_periodic_exam_school_all cascade;
drop view if exists hc_periodic_exam_cluster_last30 cascade;
drop view if exists hc_periodic_exam_cluster_all cascade;
drop view if exists hc_periodic_exam_block_last30 cascade;
drop view if exists hc_periodic_exam_block_all cascade;
drop view if exists hc_periodic_exam_district_last30 cascade;
drop view if exists hc_periodic_exam_district_all cascade;
drop view if exists hc_pat_state_mgmt_overall cascade;
drop view if exists hc_pat_state_mgmt_last30 cascade;
drop view if exists hc_pat_state_overall cascade;
drop view if exists hc_periodic_exam_school_mgmt_last30 cascade;
drop view if exists hc_periodic_exam_school_mgmt_all cascade;
drop view if exists hc_periodic_exam_cluster_mgmt_last30 cascade;
drop view if exists hc_periodic_exam_cluster_mgmt_all cascade;
drop view if exists hc_periodic_exam_block_mgmt_last30 cascade;
drop view if exists hc_periodic_exam_block_mgmt_all cascade;
drop view if exists hc_periodic_exam_district_mgmt_last30 cascade;
drop view if exists hc_periodic_exam_district_mgmt_all cascade;

create or replace function drop_view_pat()
returns int as
$body$
begin

drop view if exists periodic_exam_school_all cascade;
drop view if exists periodic_exam_cluster_all cascade;
drop view if exists periodic_exam_block_all cascade;
drop view if exists periodic_exam_district_all cascade;

drop view if exists periodic_exam_school_last7 cascade;
drop view if exists periodic_exam_cluster_last7 cascade;
drop view if exists periodic_exam_block_last7 cascade;
drop view if exists periodic_exam_district_last7 cascade;

drop view if exists periodic_exam_school_last30 cascade;
drop view if exists periodic_exam_cluster_last30 cascade;
drop view if exists periodic_exam_block_last30 cascade;
drop view if exists periodic_exam_district_last30 cascade;

drop view if exists periodic_exam_school_year_month cascade;
drop view if exists periodic_exam_cluster_year_month cascade;
drop view if exists periodic_exam_block_year_month cascade;
drop view if exists periodic_exam_district_year_month cascade;

drop view if exists periodic_exam_school_mgmt_all cascade;
drop view if exists periodic_exam_cluster_mgmt_all cascade;
drop view if exists periodic_exam_block_mgmt_all cascade;
drop view if exists periodic_exam_district_mgmt_all cascade;

drop view if exists periodic_exam_school_mgmt_last7 cascade;
drop view if exists periodic_exam_cluster_mgmt_last7 cascade;
drop view if exists periodic_exam_block_mgmt_last7 cascade;
drop view if exists periodic_exam_district_mgmt_last7 cascade;

drop view if exists periodic_exam_school_mgmt_last30 cascade;
drop view if exists periodic_exam_cluster_mgmt_last30 cascade;
drop view if exists periodic_exam_block_mgmt_last30 cascade;
drop view if exists periodic_exam_district_mgmt_last30 cascade;

drop view if exists periodic_exam_school_mgmt_year_month cascade;
drop view if exists periodic_exam_cluster_mgmt_year_month cascade;
drop view if exists periodic_exam_block_mgmt_year_month cascade;
drop view if exists periodic_exam_district_mgmt_year_month cascade;

  return 0;

    exception 
    when others then
        return 0;

end;
$body$
language plpgsql;

select drop_view_pat();

/*PAT views */

/*daterange*/

create or replace view pat_date_range as 
(select exam_code,'last30days' as date_range from periodic_exam_mst where exam_date between 
(select ((now()::Date)-INTERVAL '30 DAY')::Date) and (select now()::DATE) )
union
(select exam_code,'last7days' as date_range from periodic_exam_mst where exam_date between 
(select ((now()::Date)-INTERVAL '7 DAY')::Date) and (select now()::DATE) );

/* Materialized views for calculating total_students */
/* last 30 days */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district_last30 AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by district_id,grade)
     WITH NO DATA ;

/* block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block_last30 AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by block_id,grade)
WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster_last30 AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by cluster_id,grade)
WITH NO DATA;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school_last30 AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) 
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* Materialized views for calculating total_students based on management*/

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by block_id,grade,school_management_type)
     WITH NO DATA ;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;

/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school_mgmt_last30 AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days'))
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;

/* Materialized views for calculating total_students */
/* last 7 days */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district_last7 AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by district_id,grade)
     WITH NO DATA ;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block_last7 AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by block_id,grade)
     WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster_last7 AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by cluster_id,grade)
     WITH NO DATA ;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school_last7 AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) 
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* Materialized views for calculating total_students based on management*/
/* management views -last 7 days  */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by block_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days'))
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school_mgmt_last7 AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) 
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;

/* Materialized views for calculating total_students */
/* year month */

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district AS
(select sum(students_count) as total_students,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by district_id,grade)
     WITH NO DATA ;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block AS
(select sum(students_count) as total_students,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by block_id,grade)
     WITH NO DATA ;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster AS
(select sum(students_count) as total_students,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by cluster_id,grade)
     WITH NO DATA ;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school AS
 (select sum(students_count) as total_students,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from periodic_exam_school_result)
	 group by sge.school_id,grade)
     WITH NO DATA ;

/* management views */

/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_district_mgmt AS
(select sum(students_count) as total_students,school_management_type,district_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by district_id,grade,school_management_type)
     WITH NO DATA ;

CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_block_mgmt AS
(select sum(students_count) as total_students,school_management_type,block_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by block_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_cluster_mgmt AS
(select sum(students_count) as total_students,school_management_type,cluster_id,concat('Grade ',grade) as grade from school_grade_enrolment sge join school_hierarchy_details shd on sge.school_id=shd.school_id 
where sge.school_id in (select school_id from periodic_exam_school_result)
 group by cluster_id,grade,school_management_type)
     WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS school_grade_enrolment_school_mgmt AS
(select sum(students_count) as total_students,school_management_type,sge.school_id,concat('Grade ',grade) as grade from school_grade_enrolment sge 
 join school_hierarchy_details shd on sge.school_id=shd.school_id 
 where sge.school_id in (select school_id from periodic_exam_school_result)
 group by sge.school_id,grade,school_management_type)
     WITH NO DATA ;

/* Overall MVs */
/*PAT MV to calculate district_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude
from periodic_exam_school_result group by academic_year,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id from
(select academic_year,cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
district_id)as a
group by district_id,academic_year)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id)as c
left join 
(select academic_year,district_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,district_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from 
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
district_id order by grade desc,subject_name))as b
group by academic_year,district_id,grade)as d
group by academic_year,district_id)as d 
on c.academic_year=d.academic_year and c.district_id=d.district_id) WITH NO DATA;


/*PAT MV to calculate block_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude
from periodic_exam_school_result group by academic_year,
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id from
(select academic_year,cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
block_id)as a
group by block_id,academic_year)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id)as c
left join 
(
select academic_year,block_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,block_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
block_id order by grade desc,subject_name)) as a
group by academic_year,block_id,grade)as d
group by academic_year,block_id
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id) WITH NO DATA;

/*PAT MV to calculate cluster_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude
from periodic_exam_school_result group by academic_year,
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id from
(select academic_year,cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
cluster_id)as a
group by cluster_id,academic_year)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id)as c
left join 
(
select academic_year,cluster_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,cluster_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
cluster_id order by grade desc,subject_name)) as a
group by academic_year,cluster_id,grade)as d
group by academic_year,cluster_id
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id) WITH NO DATA;

/*PAT MV to calculate school_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,
school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude
from periodic_exam_school_result group by academic_year,
school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id from
(select academic_year,cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
school_id)as a
group by school_id,academic_year)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id)as c
left join 
(
select academic_year,school_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance from
(select academic_year,school_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
school_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
school_id order by grade desc,subject_name)) as a
group by academic_year,school_id,grade)as d
group by academic_year,school_id
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id) WITH NO DATA;

/*PAT MV to calculate district_performance, grade performance and subjectwise performance based on grade */

create or replace view periodic_grade_district_all as
select a.*,b.grade,b.subjects
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from periodic_exam_district_all)as a
left join
(select academic_year,district_id,grade,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
district_id order by 3,grade))as a
group by district_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id;

/*PAT MV to calculate block_performance, grade performance and subjectwise performance based on grade */

create or replace view periodic_grade_block_all as
select a.*,b.grade,b.subjects
from
(select academic_year,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance from periodic_exam_block_all)as a
left join
(select academic_year,block_id,grade,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
block_id order by 3,grade))as a
group by block_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id;

/*PAT MV to calculate cluster_performance, grade performance and subjectwise performance based on grade */

create or replace view periodic_grade_cluster_all as
select a.*,b.grade,b.subjects
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance from periodic_exam_cluster_all)as a
left join
(select academic_year,cluster_id,grade,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
cluster_id order by 3,grade))as a
group by cluster_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id;

/*PAT MV to calculate school_performance, grade performance and subjectwise performance based on grade */

create or replace view periodic_grade_school_all as
select a.*,b.grade,b.subjects
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from periodic_exam_school_all)as a
left join
(select academic_year,school_id,grade,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,
school_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,
school_id order by 3,grade))as a
group by school_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id;

/*------------------------last 30 days--------------------------------------------------------------------------------------------------------*/
/* Materialized view to calculate the count of students_attended  and total schools */

CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_mgmt_last30 as
(select c.school_id,b.assessment_year as academic_year,c.cluster_id,c.block_id,c.district_id,c.school_management_type,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days'))
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
 join school_hierarchy_details as c on a.school_id=c.school_id
group by c.school_id,b.assessment_year,c.cluster_id,c.block_id,c.district_id,c.school_management_type) WITH NO DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_grade_mgmt_last30 as
(select grade,academic_year,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,count(distinct school_id) as total_schools from (
select concat('Grade ',studying_class) as grade,academic_year,
pert.school_id,cluster_id,block_id,district_id,student_uid,school_management_type from periodic_exam_result_trans pert  join periodic_exam_school_result pem on pert.school_id=pem.school_id  
and pert.exam_code=pem.exam_code
where pem.exam_code in (select exam_code from pat_date_range where date_range='last30days')) as a
group by school_id,cluster_id,block_id,district_id,grade,academic_year,school_management_type) WITH NO DATA;

/*PAT MV to calculate district_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,
district_latitude,district_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,district_id,district_name,district_latitude,district_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.district_id) as b
left join (select district_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade
left join
school_grade_enrolment_district_last30  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select district_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade 
left join
 school_grade_enrolment_district_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.district_id
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id)as d
left join 
 (select district_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by district_id,academic_year)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id
    join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by district_id) tot_stud
on d.district_id=tot_stud.district_id) WITH NO DATA;

/*PAT MV to calculate block_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
block_latitude,block_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,district_id,district_name,block_id,block_name,block_latitude,block_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.block_id) as b
join (select block_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade
left join
school_grade_enrolment_block_last30  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade 
left join
 school_grade_enrolment_block_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.block_id
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id)as d
left join 
 (select block_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by block_id,academic_year)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id
    join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA;

/*PAT MV to calculate cluster_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.cluster_id) as b
join (select cluster_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade
left join
school_grade_enrolment_cluster_last30  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade 
left join
 school_grade_enrolment_cluster_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id)as d
left join 
 (select cluster_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by cluster_id,academic_year)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id
    join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id) WITH NO DATA;

/*PAT MV to calculate school_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
school_id,school_name,school_latitude,school_longitude) as a
left join 
(SELECT a_1.academic_year,
     json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
     a_1.school_id  FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
	 'Grade '::text || periodic_exam_school_result.grade AS grade,periodic_exam_school_result.school_id,
     round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
     FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_id) as b
join stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade
left join
school_grade_enrolment_school_last30  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,periodic_exam_school_result.school_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,'Grade Performance'::text AS subject_name,periodic_exam_school_result.school_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade 
left join
 school_grade_enrolment_school_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.school_id
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id)as d
left join 
stud_count_school_mgmt_last30 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id
    join
 (select school_id,total_students from school_hierarchy_details
where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) ) tot_stud
on d.school_id=tot_stud.school_id) WITH NO DATA;

/*PAT MV to calculate school_performance, grade performance and subjectwise performance for each grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from periodic_exam_school_last30)as a
left join
(select academic_year,school_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) 
order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,max(students_count) as total_students,
max(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,subject,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_last30 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade
join school_grade_enrolment_school_last30 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id
join
stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade
join
school_grade_enrolment_school_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade) WITH NO DATA;

/*PAT MV to calculate cluster_performance, grade performance and subjectwise performance for each grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance from 
	periodic_exam_cluster_last30)as a
left join
(select academic_year,cluster_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,subject,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,
cluster_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,cluster_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by cluster_id,grade)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade
join school_grade_enrolment_cluster_last30 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id
join
(select sum(students_attended) as students_attended,cluster_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade
join
school_grade_enrolment_cluster_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade) WITH NO DATA;

/*PAT MV to calculate block_performance, grade performance and subjectwise performance for each grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from 
	periodic_exam_block_last30)as a
left join
(select academic_year,block_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,subject,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,
block_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,block_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by block_id,grade)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade
join school_grade_enrolment_block_last30 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id
join
(select sum(students_attended) as students_attended,block_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade
join
school_grade_enrolment_block_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade) WITH NO DATA;

/*PAT MV to calculate district_performance, grade performance and subjectwise performance for each grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from 
	periodic_exam_district_last30)as a
left join
(select academic_year,district_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,subject,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by academic_year,grade,
district_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,district_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by district_id,grade)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade
join
school_grade_enrolment_district_last30 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id
join
(select sum(students_attended) as students_attended,district_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last30
group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade
join
school_grade_enrolment_district_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade) WITH NO DATA;

/*------------------------last 7 days--------------------------------------------------------------------------------------------------------*/

/* Materialized view to calculate the count of students_attended  and total schools */

CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_mgmt_last7 as
(select c.school_id,b.assessment_year as academic_year,c.cluster_id,c.block_id,c.district_id,c.school_management_type,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days'))
and exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
 join school_hierarchy_details as c on a.school_id=c.school_id
group by c.school_id,b.assessment_year,c.cluster_id,c.block_id,c.district_id,c.school_management_type) WITH NO DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_grade_mgmt_last7 as
(select grade,academic_year,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,count(distinct school_id) as total_schools from (
select concat('Grade ',studying_class) as grade,academic_year,
pert.school_id,cluster_id,block_id,district_id,student_uid,school_management_type from periodic_exam_result_trans pert  join periodic_exam_school_result pem on pert.school_id=pem.school_id  
and pert.exam_code=pem.exam_code
where pem.exam_code in (select exam_code from pat_date_range where date_range='last7days')) as a
group by school_id,cluster_id,block_id,district_id,grade,academic_year,school_management_type) WITH NO DATA;

/*PAT MV to calculate school_performance, grade_wise performance and subjectwise performance */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,
district_latitude,district_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,district_id,district_name,district_id,district_name,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.district_id) as b
left join (select district_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade
left join
school_grade_enrolment_district_last7  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select district_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade 
left join
 school_grade_enrolment_district_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.district_id
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id)as d
left join 
 (select district_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by district_id,academic_year)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id
   left join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by district_id) tot_stud
on d.district_id=tot_stud.district_id) WITH NO DATA;

/* periodic exam block */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
block_latitude,block_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,district_id,district_name,block_id,block_name,
block_id,block_name,block_latitude,block_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.block_id) as b
join (select block_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade
left join
school_grade_enrolment_block_last7  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade 
left join
 school_grade_enrolment_block_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.block_id
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id)as d
left join 
 (select block_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by block_id,academic_year)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id
   left join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA;

/* periodic exam cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,
cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,cluster_latitude,cluster_longitude) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.cluster_id) as b
join (select cluster_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade
left join
school_grade_enrolment_cluster_last7  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade 
left join
 school_grade_enrolment_cluster_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id)as d
left join 
 (select cluster_id,academic_year,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by cluster_id,academic_year)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id
   left join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id)  WITH NO DATA;

/*periodic exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,initcap(cluster_name) as cluster_name,
school_id,initcap(school_name)as school_name,school_latitude,school_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,district_id,district_name,block_id,block_name,cluster_id,cluster_name,
school_id,school_name,school_latitude,school_longitude) as a
left join 
(SELECT a_1.academic_year,
     json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
     a_1.school_id  FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
	 'Grade '::text || periodic_exam_school_result.grade AS grade,periodic_exam_school_result.school_id,
     round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
     FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_id) as b
join stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade
left join
school_grade_enrolment_school_last7  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id)as c
left join 
(SELECT d_2.academic_year,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,periodic_exam_school_result.school_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,'Grade Performance'::text AS subject_name,periodic_exam_school_result.school_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days')
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade 
left join
 school_grade_enrolment_school_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade) d_2
                  GROUP BY d_2.academic_year, d_2.school_id
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id)as d
left join 
stud_count_school_mgmt_last7 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id
   left join
 (select school_id,total_students from school_hierarchy_details
where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) ) tot_stud
on d.school_id=tot_stud.school_id)  WITH NO DATA;

/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from periodic_exam_school_last7)as a
left join
(select academic_year,school_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) 
order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
max(students_count) as total_students,max(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,subject,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_last7 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade
join school_grade_enrolment_school_last7 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id
join
school_grade_enrolment_school_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade
join
stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade) WITH NO DATA;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance from 
	periodic_exam_cluster_last7)as a
left join
(select academic_year,cluster_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,subject,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,
cluster_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,cluster_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by cluster_id,grade)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade
join school_grade_enrolment_cluster_last7 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id
join
school_grade_enrolment_cluster_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade
join
(select sum(students_attended) as students_attended,cluster_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by cluster_id,grade) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade) WITH NO DATA;

/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance from 
	periodic_exam_block_last7)as a
left join
(select academic_year,block_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,subject,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,
block_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,block_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by block_id,grade)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade
join school_grade_enrolment_block_last7 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade))as a
group by block_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id
join
school_grade_enrolment_block_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade
join
(select sum(students_attended) as students_attended,block_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by block_id,grade) as c
on b.block_id=c.block_id and b.grade=c.grade) WITH NO DATA;

/*--- district - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from 
	periodic_exam_district_last7)as a
left join
(select academic_year,district_id,grade,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,subject,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
group by academic_year,grade,
district_id order by 3,grade)as a
join (select sum(students_attended) as students_attended,district_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by district_id,grade)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade
join school_grade_enrolment_district_last7 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id
join
school_grade_enrolment_district_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade
join
(select sum(students_attended) as students_attended,district_id,grade,sum(total_schools) as total_schools from stud_count_school_grade_mgmt_last7
group by district_id,grade) as c
on b.district_id=c.district_id and b.grade=c.grade) WITH NO DATA;


/* PAT exception function */

CREATE OR REPLACE FUNCTION pat_no_schools()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
pat_no_schools_all text;
pat_no_schools_last7 text;
pat_no_schools_last30 text;
BEGIN
pat_no_schools_all= 'create or replace view pat_exception_data_all as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
where a.school_id !=9999 AND a.school_id not in 
(select distinct e.school_id from (select school_id from periodic_exam_school_all)as e)
and cluster_name is not null';

pat_no_schools_last7= 'create or replace view pat_exception_data_last7 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
left join periodic_exam_school_last7 c on a.school_id=c.school_id
where exists ( select pat_date_range.exam_code from pat_date_range where pat_date_range.date_range=''last7days''::text) and c.school_id is null
and a.school_id<>9999';

pat_no_schools_last30= 'create or replace view pat_exception_data_last30 as 
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,
 b.district_latitude,b.district_longitude,a.school_management_type from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
left join periodic_exam_school_last30 c on a.school_id=c.school_id
where exists ( select pat_date_range.exam_code from pat_date_range where pat_date_range.date_range=''last30days''::text) and c.school_id is null
and a.school_id<>9999';

Execute pat_no_schools_all;
Execute pat_no_schools_last7;
Execute pat_no_schools_last30;
return 0;
END;
$function$;

select pat_no_schools();

CREATE OR REPLACE FUNCTION pat_no_schools_grade()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
pat_grade_no_schools_all text;
pat_grade_no_schools_last7 text;
pat_grade_no_schools_last30 text;
BEGIN

if EXISTS (select * from school_grade_enrolment)  then
pat_grade_no_schools_all = 'create or replace view pat_exception_grade_data_all as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard
 except select school_id,grade,subject from periodic_exam_school_result
union
select distinct sma.*,''grade'' as subject from (select school_id,grade from school_grade_enrolment) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';

pat_grade_no_schools_last7 = 'create or replace view pat_exception_grade_data_last7 as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from pat_date_range where date_range=''last7days'')
 except select school_id,grade,subject from periodic_exam_school_result 
union
select distinct sma.*,''grade'' as subject from (select school_id,grade from school_grade_enrolment) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard where exam_code in(select exam_code from pat_date_range where date_range=''last7days'')
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';



pat_grade_no_schools_last30 = 'create or replace view pat_exception_grade_data_last30 as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,grade from school_grade_enrolment) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from pat_date_range where date_range=''last30days'')
 except select school_id,grade,subject from periodic_exam_school_result 
union
select distinct sma.*,''grade'' as subject from (select school_id,grade from school_grade_enrolment) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard where exam_code in(select exam_code from pat_date_range where date_range=''last30days'')
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';


Execute pat_grade_no_schools_all;
Execute pat_grade_no_schools_last7;
Execute pat_grade_no_schools_last30;

else
pat_grade_no_schools_all = 'create or replace view pat_exception_grade_data_all as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard
 except select school_id,grade,subject from periodic_exam_school_result
union
select distinct sma.*,''grade'' as subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';


pat_grade_no_schools_last7 = 'create or replace view pat_exception_grade_data_last7 as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from pat_date_range where date_range=''last7days'')
 except select school_id,grade,subject from periodic_exam_school_result 
union
select distinct sma.*,''grade'' as subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard where exam_code in(select exam_code from pat_date_range where date_range=''last7days'')
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';



pat_grade_no_schools_last30 = 'create or replace view pat_exception_grade_data_last30 as
select distinct a.school_id,initcap(a.school_name)as school_name,a.cluster_id,initcap(a.cluster_name)as cluster_name,a.block_id,
initcap(a.block_name)as block_name,a.district_id,initcap(a.district_name)as district_name
,b.school_latitude,b.school_longitude,b.cluster_latitude,b.cluster_longitude,b.block_latitude,b.block_longitude,a.school_management_type,
 b.district_latitude,b.district_longitude,cast(''Grade ''||d.grade as text)as grade,d.subject from school_hierarchy_details as a
 	inner join school_geo_master as b on a.school_id=b.school_id
inner join (select sm.*,sd.subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sm inner join subject_details sd on sd.grade=sm.grade 
 inner join periodic_exam_mst  pem on pem.subject_id=sd.subject_id and sd.grade=pem.standard where exam_code in(select exam_code from pat_date_range where date_range=''last30days'')
 except select school_id,grade,subject from periodic_exam_school_result 
union
select distinct sma.*,''grade'' as subject from (select school_id,generate_series(school_lowest_class,school_highest_class) as grade from school_master) sma inner join periodic_exam_mst  pm on sma.grade=pm.standard where exam_code in(select exam_code from pat_date_range where date_range=''last30days'')
 except select school_id,grade,''grade'' as subject from periodic_exam_school_result) as d on a.school_id = d.school_id';


Execute pat_grade_no_schools_all;
Execute pat_grade_no_schools_last7;
Execute pat_grade_no_schools_last30;

END IF;
return 0;
END;
$function$;

select pat_no_schools_grade();

/* Pat year and month */

CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_mgmt_year_month as
(select a.school_id,c.cluster_id,c.block_id,c.district_id,b.assessment_year as academic_year,b.month,school_management_type,
    count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
                                substring(exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,assessment_year, trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id,b.assessment_year,month ,school_management_type,cluster_id,block_id,district_id) WITH NO DATA ;


CREATE MATERIALIZED VIEW IF NOT EXISTS stud_count_school_grade_mgmt_year_month as
(select grade,school_id,cluster_id,block_id,district_id,school_management_type,count(distinct student_uid) as students_attended,trim(TO_CHAR(TO_DATE (month::text, 'MM'), 'Month')) AS month ,
case when month in (6,7,8,9,10,11,12) then
 (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,count(distinct school_id) as total_schools from (
select concat('Grade ',studying_class) as grade,cast (substring (exam_code,10,2) as integer) as month ,  
cast (right(exam_code,4)as integer) as year,pert.school_id,cluster_id,block_id,district_id,
school_management_type,student_uid from periodic_exam_stud_grade_count pert  join school_hierarchy_details shd on pert.school_id=shd.school_id 
where exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)) as a
group by school_id,grade,month,academic_year,school_management_type,cluster_id,block_id,district_id) WITH NO DATA;

/* District */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_year_month AS
 (SELECT d.academic_year,
    d.district_id,
    d.district_name,
    d.district_latitude,
    d.district_longitude,
    d.district_performance,
    trim(d.month) as month,
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
            c.month,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
                    a.district_id,
                    a.district_name,
                    a.district_latitude,
                    a.district_longitude,
                    b_1.district_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
                            periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,
                            periodic_exam_school_result.district_latitude,
                            periodic_exam_school_result.district_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result
						   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name, periodic_exam_school_result.district_latitude, periodic_exam_school_result.district_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.month,
                            a_1.district_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								  'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id) as b
join (select district_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
school_grade_enrolment_district  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.district_id, a_1.academic_year, a_1.month) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.district_id = b_1.district_id AND a.month = b_1.month) c
 
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.district_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result
								   	where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_district tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade, b_1.month) d_2
                  GROUP BY d_2.academic_year, d_2.district_id, d_2.month) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.district_id = d_1.district_id AND c.month = d_1.month) d
     LEFT JOIN ( select district_id,academic_year,month,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_year_month group by district_id,academic_year,month) b ON d.academic_year::text = b.academic_year::text AND d.district_id = b.district_id AND d.month = b.month
left join
 (select sum(total_students) as total_students,district_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result) group by district_id) tot_stud
on d.district_id=tot_stud.district_id) WITH NO DATA;		  

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_exam_block_year_month AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.block_name,
    d.block_latitude,
    d.block_longitude,
    d.block_performance,
    trim(d.month) as month,
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
            c.month,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.district_name,
                    a.block_id,
                    a.block_name,
                    a.block_latitude,
                    a.block_longitude,
                    b_1.block_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        
                            periodic_exam_school_result.block_id,
                            initcap(periodic_exam_school_result.block_name::text) AS block_name,
                            periodic_exam_school_result.block_latitude,
                            periodic_exam_school_result.block_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result
						   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
						  substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,periodic_exam_school_result.block_id, periodic_exam_school_result.block_name, periodic_exam_school_result.block_latitude, periodic_exam_school_result.block_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.month,
                            a_1.block_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								  'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id) as b
join (select block_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
school_grade_enrolment_block  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.block_id, a_1.academic_year, a_1.month) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.block_id = b_1.block_id AND a.month = b_1.month) c
 
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.block_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_block tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade, b_1.month) d_2
                  GROUP BY d_2.academic_year, d_2.block_id, d_2.month) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.block_id = d_1.block_id AND c.month = d_1.month) d
     LEFT JOIN (select block_id,academic_year,month,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_year_month group by block_id,academic_year,month) b ON d.academic_year::text = b.academic_year::text AND d.block_id = b.block_id AND d.month = b.month
left join
 (select sum(total_students) as total_students,block_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result) group by block_id) tot_stud
on d.block_id=tot_stud.block_id) WITH NO DATA;		  

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_exam_cluster_year_month AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.block_name,
	d.cluster_id,
	d.cluster_name,
    d.cluster_latitude,
    d.cluster_longitude,
    d.cluster_performance,
    trim(d.month) as month,
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
            c.month,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.district_name,
					a.block_id,
					a.block_name,
                    a.cluster_id,
                    a.cluster_name,
                    a.cluster_latitude,
                    a.cluster_longitude,
                    b_1.cluster_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        
                            periodic_exam_school_result.block_id,
                            initcap(periodic_exam_school_result.block_name::text) AS block_name,							
                            periodic_exam_school_result.cluster_id,
                            initcap(periodic_exam_school_result.cluster_name::text) AS cluster_name,
                            periodic_exam_school_result.cluster_latitude,
                            periodic_exam_school_result.cluster_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result
						   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,periodic_exam_school_result.block_id, periodic_exam_school_result.block_name,
						  periodic_exam_school_result.cluster_id, periodic_exam_school_result.cluster_name, periodic_exam_school_result.cluster_latitude, periodic_exam_school_result.cluster_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.month,
                            a_1.cluster_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.cluster_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								  'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.cluster_id) as b
join (select cluster_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,academic_year,month) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
school_grade_enrolment_cluster  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.cluster_id, a_1.academic_year, a_1.month) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.cluster_id = b_1.cluster_id AND a.month = b_1.month) c
 
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.cluster_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.cluster_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.cluster_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,academic_year,month) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_cluster tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade, b_1.month) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id, d_2.month) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.cluster_id = d_1.cluster_id AND c.month = d_1.month) d
     LEFT JOIN ( select cluster_id,academic_year,month,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_year_month group by cluster_id,academic_year,month) b ON d.academic_year::text = b.academic_year::text AND d.cluster_id = b.cluster_id AND d.month = b.month
left join
 (select sum(total_students) as total_students,cluster_id from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result) group by cluster_id) tot_stud
on d.cluster_id=tot_stud.cluster_id) WITH NO DATA;		  

/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_exam_school_year_month AS
( SELECT d.academic_year,
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
    trim(d.month) as month,
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
            c.month,
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
                    a.school_name,
                    a.school_latitude,
                    a.school_longitude,
                    b_1.school_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        
                            periodic_exam_school_result.block_id,
                            initcap(periodic_exam_school_result.block_name::text) AS block_name,							
							periodic_exam_school_result.cluster_id,
							initcap(periodic_exam_school_result.cluster_name) as cluster_name,
                            periodic_exam_school_result.school_id,
                            initcap(periodic_exam_school_result.school_name::text) AS school_name,
                            periodic_exam_school_result.school_latitude,
                            periodic_exam_school_result.school_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result
						   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,periodic_exam_school_result.block_id, periodic_exam_school_result.block_name,
						  periodic_exam_school_result.cluster_id, periodic_exam_school_result.cluster_name,periodic_exam_school_result.school_id, periodic_exam_school_result.school_name, periodic_exam_school_result.school_latitude, periodic_exam_school_result.school_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
                            a_1.month,
                            a_1.school_id
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.school_id,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								  'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id) as b
join stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
school_grade_enrolment_school  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)a_1
GROUP BY a_1.school_id, a_1.academic_year, a_1.month) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.school_id = b_1.school_id AND a.month = b_1.month) c
 
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.school_id,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.school_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.school_id,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result
								   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
								   substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_school tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade, b_1.month) d_2
                  GROUP BY d_2.academic_year, d_2.school_id, d_2.month) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.school_id = d_1.school_id AND c.month = d_1.month) d
     LEFT JOIN stud_count_school_mgmt_year_month b ON d.academic_year::text = b.academic_year::text AND d.school_id = b.school_id AND d.month = b.month
left join
 (select sum(total_students) as total_students,school_id from school_hierarchy_details group by school_id) tot_stud
on d.school_id=tot_stud.school_id) WITH NO DATA;		  


/* pat month and year */
/* grade filter */
/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance from periodic_exam_district_year_month)as a
left join
(select academic_year,district_id,grade,month,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,subject,month,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,month,
district_id order by 3,grade)as a
join (select district_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,academic_year,month)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month
join school_grade_enrolment_district tot_stud
 on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade))as a
group by district_id,grade,academic_year,month
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.month=b.month
join
(select district_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_district tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade) WITH NO DATA;



/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance from periodic_exam_block_year_month)as a
left join
(select academic_year,block_id,grade,month,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,subject,month,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,month,
block_id order by 3,grade)as a
join (select block_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,academic_year,month)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month
join  school_grade_enrolment_block tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade ))as a
group by block_id,grade,academic_year,month
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.month=b.month
join
(select block_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_block tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade) WITH NO DATA;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance from periodic_exam_cluster_year_month)as a
left join
(select academic_year,cluster_id,grade,month,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,subject,month,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,month,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,academic_year,month)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month
join school_grade_enrolment_cluster tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade))as a
group by cluster_id,grade,academic_year,month
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.month=b.month
join
(select cluster_id,grade,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,academic_year,month) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_cluster tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade) WITH NO DATA;


/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,trim(month) as month,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance from periodic_exam_school_year_month)as a
left join
(select academic_year,school_id,grade,trim(month) as month,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,subject,month,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or 
substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) 
group by academic_year,grade,month,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_year_month as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month
join
 school_grade_enrolment_school tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade))as a
group by school_id,grade,academic_year,month
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.month=b.month
join
stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month
left join
 school_grade_enrolment_school tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade) WITH NO DATA;

/*----------Management ------*/
/*------------------------Over all----------------------------------*/

/* periodic exam district*/

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
school_management_type
from periodic_exam_school_result where school_management_type is not null 
 group by academic_year,school_management_type,
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result  where school_management_type is not null 
group by academic_year,grade,school_management_type,
district_id)as a
group by district_id,academic_year,school_management_type)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,district_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,
school_management_type from
(select academic_year,district_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,
school_management_type from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade,subject,school_management_type,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null 
group by academic_year,grade,school_management_type,
district_id order by grade desc,subject_name))as b
group by academic_year,district_id,grade,school_management_type)as d
group by academic_year,district_id,school_management_type
)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.school_management_type=d.school_management_type) WITH NO DATA;

/*periodic exam block*/

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,school_management_type
from periodic_exam_school_result where school_management_type is not null group by academic_year,
block_id,block_name,district_id,district_name,block_latitude,block_longitude,school_management_type) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null  group by academic_year,grade,school_management_type,
block_id)as a
group by block_id,academic_year,school_management_type)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,block_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,
school_management_type from
(select academic_year,block_id,school_management_type,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,school_management_type,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
block_id order by grade desc,subject_name)) as a
group by academic_year,block_id,grade,school_management_type)as d
group by academic_year,block_id,school_management_type
)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.school_management_type=d.school_management_type) WITH NO DATA;

/*periodic exam cluster*/

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,school_management_type
from periodic_exam_school_result where school_management_type is not null group by academic_year,
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,
cluster_id,school_management_type)as a
group by cluster_id,academic_year,school_management_type)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type)as c
left join 
(
select academic_year,cluster_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,
school_management_type from
(select academic_year,cluster_id,school_management_type,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
cluster_id order by grade desc,subject_name)) as a
group by academic_year,cluster_id,grade,school_management_type)as d
group by academic_year,cluster_id,school_management_type
)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type) WITH NO DATA;

/*periodic exam school*/

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_mgmt_all as
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,
school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_management_type
from periodic_exam_school_result where school_management_type is not null  group by academic_year,
school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id,school_management_type from
(select academic_year,cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,
school_id,school_management_type)as a
group by school_id,academic_year,school_management_type)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type )as c
left join 
(
select academic_year,school_id,json_object_agg(grade,subject_wise_performance)as subject_wise_performance,school_management_type from
(select academic_year,school_id,
grade,json_object_agg(subject_name,percentage  order by subject_name)::jsonb as subject_wise_performance,school_management_type from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,
school_id,school_management_type order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
school_management_type
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,
school_id,school_management_type order by grade desc,subject_name)) as a where school_management_type is not null 
group by academic_year,school_id,grade,school_management_type)as d
group by academic_year,school_id,school_management_type
)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.school_management_type=d.school_management_type) WITH NO DATA;



/*----------------------------------------------------------- PAT grade subject wise*/

/* district - grade */

create or replace view periodic_grade_district_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,
school_management_type from periodic_exam_district_mgmt_all)as a
left join
(select academic_year,district_id,grade,school_management_type,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,school_management_type,
district_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
district_id order by 3,grade))as a
group by district_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type;


/*--- block - grade*/

create or replace view periodic_grade_block_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance,school_management_type from periodic_exam_block_mgmt_all)as a
left join
(select academic_year,block_id,grade,school_management_type,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,school_management_type,
block_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
block_id order by 3,grade))as a
group by block_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type;

/*--- cluster - grade*/

create or replace view periodic_grade_cluster_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,school_management_type,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance from periodic_exam_cluster_mgmt_all)as a
left join
(select academic_year,cluster_id,grade,school_management_type,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
cluster_id order by 3,grade))as a
group by cluster_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type;

/*--- school - grade*/

create or replace view periodic_grade_school_mgmt_all as
select a.*,b.grade,b.subjects
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from periodic_exam_school_mgmt_all)as a
left join
(select academic_year,school_id,grade,school_management_type,
json_object_agg(subject_name,percentage order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where school_management_type is not null group by academic_year,grade,subject,school_management_type,
school_id order by grade desc,subject_name)
union
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result where school_management_type is not null group by academic_year,grade,school_management_type,
school_id order by 3,grade))as a
group by school_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type;

/*------------------------last 30 days--------------------------------------------------------------------------------------------------------*/

/* dist*/
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_mgmt_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,school_management_type,
district_latitude,district_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
and school_management_type is not null
group by academic_year,district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.district_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.district_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_district_mgmt_last30  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.district_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.district_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.district_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_district_mgmt_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.district_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.school_management_type=d.school_management_type)as d
left join 
 (select district_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by district_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,district_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;	

/* block */
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_mgmt_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,school_management_type,
block_latitude,block_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
and school_management_type is not null
group by academic_year,block_id,block_name,district_id,district_name,
block_latitude,block_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.block_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.block_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_block_mgmt_last30  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.block_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.block_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.block_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_block_mgmt_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.block_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.school_management_type=d.school_management_type)as d
left join 
 (select block_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by block_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,block_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type  where d.school_management_type is not null) WITH NO DATA;	
	
/* cluster */
	
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_mgmt_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,
initcap(cluster_name) as cluster_name,school_management_type,
cluster_latitude,cluster_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
and school_management_type is not null
group by academic_year,cluster_id,cluster_name,district_id,district_name,block_id,block_name,
cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.cluster_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.cluster_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_cluster_mgmt_last30  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.cluster_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.cluster_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.cluster_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_cluster_mgmt_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type)as d
left join 
 (select cluster_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last30 group by cluster_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,cluster_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;	

/* school*/
	
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_mgmt_last30 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,
initcap(cluster_name) as cluster_name,school_id,initcap(school_name) as school_name,school_management_type,
school_latitude,school_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
and school_management_type is not null
group by academic_year,school_id,school_name,school_id,school_name,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,school_latitude,school_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
                            a_1.school_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select school_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by school_id,grade,school_management_type) as c
on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_school_mgmt_last30  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.school_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.school_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.school_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select school_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 group by school_id,grade,school_management_type) as c
on b.school_id=c.school_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_school_mgmt_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.school_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.school_management_type=d.school_management_type)as d
left join 
 stud_count_school_mgmt_last30 as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.school_management_type=b.school_management_type
   left join
 (select sum(total_students) as total_students,school_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last30days')) group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/*----------------------------------------------------------- PAT grade subject wise*/


/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,school_management_type from 
	periodic_exam_district_mgmt_last30)as a
left join
(select academic_year,district_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last30days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by academic_year,grade,school_management_type,
district_id order by 3,grade)as a
join (select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by district_id,grade,school_management_type)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_district_mgmt_last30 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by district_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type
left join
(select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_district_mgmt_last30 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* block - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance,school_management_type from 
	periodic_exam_block_mgmt_last30)as a
left join
(select academic_year,block_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last30days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by academic_year,grade,school_management_type,
block_id order by 3,grade)as a
join (select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by block_id,grade,school_management_type)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_block_mgmt_last30 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by block_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type
left join
(select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_block_mgmt_last30 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/* cluster - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance,school_management_type from 
	periodic_exam_cluster_mgmt_last30)as a
left join
(select academic_year,cluster_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last30days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by academic_year,grade,school_management_type,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by cluster_id,grade,school_management_type)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_cluster_mgmt_last30 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by cluster_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type
left join
(select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last30 where school_management_type is not null group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_cluster_mgmt_last30 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* school */
CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_mgmt_last30 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from periodic_exam_school_mgmt_last30)as a
left join
(select academic_year,school_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last30days')  and  school_management_type is not null group by academic_year,grade,subject,school_management_type,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range 
where date_range='last30days') and  school_management_type is not null group by academic_year,grade,school_management_type,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_last30 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_school_mgmt_last30 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by school_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type
left join
stud_count_school_grade_mgmt_last30 as c
on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_school_mgmt_last30 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* ------------------- Year and month -------------------------------------------*/


/* district */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_mgmt_year_month AS
 (SELECT d.academic_year,
	d.district_id,
	d.district_name,
	d.school_management_type,
    d.district_latitude,
    d.district_longitude,
    d.district_performance,
    trim(d.month) as month,
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
            c.month,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.school_management_type,
                    a.district_name,
                    a.district_latitude,
                    a.district_longitude,
                    b_1.district_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        
							periodic_exam_school_result.school_management_type,
                            periodic_exam_school_result.district_latitude,
                            periodic_exam_school_result.district_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year,periodic_exam_school_result.school_management_type, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,
						   periodic_exam_school_result.district_latitude, periodic_exam_school_result.district_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.month,
                            a_1.district_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								   'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type) as b
join (select district_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,school_management_type,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.district_id, a_1.academic_year, a_1.month,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.district_id = b_1.district_id AND a.month = b_1.month and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.district_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,b_1.school_management_type,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_management_type,
								  periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,periodic_exam_school_result.school_management_type,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.district_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select district_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,school_management_type,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade, b_1.month,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.district_id, d_2.month,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.district_id = d_1.district_id AND c.month = d_1.month
				  and c.school_management_type=d_1.school_management_type) d
left join
 (select district_id,academic_year,month,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_year_month group by district_id,academic_year,month,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.month=b.month and d.school_management_type=b.school_management_type
        join
 (select sum(total_students) as total_students,district_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM periodic_exam_school_result) group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_mgmt_year_month AS
( SELECT d.academic_year,
    d.district_id,
    d.district_name,
	d.block_id,
	d.school_management_type,
	d.block_name,
    d.block_latitude,
    d.block_longitude,
    d.block_performance,
    trim(d.month) as month,
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
			c.school_management_type,
            c.block_latitude,
            c.block_longitude,
            c.block_performance,
            c.month,
            c.grade_wise_performance,
            d_1.subject_wise_performance
           FROM ( SELECT a.academic_year,
					a.district_id,
					a.district_name,
                    a.block_id,
					a.school_management_type,
                    a.block_name,
                    a.block_latitude,
                    a.block_longitude,
                    b_1.block_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        					
                            periodic_exam_school_result.block_id,
							periodic_exam_school_result.school_management_type,
                            initcap(periodic_exam_school_result.block_name::text) AS block_name,
                            periodic_exam_school_result.block_latitude,
                            periodic_exam_school_result.block_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result 
						   where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year,periodic_exam_school_result.school_management_type, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,periodic_exam_school_result.block_id, periodic_exam_school_result.block_name,
						  periodic_exam_school_result.block_latitude, periodic_exam_school_result.block_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.month,
                            a_1.block_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								   'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type) as b
join (select block_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,school_management_type,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.block_id, a_1.academic_year, a_1.month,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.block_id = b_1.block_id AND a.month = b_1.month and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.block_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,b_1.school_management_type,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_management_type,
								  periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,periodic_exam_school_result.school_management_type,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.block_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
(select block_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,school_management_type,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade, b_1.month,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.block_id, d_2.month,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.block_id = d_1.block_id AND c.month = d_1.month
				  and c.school_management_type=d_1.school_management_type) d
left join
 (select block_id,academic_year,month,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_year_month group by block_id,academic_year,month,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.month=b.month and d.school_management_type=b.school_management_type
       join
 (select sum(total_students) as total_students,block_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM periodic_exam_school_result) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;

/* cluster */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_mgmt_year_month AS
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
    trim(d.month) as month,
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
            c.month,
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
                    b_1.cluster_performance,
                    a.month,
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
                            trim(to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY academic_year,school_management_type, (to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  district_id, district_name,block_id, block_name,
						  cluster_id, cluster_name, cluster_latitude, cluster_longitude) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.month,
                            a_1.cluster_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    cluster_id,school_management_type,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY academic_year, grade, (to_char(to_date(date_part('month'::text, exam_date)::text,
								   'MM'::text)::timestamp with time zone, 'Month'::text)), cluster_id,school_management_type) as b
join (select cluster_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,school_management_type,academic_year,month) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.cluster_id, a_1.academic_year, a_1.month,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.cluster_id = b_1.cluster_id AND a.month = b_1.month and 
a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.cluster_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,b_1.school_management_type,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    subject AS subject_name,
                                    cluster_id,school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY academic_year, grade, school_management_type,
								  subject, (to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT academic_year,
                                    'Grade '::text || grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    cluster_id,school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY academic_year, grade,school_management_type,
								  (to_char(to_date(date_part('month'::text, exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), cluster_id
                                  ORDER BY ('Grade '::text || grade) DESC, 'Grade Performance'::text) as b
join
(select cluster_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,school_management_type,academic_year,month) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade, b_1.month,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id, d_2.month,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.cluster_id = d_1.cluster_id AND c.month = d_1.month
				  and c.school_management_type=d_1.school_management_type) d
       join
 (select sum(total_students) as total_students,cluster_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id FROM periodic_exam_school_result) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type 
 left join
 student_att_count as b 
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.month=b.month and d.school_management_type=b.school_management_type where d.school_management_type is not null) WITH NO DATA;



/* school */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_mgmt_year_month AS
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
    trim(d.month) as month,
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
            c.month,
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
                    b_1.school_performance,
                    a.month,
                    b_1.grade_wise_performance
                   FROM ( SELECT periodic_exam_school_result.academic_year,
							         periodic_exam_school_result.district_id,
                            initcap(periodic_exam_school_result.district_name::text) AS district_name,        
                            periodic_exam_school_result.block_id,
                            initcap(periodic_exam_school_result.block_name::text) AS block_name,							
							periodic_exam_school_result.cluster_id,
							initcap(periodic_exam_school_result.cluster_name) as cluster_name,
                            periodic_exam_school_result.school_id,
                            initcap(periodic_exam_school_result.school_name::text) AS school_name,
							periodic_exam_school_result.school_management_type,
                            periodic_exam_school_result.school_latitude,
                            periodic_exam_school_result.school_longitude,
                            trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                           FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                          GROUP BY periodic_exam_school_result.academic_year, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)),
						  periodic_exam_school_result.district_id, periodic_exam_school_result.district_name,periodic_exam_school_result.block_id, periodic_exam_school_result.block_name,
						  periodic_exam_school_result.cluster_id, periodic_exam_school_result.cluster_name,periodic_exam_school_result.school_id, periodic_exam_school_result.school_name, periodic_exam_school_result.school_latitude, periodic_exam_school_result.school_longitude,
						  periodic_exam_school_result.school_management_type) a
                    LEFT JOIN (SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
                            a_1.month,
                            a_1.school_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text,
								  'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type) as b
join stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_school_mgmt  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.school_id, a_1.academic_year, a_1.month,a_1.school_management_type) b_1 ON a.academic_year::text = b_1.academic_year::text AND a.school_id = b_1.school_id AND a.month = b_1.month 
and a.school_management_type=b_1.school_management_type) c
             LEFT JOIN ( SELECT d_2.academic_year,
                    d_2.school_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance,
                    d_2.month
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,b_1.school_management_type,
                            b_1.month,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_management_type,
								  periodic_exam_school_result.subject, (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    trim(to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)) AS month,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat)
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade,periodic_exam_school_result.school_management_type,
								  (to_char(to_date(date_part('month'::text, periodic_exam_school_result.exam_date)::text, 'MM'::text)::timestamp with time zone, 'Month'::text)), periodic_exam_school_result.school_id
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
join
stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_school_mgmt tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade, b_1.month,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.school_id, d_2.month,d_2.school_management_type) d_1 ON c.academic_year::text = d_1.academic_year::text AND c.school_id = d_1.school_id AND c.month = d_1.month
				  and c.school_management_type=d_1.school_management_type) d
LEFT JOIN stud_count_school_mgmt_year_month b ON d.academic_year::text = b.academic_year::text AND d.school_id = b.school_id AND d.month = b.month 
and d.school_management_type = b.school_management_type
 join
 (select sum(total_students) as total_students,school_id,school_management_type from school_hierarchy_details group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;


/* PAT grade subject wise -Year and Month*/

/* district - grade */
CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_mgmt_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,
	district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,school_management_type from periodic_exam_district_mgmt_year_month)as a
left join
(select academic_year,district_id,grade,month,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,subject,month,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,month,school_management_type,
district_id order by 3,grade)as a
join (select district_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,school_management_type,academic_year,month)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month and a.school_management_type=sa.school_management_type
join school_grade_enrolment_district_mgmt tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by district_id,grade,academic_year,month,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.month=b.month and a.school_management_type=b.school_management_type
join
(select district_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by district_id,grade,school_management_type,academic_year,month) as c
on b.district_id=c.district_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_district_mgmt tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/*--- block - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_mgmt_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,block_latitude,block_longitude,block_performance,school_management_type from periodic_exam_block_mgmt_year_month)as a
left join
(select academic_year,block_id,grade,month,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,subject,month,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,month,school_management_type,
block_id order by 3,grade)as a
join (select block_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,school_management_type,academic_year,month)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month and a.school_management_type=sa.school_management_type
join  school_grade_enrolment_block_mgmt tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by block_id,grade,academic_year,month,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.month=b.month and a.school_management_type=b.school_management_type
join
(select block_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by block_id,grade,school_management_type,academic_year,month) as c
on b.block_id=c.block_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_block_mgmt tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/*--- cluster - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_mgmt_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,month,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,cluster_latitude,cluster_longitude,cluster_performance,school_management_type from periodic_exam_cluster_mgmt_year_month)as a
left join
(select academic_year,cluster_id,grade,month,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,subject,month,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,month,school_management_type,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,school_management_type,academic_year,month,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_year_month group by cluster_id,grade,school_management_type,academic_year,month)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month and a.school_management_type=sa.school_management_type
join school_grade_enrolment_cluster_mgmt tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by cluster_id,grade,academic_year,month,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.month=b.month and a.school_management_type=b.school_management_type
left join
 school_grade_enrolment_cluster_mgmt tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type
left join
student_att_grade_count as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type) WITH NO DATA;


/*--- school - grade*/

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_mgmt_year_month as 
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,trim(month) as month,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from periodic_exam_school_mgmt_year_month)as a
left join
(select academic_year,school_id,grade,trim(month) as month,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,subject,month,school_management_type,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
trim(TO_CHAR(TO_DATE(date_part('month',exam_date)::text, 'MM'), 'Month')) AS month,count(distinct school_id) as total_schools
FROM periodic_exam_school_result where periodic_exam_school_result.exam_code in (select exam_code from latest_data_to_be_processed_pat) or substring(periodic_exam_school_result.exam_code,10,6) in (select substring(exam_code,10,6) from latest_data_to_be_processed_pat) group by academic_year,grade,month,school_management_type,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_year_month as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.academic_year=sa.academic_year and a.month=sa.month and a.school_management_type=sa.school_management_type
join school_grade_enrolment_school_mgmt tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade  and a.school_management_type=tot_stud.school_management_type))as a
group by school_id,grade,academic_year,month,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.month=b.month and a.school_management_type=b.school_management_type
left join
stud_count_school_grade_mgmt_year_month as c
on b.school_id=c.school_id and b.grade=c.grade and b.academic_year=c.academic_year and b.month=c.month and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_school_mgmt tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade  and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/*------------------------last 7 days--------------------------------------------------------------------------------------------------------*/

/* dist*/
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_district_mgmt_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,school_management_type,
district_latitude,district_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
and school_management_type is not null
group by academic_year,district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as district_performance,
                            a_1.district_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.district_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_district_mgmt_last7  tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.district_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.district_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.district_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.district_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.district_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_district_mgmt_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.district_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.district_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.district_id=d.district_id and c.school_management_type=d.school_management_type)as d
left join 
 (select district_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by district_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.district_id=b.district_id and d.school_management_type=b.school_management_type
    join
 (select sum(total_students) as total_students,district_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by district_id,school_management_type) tot_stud
on d.district_id=tot_stud.district_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;	

/* block */

CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_block_mgmt_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,school_management_type,
block_latitude,block_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
and school_management_type is not null
group by academic_year,block_id,block_name,district_id,district_name,
block_latitude,block_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as block_performance,
                            a_1.block_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.block_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_block_mgmt_last7  tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.block_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.block_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.block_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.block_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.block_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_block_mgmt_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.block_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.block_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.block_id=d.block_id and c.school_management_type=d.school_management_type)as d
left join 
 (select block_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by block_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.block_id=b.block_id and d.school_management_type=b.school_management_type
    join
 (select sum(total_students) as total_students,block_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by block_id,school_management_type) tot_stud
on d.block_id=tot_stud.block_id and d.school_management_type=tot_stud.school_management_type  where d.school_management_type is not null) WITH NO DATA;	
	
/* cluster */
	
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_cluster_mgmt_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,
initcap(cluster_name) as cluster_name,school_management_type,
cluster_latitude,cluster_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
and school_management_type is not null
group by academic_year,cluster_id,cluster_name,district_id,district_name,block_id,block_name,
cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as cluster_performance,
                            a_1.cluster_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.cluster_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_cluster_mgmt_last7  tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.cluster_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.cluster_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.cluster_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.cluster_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.cluster_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_cluster_mgmt_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.cluster_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.cluster_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type)as d
left join 
 (select cluster_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by cluster_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.cluster_id=b.cluster_id and d.school_management_type=b.school_management_type
    join
 (select sum(total_students) as total_students,cluster_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by cluster_id,school_management_type) tot_stud
on d.cluster_id=tot_stud.cluster_id and d.school_management_type=tot_stud.school_management_type where d.school_management_type is not null) WITH NO DATA;	

/* school*/
	
CREATE MATERIALIZED VIEW IF NOT EXISTS periodic_exam_school_mgmt_last7 as
(select d.*,b.total_schools,b.students_count as students_attended,tot_stud.total_students from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select academic_year,district_id,initcap(district_name) as district_name,block_id,initcap(block_name) as block_name,cluster_id,
initcap(cluster_name) as cluster_name,school_id,initcap(school_name) as school_name,school_management_type,
school_latitude,school_longitude
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days')
and school_management_type is not null
group by academic_year,school_id,school_name,school_id,school_name,district_id,district_name,block_id,block_name,
cluster_id,cluster_name,school_latitude,school_longitude,school_management_type) as a
left join 
(SELECT a_1.academic_year,
                            json_object_agg(a_1.grade, json_build_object('percentage',a_1.percentage,'total_schools',total_schools,'total_students',total_students,'students_attended',students_attended)) AS grade_wise_performance,round(avg(percentage),1) as school_performance,
                            a_1.school_id,a_1.school_management_type
                           FROM (select b.*,c.students_attended,c.total_schools,tot_stud.total_students from  (SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage   
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.school_id,
								  periodic_exam_school_result.school_management_type) as b
left join (select school_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by school_id,grade,school_management_type) as c
on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_school_mgmt_last7  tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)a_1
GROUP BY a_1.school_id, a_1.academic_year,a_1.school_management_type)as b
on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type)as c
left join 
(SELECT d_2.academic_year,
                    d_2.school_id,d_2.school_management_type,
                    json_object_agg(grade,d_2.subject_wise_performance order by grade ) AS subject_wise_performance
                   FROM (SELECT b_1.academic_year,
                            b_1.school_id,b_1.school_management_type,
							grade,
                            json_object_agg(b_1.subject_name,json_build_object( 'percentage',b_1.percentage,'total_schools',b_1.total_schools,'total_students',b_1.total_students,
							'students_attended',b_1.students_attended)order by b_1.subject_name) AS subject_wise_performance
                           FROM (( SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    periodic_exam_school_result.subject AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage,
									sum(students_count) as total_students,count(distinct school_id) as total_schools,sum(students_attended) as students_attended
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null 
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade, periodic_exam_school_result.subject, periodic_exam_school_result.school_id,
								  periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, periodic_exam_school_result.subject)
                                UNION
                                ( select b.*,tot_stud.total_students,c.total_schools,c.students_attended from(SELECT periodic_exam_school_result.academic_year,
                                    'Grade '::text || periodic_exam_school_result.grade AS grade,
                                    'Grade Performance'::text AS subject_name,
                                    periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type,
                                    round(COALESCE(sum(periodic_exam_school_result.obtained_marks), 0::numeric) * 100.0 / COALESCE(sum(periodic_exam_school_result.total_marks), 0::numeric), 1) AS percentage
                                   FROM periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
                                  GROUP BY periodic_exam_school_result.academic_year, periodic_exam_school_result.grade
							, periodic_exam_school_result.school_id,periodic_exam_school_result.school_management_type
                                  ORDER BY ('Grade '::text || periodic_exam_school_result.grade) DESC, 'Grade Performance'::text) as b
left join
(select school_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 group by school_id,grade,school_management_type) as c
on b.school_id=c.school_id and b.grade=c.grade  and b.school_management_type=c.school_management_type
left join
 school_grade_enrolment_school_mgmt_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type)) b_1
                          GROUP BY b_1.academic_year, b_1.school_id, b_1.grade,b_1.school_management_type) d_2
                  GROUP BY d_2.academic_year, d_2.school_id,d_2.school_management_type)as d on c.academic_year=d.academic_year and c.school_id=d.school_id and c.school_management_type=d.school_management_type)as d
left join 
 (select school_id,academic_year,school_management_type,
	sum(students_count) as students_count,sum(total_schools) as total_schools
from stud_count_school_mgmt_last7 group by school_id,academic_year,school_management_type)as b
 on d.academic_year=b.academic_year and d.school_id=b.school_id and d.school_management_type=b.school_management_type
    join
 (select sum(total_students) as total_students,school_id,school_management_type from school_hierarchy_details shd 
 where school_id in (select school_id from periodic_exam_school_result where exam_code in  (select exam_code from pat_date_range where date_range='last7days')) group by school_id,school_management_type) tot_stud
on d.school_id=tot_stud.school_id and d.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/*----------------------------------------------------------- PAT grade subject wise*/

/* district - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_district_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,district_id,initcap(district_name)as district_name,district_latitude,district_longitude,district_performance,school_management_type from 
	periodic_exam_district_mgmt_last7)as a
left join
(select academic_year,district_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last7days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
district_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
district_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
group by academic_year,grade,school_management_type,
district_id order by 3,grade)as a
join (select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by district_id,grade,school_management_type)as sa 
on a.district_id=sa.district_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_district_mgmt_last7 tot_stud
on a.district_id=tot_stud.district_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by district_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.district_id=b.district_id and a.school_management_type=b.school_management_type
left join
(select district_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by district_id,grade,school_management_type) as c
on b.district_id=c.district_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_district_mgmt_last7 tot_stud
on b.district_id=tot_stud.district_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* block - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_block_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,block_id,initcap(block_name)as block_name,block_latitude,block_longitude,block_performance,school_management_type from 
	periodic_exam_block_mgmt_last7)as a
left join
(select academic_year,block_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last7days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
block_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
block_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
group by academic_year,grade,school_management_type,
block_id order by 3,grade)as a
join (select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by block_id,grade,school_management_type)as sa 
on a.block_id=sa.block_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_block_mgmt_last7 tot_stud
on a.block_id=tot_stud.block_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by block_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.block_id=b.block_id and a.school_management_type=b.school_management_type
left join
(select block_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by block_id,grade,school_management_type) as c
on b.block_id=c.block_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_block_mgmt_last7 tot_stud
on b.block_id=tot_stud.block_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/* cluster - grade */

CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_cluster_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,cluster_id,initcap(cluster_name)as cluster_name,cluster_latitude,cluster_longitude,cluster_performance,school_management_type from 
	periodic_exam_cluster_mgmt_last7)as a
left join
(select academic_year,cluster_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools,
sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last7days') and school_management_type is not null
group by academic_year,grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
cluster_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last7days') and school_management_type is not null
group by academic_year,grade,school_management_type,
cluster_id order by 3,grade)as a
join (select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by cluster_id,grade,school_management_type)as sa 
on a.cluster_id=sa.cluster_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_cluster_mgmt_last7 tot_stud
on a.cluster_id=tot_stud.cluster_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by cluster_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type
left join
(select cluster_id,grade,school_management_type,
	sum(students_attended) as students_attended,sum(total_schools) as total_schools
from stud_count_school_grade_mgmt_last7 where school_management_type is not null group by cluster_id,grade,school_management_type) as c
on b.cluster_id=c.cluster_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_cluster_mgmt_last7 tot_stud
on b.cluster_id=tot_stud.cluster_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;


/* school */
CREATE MATERIALIZED VIEW IF NOT EXISTS  periodic_grade_school_mgmt_last7 as
(select a.*,b.grade,b.subjects,c.students_attended,tot_stud.total_students,c.total_schools
from
(select academic_year,school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
	district_id,initcap(district_name)as district_name,school_latitude,school_longitude,school_performance,school_management_type from periodic_exam_school_mgmt_last7)as a
left join
(select academic_year,school_id,grade,school_management_type,
json_object_agg(subject_name,json_build_object('percentage',percentage,'total_students',total_students,'students_attended',students_attended,'total_schools',total_schools) order by subject_name) as subjects
from
((select academic_year,cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,
count(distinct school_id) as total_schools,sum(students_count) as total_students,sum(students_attended) as students_attended
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range 
where date_range='last7days')  and  school_management_type is not null group by academic_year,grade,subject,school_management_type,
school_id order by grade desc,subject_name)
union
(select a.*,tot_stud.total_students,sa.students_attended from 
(select academic_year,cast('Grade '||grade as text)as grade,'Grade Performance' as subject_name,
school_id,school_management_type,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,count(distinct school_id) as total_schools
from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range 
where date_range='last7days') and  school_management_type is not null group by academic_year,grade,school_management_type,
school_id order by 3,grade)as a
join stud_count_school_grade_mgmt_last7 as sa 
on a.school_id=sa.school_id and a.grade=sa.grade and a.school_management_type=sa.school_management_type
join school_grade_enrolment_school_mgmt_last7 tot_stud
on a.school_id=tot_stud.school_id and a.grade=tot_stud.grade and a.school_management_type=tot_stud.school_management_type))as a
group by school_id,grade,academic_year,school_management_type
order by 1,grade)as b on a.academic_year=b.academic_year and a.school_id=b.school_id and a.school_management_type=b.school_management_type
left join
stud_count_school_grade_mgmt_last7 as c
on b.school_id=c.school_id and b.grade=c.grade and b.school_management_type=c.school_management_type
left join
school_grade_enrolment_school_mgmt_last7 tot_stud
on b.school_id=tot_stud.school_id and b.grade=tot_stud.grade and b.school_management_type=tot_stud.school_management_type) WITH NO DATA;

/* PAT indexes */

create index  IF NOT EXISTS school_grade_enrolment_district_district_id_idx ON school_grade_enrolment_district (district_id);
create index IF NOT EXISTS school_grade_enrolment_district_grade_idx on school_grade_enrolment_district(grade);

create index IF NOT EXISTS school_grade_enrolment_block_block_id_idx on school_grade_enrolment_block(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_grade_idx on school_grade_enrolment_block(grade);

create index IF NOT EXISTS school_grade_enrolment_cluster_cluster_id_idx on school_grade_enrolment_cluster(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_grade_idx on school_grade_enrolment_cluster(grade);

create index IF NOT EXISTS school_grade_enrolment_school_school_id_idx on school_grade_enrolment_school (school_id);
create index IF NOT EXISTS school_grade_enrolment_school_grade_idx on school_grade_enrolment_school (grade);

create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_block_id_idx on stud_count_school_grade_mgmt_year_month(block_id);
create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_grade_idx on stud_count_school_grade_mgmt_year_month(grade);
create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_academic_year_idx on stud_count_school_grade_mgmt_year_month(academic_year);
create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_month_idx on stud_count_school_grade_mgmt_year_month(month);
create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_school_management_type_idx on stud_count_school_grade_mgmt_year_month(school_management_type);
create index IF NOT EXISTS stud_count_school_grade_mgmt_year_month_school_id_idx on stud_count_school_grade_mgmt_year_month(school_id);


create index IF NOT EXISTS school_grade_enrolment_district_mgmt_district_id_idx on school_grade_enrolment_district_mgmt (district_id);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_grade_idx on school_grade_enrolment_district_mgmt (grade);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_school_management_type_idx on school_grade_enrolment_district_mgmt (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_block_mgmt_block_id_idx on school_grade_enrolment_block_mgmt(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_grade_idx on school_grade_enrolment_block_mgmt(grade);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_school_management_type_idx on school_grade_enrolment_block_mgmt (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_cluster_id_idx on school_grade_enrolment_cluster_mgmt(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_grade_idx on school_grade_enrolment_cluster_mgmt(grade);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_school_management_type_idx on school_grade_enrolment_cluster_mgmt (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_school_mgmt_school_id_idx on school_grade_enrolment_school_mgmt(school_id);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_grade_idx on school_grade_enrolment_school_mgmt(grade);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_school_management_type_idx on school_grade_enrolment_school_mgmt (school_management_type);


create index IF NOT EXISTS school_grade_enrolment_school_last7_school_id_idx on school_grade_enrolment_school_last7(school_id);
create index IF NOT EXISTS school_grade_enrolment_school_last7_grade_idx on school_grade_enrolment_school_last7(grade);

create index IF NOT EXISTS school_grade_enrolment_cluster_last7_cluster_id_idx on school_grade_enrolment_cluster_last7(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_last7_grade_idx on school_grade_enrolment_cluster_last7(grade);

create index IF NOT EXISTS school_grade_enrolment_block_last7_block_id_idx on school_grade_enrolment_block_last7(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_last7_grade_idx on school_grade_enrolment_block_last7(grade);

create index IF NOT EXISTS school_grade_enrolment_district_last7_district_id_idx on school_grade_enrolment_district_last7(district_id);
create index IF NOT EXISTS school_grade_enrolment_district_last7_grade_idx on school_grade_enrolment_district_last7(grade);

create index IF NOT EXISTS school_grade_enrolment_school_last30_school_id_idx on school_grade_enrolment_school_last30(school_id);
create index IF NOT EXISTS school_grade_enrolment_school_last30_grade_idx on school_grade_enrolment_school_last30(grade);

create index IF NOT EXISTS school_grade_enrolment_cluster_last30_cluster_id_idx on school_grade_enrolment_cluster_last30(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_last30_grade_idx on school_grade_enrolment_cluster_last30(grade);

create index IF NOT EXISTS school_grade_enrolment_block_last30_block_id_idx on school_grade_enrolment_block_last30(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_last30_grade_idx on school_grade_enrolment_block_last30(grade);

create index IF NOT EXISTS school_grade_enrolment_district_last30_district_id_idx on school_grade_enrolment_district_last30(district_id);
create index IF NOT EXISTS school_grade_enrolment_district_last30_grade_idx on school_grade_enrolment_district_last30(grade);

create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last30_school_id_idx on school_grade_enrolment_school_mgmt_last30(school_id);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last30_grade_idx  on school_grade_enrolment_school_mgmt_last30(grade);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last30_school_management_type_idx  on school_grade_enrolment_school_mgmt_last30 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last30_cluster_id_idx  on school_grade_enrolment_cluster_mgmt_last30(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last30_grade_idx on school_grade_enrolment_cluster_mgmt_last30(grade);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last30_school_management_type_idx on school_grade_enrolment_cluster_mgmt_last30 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last30_block_id_idx  on school_grade_enrolment_block_mgmt_last30(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last30_grade_idx on school_grade_enrolment_block_mgmt_last30(grade);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last30_school_management_type_idx on school_grade_enrolment_block_mgmt_last30 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last30_district_id_idx on school_grade_enrolment_district_mgmt_last30(district_id);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last30_grade_idx on school_grade_enrolment_district_mgmt_last30(grade);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last30_school_management_type_idx on school_grade_enrolment_district_mgmt_last30 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last7_school_id_idx on school_grade_enrolment_school_mgmt_last7(school_id);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last7_grade_idx  on school_grade_enrolment_school_mgmt_last7(grade);
create index IF NOT EXISTS school_grade_enrolment_school_mgmt_last7_school_management_type_idx  on school_grade_enrolment_school_mgmt_last7 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last7_cluster_id_idx  on school_grade_enrolment_cluster_mgmt_last7(cluster_id);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last7_grade_idx on school_grade_enrolment_cluster_mgmt_last7(grade);
create index IF NOT EXISTS school_grade_enrolment_cluster_mgmt_last7_school_management_type_idx on school_grade_enrolment_cluster_mgmt_last7 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last7_block_id_idx  on school_grade_enrolment_block_mgmt_last7(block_id);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last7_grade_idx on school_grade_enrolment_block_mgmt_last7(grade);
create index IF NOT EXISTS school_grade_enrolment_block_mgmt_last7_school_management_type_idx on school_grade_enrolment_block_mgmt_last7 (school_management_type);

create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last7_district_id_idx on school_grade_enrolment_district_mgmt_last7(district_id);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last7_grade_idx on school_grade_enrolment_district_mgmt_last7(grade);
create index IF NOT EXISTS school_grade_enrolment_district_mgmt_last7_school_management_type_idx on school_grade_enrolment_district_mgmt_last7 (school_management_type);

create materialized view if not exists periodic_exam_school_ind_result as
select academic_year,exam_code,exam_date,school_id,grade,school_name,district_id,district_name,block_id,block_name,cluster_id,cluster_name,subject,indicator,
sum(obtained_marks)::numeric as obtained_marks,sum(total_marks)::numeric as total_marks,max(students_attended) as students_attended,max(total_students) as total_students,
school_management_type,school_category
from periodic_exam_school_qst_result where students_attended > 0
group by academic_year,exam_code,exam_date,school_id,grade,school_name,district_id,district_name,block_id,block_name,cluster_id,cluster_name,subject,indicator,school_management_type,school_category
with no data;

/* pat queries */
/*periodic exam school last 30 days */

create or replace view hc_periodic_exam_school_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,school_id)as a
group by school_id)as b
on a.school_id=b.school_id)as c
left join 
(
select school_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select school_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,subject,
school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
school_id order by grade desc,subject_name)) as a
group by school_id,grade)as d
group by school_id
)as d on c.school_id=d.school_id)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id)as b
 on d.school_id=b.school_id;


/* HC periodic exam school overall*/

create or replace view hc_periodic_exam_school_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,school_id)as a
group by school_id)as b
on a.school_id=b.school_id)as c
left join 
(
select school_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select school_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,subject,
school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,
school_id order by grade desc,subject_name)) as a
group by school_id,grade)as d
group by school_id
)as d on c.school_id=d.school_id)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id )as b
 on d.school_id=b.school_id;

/* hc periodic cluster last 30 days */

create or replace view hc_periodic_exam_cluster_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
cluster_id)as a
group by cluster_id)as b
on a.cluster_id=b.cluster_id)as c
left join 
(
select cluster_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select cluster_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,subject,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
cluster_id order by grade desc,subject_name)) as a
group by cluster_id,grade)as d
group by cluster_id
)as d on c.cluster_id=d.cluster_id)as d
left join 
 (select c.cluster_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id )as b
 on d.cluster_id=b.cluster_id;

/*hc periodic exam cluster overall*/

create or replace view hc_periodic_exam_cluster_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,
cluster_id)as a
group by cluster_id)as b
on a.cluster_id=b.cluster_id)as c
left join 
(
select cluster_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select cluster_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,subject,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,
cluster_id order by grade desc,subject_name)) as a
group by cluster_id,grade)as d
group by cluster_id
)as d on c.cluster_id=d.cluster_id)as d
left join 
 (select c.cluster_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id )as b
 on  d.cluster_id=b.cluster_id;


/*hc periodic exam block last 30 days*/

create or replace view hc_periodic_exam_block_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
block_id)as a
group by block_id)as b
on a.block_id=b.block_id)as c
left join 
(
select block_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select block_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,subject,
block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
block_id order by grade desc,subject_name)) as a
group by block_id,grade)as d
group by block_id
)as d on c.block_id=d.block_id)as d
left join 
 (select c.block_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id )as b
 on d.block_id=b.block_id;


/*hc periodic exam block overall*/

create or replace view hc_periodic_exam_block_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,
block_id)as a
group by block_id)as b
on a.block_id=b.block_id)as c
left join 
(
select block_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select block_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,subject,
block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by grade,
block_id order by grade desc,subject_name)) as a
group by block_id,grade)as d
group by block_id
)as d on c.block_id=d.block_id)as d
left join 
 (select c.block_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id )as b
 on  d.block_id=b.block_id;


/* hc periodic exam district overall */

create or replace view hc_periodic_exam_district_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')  from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from periodic_exam_school_result group by grade,
district_id)as a
group by district_id)as b
on  a.district_id=b.district_id)as c
left join 
(
select district_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select district_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from

((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from periodic_exam_school_result group by grade,subject,
district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from periodic_exam_school_result group by grade,
district_id order by grade desc,subject_name))as b

group by district_id,grade)as d
group by district_id
)as d on c.district_id=d.district_id)as d
left join 
 (select c.district_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id )as b
 on d.district_id=b.district_id; 

/* periodic exam district last 30 days*/

create or replace view hc_periodic_exam_district_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
district_id)as a
group by district_id)as b
on a.district_id=b.district_id)as c
left join 
(
select district_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select district_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,subject,
district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by grade,
district_id order by grade desc,subject_name))as b
group by district_id,grade)as d
group by district_id
)as d on c.district_id=d.district_id)as d
left join 
 (select c.district_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id )as b
 on d.district_id=b.district_id;

/*Health card state views */

create or replace view hc_pat_state_overall as
 select (select round(avg(percentage),1) as school_performance
                   from ( select ('grade '::text || periodic_exam_school_result.grade) as grade,
                            round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (0)::numeric)), 1) as percentage
                           from periodic_exam_school_result
                          group by periodic_exam_school_result.grade)a),
        (select json_object_agg(a_1.grade, a_1.percentage) as grade_wise_performance
                   from ( select ('grade '::text || periodic_exam_school_result.grade) as grade,
                            round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (0)::numeric)), 1) as percentage
                           from periodic_exam_school_result
                          group by periodic_exam_school_result.grade) a_1),
        (select sum(students_count) as students_count from (select a.school_id,b.assessment_year as academic_year,
	count(distinct(student_uid)) as students_count from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id where b.assessment_year is not null 
group by a.school_id,b.assessment_year)as a ),
        (select sum(total_schools) as total_schools from (select a.school_id,b.assessment_year as academic_year,
	count(distinct(a.school_id)) as total_schools from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id  where b.assessment_year is not null 
group by a.school_id,b.assessment_year)as a );


create or replace view hc_pat_state_last30 as
 select (select round(avg(percentage),1) as school_performance
                   from ( select ('grade '::text || periodic_exam_school_result.grade) as grade,
                            round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (1)::numeric)), 1) as percentage
                           from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                          group by periodic_exam_school_result.grade) a_1),
        (select json_object_agg(a_1.grade, a_1.percentage) as grade_wise_performance
                   from ( select ('grade '::text || periodic_exam_school_result.grade) as grade,
                            round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (1)::numeric)), 1) as percentage
                           from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                          group by periodic_exam_school_result.grade) a_1),
        (select sum(students_count) as students_count from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')),
        (select count(distinct school_id) as total_schools from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days'));


/* pat queries */
/*periodic exam school last 30 days */

create or replace view hc_periodic_exam_school_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
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
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,subject,school_management_type,
school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
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
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id,school_management_type)as b
 on d.school_id=b.school_id and d.school_management_type=b.school_management_type;


/* HC periodic exam school overall*/

create or replace view hc_periodic_exam_school_mgmt_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.school_performance,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where  school_management_type is not null
 group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as school_performance,
school_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where  school_management_type is not null
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
from periodic_exam_school_result where  school_management_type is not null 
group by grade,subject,school_management_type,school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where  school_management_type is not null group by grade,school_management_type,
school_id order by grade desc,subject_name)) as a
group by school_id,grade,school_management_type)as d
group by school_id,school_management_type
)as d on c.school_id=d.school_id and c.school_management_type=d.school_management_type)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result where  school_management_type is not null)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id ,school_management_type)as b
 on d.school_id=b.school_id and d.school_management_type=b.school_management_type;
 
/* hc periodic cluster last 30 days */

create or replace view hc_periodic_exam_cluster_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and  school_management_type is not null
group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,cluster_id,school_management_type)as a
group by cluster_id,school_management_type)as b
on a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type)as c
left join 
(
select cluster_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select cluster_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,
cluster_id order by grade desc,subject_name)) as a
group by cluster_id,grade,school_management_type)as d
group by cluster_id,school_management_type
)as d on c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.cluster_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id ,school_management_type)as b
 on d.cluster_id=b.cluster_id and d.school_management_type=b.school_management_type;

/*hc periodic exam cluster overall*/

create or replace view hc_periodic_exam_cluster_mgmt_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.cluster_performance,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as cluster_performance,
cluster_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,
cluster_id,school_management_type)as a
group by cluster_id,school_management_type)as b
on a.cluster_id=b.cluster_id and a.school_management_type=b.school_management_type)as c
left join 
(
select cluster_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select cluster_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,subject,school_management_type,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,school_management_type,
cluster_id order by grade desc,subject_name)) as a
group by cluster_id,grade,school_management_type)as d
group by cluster_id,school_management_type
)as d on c.cluster_id=d.cluster_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.cluster_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id ,school_management_type)as b
 on  d.cluster_id=b.cluster_id and d.school_management_type=b.school_management_type;


/*hc periodic exam block last 30 days*/

create or replace view hc_periodic_exam_block_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,block_id)as a
group by block_id,school_management_type)as b
on a.block_id=b.block_id and a.school_management_type=b.school_management_type)as c
left join 
(
select block_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select block_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,subject,school_management_type,block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,
block_id order by grade desc,subject_name)) as a
group by block_id,grade,school_management_type)as d
group by block_id,school_management_type)as d on c.block_id=d.block_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.block_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id,school_management_type )as b
 on d.block_id=b.block_id and d.school_management_type=b.school_management_type;


/*hc periodic exam block overall*/

create or replace view hc_periodic_exam_block_mgmt_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.block_performance,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as block_performance,
block_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,
block_id,school_management_type)as a
group by block_id,school_management_type)as b
on a.block_id=b.block_id and a.school_management_type=b.school_management_type)as c
left join 
(
select block_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select block_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,subject,school_management_type,
block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,school_management_type,
block_id order by grade desc,subject_name)) as a
group by block_id,grade,school_management_type)as d
group by block_id,school_management_type
)as d on c.block_id=d.block_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.block_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id ,school_management_type)as b
 on  d.block_id=b.block_id and d.school_management_type=b.school_management_type;


/* hc periodic exam district overall */

create or replace view hc_periodic_exam_district_mgmt_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
(select to_char(min(exam_date),'DD-MM-YYYY')  from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,school_management_type,
district_id)as a
group by district_id,school_management_type)as b
on  a.district_id=b.district_id and a.school_management_type=b.school_management_type)as c
left join 
(
select district_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select district_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from

((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,subject,school_management_type,
district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result where school_management_type is not null group by grade,school_management_type,
district_id order by grade desc,subject_name))as b
group by district_id,grade,school_management_type)as d
group by district_id,school_management_type
)as d on c.district_id=d.district_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.district_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_code,school_id,student_uid
from periodic_exam_stud_grade_count where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id,school_management_type )as b
 on d.district_id=b.district_id and d.school_management_type=b.school_management_type;

/* periodic exam district last 30 days*/

create or replace view hc_periodic_exam_district_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.district_performance,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by 
district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,round(avg(percentage),1) as district_performance,
district_id,school_management_type from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,district_id)as a
group by district_id,school_management_type)as b
on a.district_id=b.district_id and a.school_management_type=b.school_management_type)as c
left join 
(
select district_id,jsonb_agg(subject_wise_performance)as subject_wise_performance,school_management_type from
(select district_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance,school_management_type from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,subject,school_management_type,district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage,school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by grade,school_management_type,
district_id order by grade desc,subject_name))as b
group by district_id,grade,school_management_type)as d
group by district_id,school_management_type
)as d on c.district_id=d.district_id and c.school_management_type=d.school_management_type)as d
left join 
 (select c.district_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools,school_management_type
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result where school_management_type is not null)
and exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id,school_management_type )as b
 on d.district_id=b.district_id and d.school_management_type=b.school_management_type;
 
/* PAT MGMT overall */
create or replace view hc_pat_state_mgmt_overall as 
select smt.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance,round(avg(percentage),1) as school_performance
        FROM (
                SELECT (
                        'grade '::text || periodic_exam_school_result.grade
                    ) AS grade,
                    round(
                        (
                            (
                                COALESCE(
                                    sum(periodic_exam_school_result.obtained_marks),
                                    (0)::numeric
                                ) * 100.0
                            ) / COALESCE(
                                sum(periodic_exam_school_result.total_marks),
                                (0)::numeric
                            )
                        ),
                        1
                    ) AS percentage,
                    school_management_type
                FROM periodic_exam_school_result where school_management_type is not null 
                GROUP BY grade,school_management_type
            ) a_1 where school_management_type is not null group by school_management_type) smt
     LEFT JOIN ( SELECT 
            count(DISTINCT a.student_uid) AS students_count,
            count(DISTINCT a.school_id) AS total_schools,
            c.school_management_type
           FROM ( SELECT exam_id,school_id,student_uid
                   FROM periodic_exam_result_trans
                  WHERE (school_id IN ( SELECT school_id
                           FROM periodic_exam_school_result
                          WHERE school_management_type IS NOT NULL))
                  GROUP BY exam_id, school_id, student_uid) a
             LEFT JOIN ( SELECT exam_id,
                    date_part('year'::text, exam_date)::text AS assessment_year
                   FROM periodic_exam_mst) b_1 ON a.exam_id = b_1.exam_id
             LEFT JOIN school_hierarchy_details c ON a.school_id = c.school_id where c.school_management_type is not null
          GROUP BY c.school_management_type) b ON smt.school_management_type::text = b.school_management_type::text ;


/* PAT MGMT last 30 days */
create or replace view hc_pat_state_mgmt_last30 as 
select smt.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance,round(avg(percentage),1) as school_performance
        FROM (
                SELECT (
                        'grade '::text || periodic_exam_school_result.grade
                    ) AS grade,
                    round(
                        (
                            (
                                COALESCE(
                                    sum(periodic_exam_school_result.obtained_marks),
                                    (0)::numeric
                                ) * 100.0
                            ) / COALESCE(
                                sum(periodic_exam_school_result.total_marks),
                                (0)::numeric
                            )
                        ),
                        1
                    ) AS percentage,
                    school_management_type
                FROM periodic_exam_school_result where school_management_type is not null AND (exam_code::text IN ( SELECT pat_date_range.exam_code
                           FROM pat_date_range
                          WHERE pat_date_range.date_range = 'last30days'::text))
                GROUP BY grade,school_management_type
            ) a_1 group by school_management_type) smt
     LEFT JOIN ( SELECT 
            count(DISTINCT a.student_uid) AS students_count,
            count(DISTINCT a.school_id) AS total_schools,
            c.school_management_type
           FROM ( SELECT exam_id,school_id,student_uid
                   FROM periodic_exam_result_trans
                  WHERE (school_id IN ( SELECT school_id
                           FROM periodic_exam_school_result
                          WHERE school_management_type IS NOT NULL)) AND (exam_code::text IN ( SELECT pat_date_range.exam_code
                           FROM pat_date_range
                          WHERE pat_date_range.date_range = 'last30days'::text))
                  GROUP BY exam_id, school_id, student_uid) a
             LEFT JOIN ( SELECT exam_id,
                    date_part('year'::text, exam_date)::text AS assessment_year
                   FROM periodic_exam_mst) b_1 ON a.exam_id = b_1.exam_id
             LEFT JOIN school_hierarchy_details c ON a.school_id = c.school_id where c.school_management_type is not null
          GROUP BY c.school_management_type) b ON smt.school_management_type::text = b.school_management_type::text;
