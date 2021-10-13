/* drop views */

create or replace function drop_view_hc()
returns int as
$body$
begin

drop view if exists health_card_index_school_overall cascade;
drop view if exists health_card_index_cluster_overall cascade;
drop view if exists health_card_index_block_overall cascade;
drop view if exists health_card_index_district_overall cascade;
drop view if exists health_card_index_school_mgmt_overall cascade;
drop view if exists health_card_index_cluster_mgmt_overall cascade;
drop view if exists health_card_index_block_mgmt_overall cascade;
drop view if exists health_card_index_district_mgmt_overall cascade;
drop view if exists health_card_index_school_last30 cascade;
drop view if exists health_card_index_cluster_last30 cascade;
drop view if exists health_card_index_block_last30 cascade;
drop view if exists health_card_index_district_last30 cascade;
drop view if exists health_card_index_school_mgmt_last30 cascade;
drop view if exists health_card_index_cluster_mgmt_last30 cascade;
drop view if exists health_card_index_block_mgmt_last30 cascade;
drop view if exists health_card_index_district_mgmt_last30 cascade;
drop view if exists health_card_index_state cascade;
drop view if exists health_card_index_state_last30 cascade;
drop view if exists health_card_index_state_mgmt_last30 cascade;
drop view if exists health_card_index_state_mgmt_overall cascade;

  return 0;



    exception 
    when others then
        return 0;

end;
$body$
language plpgsql;

select drop_view_hc();


drop view if exists hc_udise_state cascade;
drop view if exists hc_udise_state_mgmt cascade;
drop view if exists hc_infra_state cascade;
drop view if exists hc_infra_state_mgmt cascade;

truncate progress_card_config;


/* Insert statements to progress card config  */
/* District */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
 on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name)as basic ',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join (select sad.*,sac.poor,sac.average,sac.good,sac.excellent,((rank () over ( order by attendance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_student_attendance_school_overall)) as district_level_rank_within_the_state,1-round(Rank() over (ORDER BY attendance DESC) 
/ coalesce(((select count(distinct(district_id)) from hc_student_attendance_school_overall)*1.0),1),1) as state_level_score
 from hc_student_attendance_district_overall as sad left join
(select district_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'')
 then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'') and attendance < (select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance < (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall group by district_id)as sac
on sad.district_id= sac.district_id
)as student_attendance on basic.district_id=student_attendance.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,semester,
  ((rank () over (partition by semester order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from semester_exam_district_all)) as district_level_rank_within_the_state, 
1-round( Rank() over (partition by semester ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from semester_exam_district_all)*1.0),1),2) as state_level_score
 from semester_exam_district_all where semester=(select max(semester) from semester_exam_district_all))as ped left join
(select district_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'') and school_performance < (select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance < (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all group by district_id,semester)as pes
on ped.district_id= pes.district_id and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
'left join  (select uds.*,usc.poor,usc.average,usc.good,usc.excellent from udise_district_score as uds left join 
(select district_id,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score <(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score < (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from udise_school_score group by district_id)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
'left join (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,
  ((rank () over ( order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_periodic_exam_district_all)) as district_level_rank_within_the_state,
 coalesce(1-round( Rank() over (ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from hc_periodic_exam_school_all)*1.0),1),2)) as state_level_score
 from hc_periodic_exam_district_all )as ped left join
(select district_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance < (select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance < (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_all group by district_id)as pes
on ped.district_id= pes.district_id)as pat
on basic.district_id=pat.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join hc_crc_district as crc
on basic.district_id=crc.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_district as infra
on basic.district_id=infra.district_id',True,'district','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* block */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from (select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name)as basic ',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
'left join (select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_overall as sad left join
(select block_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall  group by block_id)as sac
on sad.block_id= sac.block_id
) as b
left join(select usc.block_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_overall as sad left join
(select block_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall  group by block_id)as sac
on sad.block_id= sac.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from hc_student_attendance_school_overall)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from hc_student_attendance_school_overall as scl
left join
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_overall.block_id) AS blocks_in_district FROM   hc_student_attendance_school_overall group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by attendance
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id )as student_attendance
on basic.block_id=student_attendance.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join (select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,semester
 from semester_exam_block_all where semester=(select max(semester) from semester_exam_block_all))as ped left join
(select block_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,semester
 from semester_exam_block_all 
)as ped left join
(select block_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from semester_exam_school_all)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from semester_exam_school_all as scl
left join
(SELECT district_id,Count(DISTINCT semester_exam_school_all.block_id) AS blocks_in_district FROM  semester_exam_school_all group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by block_performance,usc.semester
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.semester=c.semester
)as semester on basic.block_id=semester.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
'left join (select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_block as b
left join(select usc.block_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from hc_udise_block as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from udise_school_metrics_agg)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from udise_school_metrics_agg as scl
left join
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.block_id) AS blocks_in_district FROM   udise_school_metrics_agg group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by infrastructure_score
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id)as udise
on basic.block_id=udise.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
'left join (select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_all )as ped left join
(select block_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_all  group by block_id)as pes
on ped.block_id= pes.block_id) as b
left join(select usc.block_id,block_performance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_all 
)as ped left join
(select block_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_all  group by block_id)as pes
on ped.block_id= pes.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from periodic_exam_school_all)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from periodic_exam_school_all as scl
left join
(SELECT district_id,Count(DISTINCT periodic_exam_school_all.block_id) AS blocks_in_district FROM  periodic_exam_school_all group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by block_performance
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id)as pat
on basic.block_id=pat.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join hc_crc_block as crc
on basic.block_id=crc.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_block as infra
on basic.block_id=infra.block_id',True,'block','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* cluster */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name)as basic ',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_overall as sad left join
(select cluster_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall  group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id
) as b
left join(select usc.cluster_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_overall as sad left join
(select cluster_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall  group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id
) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from hc_student_attendance_school_overall)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from hc_student_attendance_school_overall as scl
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_overall.cluster_id) AS clusters_in_block FROM   hc_student_attendance_school_overall group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_overall.cluster_id) AS clusters_in_district FROM   hc_student_attendance_school_overall group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by attendance
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as student_attendance
on basic.cluster_id=student_attendance.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,semester 
 from semester_exam_cluster_all  where semester=(select max(semester) from semester_exam_cluster_all)
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,semester
 from semester_exam_cluster_all 
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from semester_exam_school_all)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from semester_exam_school_all as scl
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_all.cluster_id) AS clusters_in_block FROM   semester_exam_school_all group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_all.cluster_id) AS clusters_in_district FROM   semester_exam_school_all group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by cluster_performance,usc.semester
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.semester=c.semester
)as semester
on basic.cluster_id=semester.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_cluster as b
left join(select usc.cluster_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from hc_udise_cluster as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from udise_school_metrics_agg)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from udise_school_metrics_agg as scl
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_block FROM   udise_school_metrics_agg group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_district FROM   udise_school_metrics_agg group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by infrastructure_score
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as udise
on basic.cluster_id=udise.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_all 
)as ped left join
(select cluster_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_all group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as b
left join(select usc.cluster_id,cluster_performance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_all 
)as ped left join
(select cluster_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_all group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from hc_periodic_exam_school_all)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from hc_periodic_exam_school_all as scl
left join
(SELECT block_id,Count(DISTINCT hc_periodic_exam_school_all.cluster_id) AS clusters_in_block FROM   hc_periodic_exam_school_all group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_all.cluster_id) AS clusters_in_district FROM   hc_periodic_exam_school_all group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by cluster_performance
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as pat
on basic.cluster_id=pat.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join hc_crc_cluster as crc
on basic.cluster_id=crc.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_cluster as infra
on basic.cluster_id=infra.cluster_id',True,'cluster','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* school*/
insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
'  from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as basic ',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_school_overall as sad left join
(select school_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall group by school_id)as sac
on sad.school_id= sac.school_id) as b
left join(select usc.school_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_school_overall as sad left join
(select school_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall  group by school_id)as sac
on sad.school_id= sac.school_id ) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from hc_student_attendance_school_overall)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from hc_student_attendance_school_overall as scl
left join 
(SELECT cluster_id,Count(DISTINCT hc_student_attendance_school_overall.school_id) AS schools_in_cluster FROM   hc_student_attendance_school_overall group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_overall.school_id) AS schools_in_block FROM   hc_student_attendance_school_overall group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_overall.school_id) AS schools_in_district FROM   hc_student_attendance_school_overall group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,attendance
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id)as student_attendance
on basic.school_id=student_attendance.school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
pes.poor,pes.average,pes.good,pes.excellent,ped.grade_wise_performance from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester
 from semester_exam_school_all where semester=(select max(semester) from semester_exam_school_all))as ped left join
(select school_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all 
   group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as b
left join(select usc.school_id,school_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester
from semester_exam_school_all)as ped left join
(select school_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from semester_exam_school_all)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from semester_exam_school_all as scl
left join 
(SELECT cluster_id,Count(DISTINCT semester_exam_school_all.school_id) AS schools_in_cluster FROM semester_exam_school_all group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_all.school_id) AS schools_in_block FROM   semester_exam_school_all group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_all.school_id) AS schools_in_district FROM   semester_exam_school_all group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,school_performance,usc.semester
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id and b.semester=c.semester
)as semester
on basic.school_id=semester.school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from hc_udise_school as b
left join(select usc.udise_school_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from hc_udise_school as usc
left join
(select a.*,(select count(DISTINCT(udise_school_id)) from udise_school_metrics_agg)as total_schools 
from (select udise_school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from udise_school_metrics_agg as scl
left join 
(SELECT cluster_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_cluster FROM   udise_school_metrics_agg group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_block FROM   udise_school_metrics_agg group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_district FROM   udise_school_metrics_agg group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.udise_school_id=a.udise_school_id
group by usc.udise_school_id,infrastructure_score
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.udise_school_id = c.udise_school_id)as udise
on basic.school_id=udise.udise_school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
 from hc_periodic_exam_school_all)as ped left join
(select school_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_all 
   group by school_id)as pes
on ped.school_id= pes.school_id) as b
left join(select usc.school_id,school_performance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
from hc_periodic_exam_school_all)as ped left join
(select school_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_all group by school_id)as pes
on ped.school_id= pes.school_id) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from hc_periodic_exam_school_all)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from hc_periodic_exam_school_all as scl
left join 
(SELECT cluster_id,Count(DISTINCT hc_periodic_exam_school_all.school_id) AS schools_in_cluster FROM hc_periodic_exam_school_all group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT hc_periodic_exam_school_all.school_id) AS schools_in_block FROM   hc_periodic_exam_school_all group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_all.school_id) AS schools_in_district FROM   hc_periodic_exam_school_all group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,school_performance
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id)as pat
on basic.school_id=pat.school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join hc_crc_school as crc
on basic.school_id=crc.school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_school as infra
on basic.school_id=infra.school_id',True,'school','overall')
on conflict on constraint progress_card_config_pkey do nothing;


/* progress card last 30 days  insert statements */
/* district */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name)as basic ',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join (select sad.*,sac.poor,sac.average,sac.good,sac.excellent,((rank () over ( order by attendance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_student_attendance_school_last_30_days)) as district_level_rank_within_the_state,1-round(Rank() over (ORDER BY attendance DESC) 
/ coalesce(((select count(distinct(district_id)) from hc_student_attendance_school_last_30_days)*1.0),1),1) as state_level_score
 from hc_student_attendance_district_last_30_days as sad left join
(select district_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by district_id)as sac
on sad.district_id= sac.district_id
)as student_attendance on basic.district_id=student_attendance.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,semester,
  ((rank () over (partition by semester order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from semester_exam_district_last30)) as district_level_rank_within_the_state, 
1-round( Rank() over (partition by semester ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from semester_exam_district_last30)*1.0),1),2) as state_level_score
 from semester_exam_district_last30 where semester=(select max(semester) from semester_exam_district_last30))as ped left join
(select district_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30 group by district_id,semester)as pes
on ped.district_id= pes.district_id and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
'left join 
(select uds.*,usc.poor,usc.average,usc.good,usc.excellent from udise_district_score as uds left join 
(select district_id,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from udise_school_score group by district_id)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
'left join (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,
  ((rank () over ( order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_periodic_exam_district_last30)) as district_level_rank_within_the_state,
 coalesce(1-round( Rank() over (ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from hc_periodic_exam_school_last30)*1.0),1),2)) as state_level_score
 from hc_periodic_exam_district_last30 )as ped left join
(select district_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by district_id)as pes
on ped.district_id= pes.district_id)as pat
on basic.district_id=pat.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.district_level_rank_within_the_state 
from
(select * from crc_district_report_last_30_days) as res1
join
(select a.district_id,a.visit_score,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  ((select count(distinct(district_id)) 
from crc_visits_frequency))) AS district_level_rank_within_the_state ,
case when visit_score>0 then 
coalesce(1-round(( Rank()
             over (
               ORDER BY a.visit_score DESC) / ((select count(distinct(district_id)) 
from crc_visits_frequency)*1.0)),2)) else 0 end  AS state_level_score                  
                
 from (select  crc.visit_score,crc.district_id 
 from
 (select  district_id,
 cast(COALESCE(100 - cast(schools_0 as float),0) as float)  as visit_score 
from crc_district_report_last_30_days) as crc
group by visit_score,district_id)as a) as res
on res1.district_id=res.district_id) as crc_res)
 as crc
on basic.district_id=crc.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_district as infra
on basic.district_id=infra.district_id',True,'district','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* block */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from (select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name)as basic ',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
'left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_last_30_days as sad left join
(select block_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by block_id)as sac
on sad.block_id= sac.block_id) as b
left join(select usc.block_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_last_30_days as sad left join
(select block_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by block_id)as sac
on sad.block_id= sac.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from hc_student_attendance_school_last_30_days)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from hc_student_attendance_school_last_30_days as scl
left join
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_last_30_days.block_id) AS blocks_in_district FROM   hc_student_attendance_school_last_30_days group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by attendance
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id )as student_attendance
on basic.block_id=student_attendance.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,semester
 from semester_exam_block_last30 where semester=(select max(semester) from semester_exam_block_last30))as ped left join
(select block_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,semester
 from semester_exam_block_last30 
)as ped left join
(select block_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from semester_exam_school_last30)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from semester_exam_school_last30 as scl
left join
(SELECT district_id,Count(DISTINCT semester_exam_school_last30.block_id) AS blocks_in_district FROM  semester_exam_school_last30 group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by block_performance,usc.semester
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.semester=c.semester
)as semester
on basic.block_id=semester.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
'left join (select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_block as b
left join(select usc.block_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from hc_udise_block as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from udise_school_metrics_agg)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from udise_school_metrics_agg as scl
left join
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.block_id) AS blocks_in_district FROM   udise_school_metrics_agg group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by infrastructure_score
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id)as udise
on basic.block_id=udise.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
'left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_last30 )as ped left join
(select block_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by block_id)as pes
on ped.block_id= pes.block_id) as b
left join(select usc.block_id,block_performance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_last30 
)as ped left join
(select block_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by block_id)as pes
on ped.block_id= pes.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from hc_periodic_exam_school_last30)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from hc_periodic_exam_school_last30 as scl
left join
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_last30.block_id) AS blocks_in_district FROM hc_periodic_exam_school_last30 group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by block_performance
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id)as pat
on basic.block_id=pat.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
round(res.visit_score) as visit_score,res.state_level_score,res.block_level_rank_within_the_district,res.block_level_rank_within_the_state 
from
(select * from crc_block_report_last_30_days) as res1
join
(select a.block_id,a.visit_score,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks_state) AS block_level_rank_within_the_state,
case when (a.visit_score >0) then 
coalesce(1-round(( Rank()
             over (
               ORDER BY a.visit_score DESC) / (a.total_blocks_state*1.0)),2)) 
else 0 end as state_level_score		 
 from (select  crc.visit_score,a.block_id,a.district_id,a.blocks_in_district,a.total_blocks_state 
 from
 (select  block_id,
 cast(COALESCE(100 - cast(schools_0 as float),0) as float)  as visit_score 
from crc_block_report_last_30_days) as crc
left join 
(select a.*,(select count(DISTINCT(block_id)) from crc_block_report_last_30_days)as total_blocks_state 
from (select distinct(scl.block_id),d.district_id,blocks_in_district from crc_block_report_last_30_days as scl
left join 
(SELECT district_id,Count(DISTINCT crc_block_report_last_30_days.block_id) AS blocks_in_district FROM   crc_block_report_last_30_days group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on crc.block_id=a.block_id)as a group by visit_score,block_id,district_id,total_blocks_state) as res
on res1.block_id=res.block_id) as crc_res
) as crc
on basic.block_id=crc.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_block as infra
on basic.block_id=infra.block_id',True,'block','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* cluster */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name)as basic ',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_last_30_days as sad left join
(select cluster_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id) as b
left join(select usc.cluster_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_last_30_days as sad left join
(select cluster_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from hc_student_attendance_school_last_30_days)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from hc_student_attendance_school_last_30_days as scl
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_last_30_days.cluster_id) AS clusters_in_block FROM   hc_student_attendance_school_last_30_days group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_last_30_days.cluster_id) AS clusters_in_district FROM   hc_student_attendance_school_last_30_days group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by attendance
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as student_attendance
on basic.cluster_id=student_attendance.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
'left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,semester 
 from semester_exam_cluster_last30  where semester=(select max(semester) from semester_exam_cluster_last30)
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30 group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,semester
 from semester_exam_cluster_last30 
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30 group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from semester_exam_school_last30)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from semester_exam_school_last30 as scl
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_last30.cluster_id) AS clusters_in_block FROM   semester_exam_school_last30 group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_last30.cluster_id) AS clusters_in_district FROM   semester_exam_school_last30 group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by cluster_performance,usc.semester
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.semester=c.semester
)as semester
on basic.cluster_id=semester.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_cluster as b
left join(select usc.cluster_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from hc_udise_cluster as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from udise_school_metrics_agg)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from udise_school_metrics_agg as scl
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_block FROM   udise_school_metrics_agg group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_district FROM   udise_school_metrics_agg group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by infrastructure_score
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as udise
on basic.cluster_id=udise.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_last30)as ped left join
(select cluster_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as b
left join(select usc.cluster_id,cluster_performance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_last30)as ped left join
(select cluster_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_last30  group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from periodic_exam_school_last30)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from periodic_exam_school_last30 as scl
left join
(SELECT block_id,Count(DISTINCT periodic_exam_school_last30.cluster_id) AS clusters_in_block FROM   periodic_exam_school_last30 group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT periodic_exam_school_last30.cluster_id) AS clusters_in_district FROM   periodic_exam_school_last30 group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by cluster_performance
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id)as pat
on basic.cluster_id=pat.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
round(cast(res.visit_score as Decimal),2) as visit_score,res.state_level_score,res.cluster_level_rank_within_the_block,res.cluster_level_rank_within_the_district,res.cluster_level_rank_within_the_state 
from
(select * from crc_cluster_report_last_30_days) as res1
join
(select a.cluster_id,a.visit_score,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters_state) AS cluster_level_rank_within_the_state,
case when visit_score >0 then 
coalesce(1-round(( Rank()
             over (
               ORDER BY a.visit_score DESC) / (a.total_clusters_state*1.0)),2)) else 0 end AS state_level_score		 
 from (select  crc.visit_score,a.cluster_id,a.clusters_in_block,a.block_id,a.district_id,a.clusters_in_district,a.total_clusters_state 
 from
 (select  cluster_id,
 cast(COALESCE(100 - cast(schools_0 as float),0) as float)  as visit_score 
from crc_cluster_report_last_30_days) as crc
left join 
(select a.*,(select count(DISTINCT(cluster_id)) from crc_cluster_report_last_30_days)as total_clusters_state 
from (select cluster_id,c.block_id,clusters_in_block,d.district_id,clusters_in_district from crc_cluster_report_last_30_days as scl
left join 
(SELECT block_id,Count(DISTINCT crc_cluster_report_last_30_days.cluster_id) AS clusters_in_block FROM   crc_cluster_report_last_30_days group by block_id) as c
on scl.block_id=c.block_id
left join
(SELECT district_id,Count(DISTINCT crc_cluster_report_last_30_days.cluster_id) AS clusters_in_district FROM   crc_cluster_report_last_30_days group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on crc.cluster_id=a.cluster_id)as a group by cluster_id,visit_score,block_id,district_id,total_clusters_state) as res
on res1.cluster_id=res.cluster_id) as crc_res) as crc
on basic.cluster_id=crc.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_cluster as infra
on basic.cluster_id=infra.cluster_id',True,'cluster','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* cluster*/

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
'  from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as basic ',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_school_last_30_days as sad left join
(select school_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days group by school_id)as sac
on sad.school_id= sac.school_id) as b
left join(select usc.school_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_school_last_30_days as sad left join
(select school_id,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days  group by school_id)as sac
on sad.school_id= sac.school_id ) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from hc_student_attendance_school_last_30_days)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from hc_student_attendance_school_last_30_days as scl
left join 
(SELECT cluster_id,Count(DISTINCT hc_student_attendance_school_last_30_days.school_id) AS schools_in_cluster FROM   hc_student_attendance_school_last_30_days group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_last_30_days.school_id) AS schools_in_block FROM   hc_student_attendance_school_last_30_days group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_last_30_days.school_id) AS schools_in_district FROM   hc_student_attendance_school_last_30_days group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,attendance
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id)as student_attendance
on basic.school_id=student_attendance.school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
pes.poor,pes.average,pes.good,pes.excellent,ped.grade_wise_performance from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester
 from semester_exam_school_last30 where semester=(select max(semester) from semester_exam_school_last30))as ped left join
(select school_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30 
   group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as b
left join(select usc.school_id,school_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester
from semester_exam_school_last30)as ped left join
(select school_id,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30 group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from semester_exam_school_last30)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from semester_exam_school_last30 as scl
left join 
(SELECT cluster_id,Count(DISTINCT semester_exam_school_last30.school_id) AS schools_in_cluster FROM semester_exam_school_last30 group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_last30.school_id) AS schools_in_block FROM   semester_exam_school_last30 group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_last30.school_id) AS schools_in_district FROM   semester_exam_school_last30 group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,school_performance,usc.semester
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id and b.semester=c.semester
)as semester
on basic.school_id=semester.school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from hc_udise_school as b
left join(select usc.udise_school_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from hc_udise_school as usc
left join
(select a.*,(select count(DISTINCT(udise_school_id)) from udise_school_metrics_agg)as total_schools 
from (select udise_school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from udise_school_metrics_agg as scl
left join 
(SELECT cluster_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_cluster FROM   udise_school_metrics_agg group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_block FROM   udise_school_metrics_agg group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_district FROM   udise_school_metrics_agg group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.udise_school_id=a.udise_school_id
group by usc.udise_school_id,infrastructure_score
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.udise_school_id = c.udise_school_id)as udise
on basic.school_id=udise.udise_school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
 from hc_periodic_exam_school_last30 )as ped left join
(select school_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by school_id)as pes
on ped.school_id= pes.school_id) as b
left join(select usc.school_id,school_performance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance
 from hc_periodic_exam_school_last30 )as ped left join
(select school_id,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_last30 group by school_id)as pes
on ped.school_id= pes.school_id) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from hc_periodic_exam_school_last30)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from hc_periodic_exam_school_last30 as scl
left join 
(SELECT cluster_id,Count(DISTINCT hc_periodic_exam_school_last30.school_id) AS schools_in_cluster FROM   hc_periodic_exam_school_last30 group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT hc_periodic_exam_school_last30.school_id) AS schools_in_block FROM   hc_periodic_exam_school_last30 group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_last30.school_id) AS schools_in_district FROM   hc_periodic_exam_school_last30 group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,school_performance
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id)as pat
on basic.school_id=pat.school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.school_id,res1.school_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
round(res.visit_score,2) as visit_score,res.state_level_score,res.school_level_rank_within_the_cluster,res.school_level_rank_within_the_block,res.school_level_rank_within_the_district,res.school_level_rank_within_the_state 
from
(select * from crc_school_report_last_30_days) as res1
join
(select a.school_id,a.visit_score,a.state_level_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_schools_state) AS school_level_rank_within_the_state                   
 from (select  crc.school_id,crc.state_level_score,crc.visit_score,a.cluster_id,a.schools_in_cluster,a.block_id,a.schools_in_block,a.district_id,a.schools_in_district,a.total_schools_state 
 from
 (select  school_id,
 CASE 
	WHEN COALESCE(round(schools_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 1.0
	WHEN COALESCE(round(schools_6_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.75
	WHEN COALESCE(round(schools_3_5 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.50
	WHEN COALESCE(round(schools_1_2 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.25
	WHEN COALESCE(round(((total_schools - COALESCE(visited_school_count, 0::bigint)) * 100 / total_schools)::numeric, 1)) > 0 then 0
	ELSE 0
	END as state_level_score,
case when schools_0>0  then 0 else 100 end as visit_score
from crc_school_report_last_30_days) as crc
left join 
(select a.*,(select count(DISTINCT(school_id)) from crc_school_report_last_30_days)as total_schools_state 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from crc_school_report_last_30_days as scl
left join 
(SELECT cluster_id,Count(DISTINCT crc_school_report_last_30_days.school_id) AS schools_in_cluster FROM   crc_school_report_last_30_days group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT crc_school_report_last_30_days.school_id) AS schools_in_block FROM   crc_school_report_last_30_days group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT crc_school_report_last_30_days.school_id) AS schools_in_district FROM   crc_school_report_last_30_days group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on crc.school_id=a.school_id)as a group by school_id,visit_score,cluster_id,block_id,district_id,total_schools_state,state_level_score) as res
on res1.school_id=res.school_id) as crc_res)as crc
on basic.school_id=crc.school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;


insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
'left join hc_infra_school as infra
on basic.school_id=infra.school_id',True,'school','last30')
on conflict on constraint progress_card_config_pkey do nothing;


/* Function to create progress card views for overall and last 30 days at different levels */

CREATE OR REPLACE FUNCTION progress_card_create_views()
RETURNS text AS
$$
DECLARE
select_query_dist text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''district'' and time_period=''overall''  order by id)as d';   
select_cols_dist text;
join_query_dist text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''district'' and time_period=''overall''  order by id)as d';
join_cols_dist text;
district_view text;
select_query_blk text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''block'' and time_period=''overall''  order by id)as d';   
select_cols_blk text;
join_query_blk text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''block'' and time_period=''overall''  order by id)as d';
join_cols_blk text;
block_view text;
select_query_cst text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''cluster'' and time_period=''overall''  order by id)as d';   
select_cols_cst text;
join_query_cst text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''cluster'' and time_period=''overall''  order by id)as d';
join_cols_cst text;
cluster_view text;
select_query_scl text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''school'' and time_period=''overall''  order by id)as d';   
select_cols_scl text;
join_query_scl text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''school'' and time_period=''overall''  order by id)as d';
join_cols_scl text;
school_view text;

select_query_dist_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''district'' and time_period=''last30''  order by id)as d';   
select_cols_dist_last30 text;
join_query_dist_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''district'' and time_period=''last30''  order by id)as d';
join_cols_dist_last30 text;
district_view_last30 text;
select_query_blk_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''block'' and time_period=''last30''  order by id)as d';   
select_cols_blk_last30 text;
join_query_blk_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''block'' and time_period=''last30''  order by id)as d';
join_cols_blk_last30 text;
block_view_last30 text;
select_query_cst_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''cluster'' and time_period=''last30''  order by id)as d';   
select_cols_cst_last30 text;
join_query_cst_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''cluster'' and time_period=''last30''  order by id)as d';
join_cols_cst_last30 text;
cluster_view_last30 text;
select_query_scl_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''school'' and time_period=''last30''  order by id)as d';   
select_cols_scl_last30 text;
join_query_scl_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''school'' and time_period=''last30''  order by id)as d';
join_cols_scl_last30 text;
school_view_last30 text;
BEGIN
Execute select_query_dist into select_cols_dist;
Execute join_query_dist into join_cols_dist;
Execute select_query_blk into select_cols_blk;
Execute join_query_blk into join_cols_blk;
Execute select_query_cst into select_cols_cst;
Execute join_query_cst into join_cols_cst;
Execute select_query_scl into select_cols_scl;
Execute join_query_scl into join_cols_scl;
Execute select_query_dist_last30 into select_cols_dist_last30;
Execute join_query_dist_last30 into join_cols_dist_last30;
Execute select_query_blk_last30 into select_cols_blk_last30;
Execute join_query_blk_last30 into join_cols_blk_last30;
Execute select_query_cst_last30 into select_cols_cst_last30;
Execute join_query_cst_last30 into join_cols_cst_last30;
Execute select_query_scl_last30 into select_cols_scl_last30;
Execute join_query_scl_last30 into join_cols_scl_last30;

district_view='create or replace view progress_card_index_district_overall as 
'||select_cols_dist||' '||join_cols_dist||';
';
Execute district_view; 
block_view='create or replace view progress_card_index_block_overall as 
'||select_cols_blk||' '||join_cols_blk||';
';
Execute block_view; 
cluster_view='create or replace view progress_card_index_cluster_overall as 
'||select_cols_cst||' '||join_cols_cst||';
';
Execute cluster_view; 
school_view='create or replace view progress_card_index_school_overall as 
'||select_cols_scl||' '||join_cols_scl||';
';
Execute school_view; 

district_view_last30='create or replace view progress_card_index_district_last30 as 
'||select_cols_dist_last30||' '||join_cols_dist_last30||';
';
Execute district_view_last30; 
block_view_last30='create or replace view progress_card_index_block_last30 as 
'||select_cols_blk_last30||' '||join_cols_blk_last30||';
';
Execute block_view_last30; 
cluster_view_last30='create or replace view progress_card_index_cluster_last30 as 
'||select_cols_cst_last30||' '||join_cols_cst_last30||';
';
Execute cluster_view_last30; 
school_view_last30='create or replace view progress_card_index_school_last30 as 
'||select_cols_scl_last30||' '||join_cols_scl_last30||';
';
Execute school_view_last30; 
return 0;
END;
$$LANGUAGE plpgsql;


/* progress card management queries */
/* district */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,
shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,school_management_type)as basic ',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;


insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
'left join 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent,((rank () over (partition by sac.school_management_type order by attendance desc))||'' out of ''||(select count(distinct(district_id)) 
from school_student_total_attendance)) as district_level_rank_within_the_state,coalesce(1-round((Rank() over (partition by sac.school_management_type ORDER BY attendance DESC) / ((select count(distinct(district_id)) 
from school_student_total_attendance)*1.0)),2)) as state_level_score
 from hc_student_attendance_district_mgmt_overall as sad left join
(select district_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall group by district_id,school_management_type)as sac
on sad.district_id= sac.district_id and sad.school_management_type=sac.school_management_type
)as student_attendance
on basic.district_id=student_attendance.district_id and basic.school_management_type=student_attendance.school_management_type ',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,school_management_type,semester,
  ((rank () over ( partition by school_management_type,semester order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from semester_exam_district_mgmt_all)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type,semester ORDER BY district_performance DESC) /
 ((select count(distinct(district_id)) from semester_exam_district_mgmt_all)*1.0)),2)) as state_level_score
 from semester_exam_district_mgmt_all where semester=(select max(semester) from semester_exam_district_mgmt_all))as ped left join
(select district_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_all group by district_id,school_management_type,semester)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id and basic.school_management_type=semester.school_management_type',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select uds.*,usc.poor,usc.average,usc.good,usc.excellent from udise_district_mgt_score as uds left join 
(select district_id,school_management_type,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from udise_school_mgt_score group by district_id,school_management_type)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id and basic.school_management_type=udise.school_management_type',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,school_management_type,
  ((rank () over ( partition by school_management_type order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_periodic_exam_district_mgmt_all)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type ORDER BY district_performance DESC) / ((select count(distinct(district_id)) from semester_exam_district_mgmt_all)*1.0)),2)) as state_level_score
 from hc_periodic_exam_district_mgmt_all )as ped left join
(select district_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_all group by district_id,school_management_type)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type)as pat
on basic.district_id=pat.district_id and basic.school_management_type=pat.school_management_type
 ',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
'left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.district_level_rank_within_the_state,res1.school_management_type 
from
(select * from crc_district_mgmt_all) as res1
join
(select a.district_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  ((select count(distinct(district_id)) 
from crc_visits_frequency))) AS district_level_rank_within_the_state ,
case when visit_score>0 then 
coalesce(1-round(( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / ((select count(distinct(district_id)) 
from crc_visits_frequency)*1.0)),2)) else 0 end  AS state_level_score                  
                
 from (select  crc.visit_score,crc.district_id ,crc.school_management_type
 from
 (select  district_id,school_management_type,
 round(COALESCE(100 - schools_0 ),2) as visit_score 
from crc_district_mgmt_all) as crc
group by visit_score,district_id,school_management_type)as a) as res
on res1.district_id=res.district_id and res1.school_management_type=res.school_management_type) as crc_res) as crc
on basic.district_id=crc.district_id and basic.school_management_type=crc.school_management_type',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_district as infra
on basic.district_id=infra.district_id and basic.school_management_type=infra.school_management_type',True,'district_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* block */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
'  from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,
sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,school_management_type)as basic ',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_mgmt_overall as sad left join
(select block_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.block_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_mgmt_overall as sad left join
(select block_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from hc_student_attendance_school_mgmt_overall as scl
left join
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.block_id) AS blocks_in_district,school_management_type 
FROM   hc_student_attendance_school_mgmt_overall group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks, school_management_type from hc_student_attendance_school_mgmt_overall group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by attendance,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type )as student_attendance
on basic.block_id=student_attendance.block_id and basic.school_management_type=student_attendance.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,school_management_type,semester
 from semester_exam_block_mgmt_all
where semester=(select max(semester) from semester_exam_block_mgmt_all) )as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_all  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,school_management_type,semester
 from semester_exam_block_mgmt_all 
)as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_all  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from semester_exam_school_mgmt_all as scl
left join
(SELECT district_id,Count(DISTINCT semester_exam_school_mgmt_all.block_id) AS blocks_in_district,school_management_type FROM  semester_exam_school_mgmt_all group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from semester_exam_school_mgmt_all group by school_management_type)as e
on scl.school_management_type=e.school_management_type
)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by block_performance,usc.school_management_type,usc.semester
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type and b.semester=c.semester
)as semester
on basic.block_id=semester.block_id and basic.school_management_type=semester.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_mgmt_block as b
left join(select usc.block_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from hc_udise_mgmt_block as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from udise_school_metrics_agg as scl
left join
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.block_id) AS blocks_in_district,school_management_type FROM   udise_school_metrics_agg group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from udise_school_metrics_agg group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.block_id=a.block_id  and usc.school_management_type=a.school_management_type
group by infrastructure_score,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type)as udise
on basic.block_id=udise.block_id and basic.school_management_type=udise.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_all )as ped left join
(select block_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_mgmt_all  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.block_id,block_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_all 
)as ped left join
(select block_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_mgmt_all  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from periodic_exam_school_mgmt_all as scl
left join
(SELECT district_id,Count(DISTINCT periodic_exam_school_mgmt_all.block_id) AS blocks_in_district,school_management_type FROM  periodic_exam_school_mgmt_all group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from periodic_exam_school_mgmt_all group by school_management_type)as e
on scl.school_management_type=e.school_management_type
)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by block_performance,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type)as pat
on basic.block_id=pat.block_id and basic.school_management_type=pat.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.block_level_rank_within_the_district,res.block_level_rank_within_the_state ,res.school_management_type
from
(select * from crc_block_mgmt_all) as res1
join
(select a.block_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks_state) AS block_level_rank_within_the_state,
case when (a.visit_score >0) then 
coalesce(1-round(( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / (a.total_blocks_state*1.0)),2)) 
else 0 end as state_level_score		 
 from (select  crc.visit_score,a.block_id,a.district_id,a.blocks_in_district,a.total_blocks_state,a.school_management_type 
 from
 (select  block_id,school_management_type,
  round(COALESCE(100 - schools_0 ),2)   as visit_score 
from crc_block_mgmt_all) as crc
left join 
(select a.*
from (select distinct(scl.block_id),d.district_id,blocks_in_district,d.school_management_type,e.total_blocks_state from crc_block_mgmt_all as scl
left join 
(SELECT district_id,Count(DISTINCT crc_block_mgmt_all.block_id) AS blocks_in_district ,school_management_type FROM   crc_block_mgmt_all group by district_id,school_management_type ) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks_state,school_management_type from crc_block_mgmt_all group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on crc.block_id=a.block_id and crc.school_management_type=a.school_management_type)as a group by visit_score,block_id,district_id,total_blocks_state,school_management_type) as res
on res1.block_id=res.block_id and res1.school_management_type=res.school_management_type) as crc_res
) as crc
on basic.block_id=crc.block_id and basic.school_management_type=crc.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_block as infra
on basic.block_id=infra.block_id and basic.school_management_type=infra.school_management_type',True,'block_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* cluster */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,school_management_type)as basic ',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_mgmt_overall as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.cluster_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_mgmt_overall as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from hc_student_attendance_school_mgmt_overall as scl
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.cluster_id) AS clusters_in_block,school_management_type FROM   hc_student_attendance_school_mgmt_overall 
group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.cluster_id) AS clusters_in_district,school_management_type FROM   hc_student_attendance_school_mgmt_overall 
group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id))as total_clusters,school_management_type from hc_student_attendance_school_mgmt_overall group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by attendance,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as student_attendance
on basic.cluster_id=student_attendance.cluster_id and basic.school_management_type=student_attendance.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,school_management_type,semester
 from semester_exam_cluster_mgmt_all where semester=(select max(semester) from semester_exam_cluster_mgmt_all))as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_all group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,school_management_type,semester
 from semester_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_all group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from semester_exam_school_mgmt_all as scl
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_mgmt_all.cluster_id) AS clusters_in_block,school_management_type FROM   semester_exam_school_mgmt_all group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_mgmt_all.cluster_id) AS clusters_in_district,school_management_type FROM   semester_exam_school_mgmt_all group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from semester_exam_school_mgmt_all group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by cluster_performance,usc.school_management_type,semester
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type and b.semester=c.semester)as semester
on basic.cluster_id=semester.cluster_id and basic.school_management_type=semester.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_mgmt_cluster as b
left join(select usc.cluster_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from hc_udise_mgmt_cluster as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from udise_school_metrics_agg as scl
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_block,school_management_type FROM   udise_school_metrics_agg group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_district,school_management_type FROM   udise_school_metrics_agg group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from udise_school_metrics_agg group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by infrastructure_score,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as udise
on basic.cluster_id=udise.cluster_id and basic.school_management_type=udise.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_all group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_all group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from hc_periodic_exam_school_mgmt_all as scl
left join
(SELECT block_id,Count(DISTINCT hc_periodic_exam_school_mgmt_all.cluster_id) AS clusters_in_block,school_management_type FROM   hc_periodic_exam_school_mgmt_all group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_mgmt_all.cluster_id) AS clusters_in_district,school_management_type FROM   hc_periodic_exam_school_mgmt_all group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from hc_periodic_exam_school_mgmt_all group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by cluster_performance,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as pat
on basic.cluster_id=pat.cluster_id and basic.school_management_type=pat.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.cluster_level_rank_within_the_block,res.cluster_level_rank_within_the_district,res.cluster_level_rank_within_the_state,res.school_management_type
from
(select * from crc_cluster_report_mgmt_last_30_days) as res1
join
(select a.cluster_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters_state) AS cluster_level_rank_within_the_state,
case when visit_score >0 then 
coalesce(1-round(( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / (a.total_clusters_state*1.0)),2)) else 0 end AS state_level_score		 
 from (select  crc.visit_score,a.cluster_id,a.clusters_in_block,a.block_id,a.district_id,a.clusters_in_district,a.total_clusters_state,a.school_management_type 
 from
 (select  cluster_id,school_management_type,
 round(COALESCE(100 - schools_0 ),2)  as visit_score 
from crc_cluster_report_mgmt_last_30_days) as crc
left join 
(select a.*
from (select cluster_id,c.block_id,clusters_in_block,d.district_id,clusters_in_district,d.school_management_type,e.total_clusters_state from crc_cluster_report_mgmt_last_30_days as scl
left join 
(SELECT block_id,Count(DISTINCT crc_cluster_report_mgmt_last_30_days.cluster_id) AS clusters_in_block,school_management_type FROM   crc_cluster_report_mgmt_last_30_days 
group by block_id,school_management_type) as c
on scl.block_id=c.block_id and scl.school_management_type=c.school_management_type
left join
(SELECT district_id,Count(DISTINCT crc_cluster_report_mgmt_last_30_days.cluster_id) AS clusters_in_district,school_management_type FROM   crc_cluster_report_mgmt_last_30_days 
group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters_state,school_management_type from crc_cluster_report_mgmt_last_30_days group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on crc.cluster_id=a.cluster_id and crc.school_management_type=a.school_management_type)as a
 group by cluster_id,visit_score,block_id,district_id,total_clusters_state,school_management_type) as res
on res1.cluster_id=res.cluster_id and res1.school_management_type=res.school_management_type) as crc_res) as crc
on basic.cluster_id=crc.cluster_id and basic.school_management_type=crc.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_cluster as infra
on basic.cluster_id=infra.cluster_id and basic.school_management_type=infra.school_management_type',True,'cluster_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;


/* school */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,shd.school_management_type,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,school_management_type)as basic ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_school_mgmt_overall as sad left join
(select school_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_overall group by school_id,school_management_type)as sac
on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type) as b
left join(select usc.school_id,attendance,usc.school_management_type,
	   ( ( Rank()
			 over (
			   PARTITION BY a.cluster_id,usc.school_management_type
			   ORDER BY usc.attendance DESC)
		   || '' out of '' :: text )
		 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
	 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
	 from hc_student_attendance_school_mgmt_overall as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from hc_student_attendance_school_mgmt_overall  group by school_id,school_management_type)as sac
	on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type ) as usc
	left join
	(select a.*
	from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.total_schools,e.school_management_type
	 from hc_student_attendance_school_mgmt_overall as scl
	left join 
	(SELECT cluster_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.school_id) AS schools_in_cluster,school_management_type FROM   hc_student_attendance_school_mgmt_overall 
	group by cluster_id,school_management_type) as c
	on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
	left join
	(SELECT block_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.school_id) AS schools_in_block,school_management_type FROM   hc_student_attendance_school_mgmt_overall 
	group by block_id,school_management_type)as b
	on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
	left join 
	(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_overall.school_id) AS schools_in_district,school_management_type FROM   hc_student_attendance_school_mgmt_overall 
	group by district_id,school_management_type) as d
	on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
	left join 
	(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from hc_student_attendance_school_mgmt_overall group by school_management_type) as e 
	on scl.school_management_type=e.school_management_type)as a)as a
	on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
	group by usc.school_id,attendance,usc.school_management_type,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
	ON b.school_id = c.school_id and b.school_management_type=c.school_management_type where b.school_management_type is not null)as student_attendance
on basic.school_id=student_attendance.school_id  and basic.school_management_type=student_attendance.school_management_type
 ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
	pes.poor,pes.average,pes.good,pes.excellent,ped.grade_wise_performance,ped.school_management_type from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester,school_management_type
	 from semester_exam_school_mgmt_all where semester=(select max(semester) from semester_exam_school_mgmt_all))as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from semester_exam_school_mgmt_all 
	   group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as b
	left join(select usc.school_id,school_performance,usc.semester,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_block )) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
	 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester,school_management_type
	from semester_exam_school_mgmt_all)as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from semester_exam_school_mgmt_all  where school_management_type is not null group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as usc
	left join
	(select a.*
	from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from semester_exam_school_mgmt_all as scl
	left join 
	(SELECT cluster_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_all.school_id) AS schools_in_cluster FROM semester_exam_school_mgmt_all 
	where school_management_type is not null group by cluster_id,school_management_type) as c
	on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
	left join
	(SELECT block_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_all.school_id) AS schools_in_block FROM   semester_exam_school_mgmt_all 
	where school_management_type is not null group by block_id,school_management_type)as b
	on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
	left join 
	(SELECT district_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_all.school_id) AS schools_in_district FROM   semester_exam_school_mgmt_all 
	where school_management_type is not null group by district_id,school_management_type) as d
	on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
	left join
	(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from semester_exam_school_mgmt_all 
	where school_management_type is not null group by school_management_type) as e 
		on scl.school_management_type=e.school_management_type)as a)as a
	on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
	group by usc.school_id,school_performance,usc.semester,usc.school_management_type
	,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
	ON b.school_id = c.school_id and b.semester=c.semester and b.semester=c.semester and b.school_management_type=c.school_management_type)as semester
on basic.school_id=semester.school_id and basic.school_management_type=semester.school_management_type
 ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score 
from hc_udise_mgmt_school as b
left join
(select usc.udise_school_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (Partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) 
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (PARTITION BY usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from hc_udise_mgmt_school as usc
left join
(select a.*
from (select udise_school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from udise_school_metrics_agg as scl
left join 
(SELECT cluster_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_cluster,school_management_type FROM   udise_school_metrics_agg  
where school_management_type is not null group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_block,school_management_type FROM   udise_school_metrics_agg 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_district,school_management_type FROM   udise_school_metrics_agg 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(udise_school_id)) as total_schools,school_management_type from udise_school_metrics_agg where school_management_type is not null group by school_management_type )as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.udise_school_id=a.udise_school_id and usc.school_management_type=a.school_management_type
group by usc.udise_school_id,infrastructure_score,usc.school_management_type
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.udise_school_id = c.udise_school_id and b.school_management_type=c.school_management_type where b.school_management_type is not null)as udise
on basic.school_id=udise.udise_school_id and basic.school_management_type=udise.school_management_type ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_school_mgmt_all)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_all 
   group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.school_id,school_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
from hc_periodic_exam_school_mgmt_all)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_all group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from hc_periodic_exam_school_mgmt_all as scl
left join 
(SELECT cluster_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_all.school_id) AS schools_in_cluster FROM hc_periodic_exam_school_mgmt_all 
where school_management_type is not null  group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id  and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_all.school_id) AS schools_in_block FROM   hc_periodic_exam_school_mgmt_all 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_all.school_id) AS schools_in_district FROM   hc_periodic_exam_school_mgmt_all 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from hc_periodic_exam_school_mgmt_all where school_management_type is not null group by school_management_type) as e 
	on scl.school_management_type=e.school_management_type)as a)as a
on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
group by usc.school_id,school_performance,usc.school_management_type,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id and b.school_management_type=c.school_management_type)as pat
on basic.school_id=pat.school_id and basic.school_management_type=pat.school_management_type ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.school_id,res1.school_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,
res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
round(cast(res.visit_score as decimal),2) as visit_score,res.state_level_score,res.school_level_rank_within_the_cluster,
res.school_level_rank_within_the_block,res.school_level_rank_within_the_district,res.school_level_rank_within_the_state ,res1.school_management_type
from
(select * from crc_school_mgmt_all) as res1
join
(select a.school_id,a.visit_score,a.state_level_score,a.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_schools_state) AS school_level_rank_within_the_state                   
 from (select  crc.school_id,crc.state_level_score,crc.visit_score,a.cluster_id,a.schools_in_cluster,a.block_id,a.schools_in_block,a.district_id,a.schools_in_district,a.total_schools_state,crc.school_management_type 
 from
 (select  school_id,school_management_type,
 CASE 
	WHEN COALESCE(round(schools_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 1.0
	WHEN COALESCE(round(schools_6_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.75
	WHEN COALESCE(round(schools_3_5 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.50
	WHEN COALESCE(round(schools_1_2 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.25
	WHEN COALESCE(round(((total_schools - COALESCE(visited_school_count, 0::bigint)) * 100 / total_schools)::numeric, 1)) > 0 then 0
	ELSE 0
	END as state_level_score,
case when schools_0>0  then 0 else 100 end as visit_score
from crc_school_mgmt_all ) as crc
left join 
(select a.*
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools_state from crc_school_mgmt_all as scl
left join 
(SELECT cluster_id,school_management_type,Count(DISTINCT crc_school_mgmt_all.school_id) AS schools_in_cluster FROM   crc_school_mgmt_all 
where school_management_type is not null group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,school_management_type,Count(DISTINCT crc_school_mgmt_all.school_id) AS schools_in_block FROM   crc_school_mgmt_all 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,school_management_type,Count(DISTINCT crc_school_mgmt_all.school_id) AS schools_in_district FROM   crc_school_mgmt_all 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select school_management_type,count(DISTINCT(school_id)) as total_schools_state from crc_school_mgmt_all 
where school_management_type is not null group by school_management_type)as e
on scl.school_management_type=e.school_management_type )as a)as a
on crc.school_id=a.school_id and crc.school_management_type=a.school_management_type)as a 
group by school_id,visit_score,cluster_id,block_id,district_id,total_schools_state,state_level_score,school_management_type) as res
on res1.school_id=res.school_id and res1.school_management_type=res.school_management_type where res1.school_management_type is not null) as crc_res) as crc
on basic.school_id=crc.school_id and basic.school_management_type=crc.school_management_type ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_school as infra
on basic.school_id=infra.school_id and basic.school_management_type=infra.school_management_type ',True,'school_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* district _mgmt last 30 days*/

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
'  from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,school_management_type)as basic ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent,((rank () over (partition by sac.school_management_type order by attendance desc))||'' out of ''||(select count(distinct(district_id)) 
from school_student_total_attendance)) as district_level_rank_within_the_state,
1-round((Rank() over (partition by sac.school_management_type ORDER BY attendance DESC) / coalesce((select count(distinct(district_id)) from school_student_total_attendance),1)*1.0),2) as state_level_score
 from hc_student_attendance_district_mgmt_last_30_days as sad left join
(select district_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_last_30_days group by district_id,school_management_type)as sac
on sad.district_id= sac.district_id and sad.school_management_type=sac.school_management_type
)as student_attendance
on basic.district_id=student_attendance.district_id and basic.school_management_type=student_attendance.school_management_type ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,school_management_type,semester,
  ((rank () over ( partition by school_management_type,semester order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from semester_exam_district_mgmt_last30)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type,semester ORDER BY district_performance DESC) /
 ((select count(distinct(district_id)) from semester_exam_district_mgmt_last30)*1.0)),2)) as state_level_score
 from semester_exam_district_mgmt_last30 where semester=(select max(semester) from semester_exam_district_mgmt_last30))as ped left join
(select district_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_last30 group by district_id,school_management_type,semester)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id and basic.school_management_type=semester.school_management_type ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select uds.*,usc.poor,usc.average,usc.good,usc.excellent from udise_district_mgt_score as uds left join 
(select district_id,school_management_type,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from udise_school_mgt_score group by district_id,school_management_type)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id and basic.school_management_type=udise.school_management_type ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,school_management_type,
  ((rank () over ( partition by school_management_type order by district_performance desc))||'' out of ''||(select count(distinct(district_id)) 
from hc_periodic_exam_district_mgmt_last30)) as district_level_rank_within_the_state, 
1-round( Rank() over (partition by school_management_type ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from semester_exam_district_mgmt_last30)*1.0),1),2) as state_level_score
 from hc_periodic_exam_district_mgmt_last30 )as ped left join
(select district_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_last30 group by district_id,school_management_type)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type)as pat
on basic.district_id=pat.district_id and basic.school_management_type=pat.school_management_type
 ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.district_level_rank_within_the_state,res1.school_management_type 
from
(select * from crc_district_report_mgmt_last_30_days) as res1
join
(select a.district_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  ((select count(distinct(district_id)) 
from crc_visits_frequency))) AS district_level_rank_within_the_state ,
case when visit_score>0 then 
1-round( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / coalesce(((select count(distinct(district_id)) from crc_visits_frequency)*1.0),1),2) else 0 end  AS state_level_score                  
                
 from (select  crc.visit_score,crc.district_id ,crc.school_management_type
 from
 (select  district_id,school_management_type,
 round(COALESCE(100 - schools_0 ),2)  as visit_score 
from crc_district_report_mgmt_last_30_days) as crc
group by visit_score,district_id,school_management_type)as a) as res
on res1.district_id=res.district_id and res1.school_management_type=res.school_management_type) as crc_res) as crc
on basic.district_id=crc.district_id and basic.school_management_type=crc.school_management_type
 ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_district as infra
on basic.district_id=infra.district_id and basic.school_management_type=infra.school_management_type ',True,'district_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* block _mgmt last30*/

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,
sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,school_management_type)as basic ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_mgmt_last_30_days as sad left join
(select block_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_last_30_days  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.block_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_block_mgmt_last_30_days as sad left join
(select block_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_last_30_days  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from hc_student_attendance_school_mgmt_last_30_days as scl
left join
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.block_id) AS blocks_in_district,school_management_type 
FROM   hc_student_attendance_school_mgmt_last_30_days group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks, school_management_type from hc_student_attendance_school_mgmt_last_30_days group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by attendance,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type )as student_attendance
on basic.block_id=student_attendance.block_id and basic.school_management_type=student_attendance.school_management_type ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,school_management_type,semester
 from semester_exam_block_mgmt_last30
where semester=(select max(semester) from semester_exam_block_mgmt_last30) )as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_last30  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,school_management_type,semester
 from semester_exam_block_mgmt_last30
)as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_last30  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from semester_exam_school_mgmt_last30 as scl
left join
(SELECT district_id,Count(DISTINCT semester_exam_school_mgmt_last30.block_id) AS blocks_in_district,school_management_type FROM  semester_exam_school_mgmt_last30 group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from semester_exam_school_mgmt_last30 group by school_management_type)as e
on scl.school_management_type=e.school_management_type
)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by block_performance,usc.school_management_type,usc.semester
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type and b.semester=c.semester
)as semester
on basic.block_id=semester.block_id and basic.school_management_type=semester.school_management_type
 ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_mgmt_block as b
left join(select usc.block_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from hc_udise_mgmt_block as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from udise_school_metrics_agg as scl
left join
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.block_id) AS blocks_in_district,school_management_type FROM   udise_school_metrics_agg group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from udise_school_metrics_agg group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.block_id=a.block_id  and usc.school_management_type=a.school_management_type
group by infrastructure_score,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type)as udise
on basic.block_id=udise.block_id and basic.school_management_type=udise.school_management_type
 ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_last30 )as ped left join
(select block_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_mgmt_last30  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.block_id,block_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || '' out of '' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_last30 
)as ped left join
(select block_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_mgmt_last30  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from periodic_exam_school_mgmt_last30 as scl
left join
(SELECT district_id,Count(DISTINCT periodic_exam_school_mgmt_last30.block_id) AS blocks_in_district,school_management_type FROM  periodic_exam_school_mgmt_last30 group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks,school_management_type from periodic_exam_school_mgmt_last30 group by school_management_type)as e
on scl.school_management_type=e.school_management_type
)as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by block_performance,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type)as pat
on basic.block_id=pat.block_id and basic.school_management_type=pat.school_management_type
 ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.block_level_rank_within_the_district,res.block_level_rank_within_the_state ,res.school_management_type
from
(select * from crc_block_report_mgmt_last_30_days) as res1
join
(select a.block_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_blocks_state) AS block_level_rank_within_the_state,
case when (a.visit_score >0) then 
coalesce(1-round(( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / (a.total_blocks_state*1.0)),2)) 
else 0 end as state_level_score		 
 from (select  crc.visit_score,a.block_id,a.district_id,a.blocks_in_district,a.total_blocks_state,a.school_management_type 
 from
 (select  block_id,school_management_type,
 round(COALESCE(100 - schools_0 ),2)   as visit_score 
from crc_block_report_mgmt_last_30_days) as crc
left join 
(select a.*
from (select distinct(scl.block_id),d.district_id,blocks_in_district,d.school_management_type,e.total_blocks_state from crc_block_report_mgmt_last_30_days as scl
left join 
(SELECT district_id,Count(DISTINCT crc_block_report_mgmt_last_30_days.block_id) AS blocks_in_district ,school_management_type FROM   crc_block_report_mgmt_last_30_days group by district_id,school_management_type ) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(block_id)) as total_blocks_state,school_management_type from crc_block_report_mgmt_last_30_days group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on crc.block_id=a.block_id and crc.school_management_type=a.school_management_type)as a group by visit_score,block_id,district_id,total_blocks_state,school_management_type) as res
on res1.block_id=res.block_id and res1.school_management_type=res.school_management_type) as crc_res
) as crc
on basic.block_id=crc.block_id and basic.school_management_type=crc.school_management_type ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_block as infra
on basic.block_id=infra.block_id and basic.school_management_type=infra.school_management_type  ',True,'block_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* cluster _mgmt last30*/

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
'  from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,school_management_type)as basic ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_mgmt_last_30_days as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_last_30_days  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.cluster_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
 from hc_student_attendance_cluster_mgmt_last_30_days as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_mgmt_last_30_days  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from hc_student_attendance_school_mgmt_last_30_days as scl
left join
(SELECT block_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.cluster_id) AS clusters_in_block,school_management_type FROM   hc_student_attendance_school_mgmt_last_30_days 
group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.cluster_id) AS clusters_in_district,school_management_type FROM   hc_student_attendance_school_mgmt_last_30_days 
group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id))as total_clusters,school_management_type from hc_student_attendance_school_mgmt_last_30_days group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by attendance,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as student_attendance
on basic.cluster_id=student_attendance.cluster_id and basic.school_management_type=student_attendance.school_management_type
 ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(
select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,school_management_type,semester
 from semester_exam_cluster_mgmt_last30 where semester=(select max(semester) from semester_exam_cluster_mgmt_last30))as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_last30 group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,school_management_type,semester
 from semester_exam_cluster_mgmt_last30 
)as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_mgmt_last30 group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from semester_exam_school_mgmt_last30 as scl
left join
(SELECT block_id,Count(DISTINCT semester_exam_school_mgmt_last30.cluster_id) AS clusters_in_block,school_management_type FROM   semester_exam_school_mgmt_last30 group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT semester_exam_school_mgmt_last30.cluster_id) AS clusters_in_district,school_management_type FROM   semester_exam_school_mgmt_last30 group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from semester_exam_school_mgmt_last30 group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by cluster_performance,usc.school_management_type,semester
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type and b.semester=c.semester
)as semester
on basic.cluster_id=semester.cluster_id and basic.school_management_type=semester.school_management_type ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_mgmt_cluster as b
left join(select usc.cluster_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from hc_udise_mgmt_cluster as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from udise_school_metrics_agg as scl
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_block,school_management_type FROM   udise_school_metrics_agg group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.cluster_id) AS clusters_in_district,school_management_type FROM   udise_school_metrics_agg group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from udise_school_metrics_agg group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by infrastructure_score,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as udise
on basic.cluster_id=udise.cluster_id and basic.school_management_type=udise.school_management_type
 ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_last30
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_last30 group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || '' out of '' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_last30 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_last30 group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from hc_periodic_exam_school_mgmt_last30 as scl
left join
(SELECT block_id,Count(DISTINCT hc_periodic_exam_school_mgmt_last30.cluster_id) AS clusters_in_block,school_management_type FROM   hc_periodic_exam_school_mgmt_last30 group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT hc_periodic_exam_school_mgmt_last30.cluster_id) AS clusters_in_district,school_management_type FROM   hc_periodic_exam_school_mgmt_last30 group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters,school_management_type from hc_periodic_exam_school_mgmt_last30 group by school_management_type)as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
group by cluster_performance,usc.school_management_type
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type)as pat
on basic.cluster_id=pat.cluster_id and basic.school_management_type=pat.school_management_type ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
res.visit_score,res.state_level_score,res.cluster_level_rank_within_the_block,res.cluster_level_rank_within_the_district,res.cluster_level_rank_within_the_state,res.school_management_type
from
(select * from crc_cluster_report_mgmt_last_30_days) as res1
join
(select a.cluster_id,a.visit_score,a.school_management_type,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_clusters_state) AS cluster_level_rank_within_the_state,
case when visit_score >0 then 
coalesce(1-round(( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC) / (a.total_clusters_state*1.0)),2)) else 0 end AS state_level_score		 
 from (select  crc.visit_score,a.cluster_id,a.clusters_in_block,a.block_id,a.district_id,a.clusters_in_district,a.total_clusters_state,a.school_management_type 
 from
 (select  cluster_id,school_management_type,
  round(COALESCE(100 - schools_0 ),2)   as visit_score 
from crc_cluster_report_mgmt_last_30_days) as crc
left join 
(select a.*
from (select cluster_id,c.block_id,clusters_in_block,d.district_id,clusters_in_district,d.school_management_type,e.total_clusters_state from crc_cluster_report_mgmt_last_30_days as scl
left join 
(SELECT block_id,Count(DISTINCT crc_cluster_report_mgmt_last_30_days.cluster_id) AS clusters_in_block,school_management_type FROM   crc_cluster_report_mgmt_last_30_days 
group by block_id,school_management_type) as c
on scl.block_id=c.block_id and scl.school_management_type=c.school_management_type
left join
(SELECT district_id,Count(DISTINCT crc_cluster_report_mgmt_last_30_days.cluster_id) AS clusters_in_district,school_management_type FROM   crc_cluster_report_mgmt_last_30_days 
group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(cluster_id)) as total_clusters_state,school_management_type from crc_cluster_report_mgmt_last_30_days group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on crc.cluster_id=a.cluster_id and crc.school_management_type=a.school_management_type)as a
 group by cluster_id,visit_score,block_id,district_id,total_clusters_state,school_management_type) as res
on res1.cluster_id=res.cluster_id and res1.school_management_type=res.school_management_type) as crc_res) as crc
on basic.cluster_id=crc.cluster_id and basic.school_management_type=crc.school_management_type
 ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_cluster as infra
on basic.cluster_id=infra.cluster_id and basic.school_management_type=infra.school_management_type ',True,'cluster_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* school mgmt last30*/

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic','select basic.*',
' from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,shd.school_management_type,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,school_management_type)as basic ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance','row_to_json(student_attendance.*) as student_attendance',
' left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select sad.*,sac.poor,sac.average,sac.good,sac.excellent
	 from hc_student_attendance_school_mgmt_last_30_days as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from hc_student_attendance_school_mgmt_overall group by school_id,school_management_type)as sac
	on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type) as b
	left join(select usc.school_id,attendance,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || '' out of '' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
	 from (select sad.*,sac.poor,sac.average,sac.good,sac.excellent
	 from hc_student_attendance_school_mgmt_last_30_days as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from hc_student_attendance_school_mgmt_last_30_days  group by school_id,school_management_type)as sac
	on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type ) as usc
	left join
	(select a.*
	from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.total_schools,e.school_management_type
	 from hc_student_attendance_school_mgmt_last_30_days as scl
	left join 
	(SELECT cluster_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.school_id) AS schools_in_cluster,school_management_type FROM   hc_student_attendance_school_mgmt_last_30_days 
	group by cluster_id,school_management_type) as c
	on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
	left join
	(SELECT block_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.school_id) AS schools_in_block,school_management_type FROM   hc_student_attendance_school_mgmt_last_30_days 
	group by block_id,school_management_type)as b
	on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
	left join 
	(SELECT district_id,Count(DISTINCT hc_student_attendance_school_mgmt_last_30_days.school_id) AS schools_in_district,school_management_type FROM   hc_student_attendance_school_mgmt_last_30_days 
	group by district_id,school_management_type) as d
	on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
	left join 
	(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from hc_student_attendance_school_mgmt_last_30_days group by school_management_type) as e 
	on scl.school_management_type=e.school_management_type)as a)as a
	on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
	group by usc.school_id,attendance,usc.school_management_type,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
	ON b.school_id = c.school_id and b.school_management_type=c.school_management_type where b.school_management_type is not null)as student_attendance
on basic.school_id=student_attendance.school_id 
 ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat','row_to_json(semester.*) as student_semester',
' left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
	pes.poor,pes.average,pes.good,pes.excellent,ped.grade_wise_performance,ped.school_management_type from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester,school_management_type
	 from semester_exam_school_mgmt_last30 where semester=(select max(semester) from semester_exam_school_mgmt_last30))as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from semester_exam_school_mgmt_last30 
	   group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as b
	left join(select usc.school_id,school_performance,usc.semester,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_block )) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || '' out of '' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
	 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester,school_management_type
	from semester_exam_school_mgmt_last30)as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
	 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
	   from semester_exam_school_mgmt_last30  where school_management_type is not null group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as usc
	left join
	(select a.*
	from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from semester_exam_school_mgmt_last30 as scl
	left join 
	(SELECT cluster_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_last30.school_id) AS schools_in_cluster FROM semester_exam_school_mgmt_last30 
	where school_management_type is not null group by cluster_id,school_management_type) as c
	on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
	left join
	(SELECT block_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_last30.school_id) AS schools_in_block FROM   semester_exam_school_mgmt_last30 
	where school_management_type is not null group by block_id,school_management_type)as b
	on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
	left join 
	(SELECT district_id,school_management_type,Count(DISTINCT semester_exam_school_mgmt_last30.school_id) AS schools_in_district FROM   semester_exam_school_mgmt_last30 
	where school_management_type is not null group by district_id,school_management_type) as d
	on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
	left join
	(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from semester_exam_school_mgmt_last30 
	where school_management_type is not null group by school_management_type) as e 
		on scl.school_management_type=e.school_management_type)as a)as a
	on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
	group by usc.school_id,school_performance,usc.semester,usc.school_management_type
	,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
	ON b.school_id = c.school_id and b.semester=c.semester and b.semester=c.semester and b.school_management_type=c.school_management_type )as semester
on basic.school_id=semester.school_id and basic.school_management_type=semester.school_management_type ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise','row_to_json(udise.*) as udise',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score 
from hc_udise_mgmt_school as b
left join
(select usc.udise_school_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (Partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) 
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (PARTITION BY usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from hc_udise_mgmt_school as usc
left join
(select a.*
from (select udise_school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from udise_school_metrics_agg as scl
left join 
(SELECT cluster_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_cluster,school_management_type FROM   udise_school_metrics_agg  
where school_management_type is not null group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_block,school_management_type FROM   udise_school_metrics_agg 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,Count(DISTINCT udise_school_metrics_agg.udise_school_id) AS schools_in_district,school_management_type FROM   udise_school_metrics_agg 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select count(DISTINCT(udise_school_id)) as total_schools,school_management_type from udise_school_metrics_agg where school_management_type is not null group by school_management_type )as e
on scl.school_management_type=e.school_management_type)as a)as a
on usc.udise_school_id=a.udise_school_id and usc.school_management_type=a.school_management_type
group by usc.udise_school_id,infrastructure_score,usc.school_management_type
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.udise_school_id = c.udise_school_id and b.school_management_type=c.school_management_type where b.school_management_type is not null)as udise
on basic.school_id=udise.udise_school_id and basic.school_management_type=udise.school_management_type ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat','row_to_json(pat.*) as PAT_performance',
' left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_school_mgmt_last30)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_last30 
   group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.school_id,school_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || '' out of '' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.poor,pes.average,pes.good,pes.excellent from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
from hc_periodic_exam_school_mgmt_last30)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_periodic_exam_school_mgmt_last30 group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as usc
left join
(select a.*
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools from hc_periodic_exam_school_mgmt_last30 as scl
left join 
(SELECT cluster_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_last30.school_id) AS schools_in_cluster FROM hc_periodic_exam_school_mgmt_last30 
where school_management_type is not null  group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id  and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_last30.school_id) AS schools_in_block FROM   hc_periodic_exam_school_mgmt_last30 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,school_management_type,Count(DISTINCT hc_periodic_exam_school_mgmt_last30.school_id) AS schools_in_district FROM   hc_periodic_exam_school_mgmt_last30 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(SELECT school_management_type,count(DISTINCT(school_id)) as total_schools from hc_periodic_exam_school_mgmt_last30 where school_management_type is not null group by school_management_type) as e 
	on scl.school_management_type=e.school_management_type)as a)as a
on usc.school_id=a.school_id and usc.school_management_type=a.school_management_type
group by usc.school_id,school_performance,usc.school_management_type,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id and b.school_management_type=c.school_management_type)as pat
on basic.school_id=pat.school_id and basic.school_management_type=pat.school_management_type ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','row_to_json(crc.*) as CRC_visit',
' left join 
(select crc_res.*
from 
(select res1.district_id,res1.district_name,res1.block_id,res1.block_name,res1.cluster_id,res1.cluster_name,res1.school_id,res1.school_name,res1.total_schools,res1.total_crc_visits,res1.visited_school_count,
res1.not_visited_school_count,res1.data_from_date,res1.data_upto_date,res1.schools_0,res1.schools_1_2,res1.schools_3_5,
res1.schools_6_10,res1.schools_10,res1.no_of_schools_per_crc,res1.visit_percent_per_school,
round(cast(res.visit_score as decimal),2) as visit_score,res.state_level_score,res.school_level_rank_within_the_cluster,
res.school_level_rank_within_the_block,res.school_level_rank_within_the_district,res.school_level_rank_within_the_state ,res1.school_management_type
from
(select * from crc_school_report_mgmt_last_30_days) as res1
join
(select a.school_id,a.visit_score,a.state_level_score,a.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || '' out of '' :: text )
         ||  a.total_schools_state) AS school_level_rank_within_the_state                   
 from (select  crc.school_id,crc.state_level_score,crc.visit_score,a.cluster_id,a.schools_in_cluster,a.block_id,a.schools_in_block,a.district_id,a.schools_in_district,a.total_schools_state,crc.school_management_type 
 from
 (select  school_id,school_management_type,
 CASE 
	WHEN COALESCE(round(schools_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 1.0
	WHEN COALESCE(round(schools_6_10 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.75
	WHEN COALESCE(round(schools_3_5 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.50
	WHEN COALESCE(round(schools_1_2 * 100::numeric / total_schools::numeric, 1), 0::numeric) > 0 then 0.25
	WHEN COALESCE(round(((total_schools - COALESCE(visited_school_count, 0::bigint)) * 100 / total_schools)::numeric, 1)) > 0 then 0
	ELSE 0
	END as state_level_score,
case when schools_0>0  then 0 else 100 end as visit_score
from crc_school_report_mgmt_last_30_days ) as crc
left join 
(select a.*
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,e.school_management_type,e.total_schools_state from crc_school_report_mgmt_last_30_days as scl
left join 
(SELECT cluster_id,school_management_type,Count(DISTINCT crc_school_report_mgmt_last_30_days.school_id) AS schools_in_cluster FROM   crc_school_report_mgmt_last_30_days 
where school_management_type is not null group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,school_management_type,Count(DISTINCT crc_school_report_mgmt_last_30_days.school_id) AS schools_in_block FROM   crc_school_report_mgmt_last_30_days 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,school_management_type,Count(DISTINCT crc_school_report_mgmt_last_30_days.school_id) AS schools_in_district FROM   crc_school_report_mgmt_last_30_days 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select school_management_type,count(DISTINCT(school_id)) as total_schools_state from crc_school_report_mgmt_last_30_days 
where school_management_type is not null group by school_management_type)as e
on scl.school_management_type=e.school_management_type )as a)as a
on crc.school_id=a.school_id and crc.school_management_type=a.school_management_type)as a 
group by school_id,visit_score,cluster_id,block_id,district_id,total_schools_state,state_level_score,school_management_type) as res
on res1.school_id=res.school_id and res1.school_management_type=res.school_management_type where res1.school_management_type is not null) as crc_res) as crc
on basic.school_id=crc.school_id and basic.school_management_type=crc.school_management_type ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','row_to_json(infra.*) as school_infrastructure',
' left join
hc_infra_mgmt_school as infra
on basic.school_id=infra.school_id and basic.school_management_type=infra.school_management_type ',True,'school_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;


/* Function to create progress card views for overall and last 30 days at different levels with management  */

CREATE OR REPLACE FUNCTION progress_card_create_mgmt_views()
RETURNS text AS
$$
DECLARE
select_query_dist_mgmt text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''district_mgmt'' and time_period=''overall''  order by id)as d';   
select_cols_dist_mgmt text;
join_query_dist_mgmt text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''district_mgmt'' and time_period=''overall''  order by id)as d';
join_cols_dist_mgmt text;
district_view_mgmt text;
select_query_blk_mgmt text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''block_mgmt'' and time_period=''overall''  order by id)as d';   
select_cols_blk_mgmt text;
join_query_blk_mgmt text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''block_mgmt'' and time_period=''overall''  order by id)as d';
join_cols_blk_mgmt text;
block_view_mgmt text;
select_query_cst_mgmt text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''cluster_mgmt'' and time_period=''overall''  order by id)as d';   
select_cols_cst_mgmt text;
join_query_cst_mgmt text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''cluster_mgmt'' and time_period=''overall''  order by id)as d';
join_cols_cst_mgmt text;
cluster_view_mgmt text;
select_query_scl_mgmt text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''school_mgmt'' and time_period=''overall''  order by id)as d';   
select_cols_scl_mgmt text;
join_query_scl_mgmt text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''school_mgmt'' and time_period=''overall''  order by id)as d';
join_cols_scl_mgmt text;
school_view_mgmt text;

select_query_dist_mgmt_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''district_mgmt'' and time_period=''last30''  order by id)as d';   
select_cols_dist_mgmt_last30 text;
join_query_dist_mgmt_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''district_mgmt'' and time_period=''last30''  order by id)as d';
join_cols_dist_mgmt_last30 text;
district_view_mgmt_last30 text;
select_query_blk_mgmt_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''block_mgmt'' and time_period=''last30''  order by id)as d';   
select_cols_blk_mgmt_last30 text;
join_query_blk_mgmt_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''block_mgmt'' and time_period=''last30''  order by id)as d';
join_cols_blk_mgmt_last30 text;
block_view_mgmt_last30 text;
select_query_cst_mgmt_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''cluster_mgmt'' and time_period=''last30''  order by id)as d';   
select_cols_cst_mgmt_last30 text;
join_query_cst_mgmt_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''cluster_mgmt'' and time_period=''last30''  order by id)as d';
join_cols_cst_mgmt_last30 text;
cluster_view_mgmt_last30 text;
select_query_scl_mgmt_last30 text:='select string_agg(col,'','') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''school_mgmt'' and time_period=''last30''  order by id)as d';   
select_cols_scl_mgmt_last30 text;
join_query_scl_mgmt_last30 text:='select string_agg(col,'' '') from (select concat(join_query)as col from progress_card_config where status=''true'' and category=''school_mgmt'' and time_period=''last30''  order by id)as d';
join_cols_scl_mgmt_last30 text;
school_view_mgmt_last30 text;
BEGIN
Execute select_query_dist_mgmt into select_cols_dist_mgmt;
Execute join_query_dist_mgmt into join_cols_dist_mgmt;
Execute select_query_blk_mgmt into select_cols_blk_mgmt;
Execute join_query_blk_mgmt into join_cols_blk_mgmt;
Execute select_query_cst_mgmt into select_cols_cst_mgmt;
Execute join_query_cst_mgmt into join_cols_cst_mgmt;
Execute select_query_scl_mgmt into select_cols_scl_mgmt;
Execute join_query_scl_mgmt into join_cols_scl_mgmt;
Execute select_query_dist_mgmt_last30 into select_cols_dist_mgmt_last30;
Execute join_query_dist_mgmt_last30 into join_cols_dist_mgmt_last30;
Execute select_query_blk_mgmt_last30 into select_cols_blk_mgmt_last30;
Execute join_query_blk_mgmt_last30 into join_cols_blk_mgmt_last30;
Execute select_query_cst_mgmt_last30 into select_cols_cst_mgmt_last30;
Execute join_query_cst_mgmt_last30 into join_cols_cst_mgmt_last30;
Execute select_query_scl_mgmt_last30 into select_cols_scl_mgmt_last30;
Execute join_query_scl_mgmt_last30 into join_cols_scl_mgmt_last30;

district_view_mgmt='create or replace view progress_card_index_district_mgmt_overall as 
'||select_cols_dist_mgmt||' '||join_cols_dist_mgmt||';
';
Execute district_view_mgmt; 
block_view_mgmt='create or replace view progress_card_index_block_mgmt_overall as 
'||select_cols_blk_mgmt||' '||join_cols_blk_mgmt||';
';
Execute block_view_mgmt; 
cluster_view_mgmt='create or replace view progress_card_index_cluster_mgmt_overall as 
'||select_cols_cst_mgmt||' '||join_cols_cst_mgmt||';
';
Execute cluster_view_mgmt; 
school_view_mgmt='create or replace view progress_card_index_school_mgmt_overall as 
'||select_cols_scl_mgmt||' '||join_cols_scl_mgmt||';
';
Execute school_view_mgmt; 

district_view_mgmt_last30='create or replace view progress_card_index_district_mgmt_last30 as 
'||select_cols_dist_mgmt_last30||' '||join_cols_dist_mgmt_last30||';
';
Execute district_view_mgmt_last30; 
block_view_mgmt_last30='create or replace view progress_card_index_block_mgmt_last30 as 
'||select_cols_blk_mgmt_last30||' '||join_cols_blk_mgmt_last30||';
';
Execute block_view_mgmt_last30; 
cluster_view_mgmt_last30='create or replace view progress_card_index_cluster_mgmt_last30 as 
'||select_cols_cst_mgmt_last30||' '||join_cols_cst_mgmt_last30||';
';
Execute cluster_view_mgmt_last30; 
school_view_mgmt_last30='create or replace view progress_card_index_school_mgmt_last30 as 
'||select_cols_scl_mgmt_last30||' '||join_cols_scl_mgmt_last30||';
';
Execute school_view_mgmt_last30; 
return 0;
END;
$$LANGUAGE plpgsql;


/* progress Card index overall state */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic',' select ''basic_details'' as data_source,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as data
)as basic_details ',' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance',' union
(select ''student_attendance''as data,row_to_json(state_attendance)::text from
  (select hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date,
 sum(case when data.attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''average'')  and data.attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''good'') and data.attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_overall as data, hc_student_attendance_state_overall hsao
   group by hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date)as state_attendance) ',
   ' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat',' union
(select ''student_semester'' as data,
  row_to_json(sat)::text from (select hc_sat_state_overall.school_performance as performance,hc_sat_state_overall.grade_wise_performance,hc_sat_state_overall.students_count,hc_sat_state_overall.total_schools,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_all) as data, hc_sat_state_overall) as sat)',
' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise',' union
(select ''udise''as data,row_to_json(udise)::text from (select * from hc_udise_state)as udise) ',
' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat',' union
(select ''pat_performance''as data,
  row_to_json(pat)::text from (select hc_pat_state_overall.*,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_all) as data, hc_pat_state_overall) as pat) ',
' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc',' union
SELECT ''crc_visit''::text AS data_source, row_to_json(crc.*)::text FROM (
select res.*,cast((100 - (res.schools_0)) as float) as visit_score from
(
select total_schools,total_crc_visits,visited_school_count,not_visited_school_count,
(SELECT round(NULLIF((((count(DISTINCT school_hierarchy_details.school_id))::double precision / NULLIF((count(DISTINCT school_hierarchy_details.cluster_id))::double precision, (0)::double precision)))::numeric, (1)::numeric)) AS no_of_schools_per_crc FROM school_hierarchy_details) as no_of_schools_per_crc,
( SELECT min(a.visit_date) AS min FROM ( SELECT crc_inspection_trans.visit_date,
(date_part(''month''::text, crc_inspection_trans.visit_date))::text AS month,
(date_part(''year''::text, crc_inspection_trans.visit_date))::text AS year
FROM crc_inspection_trans) a WHERE ((a.year IN ( SELECT "substring"(min_year.monthyear, 1, 4) AS year
FROM ( SELECT min(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
FROM crc_visits_frequency) min_year)) AND (a.month IN ( SELECT "substring"(min_month.monthyear, 6) AS month
FROM ( SELECT min(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
FROM crc_visits_frequency) min_month)))) AS data_from_date,
( SELECT max(a.visit_date) AS max
FROM ( SELECT crc_inspection_trans.visit_date,
(date_part(''month''::text, crc_inspection_trans.visit_date))::text AS month,
(date_part(''year''::text, crc_inspection_trans.visit_date))::text AS year
FROM crc_inspection_trans) a
          WHERE ((a.year IN ( SELECT "substring"(max_year.monthyear, 1, 4) AS year
                   FROM ( SELECT max(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
                           FROM crc_visits_frequency) max_year)) AND (a.month IN ( SELECT "substring"(max_month.monthyear, 6) AS month
                   FROM ( SELECT max(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
                           FROM crc_visits_frequency) max_month)))) AS data_upto_date,
COALESCE(round(((schools_0 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_0,
    COALESCE(round(((schools_1_2 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_1_2,
    COALESCE(round(((schools_3_5 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_3_5,
    COALESCE(round(((schools_6_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_6_10,
    COALESCE(round(((schools_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_10
from (
SELECT  sum(hc_crc_school.total_schools) AS total_schools,
sum(hc_crc_school.total_crc_visits) AS total_crc_visits,
            sum(hc_crc_school.visited_school_count) AS visited_school_count,
            sum(hc_crc_school.not_visited_school_count) AS not_visited_school_count,
                    sum(
                        CASE
                            WHEN (hc_crc_school.schools_0 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_0,
                    sum(
                        CASE
                            WHEN (hc_crc_school.schools_1_2 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_1_2,
                    sum(
                        CASE
                            WHEN (hc_crc_school.schools_3_5 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_3_5,
                    sum(
                        CASE
                            WHEN (hc_crc_school.schools_6_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_6_10,
                    sum(
                        CASE
                            WHEN (hc_crc_school.schools_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_10
                   FROM hc_crc_school) as spd) as res
				   ) crc ',
' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra',' union
(select ''school_infrastructure''as data,row_to_json(infra)::text from (select * from hc_infra_state)as infra) ',
' ',True,'state','overall')
on conflict on constraint progress_card_config_pkey do nothing;


/* progress Card index last 30 days state */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic',' select ''basic_details'' as data_source,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as data
)as basic_details ',' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance',' union
(select ''student_attendance''as data,row_to_json(state_attendance)::text from
  (select hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date,
 sum(case when data.attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''average'')  and data.attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''good'') and data.attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when data.attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from hc_student_attendance_school_last_30_days as data, hc_student_attendance_state_last30 hsao
   group by hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date)as state_attendance) ',
   ' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat',' union
(select ''student_semester'' as data,
  row_to_json(sat)::text from (select hc_sat_state_last30.school_performance as performance,hc_sat_state_last30.grade_wise_performance,hc_sat_state_last30.students_count,hc_sat_state_last30.total_schools,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from semester_exam_school_last30) as data, hc_sat_state_last30) as sat)',
' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise',' union
(select ''udise''as data,row_to_json(udise)::text from (select * from hc_udise_state)as udise) ',
' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat',' union
(select ''pat_performance'' as data,
  row_to_json(pat)::text from (select hc_pat_state_last30.*,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from periodic_exam_school_last30) as data, hc_pat_state_last30) as pat) ',
' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc',' union
SELECT ''crc_visit''::text AS data_source,
    row_to_json(crc.*)::text AS "values"
   FROM (select res.*,cast((100 - (res.schools_0)) as float) as visit_score from
(
select
total_schools,total_crc_visits,visited_school_count,not_visited_school_count,(SELECT round(NULLIF((((count(DISTINCT school_hierarchy_details.school_id))::double precision / NULLIF((count(DISTINCT school_hierarchy_details.cluster_id))::double precision, (0)::double precision)))::numeric, (1)::numeric)) AS no_of_schools_per_crc FROM school_hierarchy_details) as no_of_schools_per_crc,
( SELECT to_char(min(days_in_period.day)::timestamp with time zone, ''DD-MM-YYYY''::text) AS data_from_date
           FROM ( SELECT generate_series(now()::date - ''30 days''::interval, (now()::date - ''30 days''::interval)::date::timestamp without time zone, ''30 days''::interval)::date AS day) days_in_period) AS data_from_date,
( SELECT to_char(max(days_in_period.day)::timestamp with time zone, ''DD-MM-YYYY''::text) AS data_upto_date
           FROM ( SELECT generate_series(now()::date - ''30 days''::interval, (now()::date - ''1 day''::interval)::date::timestamp without time zone, ''1 day''::interval)::date AS day) days_in_period) AS data_upto_date,
COALESCE(round(((schools_0 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_0,
    COALESCE(round(((schools_1_2 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_1_2,
    COALESCE(round(((schools_3_5 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_3_5,
    COALESCE(round(((schools_6_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_6_10,
    COALESCE(round(((schools_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_10
from (
SELECT  sum(crc_school_report_last_30_days.total_schools) AS total_schools,
sum(crc_school_report_last_30_days.total_crc_visits) AS total_crc_visits,
            sum(crc_school_report_last_30_days.visited_school_count) AS visited_school_count,
            sum(crc_school_report_last_30_days.not_visited_school_count) AS not_visited_school_count,
                    sum(
                        CASE
                            WHEN (crc_school_report_last_30_days.schools_0 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_0,
                    sum(
                        CASE
                            WHEN (crc_school_report_last_30_days.schools_1_2 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_1_2,
                    sum(
                        CASE
                            WHEN (crc_school_report_last_30_days.schools_3_5 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_3_5,
                    sum(
                        CASE
                            WHEN (crc_school_report_last_30_days.schools_6_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_6_10,
                    sum(
                        CASE
                            WHEN (crc_school_report_last_30_days.schools_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_10
                   FROM crc_school_report_last_30_days) as spd)as res ) crc ',
' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;


insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra',' union
(select ''school_infrastructure''as data,row_to_json(infra)::text from (select * from hc_infra_state)as infra) ',
' ',True,'state','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* Function to create progress card state level view for last30 */

create or replace function progress_card_index_state()
RETURNS text AS
$$
DECLARE
udise_query text:= 'select string_agg(''cast(avg(''||lower(column_name)||'')as int)as ''||lower(column_name),'','')
   from udise_config where status = ''1'' and type=''indice''';
udise_cols text ;

infra_query text:= 
'select concat(''cast(sum(''||string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value'',''+'')||
  '')/10 as int) as average_value,'',''cast((sum(''||string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value'',''+'')||
'')/10)*100/sum(total_schools_data_received)as int) as average_percent,
  '',string_agg(''sum(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value)as ''
  ||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value ,''||''cast(sum(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||
  ''_value)*100/sum(total_schools_data_received)as int) as ''
  ||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','',''))
    from infrastructure_master where status = true';
infra_atf_query text:=
'select ''(select json_agg(areas_to_focus)as areas_to_focus  from 
 	(select array_remove(array[''||string_agg(''case when cast(sum(''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value)*100/sum(total_schools_data_received)as int)<30 then ''''''||
 case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
''],''''0'''')as areas_to_focus from hc_infra_school)as infra)'' 
from infrastructure_master where status = true order by 1';   

infra_cols text;
infra_atf_cols text;
infra_atf text;
create_infra_view text;
create_udise_view text;
create_state_view text;
create_state_view_last30 text;

select_query_state text:='select string_agg(col,'' '') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''state'' and time_period=''overall''  order by id)as d';   
select_cols_state text;

select_query_state_last30 text:='select string_agg(col,'' '') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''state'' and time_period=''last30''  order by id)as d';   
select_cols_state_last30 text;

BEGIN
if EXISTS (select * from progress_card_config where status='True' and data_source='infra')  then
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_infra_view = 'create or replace view hc_infra_state as
(select ''school_infrastructure''as data,row_to_json(infra)::text 
 from (select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''average'')  and infra_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''good'') and infra_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
 from hc_infra_school)as infra) ;';
Execute create_infra_view;  

END if;
Execute udise_query into udise_cols;

create_udise_view = ' create or replace view hc_udise_state as 
select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent
   from udise_school_score;';

Execute create_udise_view;
Execute select_query_state into select_cols_state;
create_state_view='create or replace view progress_card_index_state as '||select_cols_state||'';
Execute create_state_view; 

Execute select_query_state_last30 into select_cols_state_last30;
create_state_view_last30='create or replace view progress_card_index_state_last30 as '||select_cols_state_last30||'';

Execute create_state_view_last30; 
return 0;
END;
$$LANGUAGE plpgsql;

/* progress Card index mgmt overall state */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic',' select ''basic_details'' as data_source,school_management_type,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students,school_management_type from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and shd.school_management_type IS NOT NULL
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,shd.school_management_type) as data group by school_management_type)as basic_details
 ',' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance',' union
(select ''student_attendance'' as data,school_management_type,row_to_json(state_attendance)::text from
  (select hsamo.attendance,hsamo.students_count,hsamo.total_schools,hsamo.data_from_date,hsamo.data_upto_date,
  hsamo.school_management_type,poor,average,good,excellent
from (select
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
from hc_student_attendance_school_mgmt_overall hsao group by school_management_type) as data
left join hc_student_attendance_state_mgmt_overall hsamo on 
hsamo.school_management_type=data.school_management_type)as state_attendance) ',
   ' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat',' union
(select ''student_semester'' as data,school_management_type,
  row_to_json(sat)::text from (select hs.school_performance as performance,hs.grade_wise_performance,hs.school_management_type,hs.students_count,hs.total_schools,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
   from hc_semester_exam_school_mgmt_all where school_management_type is not null group by school_management_type) as data left join hc_sat_state_mgmt_overall hs on data.school_management_type=hs.school_management_type) as sat)
 ',' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise',' union
(select ''udise''as data,school_management_type,row_to_json(udise)::text from (select * from hc_udise_state_mgmt where school_management_type is not null)as udise)  ',
' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat',' union
(select ''pat_performance'' as data,school_management_type,
  row_to_json(pat)::text from (select hs.*,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
   from hc_periodic_exam_school_mgmt_all where school_management_type is not null group by school_management_type) as data left join hc_pat_state_mgmt_overall hs on data.school_management_type=hs.school_management_type) as pat)
 ',' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','  union
SELECT ''crc_visit''::text AS data_source,school_management_type, row_to_json(crc.*)::text FROM (
select res.*,cast((100 - (res.schools_0)) as float) as visit_score from
(
select total_schools,total_crc_visits,visited_school_count,not_visited_school_count,
(SELECT round(NULLIF((((count(DISTINCT school_hierarchy_details.school_id))::double precision / NULLIF((count(DISTINCT school_hierarchy_details.cluster_id))::double precision, (0)::double precision)))::numeric, (1)::numeric)) AS no_of_schools_per_crc FROM school_hierarchy_details) as no_of_schools_per_crc,
( SELECT min(a.visit_date) AS min FROM ( SELECT crc_inspection_trans.visit_date,
(date_part(''month''::text, crc_inspection_trans.visit_date))::text AS month,
(date_part(''year''::text, crc_inspection_trans.visit_date))::text AS year
FROM crc_inspection_trans) a WHERE ((a.year IN ( SELECT "substring"(min_year.monthyear, 1, 4) AS year
FROM ( SELECT min(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
FROM crc_visits_frequency) min_year)) AND (a.month IN ( SELECT "substring"(min_month.monthyear, 6) AS month
FROM ( SELECT min(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
FROM crc_visits_frequency) min_month)))) AS data_from_date,
( SELECT max(a.visit_date) AS max
FROM ( SELECT crc_inspection_trans.visit_date,
(date_part(''month''::text, crc_inspection_trans.visit_date))::text AS month,
(date_part(''year''::text, crc_inspection_trans.visit_date))::text AS year
FROM crc_inspection_trans) a
          WHERE ((a.year IN ( SELECT "substring"(max_year.monthyear, 1, 4) AS year
                   FROM ( SELECT max(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
                           FROM crc_visits_frequency) max_year)) AND (a.month IN ( SELECT "substring"(max_month.monthyear, 6) AS month
                   FROM ( SELECT max(concat(crc_visits_frequency.year, ''-'', crc_visits_frequency.month)) AS monthyear
                           FROM crc_visits_frequency) max_month)))) AS data_upto_date,
COALESCE(round(((schools_0 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_0,
    COALESCE(round(((schools_1_2 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_1_2,
    COALESCE(round(((schools_3_5 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_3_5,
    COALESCE(round(((schools_6_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_6_10,
    COALESCE(round(((schools_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_10,school_management_type
from (
SELECT  sum(total_schools) AS total_schools,
sum(total_crc_visits) AS total_crc_visits,
            sum(visited_school_count) AS visited_school_count,
            sum(not_visited_school_count) AS not_visited_school_count,
                    sum(
                        CASE
                            WHEN (schools_0 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_0,
                    sum(
                        CASE
                            WHEN (schools_1_2 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_1_2,
                    sum(
                        CASE
                            WHEN (schools_3_5 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_3_5,
                    sum(
                        CASE
                            WHEN (schools_6_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_6_10,
                    sum(
                        CASE
                            WHEN (schools_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_10,school_management_type
                   FROM crc_school_mgmt_all where school_management_type is not null group by school_management_type) as spd) as res
				   ) crc ',
' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra',' union
(select ''school_infrastructure''as data,school_management_type,row_to_json(infra)::text from (select * from hc_infra_state_mgmt where school_management_type is not null)as infra) ',
' ',True,'state_mgmt','overall')
on conflict on constraint progress_card_config_pkey do nothing;

/* progress Card index mgmt last30 state */

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('basic',' select ''basic_details'' as data_source,school_management_type,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students,school_management_type from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and shd.school_management_type IS NOT NULL
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,shd.school_management_type) as data where school_management_type is not null group by school_management_type)as basic_details
 ',' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('attendance',' union
(select ''student_attendance'' as data,school_management_type,row_to_json(state_attendance)::text from
  (select hsamo.attendance,hsamo.students_count,hsamo.total_schools,hsamo.data_from_date,hsamo.data_upto_date,
  hsamo.school_management_type,poor,average,good,excellent
from (select
 sum(case when attendance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''average'')  and attendance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''good'') and attendance<(select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when attendance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
from hc_student_attendance_school_mgmt_last_30_days hsao where school_management_type is not null group by school_management_type) as data
left join hc_student_attendance_state_mgmt_last30 hsamo on 
hsamo.school_management_type=data.school_management_type)as state_attendance) ',
   ' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('sat',' union
(select ''student_semester'' as data,school_management_type,
  row_to_json(sat)::text from (select hs.school_performance as performance,hs.grade_wise_performance,hs.school_management_type,hs.students_count,hs.total_schools,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
   from hc_semester_exam_school_mgmt_last30 where school_management_type is not null group by school_management_type) as data left join hc_sat_state_mgmt_last30 hs on data.school_management_type=hs.school_management_type) as sat) ',
' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('udise',' union
(select ''udise''as data,school_management_type,row_to_json(udise)::text from (select * from hc_udise_state_mgmt)as udise)  ',
' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('pat',' union
(select ''pat_performance'' as data,school_management_type,
  row_to_json(pat)::text from (select hs.*,poor,average,good,excellent
from
(select sum(case when school_performance < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''average'')  and school_performance<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''good'') and school_performance< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when school_performance >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
   from hc_periodic_exam_school_mgmt_last30 where school_management_type is not null group by school_management_type) as data left join hc_pat_state_mgmt_last30 hs on data.school_management_type=hs.school_management_type) as pat) ',
' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('crc','  union
SELECT ''crc_visit''::text AS data_source,school_management_type,
    row_to_json(crc.*)::text AS "values"
   FROM (select res.*,cast((100 - (res.schools_0)) as float) as visit_score from
(
select
total_schools,total_crc_visits,visited_school_count,not_visited_school_count,(SELECT round(NULLIF((((count(DISTINCT school_hierarchy_details.school_id))::double precision / NULLIF((count(DISTINCT school_hierarchy_details.cluster_id))::double precision, (0)::double precision)))::numeric, (1)::numeric)) AS no_of_schools_per_crc FROM school_hierarchy_details) as no_of_schools_per_crc,
( SELECT to_char(min(days_in_period.day)::timestamp with time zone, ''DD-MM-YYYY''::text) AS data_from_date
           FROM ( SELECT generate_series(now()::date - ''30 days''::interval, (now()::date - ''30 days''::interval)::date::timestamp without time zone, ''30 days''::interval)::date AS day) days_in_period) AS data_from_date,
( SELECT to_char(max(days_in_period.day)::timestamp with time zone, ''DD-MM-YYYY''::text) AS data_upto_date
           FROM ( SELECT generate_series(now()::date - ''30 days''::interval, (now()::date - ''1 day''::interval)::date::timestamp without time zone, ''1 day''::interval)::date AS day) days_in_period) AS data_upto_date,
COALESCE(round(((schools_0 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_0,
    COALESCE(round(((schools_1_2 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_1_2,
    COALESCE(round(((schools_3_5 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_3_5,
    COALESCE(round(((schools_6_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_6_10,
    COALESCE(round(((schools_10 * (100)::numeric) / (total_schools)::numeric), 1), (0)::numeric) AS schools_10,school_management_type
from (
SELECT  sum(total_schools) AS total_schools,
sum(total_crc_visits) AS total_crc_visits,
            sum(visited_school_count) AS visited_school_count,
            sum(not_visited_school_count) AS not_visited_school_count,
                    sum(
                        CASE
                            WHEN (schools_0 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_0,
                    sum(
                        CASE
                            WHEN (schools_1_2 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_1_2,
                    sum(
                        CASE
                            WHEN (schools_3_5 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_3_5,
                    sum(
                        CASE
                            WHEN (schools_6_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_6_10,
                    sum(
                        CASE
                            WHEN (schools_10 > (0)::numeric) THEN 1
                            ELSE 0
                        END) AS schools_10,school_management_type
                   FROM crc_school_report_mgmt_last_30_days where school_management_type is not null group by school_management_type) as spd)as res ) crc ',
' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

insert into progress_card_config(data_source,select_query,join_query,status,category,time_period) values('infra','  union
(select ''school_infrastructure''as data,school_management_type,row_to_json(infra)::text from (select * from hc_infra_state_mgmt where school_management_type is not null)as infra) ',
' ',True,'state_mgmt','last30')
on conflict on constraint progress_card_config_pkey do nothing;

/* progress Card index overall state mgmt */

create or replace function progress_card_index_state_mgmt()
RETURNS text AS
$$
DECLARE
udise_query text:= 'select string_agg(''cast(avg(''||lower(column_name)||'')as int)as ''||lower(column_name),'','')
   from udise_config where status = ''1'' and type=''indice''';
udise_cols text ;
infra_query text:= 
'select concat(''cast(sum(''||string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value'',''+'')||
  '')/10 as int) as average_value,'',''cast((sum(''||string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value'',''+'')||
'')/10)*100/sum(total_schools_data_received)as int) as average_percent,
  '',string_agg(''sum(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value)as ''
  ||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value ,''||''cast(sum(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||
  ''_value)*100/sum(total_schools_data_received)as int) as ''
  ||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','',''))
    from infrastructure_master where status = true';
infra_atf_query text:=
'select ''(select json_agg(areas_to_focus)as areas_to_focus  from 
 	(select array_remove(array[''||string_agg(''case when cast(sum(''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value)*100/sum(total_schools_data_received)as int)<30 then ''''''||
 case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
''],''''0'''')as areas_to_focus from hc_infra_school)as infra)'' 
from infrastructure_master where status = true order by 1';   
infra_cols text;
infra_atf_cols text;
infra_atf text;
create_infra_view text;
create_udise_view text;
create_state_view text;
create_state_view_last30 text;

select_query_state text:='select string_agg(col,'' '') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''state_mgmt'' and time_period=''overall''  order by id)as d';   
select_cols_state text;
select_query_state_last30 text:='select string_agg(col,'' '') from (select concat(select_query)as col from progress_card_config where status=''true'' and category=''state_mgmt'' and time_period=''last30''  order by id)as d';   
select_cols_state_lat30 text;

BEGIN
Execute udise_query into udise_cols;

if EXISTS (select * from progress_card_config where status='True' and data_source='infra')  then
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_infra_view = 'create or replace view hc_infra_state_mgmt as
(select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''average'')  and infra_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''good'') and infra_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when infra_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
 from hc_infra_mgmt_school group by school_management_type) ;';
Execute create_infra_view;  
END if;

create_udise_view = ' create or replace view hc_udise_state_mgmt as 
(select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score < (select value_to from progress_card_category_config where categories=''poor'') then 1 else 0 end)as poor,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''average'')  and infrastructure_score<(select value_to from progress_card_category_config where categories=''average'') then 1 else 0 end)as average,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''good'') and infrastructure_score< (select value_to from progress_card_category_config where categories=''good'') then 1 else 0 end)as good,
 sum(case when Infrastructure_score >= (select value_from from progress_card_category_config where categories=''excellent'') then 1 else 0 end)as excellent,school_management_type
   from udise_school_mgt_score group by school_management_type) ';

Execute create_udise_view;
Execute select_query_state into select_cols_state;
create_state_view=
'create or replace view progress_card_index_state_mgmt_overall as '||select_cols_state||'';

Execute create_state_view; 
Execute select_query_state_last30 into select_cols_state_lat30;
create_state_view_last30=
'create or replace view progress_card_index_state_mgmt_last30 as '||select_cols_state_lat30||'';

Execute create_state_view_last30; 

return 0;
END;
$$LANGUAGE plpgsql;


update progress_card_config set status= true where lower(data_source) in (select lower(template) from nifi_template_info where status=true);
update progress_card_config set status= false where lower(data_source) in (select lower(template) from nifi_template_info where status=false);

select progress_card_create_views();
select progress_card_create_mgmt_views();
select progress_card_index_state();
select progress_card_index_state_mgmt();

