/* implementation of delete data */

CREATE OR REPLACE FUNCTION del_data(p_data_source text,p_year int default null,VARIADIC p_month int[] default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_month int;
t_name text;
BEGIN

IF p_data_source='student_attendance' or p_data_source='teacher_attendance' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
  foreach v_month in array p_month loop
    execute 'delete from '||t_name||' where year='||p_year||' and  month='||v_month;
  end loop;
END LOOP;
END IF;

IF p_data_source='crc' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
  foreach v_month in array p_month loop
    IF t_name='crc_inspection_trans' THEN
    execute 'delete from '||t_name||' where visit_date is not null and extract(month from visit_date)='||v_month||' and extract(year from visit_date)='||p_year;
    ELSE
    execute 'delete from '||t_name||' where month='||v_month||' and year='||p_year;
    END IF;
  end loop;
END LOOP;
END IF;

return 0;
END;
$$  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pat_del_data(p_data_source text,VARIADIC p_exam_code text[] default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_exam_code text;
v_batch_id text;
t_name text;
BEGIN
IF p_data_source='periodic_assessment_test' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
  foreach v_exam_code in array p_exam_code loop
    IF t_name='periodic_exam_qst_mst' THEN
    execute 'delete from '||t_name||' where exam_id in (select distinct exam_id from periodic_exam_mst where exam_code  = '''||v_exam_code||''')';
    ELSE
    execute 'delete from '||t_name||' where exam_code = '''||v_exam_code||'''';
    END IF;
  end loop;
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION diksha_tpd_del_data(p_data_source text,VARIADIC p_batch_id text[] default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_batch_id text;
t_name text;
BEGIN
IF p_data_source='diksha_tpd' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
  foreach v_batch_id in array p_batch_id loop
    IF t_name='diksha_tpd_agg' THEN
    execute 'delete from '||t_name||' where collection_id in (select distinct collection_id from diksha_tpd_trans where batch_id  = '''||v_batch_id||''')';
    ELSE
    execute 'delete from '||t_name||' where batch_id = '''||v_batch_id||'''';
    END IF;
  end loop;
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION diksha_summary_rollup_del_data(p_data_source text,p_from_date date default null,p_to_date date default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_exam_code text;
v_batch_id text;
t_name text;
BEGIN

IF p_data_source='diksha_summary_rollup' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
execute 'delete from '||t_name||' where content_view_date >='''||p_from_date||'''::date and content_view_date<='''||p_to_date||'''::date';
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION all_del_data(p_data_source text)
RETURNS text AS
$$
DECLARE
error_msg text;
v_exam_code text;
v_batch_id text;
t_name text;
BEGIN
IF p_data_source='infrastructure' or p_data_source='static' or p_data_source='udise' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
execute 'delete from '||t_name;
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION semester_del_data(p_data_source text,p_academic_year text,VARIADIC p_semester int[] default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_semester text;
t_name text;
BEGIN
IF p_data_source='semester_assessment_test' THEN
FOR t_name in select table_name
from del_data_source_details
where data_source = p_data_source order by order_of_execution 
LOOP
  foreach v_semester in array p_semester loop
    IF t_name='semester_exam_qst_mst' THEN
    execute 'delete from '||t_name||' where exam_id in (select distinct exam_id from semester_exam_mst where assessment_year= '''||p_academic_year||''' and semester= '||v_semester||')';
    ELSE IF t_name='semester_exam_result_staging_2' or t_name='semester_exam_school_qst_result' or t_name='semester_exam_result_temp' or t_name='semester_exam_school_result' or t_name='semester_exam_result_staging_1' or t_name='semester_exam_result_trans' THEN
    execute 'delete from '||t_name||' where exam_code in (select distinct exam_code from semester_exam_mst where assessment_year= '''||p_academic_year||''' and semester= '||v_semester||')';
    ELSE IF t_name='semester_exam_stud_grade_count' THEN execute 'delete from '||t_name||' where exam_code in (select distinct exam_code from semester_exam_mst where assessment_year= '''||p_academic_year||''' and semester= '||v_semester||')';
	ELSE 
    execute 'delete from '||t_name||'  where  assessment_year= '''||p_academic_year||''' and semester= '||v_semester;
	END IF;
    END IF;
    END IF;
  end loop;
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

/* Data Retention */
insert into data_replay_meta(filename,ff_uuid,retention_period) values('test','test',90) on conflict on constraint data_replay_meta_pkey do nothing;

CREATE OR REPLACE FUNCTION pat_del_data_ret(p_data_source text)
RETURNS text AS
$$
DECLARE
error_msg text;
v_exam_code text;
BEGIN
IF p_data_source='periodic_assessment_test' THEN
FOR v_exam_code in select exam_code from periodic_exam_mst where 
to_date(substr(exam_code,8,14),'ddmmyyyy')<(now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval)::date
except
select exam_code from periodic_exam_mst 
where exam_code in 
(select unnest(string_to_array(regexp_replace(exam_code,'[^a-zA-Z0-9,]','','g'),',')) as exam_code 
from data_replay_meta where created_on>now()-'5days'::interval 
and cqube_process_status='SUCCESS' and data_source='periodic_assessment_test') 
LOOP
    execute 'delete from periodic_exam_result_trans where exam_code = '''||v_exam_code||'''';
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION semester_del_data_ret(p_data_source text)
RETURNS text AS
$$
DECLARE
error_msg text;
v_exam_code text;
BEGIN
IF p_data_source='semester_assessment_test' THEN
FOR v_exam_code in select exam_code from semester_exam_mst sem where 
to_date(substr(sem.exam_code,8,14),'ddmmyyyy')<(now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval)::date
except
select distinct exam_code from semester_exam_mst sem 
join (select distinct unnest(string_to_array(regexp_replace(semesters,'[^0-9,]','','g'),',')) as semesters,
academic_year from data_replay_meta where created_on>now()-'5days'::interval 
and cqube_process_status='SUCCESS' and data_source=p_data_source) dsem 
on sem.semester=dsem.semesters::int and sem.assessment_year=dsem.academic_year
LOOP
    execute 'delete from semester_exam_result_trans where exam_code = '''||v_exam_code||'''';
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION diksha_summary_rollup_del_data_ret(p_data_source text)
RETURNS text AS
$$
DECLARE
error_msg text;
v_date date;
BEGIN
IF p_data_source='diksha_summary_rollup' THEN
FOR v_date in select distinct content_view_date from diksha_content_trans 
    where content_view_date < (now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') 
    from data_replay_meta)::interval)::date
LOOP
execute 'delete from diksha_content_trans where content_view_date ='''||v_date||'''::date';
END LOOP;
END IF;
return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION del_data_ret(p_data_source text,p_year int default null,VARIADIC p_month int[] default null)
RETURNS text AS
$$
DECLARE
error_msg text;
v_month int;
t_name text;
v_my record;
BEGIN

IF p_data_source='student_attendance' THEN
FOR v_my in (select distinct month,year from student_attendance_trans where to_date(year||'-'||month||'-01','yyyy-mm-dd')<(select (date_trunc('month',now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval))::date) order by 1,2 desc) except (select distinct unnest(string_to_array(regexp_replace(months,'[^a-zA-Z0-9,]','','g'),','))::int as month,year from data_replay_meta where data_source='student_attendance' and created_on >now()-'5days'::interval)
LOOP
     execute 'delete from student_attendance_trans where year='||v_my.year||' and  month='||v_my.month;
END LOOP;
END IF;

IF p_data_source='teacher_attendance' THEN
FOR v_my in (select distinct month,year from teacher_attendance_trans where to_date(year||'-'||month||'-01','yyyy-mm-dd')<(select (date_trunc('month',now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval))::date) order by 1,2 desc) except (select distinct unnest(string_to_array(regexp_replace(months,'[^a-zA-Z0-9,]','','g'),','))::int as month,year from data_replay_meta where data_source='teacher_attendance' and created_on >now()-'5days'::interval)
LOOP
     execute 'delete from teacher_attendance_trans where year='||v_my.year||' and  month='||v_my.month;
END LOOP;
END IF;

IF p_data_source='crc' THEN
FOR v_my in (select distinct month,year from crc_location_trans where to_date(year||'-'||month||'-01','yyyy-mm-dd')<(select (date_trunc('month',now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval))::date) order by 1,2 desc) except (select distinct unnest(string_to_array(regexp_replace(months,'[^a-zA-Z0-9,]','','g'),','))::int as month,year from data_replay_meta where data_source='crc' and created_on >now()-'5days'::interval)
LOOP
    execute 'delete from crc_location_trans where month='||v_my.month||' and year='||v_my.year;
END LOOP;
FOR v_my in (select distinct extract(month from visit_date) as month,extract(year from visit_date) as year from crc_inspection_trans where visit_date is not null and to_date(extract(year from visit_date)||'-'||extract(month from visit_date)||'-01','yyyy-mm-dd')<(select (date_trunc('month',now() -(select concat(trim(coalesce(max(retention_period),90)::text),'days') from data_replay_meta)::interval))::date) order by 1,2 desc) except (select distinct unnest(string_to_array(regexp_replace(months,'[^a-zA-Z0-9,]','','g'),','))::int as month,year from data_replay_meta where data_source='crc' and created_on >now()-'5days'::interval)
LOOP
    execute 'delete from crc_inspection_trans where extract(month from visit_date)='||v_my.month||' and extract(year from visit_date)='||v_my.year;
END LOOP;
END IF;

return 0;
END;
$$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION academic_year(date_check date) returns varchar(10) as $$
declare data varchar;
begin
select case when cast(to_char(date_check, 'MM')as int) in (6,7,8,9,10,11,12) then (cast(to_char(date_check,'YYYY') as int) ||'-'||substring(cast((cast(to_char(date_check,'YYYY') as int)+1) as text),3,2)) else ((cast(to_char(date_check,'YYYY') as int)-1) ||'-'||substring(cast(to_char(date_check,'YYYY') as text),3,2)) end into data;

return data;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION academic_year_by_month_year(month int,year int) returns varchar(10) as $$
declare data varchar;
begin
select case when month in (6,7,8,9,10,11,12) then cast(year as text) ||'-'||substring(cast(year+1 as text),3,2) else cast(year-1 as text) ||'-'|| substring(cast(year as text),3,2) end into data;

return data;
END; $$
LANGUAGE PLPGSQL;

