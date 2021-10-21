/* Drop views */

drop view if exists crc_trans_to_aggregate_with_date cascade;
drop view if exists hc_crc_school cascade;
drop view if exists hc_crc_cluster cascade;
drop view if exists hc_crc_block cascade;
drop view if exists hc_crc_district cascade;
drop view if exists crc_school_mgmt_all cascade;

/* overall */
/*crc - school */

create or replace view hc_crc_school as
select b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.school_id,b.school_name,b.visit_score,b.state_level_score,
(select to_char(min(monthyear),'DD-MM-YYYY')as data_from_date from(select distinct (concat(year, '-', month)||'-01')::date as monthyear from crc_visits_frequency)as d) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date,
b.total_schools,b.total_crc_visits,b.visited_school_count,b.not_visited_school_count,b.schools_0,b.schools_1_2,b.schools_3_5,b.schools_6_10,b.schools_10 ,b.no_of_schools_per_crc,b.visit_percent_per_school,
( ( Rank()
             over (
               PARTITION BY b.cluster_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || sum(b.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY b.block_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || sum(b.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY b.district_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || sum(b.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         ||  sum(b.total_schools_state)) AS school_level_rank_within_the_state
		 from 
(select res.district_id,res.district_name,res.block_id,res.block_name,res.cluster_id,res.cluster_name,res.school_id,res.school_name,res.total_schools,res.total_crc_visits,res.visited_school_count,res.not_visited_school_count,
res.schools_0,res.schools_1_2,res.schools_3_5,res.schools_6_10,res.schools_10 ,res.no_of_schools_per_crc,res.visit_percent_per_school,schools_in_cluster,schools_in_block,schools_in_district,
case when res.schools_0>0  then 0 else 100 end as visit_score,res.state_level_score,b.total_schools_state
from
(select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,
initcap(spd.school_name) as school_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,
coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
CASE 
	WHEN COALESCE(round(spd.schools_10 * 100::numeric / spd.total_schools::numeric, 1), 0::numeric) > 0 then 1.0
	WHEN COALESCE(round(spd.schools_6_10 * 100::numeric / spd.total_schools::numeric, 1), 0::numeric) > 0 then 0.75
	WHEN COALESCE(round(spd.schools_3_5 * 100::numeric / spd.total_schools::numeric, 1), 0::numeric) > 0 then 0.50
	WHEN COALESCE(round(spd.schools_1_2 * 100::numeric / spd.total_schools::numeric, 1), 0::numeric) > 0 then 0.25
	WHEN COALESCE(round(((spd.total_schools - COALESCE(scl_v.visited_school_count, 0::bigint)) * 100 / spd.total_schools)::numeric, 1)) > 0 then 0
	ELSE 0
	END as state_level_score
from (
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,
  count(distinct school_id) as total_schools,
round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
    from school_hierarchy_details  where cluster_name is not null and block_name is not null
    and school_name is not null and district_name is not null
    group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name) s left join
(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,
case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,
case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,
case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,
case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10
from crc_visits_frequency
where visit_count>0 and cluster_name is not null
group by school_id) d group by school_id) t on s.school_id=t.schl_id) spd
left join
(select school_id,count(distinct(school_id))as visited_school_count from crc_visits_frequency
  where visit_count>0  and cluster_name is not null group by school_id)as scl_v
on spd.school_id=scl_v.school_id) as res
left join
(select  distinct a.*,(select count(DISTINCT(school_id)) from school_hierarchy_details 
where school_name is not null and cluster_name is not null )as total_schools_state 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from school_hierarchy_details  as  scl
left join 
(SELECT cluster_id,Count(DISTINCT school_hierarchy_details.school_id) AS schools_in_cluster FROM school_hierarchy_details 
where school_name is not null and cluster_name is not null  group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT school_hierarchy_details.school_id) AS schools_in_block FROM   school_hierarchy_details 
where school_name is not null and cluster_name is not null  group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT school_hierarchy_details.school_id) AS schools_in_district FROM   school_hierarchy_details 
where school_name is not null and cluster_name is not null  group by district_id) as d
on scl.district_id=d.district_id)as a)as b
on res.school_id=b.school_id) as b 
group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,visit_score,data_from_date,data_upto_date,total_schools,total_crc_visits,
visited_school_count,not_visited_school_count,schools_0,schools_1_2,schools_3_5,schools_6_10,schools_10 ,no_of_schools_per_crc,visit_percent_per_school,state_level_score,schools_in_cluster,schools_in_block,
schools_in_district,total_schools_state;

/* crc - cluster */

create or replace view hc_crc_cluster as
select 
b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.visit_score,
(select to_char(min(monthyear),'DD-MM-YYYY')as data_from_date from(select distinct (concat(year, '-', month)||'-01')::date as monthyear from crc_visits_frequency)as d) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date,b.total_schools,b.total_crc_visits,b.visited_school_count,b.not_visited_school_count,b.schools_0,b.schools_1_2,b.schools_3_5,b.schools_6_10,b.schools_10 ,b.no_of_schools_per_crc,b.visit_percent_per_school,b.clusters_in_block,b.clusters_in_district,
b.total_clusters,
( ( Rank()
             over (
               PARTITION BY b.block_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || b.clusters_in_block ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY b.district_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || b.clusters_in_district ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         ||  b.total_clusters) AS cluster_level_rank_within_the_state,
case when visit_score>0 then 
coalesce(1-round(( Rank()
             over (
               ORDER BY b.visit_score DESC) / (b.total_clusters*1.0)),2)) else 0 end AS state_level_score
		 from 
(select res.district_id,res.district_name,res.block_id,res.block_name,res.cluster_id,res.cluster_name,res.total_schools,res.total_crc_visits,res.visited_school_count,
res.not_visited_school_count,res.schools_0,res.schools_1_2,res.schools_3_5,res.schools_6_10,res.schools_10 ,res.no_of_schools_per_crc,res.visit_percent_per_school,b.clusters_in_block,b.clusters_in_district,
b.total_clusters,
round(COALESCE(100 - schools_0 ,0) ,2) as visit_score 
from

(select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school
from (
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name) s 
left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select cluster_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from hc_crc_school where  cluster_name is not null
group by cluster_id) d group by cluster_id) t on s.cluster_id=t.clt_id) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count from crc_visits_frequency 
    where visit_count>0  and cluster_name is not null group by cluster_id)as scl_v
on spd.cluster_id=scl_v.cluster_id ) as res
left join
(select a.*,(select count(DISTINCT(cluster_id)) from school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from school_hierarchy_details 
 as scl
left join
(SELECT block_id,Count(DISTINCT school_hierarchy_details.cluster_id) AS clusters_in_block FROM   school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999 group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT school_hierarchy_details.cluster_id) AS clusters_in_district FROM   school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999 group by district_id) as d
on scl.district_id=d.district_id)as a)as b
on res.cluster_id=b.cluster_id) as b   group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,visit_score,total_clusters,data_from_date,data_upto_date,total_schools,total_crc_visits,
visited_school_count,not_visited_school_count,schools_0,schools_1_2,schools_3_5,schools_6_10,schools_10 ,no_of_schools_per_crc,visit_percent_per_school,clusters_in_block,clusters_in_district,
total_clusters;

/* crc - block */
create or replace view hc_crc_block as
select b.district_id,b.district_name,b.block_id,b.block_name,b.visit_score,
(select to_char(min(monthyear),'DD-MM-YYYY')as data_from_date from(select distinct (concat(year, '-', month)||'-01')::date as monthyear from crc_visits_frequency)as d) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date,
total_schools,b.total_crc_visits,b.visited_school_count,b.not_visited_school_count,b.schools_0,b.schools_1_2,b.schools_3_5,b.schools_6_10,b.schools_10 ,b.no_of_schools_per_crc,b.visit_percent_per_school,
b.blocks_in_district,
b.total_blocks,
( ( Rank()
             over (
               PARTITION BY b.district_id
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || b.blocks_in_district ) AS block_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         ||  b.total_blocks) AS block_level_rank_within_the_state,
case when visit_score>0 then 
coalesce(1-round(( Rank()
             over (
               ORDER BY b.visit_score DESC) / (b.total_blocks*1.0)),2)) else 0 end AS state_level_score
		 from 
(select res.district_id,res.district_name,res.block_id,res.block_name,res.total_schools,res.total_crc_visits,res.visited_school_count,res.not_visited_school_count,res.schools_0,res.schools_1_2,
res.schools_3_5,res.schools_6_10,res.schools_10 ,res.no_of_schools_per_crc,res.visit_percent_per_school,b.blocks_in_district,
b.total_blocks,
round(COALESCE(100 - schools_0 ,0) ,2) as visit_score 
from
(select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score
from (
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
     group by district_id,district_name,block_id,block_name) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from hc_crc_school where  cluster_name is not null
group by block_id) d group by block_id) t on s.block_id=t.blk_id) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count from crc_visits_frequency 
    where visit_count>0  and cluster_name is not null group by block_id)as scl_v
on spd.block_id=scl_v.block_id ) as res
left join
(select a.*,(select count(DISTINCT(block_id)) from  school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from school_hierarchy_details as scl
left join
(SELECT district_id,Count(DISTINCT school_hierarchy_details.block_id) AS blocks_in_district FROM     school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999 group by district_id) as d
on scl.district_id=d.district_id)as a)as b
on res.block_id=b.block_id) as b group by district_id,district_name,block_id,block_name,visit_score,total_blocks,data_from_date,data_upto_date,total_schools,total_crc_visits,
visited_school_count,not_visited_school_count,schools_0,schools_1_2,schools_3_5,schools_6_10,schools_10 ,no_of_schools_per_crc,visit_percent_per_school,blocks_in_district,
total_blocks;

/* crc - district */

create or replace view hc_crc_district as
select b.district_id,b.district_name,b.visit_score,
(select to_char(min(monthyear),'DD-MM-YYYY')as data_from_date from(select distinct (concat(year, '-', month)||'-01')::date as monthyear from crc_visits_frequency)as d) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date,
b.total_schools,b.total_crc_visits,b.visited_school_count,b.not_visited_school_count,b.schools_0,b.schools_1_2,b.schools_3_5,b.schools_6_10,b.schools_10 ,b.no_of_schools_per_crc,b.visit_percent_per_school,
( ( Rank()
             over (
               ORDER BY b.visit_score DESC)
           || ' out of ' :: text )
         || (select count(distinct(district_id)) 
from school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999) ) AS district_level_rank_within_the_state,
case when visit_score>0 then 
coalesce(1-round(( Rank()
             over (
               ORDER BY b.visit_score DESC) / ((select count(distinct(district_id)) 
from school_hierarchy_details 
where school_name is not null and cluster_name is not null and district_id!=9999)*1.0)),2)) else 0 end AS state_level_score
		 from 
(select res.district_id,res.district_name,res.total_schools,res.total_crc_visits,res.visited_school_count,res.not_visited_school_count,res.schools_0,res.schools_1_2,
res.schools_3_5,res.schools_6_10,res.schools_10 ,res.no_of_schools_per_crc,res.visit_percent_per_school,
round(COALESCE(100 - schools_0 ,0) ,2) as visit_score 
from
(select 
spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score
 from 
((select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
    group by district_id,district_name) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10 from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from hc_crc_school where  cluster_name is not null
group by district_id)as d group by district_id)as t  on s.district_id=t.dist_id)as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count from crc_visits_frequency 
    where visit_count>0 and  cluster_name is not null group by district_id)as scl_v
on spd.district_id=scl_v.district_id) as res)as b
group by district_id,district_name,visit_score,data_from_date,data_upto_date,total_schools,total_crc_visits,
visited_school_count,not_visited_school_count,schools_0,schools_1_2,schools_3_5,schools_6_10,schools_10 ,no_of_schools_per_crc,visit_percent_per_school;


/* CRC time selection */

create or replace view crc_trans_to_aggregate_with_date as 
select  a.school_id,INITCAP(b.school_name)as school_name,b.district_id,INITCAP(b.district_name)as district_name,b.block_id,
  INITCAP(b.block_name)as block_name,b.cluster_id,
  INITCAP(b.cluster_name)as cluster_name ,INITCAP(b.crc_name)as crc_name,
  sum(cast((case when in_school_location='true' or in_school_location='t' then 1 else 0 end ) as int)) as visit_count,
  sum(cast((case when in_school_location is null or in_school_location ='f' or in_school_location='false' then 1 else 0 end ) as int)) as missed_visit_count,
      a.month,
    a.year,a.visit_date,
  now() as created_on,
  now() as updated_on,b.school_management_type,b.school_category
  from (select crc_inspection_id as inspection_id, clt.school_id,month,year,bool_or(in_school_location) as in_school_location,visit_date
 from crc_inspection_trans cit inner join crc_location_trans clt on clt.inspection_id=cit.crc_inspection_id
 group by crc_inspection_id, clt.school_id,month,year) as a left join school_hierarchy_details as b on a.school_id=b.school_id
  where a.school_id<>0 and a.inspection_id<>0 and b.school_id<>9999 and b.cluster_name is not null and b.district_name is not null and b.block_name is not null and b.school_name is not null and visit_date is NOT NULL
  group by a.school_id,b.school_name,b.district_id,b.district_name,b.block_id, b.block_name,b.cluster_id,b.cluster_name,b.crc_name,a.month,a.year,a.visit_date,b.school_management_type,b.school_category
  order by school_id desc ;

/* CRC - time selection */
/* school */

CREATE OR REPLACE FUNCTION crc_time_selection_school(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_school_report_'||period||' as
select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,
initcap(spd.school_name) as school_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,
coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
from (
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,
  count(distinct school_id) as total_schools,
round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
    from school_hierarchy_details  where cluster_name is not null and block_name is not null
    and school_name is not null and district_name is not null
    group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name) s left join
(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,
case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,
case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,
case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,
case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10
from crc_trans_to_aggregate_with_date
where visit_count>0 and cluster_name is not null and school_id!=9999 and visit_date is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date))
group by school_id) d group by school_id) t on s.school_id=t.schl_id) spd
left join
(select school_id,count(distinct(school_id))as visited_school_count from crc_trans_to_aggregate_with_date
  where visit_count>0  and cluster_name is not null and school_id!=9999 and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) group by school_id)as scl_v
on spd.school_id=scl_v.school_id where spd.school_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_school_report_last_1_day cascade;
drop view if exists crc_school_report_last_7_days cascade;
drop view if exists crc_school_report_last_30_days cascade;

select crc_time_selection_school('last_1_day');
select crc_time_selection_school('last_7_days');
select crc_time_selection_school('last_30_days');


/* cluster */

CREATE OR REPLACE FUNCTION crc_time_selection_cluster(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_cluster_report_'||period||' as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)

from (
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name) s left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select cluster_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from crc_school_report_'||period||' where  cluster_name is not null 
group by cluster_id) d group by cluster_id) t on s.cluster_id=t.clt_id) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count from crc_trans_to_aggregate_with_date
    where visit_count>0 and cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) group by cluster_id)as scl_v
on spd.cluster_id=scl_v.cluster_id where spd.cluster_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_cluster_report_last_1_day;
drop view if exists crc_cluster_report_last_7_days;
drop view if exists crc_cluster_report_last_30_days;

select crc_time_selection_cluster('last_1_day');
select crc_time_selection_cluster('last_7_days');
select crc_time_selection_cluster('last_30_days');


/* block */

CREATE OR REPLACE FUNCTION crc_time_selection_block(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_block_report_'||period||' as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
from (
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
     group by district_id,district_name,block_id,block_name) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from crc_school_report_'||period||' where  cluster_name is not null
group by block_id) d group by block_id) t on s.block_id=t.blk_id) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count from crc_trans_to_aggregate_with_date
    where visit_count>0  and cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) group by block_id)as scl_v
on spd.block_id=scl_v.block_id  where spd.block_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_block_report_last_1_day;
drop view if exists crc_block_report_last_7_days;
drop view if exists crc_block_report_last_30_days;

select crc_time_selection_block('last_1_day');
select crc_time_selection_block('last_7_days');
select crc_time_selection_block('last_30_days');

/* district */

CREATE OR REPLACE FUNCTION crc_time_selection_district(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_district_report_'||period||' as
select spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
 from 
((select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
    group by district_id,district_name) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10 from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from crc_school_report_'||period||' where  cluster_name is not null
group by district_id)as d group by district_id)as t  on s.district_id=t.dist_id)as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count from crc_trans_to_aggregate_with_date 
    where visit_count>0 and  cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) group by district_id)as scl_v
on spd.district_id=scl_v.district_id  where spd.district_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_district_report_last_1_day;
drop view if exists crc_district_report_last_7_days;
drop view if exists crc_district_report_last_30_days;


select crc_time_selection_district('last_1_day');
select crc_time_selection_district('last_7_days');
select crc_time_selection_district('last_30_days');

/* CRC month and year queries */

/* school */
	create or replace view crc_school_report_year_month as
	select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,
	initcap(spd.school_name) as school_name,spd.total_schools,
	coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
	(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
	coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,
	coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,
	coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
	coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
	coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
	coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,spd.month,
spd.academic_year 
	from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.school_id,s.school_name,s.total_schools,s.no_of_schools_per_crc,t.schl_id,
	t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
	((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,
   count(distinct school_id) as total_schools,
 round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
		from school_hierarchy_details  where cluster_name is not null and block_name is not null
		and school_name is not null and district_name is not null
		group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name) b )  s
left join
	(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,
	sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month
	from
	(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,
	case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,
	case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,
	case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,
	case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month
	from crc_visits_frequency
	where visit_count>0 and cluster_name is not null and school_id!=9999 
	group by school_id,academic_year,month) d group by school_id,academic_year,month) t on s.school_id=t.schl_id and s.academic_year=t.academic_year and s.month=t.month) spd
	left join
	(select school_id,count(distinct(school_id))as visited_school_count,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency
	  where visit_count>0  and cluster_name is not null and school_id!=9999  group by school_id,academic_year,month)as scl_v
	on spd.school_id=scl_v.school_id and spd.academic_year=scl_v.academic_year and spd.month=scl_v.month where spd.school_id!=9999 and spd.academic_year is not null and spd.month is not null;

/* cluster */
create or replace view crc_cluster_report_year_month as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.month,spd.academic_year
from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name) b ) s left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month
from
(select cluster_id,academic_year,month,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10
 from crc_school_report_year_month where  cluster_name is not null 
group by cluster_id,academic_year,month) d group by cluster_id,academic_year,month) t on s.cluster_id=t.clt_id and s.month=t.month and s.academic_year=t.academic_year) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency
    where visit_count>0 and cluster_name is not null  group by cluster_id,academic_year,month)as scl_v
on spd.cluster_id=scl_v.cluster_id and spd.month=scl_v.month and spd.academic_year=scl_v.academic_year where spd.cluster_id!=9999 and spd.academic_year is not null and spd.month is not null;

/* block */
create or replace view crc_block_report_year_month as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.academic_year,spd.month
from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
	((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
     group by district_id,district_name,block_id,block_name) b ) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,academic_year,month
 from crc_school_report_year_month where  cluster_name is not null
group by block_id,academic_year,month) d group by block_id,academic_year,month) t on s.block_id=t.blk_id and s.academic_year=t.academic_year and s.month=t.month) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency
    where visit_count>0  and cluster_name is not null  group by block_id,academic_year,month)as scl_v
on spd.block_id=scl_v.block_id and spd.academic_year=scl_v.academic_year and spd.month=scl_v.month where spd.block_id!=9999;

/* district */
create or replace view crc_district_report_year_month as
select spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.month,
spd.academic_year
 from (select s.month,s.academic_year,s.district_id,s.district_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
	((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc 
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null
    group by district_id,district_name) b ) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,academic_year,month
 from crc_school_report_year_month where  cluster_name is not null
group by district_id,academic_year,month)as d group by district_id,academic_year,month)as t  on s.district_id=t.dist_id and s.academic_year=t.academic_year and s.month=t.month) as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency 
    where visit_count>0 and  cluster_name is not null group by district_id,academic_year,month)as scl_v
on spd.district_id=scl_v.district_id and spd.month=scl_v.month and spd.academic_year=scl_v.academic_year  where spd.district_id!=9999;

/* CRC - Management overall*/

/* crc school all*/

create or replace view crc_school_mgmt_all as
select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,
initcap(spd.school_name) as school_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,
coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,spd.school_management_type,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date
from (
select s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.school_id,s.school_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,
  count(distinct school_id) as total_schools,
round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
    from school_hierarchy_details  where cluster_name is not null and block_name is not null
    and school_name is not null and district_name is not null and school_management_type is not null 
    group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,school_management_type) s left join
(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,
case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,
case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,
case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,
case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10,school_management_type
from crc_visits_frequency
where visit_count>0 and cluster_name is not null and school_id!=9999
and school_management_type is not null 
group by school_id,school_management_type) d group by school_id,school_management_type) t on 
s.school_id=t.schl_id and s.school_management_type=t.school_management_type) spd
left join
(select school_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_visits_frequency
  where visit_count>0  and cluster_name is not null  and school_management_type is not null 
  group by school_id,school_management_type)as scl_v
on spd.school_id=scl_v.school_id and spd.school_management_type=scl_v.school_management_type where spd.school_id!=9999 and spd.school_management_type is not null;

/* crc -cluster all*/

create or replace view crc_cluster_mgmt_all  as 
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,spd.school_management_type,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date
from (select s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_management_type) s left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select cluster_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_mgmt_all where  cluster_name is not null
group by cluster_id,school_management_type) d group by cluster_id,school_management_type) t on s.cluster_id=t.clt_id and s.school_management_type=t.school_management_type) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_visits_frequency
    where visit_count>0 and cluster_name is not null 
and school_management_type is not null  group by cluster_id,school_management_type)as scl_v
on spd.cluster_id=scl_v.cluster_id and spd.school_management_type=scl_v.school_management_type where spd.cluster_id!=9999 and spd.school_management_type is not null;

/* crc - block all */

create or replace view crc_block_mgmt_all as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.school_management_type,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date
from (select s.district_id,s.district_name,s.block_id,s.block_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null   
	group by district_id,district_name,block_id,block_name,school_management_type) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_mgmt_all where  cluster_name is not null  and school_management_type is not null 
group by block_id,school_management_type) d group by block_id,school_management_type) t on s.block_id=t.blk_id and s.school_management_type=t.school_management_type) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_visits_frequency
    where visit_count>0  and cluster_name is not null 
	and school_management_type is not null group by block_id,school_management_type)as scl_v
on spd.block_id=scl_v.block_id and spd.school_management_type=scl_v.school_management_type where spd.block_id!=9999 and spd.school_management_type is not null;

/* crc - District all */

create or replace view crc_district_mgmt_all as
select spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.school_management_type,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
(select to_char((((max(concat(year, '-', month))||'-01')::date+'1month'::interval)::date-'1day'::interval)::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_upto_date
 from 
(select s.district_id,s.district_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type 
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
    group by district_id,district_name,school_management_type) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_mgmt_all where  cluster_name is not null and school_management_type is not null 
group by district_id,school_management_type)as d group by district_id,school_management_type)as t  on s.district_id=t.dist_id and s.school_management_type=t.school_management_type )as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_visits_frequency 
    where visit_count>0 and  cluster_name is not null 
 and school_management_type is not null group by district_id,school_management_type)as scl_v
on spd.district_id=scl_v.district_id and spd.school_management_type=scl_v.school_management_type where spd.district_id!=9999 and spd.school_management_type is not null;

/* Time selection with management */
/* school */

CREATE OR REPLACE FUNCTION crc_time_selection_school_mgmt(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_school_report_mgmt_'||period||' as
select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,
initcap(spd.school_name) as school_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,
coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
spd.school_management_type
from (
select s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.school_id,s.school_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10 from
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,
  count(distinct school_id) as total_schools,
round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
    from school_hierarchy_details  where cluster_name is not null and block_name is not null
    and school_name is not null and district_name is not null and school_management_type is not null 
    group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,school_management_type) s left join
(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,
case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,
case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,
case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,
case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10,school_management_type
from crc_trans_to_aggregate_with_date
where visit_count>0 and cluster_name is not null and school_id!=9999 and visit_date is not null 
and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date))  and school_management_type is not null 
group by school_id,school_management_type) d group by school_id,school_management_type) t on 
s.school_id=t.schl_id and s.school_management_type=t.school_management_type) spd
left join
(select school_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_trans_to_aggregate_with_date
  where visit_count>0  and cluster_name is not null and school_id!=9999 and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) 
  and school_management_type is not null 
  group by school_id,school_management_type)as scl_v
on spd.school_id=scl_v.school_id and spd.school_management_type=scl_v.school_management_type where spd.school_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;


drop view if exists crc_school_report_mgmt_last_1_day cascade;
drop view if exists crc_school_report_mgmt_last_7_days cascade;
drop view if exists crc_school_report_mgmt_last_30_days cascade;

select crc_time_selection_school_mgmt('last_1_day');
select crc_time_selection_school_mgmt('last_7_days');
select crc_time_selection_school_mgmt('last_30_days');

/* cluster */

CREATE OR REPLACE FUNCTION crc_time_selection_cluster_mgmt(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_cluster_report_mgmt_'||period||' as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
spd.school_management_type
from (select s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_management_type) s left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select cluster_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_report_mgmt_'||period||' where  cluster_name is not null
group by cluster_id,school_management_type) d group by cluster_id,school_management_type) t on s.cluster_id=t.clt_id
and s.school_management_type=t.school_management_type) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_trans_to_aggregate_with_date
    where visit_count>0 and cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date))
and school_management_type is not null  group by cluster_id,school_management_type)as scl_v
on spd.cluster_id=scl_v.cluster_id and spd.school_management_type=scl_v.school_management_type where spd.cluster_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;


drop view if exists crc_cluster_report_mgmt_last_1_day cascade;
drop view if exists crc_cluster_report_mgmt_last_7_days cascade;
drop view if exists crc_cluster_report_mgmt_last_30_days cascade;

select crc_time_selection_cluster_mgmt('last_1_day');
select crc_time_selection_cluster_mgmt('last_7_days');
select crc_time_selection_cluster_mgmt('last_30_days');


/* block */
CREATE OR REPLACE FUNCTION crc_time_selection_block_mgmt(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_block_report_mgmt_'||period||' as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period)
,spd.school_management_type
from (select s.district_id,s.district_name,s.block_id,s.block_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null   group by district_id,district_name,block_id,block_name,school_management_type,school_management_type) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_report_mgmt_'||period||' where  cluster_name is not null  and school_management_type is not null 
group by block_id,school_management_type) d group by block_id,school_management_type) t on s.block_id=t.blk_id and 
s.school_management_type=t.school_management_type) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_trans_to_aggregate_with_date
    where visit_count>0  and cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) 
	and school_management_type is not null group by block_id,school_management_type)as scl_v
on spd.block_id=scl_v.block_id and spd.school_management_type=scl_v.school_management_type where spd.block_id!=9999 and spd.school_management_type is not null';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_block_report_mgmt_last_1_day;
drop view if exists crc_block_report_mgmt_last_7_days;
drop view if exists crc_block_report_mgmt_last_30_days;

select crc_time_selection_block_mgmt('last_1_day');
select crc_time_selection_block_mgmt('last_7_days');
select crc_time_selection_block_mgmt('last_30_days');

/* district */

CREATE OR REPLACE FUNCTION crc_time_selection_district_mgmt(period text)
RETURNS text AS
$$
DECLARE
crc_res text;
number_of_days text;
BEGIN

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

crc_res:='create or replace view crc_district_report_mgmt_'||period||' as
select spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,
(select to_char(min(days_in_period.day),''DD-MM-YYYY'') as data_from_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-'''||number_of_days||'''::interval)::date,'''||number_of_days||'''::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),''DD-MM-YYYY'') as data_upto_date from (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date) as day) as days_in_period),
spd.school_management_type
 from 
(select s.district_id,s.district_name,s.total_schools,s.no_of_schools_per_crc,s.school_management_type,
t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,t.schools_0 from
(select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type 
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
    group by district_id,district_name,school_management_type) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,school_management_type from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_report_mgmt_'||period||' where  cluster_name is not null and school_management_type is not null 
group by district_id,school_management_type)as d group by district_id,school_management_type)as t  on s.district_id=t.dist_id and s.school_management_type=t.school_management_type )as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count,school_management_type from crc_trans_to_aggregate_with_date 
    where visit_count>0 and  cluster_name is not null and visit_date in (select (generate_series(''now()''::date-'''||number_of_days||'''::interval,(''now()''::date-''1day''::interval)::date,''1day''::interval)::date)) 
 and school_management_type is not null group by district_id,school_management_type)as scl_v
on spd.district_id=scl_v.district_id and spd.school_management_type=scl_v.school_management_type where spd.district_id!=9999';

EXECUTE crc_res;
return 0;
END;
$$ LANGUAGE plpgsql;

drop view if exists crc_district_report_mgmt_last_1_day;
drop view if exists crc_district_report_mgmt_last_7_days;
drop view if exists crc_district_report_mgmt_last_30_days;


select crc_time_selection_district_mgmt('last_1_day');
select crc_time_selection_district_mgmt('last_7_days');
select crc_time_selection_district_mgmt('last_30_days');


/* year and month queries with management */

/* school */

	create or replace view crc_school_report_mgmt_year_month as

	select spd.district_id,initcap(spd.district_name)as district_name,spd.block_id,initcap(spd.block_name) as block_name,spd.cluster_id,initcap(spd.cluster_name)as cluster_name,spd.school_id,

	initcap(spd.school_name) as school_name,spd.total_schools,

	coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,

	(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,

	coalesce(round((spd.total_schools-coalesce(visited_school_count,0))*100/spd.total_schools,1),0) as schools_0,

	coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,

	coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,

	coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,

	coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,

	coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,spd.month,

spd.academic_year,spd.school_management_type

	from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.school_id,s.school_name,s.total_schools,s.no_of_schools_per_crc,t.schl_id,

	t.total_visits,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,s.school_management_type from

	((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  

cross join

(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,

   count(distinct school_id) as total_schools,

 round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type

		from school_hierarchy_details  where cluster_name is not null and block_name is not null

		and school_name is not null and district_name is not null and school_management_type is not null

		group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,school_management_type) b )  s

left join

	(select school_id as schl_id, sum(school_count) as total_visits,sum(schools_1_2) as schools_1_2,

	sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month,school_management_type

	from

	(select school_id,sum(visit_count)as visit_count,count(distinct(school_id))*sum(visit_count) as school_count,

	case when sum(visit_count) between 1 and 2 then count(distinct(school_id)) end as schools_1_2,

	case when sum(visit_count) between 3 and 5 then count(distinct(school_id)) end as schools_3_5,

	case when sum(visit_count) between 6 and 10 then count(distinct(school_id)) end as schools_6_10,

	case when sum(visit_count) >10 then count(distinct(school_id)) end as schools_10,

case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month,school_management_type

	from crc_visits_frequency

	where visit_count>0 and cluster_name is not null and school_id!=9999 and school_management_type is not null

	group by school_id,academic_year,month,school_management_type) d group by school_id,academic_year,month,school_management_type) t 
	on s.school_id=t.schl_id and s.academic_year=t.academic_year and s.month=t.month and s.school_management_type=t.school_management_type) spd

	left join

	(select school_id,count(distinct(school_id))as visited_school_count,
	case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month,school_management_type
	from crc_visits_frequency
    where visit_count>0  and cluster_name is not null and school_id!=9999 and school_management_type is not null group by school_id,academic_year,month,school_management_type)as scl_v

	on spd.school_id=scl_v.school_id and spd.academic_year=scl_v.academic_year and spd.month=scl_v.month and spd.school_management_type=scl_v.school_management_type 
	where spd.school_id!=9999 and spd.academic_year is not null and spd.month is not null and spd.school_management_type is not null;
	
	
/* cluster */

create or replace view crc_cluster_report_mgmt_year_month as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.cluster_id,
initcap(spd.cluster_name)as cluster_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,
coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.month,spd.academic_year,spd.school_management_type 
from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.cluster_id,s.cluster_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,s.school_management_type  from
((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select district_id,district_name,block_id,block_name,cluster_id,cluster_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc,school_management_type 
     from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type  is not null
      group by district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_management_type) b ) s left join 
(select cluster_id as clt_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month,school_management_type
from
(select cluster_id,academic_year,month,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,school_management_type
 from crc_school_report_mgmt_year_month where  cluster_name is not null and school_management_type  is not null
group by cluster_id,academic_year,month,school_management_type) d group by cluster_id,academic_year,month,school_management_type) t 
on s.cluster_id=t.clt_id and s.month=t.month and s.academic_year=t.academic_year and s.school_management_type=t.school_management_type) spd
left join 
(select cluster_id,count(distinct(school_id))as visited_school_count,school_management_type,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency
    where visit_count>0 and cluster_name is not null and school_management_type is not null  group by cluster_id,academic_year,month,school_management_type)as scl_v
on spd.cluster_id=scl_v.cluster_id and spd.month=scl_v.month and spd.academic_year=scl_v.academic_year and spd.school_management_type=scl_v.school_management_type
where spd.cluster_id!=9999 and spd.academic_year is not null and spd.month is not null and spd.school_management_type is not null;


/* block */

create or replace view crc_block_report_mgmt_year_month as
select spd.district_id,initcap(spd.district_name) as district_name,spd.block_id,initcap(spd.block_name)as block_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.academic_year,spd.month,spd.school_management_type 
from (select s.month,s.academic_year,s.district_id,s.district_name,s.block_id,s.block_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,s.school_management_type from
	((select distinct month,case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select district_id,district_name,block_id,block_name,count(distinct school_id) as total_schools,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc ,school_management_type
    from school_hierarchy_details  where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
     group by district_id,district_name,block_id,block_name,school_management_type) b ) s left join 
(select block_id as blk_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month,school_management_type
from
(select block_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,academic_year,month,school_management_type
 from crc_school_report_mgmt_year_month where  cluster_name is not null and school_management_type is not null
group by block_id,academic_year,month,school_management_type) d group by block_id,academic_year,month,school_management_type) t 
on s.block_id=t.blk_id and s.academic_year=t.academic_year and s.month=t.month and s.school_management_type=t.school_management_type) spd
left join 
(select block_id,count(distinct(school_id))as visited_school_count,school_management_type,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency
    where visit_count>0  and cluster_name is not null and school_management_type is not null  group by block_id,academic_year,month,school_management_type)as scl_v
on spd.block_id=scl_v.block_id and spd.academic_year=scl_v.academic_year and spd.month=scl_v.month and spd.school_management_type=scl_v.school_management_type 
where spd.block_id!=9999 and spd.school_management_type is not null;

/* district */

create or replace view crc_district_report_mgmt_year_month as
select spd.district_id,initcap(spd.district_name)as district_name,spd.total_schools,
coalesce(spd.total_visits,0) total_crc_visits,coalesce(visited_school_count,0) as visited_school_count,
(spd.total_schools-coalesce(visited_school_count,0)) as not_visited_school_count,
coalesce(round(spd.schools_0*100/spd.total_schools,1),0) as schools_0,
coalesce(round(spd.schools_1_2*100/spd.total_schools,1),0) as schools_1_2,coalesce(round(spd.schools_3_5*100/spd.total_schools,1),0) as schools_3_5,coalesce(round(spd.schools_6_10*100/spd.total_schools,1),0) as schools_6_10,
coalesce(round(spd.schools_10*100/spd.total_schools,1),0) as schools_10,spd.no_of_schools_per_crc,
coalesce(round(cast(cast(spd.total_visits as float)/cast(spd.total_schools as float) as numeric),1),0) as visit_percent_per_school,
COALESCE(1-round(spd.schools_0 ::numeric / spd.total_schools::numeric, 1), 0::numeric) AS state_level_score,spd.month,
spd.academic_year,spd.school_management_type
 from (select s.month,s.academic_year,s.district_id,s.district_name,s.total_schools,s.no_of_schools_per_crc,
	t.total_visits,t.schools_0,t.schools_1_2,t.schools_3_5,t.schools_6_10,t.schools_10,s.school_management_type from
	((select distinct month,
	case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year from crc_visits_frequency) as a  
cross join
(select count(distinct school_id) as total_schools,district_id,district_name,
    round(cast(cast(count(distinct school_id) as float)/nullif(cast(count(distinct cluster_id) as float),0) as numeric),1) as no_of_schools_per_crc ,school_management_type
    from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and district_name is not null and school_management_type is not null
    group by district_id,district_name,school_management_type) b ) s left join 
(select district_id as dist_id, sum(school_count) as total_visits,sum(schools_0)as schools_0,sum(schools_1_2) as schools_1_2,
sum(schools_3_5) as schools_3_5,sum(schools_6_10) as schools_6_10,sum(schools_10) as schools_10,academic_year,month,school_management_type from
 (select district_id,sum(total_crc_visits)as school_count, 
sum(case when schools_0>0 then 1 else 0 end) as schools_0,
  sum(case when schools_1_2>0 then 1 else 0 end) as schools_1_2,
 sum(case when schools_3_5>0 then 1 else 0 end) as schools_3_5,
 sum(case when schools_6_10>0 then 1 else 0 end) as schools_6_10,
 sum(case when schools_10>0 then 1 else 0 end) as schools_10,academic_year,month,school_management_type
 from crc_school_report_mgmt_year_month where  cluster_name is not null and school_management_type is not null
group by district_id,academic_year,month,school_management_type)as d group by district_id,academic_year,month,school_management_type)as t 
on s.district_id=t.dist_id and s.academic_year=t.academic_year and s.month=t.month and s.school_management_type=t.school_management_type) as spd
left join 
(select district_id,count(distinct(school_id))as visited_school_count,school_management_type,
case when month in (6,7,8,9,10,11,12) then (year ||'-'|| substring(cast((year+1) as text),3,2)) else ((year-1) || '-' || substring(cast(year as text),3,2)) end as academic_year,month from crc_visits_frequency 
where visit_count>0 and  cluster_name is not null and school_management_type is not null group by district_id,academic_year,month,school_management_type)as scl_v
on spd.district_id=scl_v.district_id and spd.month=scl_v.month and spd.academic_year=scl_v.academic_year and spd.school_management_type=scl_v.school_management_type
 where spd.district_id!=9999 and spd.school_management_type is not null;
