/* subject_master */

create table if not exists subject_master
(
subject_id  bigint primary key not null,
subject_name  double precision,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone 
-- ,foreign key (school_id) references school_master(school_id)
);


/*school_student_subject_total_marks*/

create table if not exists school_student_subject_total_marks
(
id  serial,
year  int,
semester  smallint,
school_id  bigint,
grade int,
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
subject_3_marks_scored  int,
subject_3_total_marks  int,
subject_1_marks_scored int,  
subject_1_total_marks  int,
subject_2_marks_scored  int,
subject_2_total_marks  int,
subject_7_marks_scored  int,
subject_7_total_marks  int,
subject_6_marks_scored  int,
subject_6_total_marks  int,
subject_4_marks_scored  int,
subject_4_total_marks  int,
subject_5_marks_scored  int,
subject_5_total_marks  int,
subject_8_marks_scored  int,
subject_8_total_marks  int,
students_count bigint,
created_on  TIMESTAMP without time zone ,
updated_on  TIMESTAMP without time zone,
primary key(school_id,semester,grade)
);

create index if not exists school_student_total_marks_id on school_student_subject_total_marks(semester,school_id,block_id,cluster_id);


/* Semester validation tables */

create table if not exists sat_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_exam_id int,
count_null_question_id int,
count_null_assessment_year int,
count_null_medium int,
count_null_standard int,
count_null_subject_id int,
count_null_subject_name int,
count_null_exam_type_id int,
count_null_exam_type int,
count_null_exam_code int,
count_null_exam_date int,
count_null_total_questions int,
count_null_total_marks int,
count_null_question_title int,
count_null_question int,
count_null_question_marks int,
count_null_id int,
count_null_student_uid int,
count_null_school_id int,
count_null_studying_class int,
count_null_obtained_marks int,
count_null_grade int
);

create table if not exists semester_exam_mst_dup(
exam_id	int,
assessment_year	varchar(20),
medium	varchar(20),
standard	int,
division	varchar(20),
subject_id	int,
subject_name	varchar(50),
exam_type_id	int,
exam_type	varchar(50),
exam_code	varchar(100),
exam_date	date,
total_questions	int,
total_marks	int,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

create table if not exists semester_exam_qst_mst_dup(
question_id	int,
exam_id	int,
indicator_id	int,
indicator_title	varchar(20),
indicator	text,
question_title	varchar(20),
question	text,
question_marks	numeric,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

create table if not exists semester_exam_result_dup(
id	int,
exam_id	int,
exam_code	varchar(100),
student_id	bigint,
student_uid	bigint,
school_id	bigint,
studying_class	int,
section	varchar(20),
question_id	int,
obtained_marks	numeric,
num_of_times int,
ff_uuid varchar(255),
created_on_file_process  TIMESTAMP without time zone default current_timestamp
);

/*SAT data tables*/

create table if not exists semester_exam_mst(
exam_id  int,
assessment_year  varchar(20),
medium  varchar(20),
standard  int,
division  varchar(20),
subject_id  int,
subject_name  varchar(50),
exam_type_id  int,
exam_type  varchar(50),
exam_code  varchar(100),
exam_date  date,
total_questions  int,
total_marks  numeric,
created_on  timestamp,
updated_on  timestamp,
primary key(exam_id,assessment_year)
);

create table if not exists semester_exam_qst_mst(
question_id  int primary key not null,
exam_id  int,
indicator_id  int,
indicator_title varchar(20),
indicator  text,
question_title  varchar(20),
question  text,
question_marks  numeric,
created_on  timestamp,
updated_on  timestamp
);

create table if not exists semester_exam_result_temp(
id  int primary key not null,
ffuid text,
exam_id  int,
exam_code  varchar(100),
student_id  bigint,
student_uid  bigint,
school_id  bigint,
studying_class  int,
section  varchar(20),
question_id  int,
obtained_marks  numeric,
created_on  timestamp,
updated_on  timestamp
);

create table if not exists semester_exam_result_staging_1(
id  int,
ff_uuid text,
exam_id  int,
exam_code  varchar(100),
student_id  bigint,
student_uid  bigint,
school_id  bigint,
studying_class  int,
section  varchar(20),
question_id  int,
obtained_marks  numeric,
created_on  timestamp,
updated_on  timestamp
);

create table if not exists semester_exam_result_staging_2(
id  int,
ff_uuid text,
exam_id  int,
exam_code  varchar(100),
student_id  bigint,
student_uid  bigint,
school_id  bigint,
studying_class  int,
section  varchar(20),
question_id  int,
obtained_marks  numeric,
created_on  timestamp,
updated_on  timestamp
);

create table if not exists semester_exam_result_trans(
id  int,
exam_id  int,
exam_code  varchar(100),
student_id  bigint,
student_uid  bigint,
school_id  bigint,
studying_class  int,
section  varchar(20),
question_id  int,
obtained_marks  numeric,
created_on  timestamp,
updated_on  timestamp,
primary key(exam_code, student_uid, question_id)
);

create table if not exists semester_exam_school_result
(id  serial,
academic_year  varchar(50),
exam_code  varchar(100),
school_id  bigint,
grade  smallint,
school_name  varchar(200),
school_latitude  double precision,
school_longitude  double precision,
district_id  bigint,
district_name  varchar(100),
district_latitude  double precision,
district_longitude  double precision,
block_id  bigint,
block_name  varchar(100),
block_latitude  double precision,
block_longitude  double precision,
cluster_id  bigint,
cluster_name  varchar(100),
cluster_latitude  double precision,
cluster_longitude  double precision,
subject  text,
obtained_marks  numeric,
total_marks  numeric,
students_count   int,
created_on  timestamp,
updated_on  timestamp,
primary key(academic_year,exam_code,school_id)
);

alter table semester_exam_school_result add COLUMN if not exists exam_date date;

alter table semester_exam_school_result add COLUMN if not exists students_attended int;

create table if not exists semester_exam_school_qst_result
(id  serial,
academic_year  varchar(50),
exam_code varchar(100),
exam_date  date,
school_id  bigint,
grade  smallint,
school_name  varchar(200),
district_id  bigint,
district_name  varchar(100),
block_id  bigint,
block_name  varchar(100),
cluster_id  bigint,
cluster_name  varchar(100),
subject  text,
question_id	int,
indicator	text,
obtained_marks  numeric,
total_marks  numeric,
students_attended   int,
total_students int,
created_on  timestamp,
updated_on  timestamp,
primary key(academic_year,exam_code,school_id,question_id)
);



/* SAT adding semester */
alter table semester_exam_mst_dup add column if not exists semester int;

alter table semester_exam_mst add column if not exists semester int;
alter table semester_exam_mst drop constraint if exists semester_exam_mst_pkey;
alter table semester_exam_mst add primary key(exam_id,assessment_year,semester);

alter table semester_exam_school_result add column if not exists semester int;

alter table semester_exam_school_qst_result add column if not exists school_management_type varchar(100);
alter table semester_exam_school_qst_result add column if not exists school_category varchar(100);

alter table semester_exam_school_result add column if not exists school_management_type varchar(100);
alter table semester_exam_school_result add column if not exists school_category varchar(100);

alter table sat_null_col add column  IF NOT EXISTS count_null_semester int;

create table if not exists semester_exam_stud_grade_count(exam_code varchar(100),student_uid bigint,school_id bigint,studying_class bigint,primary key(exam_code,student_uid,school_id));

create or replace function drop_mv()
returns int as
$body$
begin

	drop materialized view  if exists semester_exam_school_ind_result cascade;
  return 0;

    exception 
    when others then
        return 0;

end;
$body$
language plpgsql;

select drop_mv();

create table if not exists semester_exam_school_ind_result
(id  serial,
academic_year  varchar(50),
exam_code varchar(100),
exam_date  date,
school_id  bigint,
grade  smallint,
school_name  varchar(200),
district_id  bigint,
district_name  varchar(100),
block_id  bigint,
block_name  varchar(100),
cluster_id  bigint,
cluster_name  varchar(100),
subject  text,
indicator	text,
obtained_marks  numeric,
total_marks  numeric,
students_attended   int,
total_students int,
school_management_type varchar(100),
school_category varchar(100),
created_on  timestamp,
updated_on  timestamp,
primary key(academic_year,exam_code,school_id,indicator)
);

create table if not exists sat_trans_null_col(
filename varchar(200) ,
ff_uuid varchar(200),
count_null_exam_id int,
count_null_question_id int,
count_null_exam_code int,
count_null_exam_date int,
count_null_id int,
count_null_student_uid int,
count_null_school_id int,
count_null_studying_class int,
count_null_obtained_marks int,
count_of_null_rows int
);

alter table sat_null_col add column if not exists count_of_null_rows int;
