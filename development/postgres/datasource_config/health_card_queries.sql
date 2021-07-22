/*Health card index*/

/*udise*/

create or replace view hc_udise_district as 
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_score as uds left join 
(select district_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by district_id)as usc
on uds.district_id= usc.district_id;

create or replace view hc_udise_block as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_block_score as uds left join 
(select block_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by block_id)as usc
on uds.block_id= usc.block_id;

create or replace view hc_udise_cluster as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_cluster_score as uds left join 
(select cluster_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by cluster_id)as usc
on uds.cluster_id= usc.cluster_id;

create or replace view hc_udise_school as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_school_score as uds left join 
(select udise_school_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by udise_school_id)as usc
on uds.udise_school_id= usc.udise_school_id;


/*crc*/

create or replace view hc_crc_school as
select b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.school_id,b.school_name,b.visit_score,b.state_level_score,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
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


create or replace view hc_crc_cluster as
select 
b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.visit_score,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
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


create or replace view hc_crc_block as
select b.district_id,b.district_name,b.block_id,b.block_name,b.visit_score,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
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


create or replace view hc_crc_district as
select b.district_id,b.district_name,b.visit_score,
(select to_char((min(concat(year, '-', month))||'-01')::date,'DD-MM-YYYY') as monthyear from crc_visits_frequency) as data_from_date,
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

/* pat queries */
/*periodic exam school last 30 days */

create or replace view hc_periodic_exam_school_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as district_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')  from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from periodic_exam_school_result group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days')
group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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

/* HC semester exam school overall*/

create or replace view hc_semester_exam_school_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as school_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from semester_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from semester_exam_school_result group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
school_id from
(select cast('Grade '||grade as text)as grade,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by grade,school_id)as a
group by school_id)as b
on a.school_id=b.school_id)as c
left join 
(
select school_id,jsonb_agg(subject_wise_performance)as subject_wise_performance from
(select school_id,
json_build_object(grade,json_object_agg(subject_name,percentage  order by subject_name))::jsonb as subject_wise_performance from
((select cast('Grade '||grade as text)as grade,cast(subject as text)as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by grade,subject,
school_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
school_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),1),1) as percentage
from semester_exam_school_result group by grade,
school_id order by grade desc,subject_name)) as a
group by school_id,grade)as d
group by school_id
)as d on c.school_id=d.school_id)as d
left join 
 (select a.school_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count where school_id in (select school_id from semester_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id )as b
 on d.school_id=b.school_id;

/* hc semester cluster last 30 days */

create or replace view hc_semester_exam_cluster_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
cluster_id from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by grade,subject,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
and exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id )as b
 on d.cluster_id=b.cluster_id;

/*hc semester exam cluster overall*/

create or replace view hc_semester_exam_cluster_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from semester_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from semester_exam_school_result group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
cluster_id from
(select cast('Grade '||grade as text)as grade,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
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
from semester_exam_school_result group by grade,subject,
cluster_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
cluster_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
cluster_id order by grade desc,subject_name)) as a
group by cluster_id,grade)as d
group by cluster_id
)as d on c.cluster_id=d.cluster_id)as d
left join 
 (select c.cluster_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.cluster_id )as b
 on  d.cluster_id=b.cluster_id;


/*hc semester exam block last 30 days*/

create or replace view hc_semester_exam_block_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
block_id from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by grade,subject,
block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
and exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id )as b
 on d.block_id=b.block_id;


/*hc semester exam block overall*/

create or replace view hc_semester_exam_block_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from semester_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from semester_exam_school_result group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
block_id from
(select cast('Grade '||grade as text)as grade,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
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
from semester_exam_school_result group by grade,subject,
block_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
block_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
block_id order by grade desc,subject_name)) as a
group by block_id,grade)as d
group by block_id
)as d on c.block_id=d.block_id)as d
left join 
 (select c.block_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count where school_id in (select school_id from semester_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.block_id )as b
 on  d.block_id=b.block_id;


/* hc semester exam district overall */

create or replace view hc_semester_exam_district_all as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')  from semester_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date)
from semester_exam_school_result group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
district_id from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
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
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,subject,
district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result group by grade,
district_id order by grade desc,subject_name))as b

group by district_id,grade)as d
group by district_id
)as d on c.district_id=d.district_id)as d
left join 
 (select c.district_id,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_code,school_id,student_uid
from semester_exam_stud_grade_count where school_id in (select school_id from semester_exam_school_result)
group by exam_code,school_id,student_uid) as a
left join (select exam_code,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_code=b.exam_code
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id )as b
 on d.district_id=b.district_id;

/* semester exam district last 30 days*/

create or replace view hc_semester_exam_district_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period)
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by 
district_id,district_name,district_latitude,district_longitude) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
district_id from
(select cast('Grade '||grade as text)as grade,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by grade,subject,
district_id order by grade desc,subject_name)
union
(select cast('Grade '||grade as text)as grade,'Grade Performance'as subject_name,
district_id,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from semester_exam_school_result 
where exam_code in (select exam_code from sat_date_range where date_range='last30days')
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
from semester_exam_result_trans where school_id in (select school_id from semester_exam_school_result)
and exam_code in (select exam_code from sat_date_range where date_range='last30days')
group by exam_id,school_id,student_uid) as a
left join (select exam_id,date_part('year',exam_date)::text as assessment_year from semester_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by c.district_id )as b
 on d.district_id=b.district_id;



/*----health card ----*/


/*--------------------------------------------------------------HEALTH CARD INDEX main views---------------------------------*/

/*Health card index school overall*/

create or replace view health_card_index_school_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as basic
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_school_overall as sad left join
(select school_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_overall group by school_id)as sac
on sad.school_id= sac.school_id) as b
left join(select usc.school_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_school_overall as sad left join
(select school_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.school_id=student_attendance.school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75,ped.grade_wise_performance from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester
 from semester_exam_school_all where semester=(select max(semester) from semester_exam_school_all))as ped left join
(select school_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_all 
   group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as b
left join(select usc.school_id,school_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester
from semester_exam_school_all)as ped left join
(select school_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=semester.school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from hc_udise_school as b
left join(select usc.udise_school_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.school_id=udise.udise_school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
 from hc_periodic_exam_school_all)as ped left join
(select school_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_all 
   group by school_id)as pes
on ped.school_id= pes.school_id) as b
left join(select usc.school_id,school_performance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
from hc_periodic_exam_school_all)as ped left join
(select school_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=pat.school_id
left join 
hc_crc_school as crc
on basic.school_id=crc.school_id
left join
hc_infra_school as infra
on basic.school_id=infra.school_id;


/*Health card index school last 30 days*/

create or replace view health_card_index_school_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as basic
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_school_last_30_days as sad left join
(select school_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_last_30_days group by school_id)as sac
on sad.school_id= sac.school_id) as b
left join(select usc.school_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_school_last_30_days as sad left join
(select school_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.school_id=student_attendance.school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75,ped.grade_wise_performance from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester
 from semester_exam_school_last30 where semester=(select max(semester) from semester_exam_school_last30))as ped left join
(select school_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_last30 
   group by school_id,semester)as pes
on ped.school_id= pes.school_id and ped.semester=pes.semester) as b
left join(select usc.school_id,school_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester
from semester_exam_school_last30)as ped left join
(select school_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=semester.school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from hc_udise_school as b
left join(select usc.udise_school_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.school_id=udise.udise_school_id
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date
 from hc_periodic_exam_school_last30 )as ped left join
(select school_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_last30 group by school_id)as pes
on ped.school_id= pes.school_id) as b
left join(select usc.school_id,school_performance,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance
 from hc_periodic_exam_school_last30 )as ped left join
(select school_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=pat.school_id
left join 
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
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.school_id=crc.school_id
left join
hc_infra_school as infra
on basic.school_id=infra.school_id;


/*Health card index cluster overall*/

create or replace view health_card_index_cluster_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name)as basic
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_overall as sad left join
(select cluster_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_overall  group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id
) as b
left join(select usc.cluster_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_overall as sad left join
(select cluster_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=student_attendance.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,semester 
 from semester_exam_cluster_all  where semester=(select max(semester) from semester_exam_cluster_all)
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_all group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,semester
 from semester_exam_cluster_all 
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=semester.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_cluster as b
left join(select usc.cluster_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.cluster_id=udise.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_all 
)as ped left join
(select cluster_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_all group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as b
left join(select usc.cluster_id,cluster_performance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_all 
)as ped left join
(select cluster_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=pat.cluster_id
left join 
hc_crc_cluster as crc
on basic.cluster_id=crc.cluster_id
left join
hc_infra_cluster as infra
on basic.cluster_id=infra.cluster_id;

/*Health card index cluster last 30 days*/

create or replace view health_card_index_cluster_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name)as basic
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_last_30_days as sad left join
(select cluster_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_last_30_days group by cluster_id)as sac
on sad.cluster_id= sac.cluster_id) as b
left join(select usc.cluster_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_last_30_days as sad left join
(select cluster_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=student_attendance.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,semester 
 from semester_exam_cluster_last30  where semester=(select max(semester) from semester_exam_cluster_last30)
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_last30 group by cluster_id,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,semester
 from semester_exam_cluster_last30 
)as ped left join
(select cluster_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=semester.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_cluster as b
left join(select usc.cluster_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.cluster_id=udise.cluster_id
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_last30)as ped left join
(select cluster_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_last30 group by cluster_id)as pes
on ped.cluster_id= pes.cluster_id) as b
left join(select usc.cluster_id,cluster_performance,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date
 from hc_periodic_exam_cluster_last30)as ped left join
(select cluster_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=pat.cluster_id
left join 
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
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.cluster_id=crc.cluster_id
left join
hc_infra_cluster as infra
on basic.cluster_id=infra.cluster_id;


/*Health card index block overall*/

create or replace view health_card_index_block_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name)as basic
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_overall as sad left join
(select block_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_overall  group by block_id)as sac
on sad.block_id= sac.block_id
) as b
left join(select usc.block_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_overall as sad left join
(select block_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.block_id=student_attendance.block_id
left join 
(
select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,semester
 from semester_exam_block_all where semester=(select max(semester) from semester_exam_block_all))as ped left join
(select block_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_all  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,semester
 from semester_exam_block_all 
)as ped left join
(select block_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
)as semester
on basic.block_id=semester.block_id
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_block as b
left join(select usc.block_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.block_id=udise.block_id
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_all )as ped left join
(select block_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from periodic_exam_school_all  group by block_id)as pes
on ped.block_id= pes.block_id) as b
left join(select usc.block_id,block_performance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_all 
)as ped left join
(select block_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.block_id=pat.block_id
left join 
hc_crc_block as crc
on basic.block_id=crc.block_id
left join
hc_infra_block as infra
on basic.block_id=infra.block_id;

/*Health card index block last 30 days*/

create or replace view health_card_index_block_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name)as basic
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_last_30_days as sad left join
(select block_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_last_30_days group by block_id)as sac
on sad.block_id= sac.block_id) as b
left join(select usc.block_id,attendance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_last_30_days as sad left join
(select block_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.block_id=student_attendance.block_id
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,semester
 from semester_exam_block_last30 where semester=(select max(semester) from semester_exam_block_last30))as ped left join
(select block_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_last30  group by block_id,semester)as pes
on ped.block_id= pes.block_id and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,semester
 from semester_exam_block_last30 
)as ped left join
(select block_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.block_id=semester.block_id
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_block as b

left join(select usc.block_id,infrastructure_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
on basic.block_id=udise.block_id
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_last30 )as ped left join
(select block_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_last30 group by block_id)as pes
on ped.block_id= pes.block_id) as b
left join(select usc.block_id,block_performance,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date
 from hc_periodic_exam_block_last30 
)as ped left join
(select block_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.block_id=pat.block_id
left join 
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
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.block_id=crc.block_id
left join
hc_infra_block as infra
on basic.block_id=infra.block_id;

/* Health card index district overall */


create or replace view health_card_index_district_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name)as basic
left join 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75,((rank () over ( order by attendance desc))||' out of '||(select count(distinct(district_id)) 
from hc_student_attendance_school_overall)) as district_level_rank_within_the_state,1-round(Rank() over (ORDER BY attendance DESC) 
/ coalesce(((select count(distinct(district_id)) from hc_student_attendance_school_overall)*1.0),1),1) as state_level_score
 from hc_student_attendance_district_overall as sad left join
(select district_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_overall group by district_id)as sac
on sad.district_id= sac.district_id
)as student_attendance
on basic.district_id=student_attendance.district_id
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,semester,
  ((rank () over (partition by semester order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from semester_exam_district_all)) as district_level_rank_within_the_state, 
1-round( Rank() over (partition by semester ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from semester_exam_district_all)*1.0),1),2) as state_level_score
 from semester_exam_district_all where semester=(select max(semester) from semester_exam_district_all))as ped left join
(select district_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_all group by district_id,semester)as pes
on ped.district_id= pes.district_id and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id
left join 
(select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_score as uds left join 
(select district_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by district_id)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,
  ((rank () over ( order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from hc_periodic_exam_district_all)) as district_level_rank_within_the_state,
 coalesce(1-round( Rank() over (ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from hc_periodic_exam_school_all)*1.0),1),2)) as state_level_score
 from hc_periodic_exam_district_all )as ped left join
(select district_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_all group by district_id)as pes
on ped.district_id= pes.district_id)as pat
on basic.district_id=pat.district_id
left join 
hc_crc_district as crc
on basic.district_id=crc.district_id
left join
hc_infra_district as infra
on basic.district_id=infra.district_id;


/* health card index district last 30 days */

create or replace view health_card_index_district_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name)as basic
left join 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75,((rank () over ( order by attendance desc))||' out of '||(select count(distinct(district_id)) 
from hc_semester_performance_district)) as district_level_rank_within_the_state,coalesce(1-round((Rank() over (ORDER BY attendance DESC) / ((select count(distinct(district_id)) from hc_semester_performance_district)*1.0)),2)) as state_level_score
 from hc_student_attendance_district_last_30_days as sad left join
(select district_id,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_last_30_days group by district_id)as sac
on sad.district_id= sac.district_id
)as student_attendance
on basic.district_id=student_attendance.district_id
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,semester,
  ((rank () over (partition by semester order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from semester_exam_district_last30)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by semester ORDER BY district_performance DESC) / ((select count(distinct(district_id)) from hc_semester_performance_district)*1.0)),2)) as state_level_score
 from semester_exam_district_last30 where semester=(select max(semester) from semester_exam_district_last30))as ped left join
(select district_id,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_last30 group by district_id,semester)as pes
on ped.district_id= pes.district_id and ped.semester=pes.semester
)as semester
on basic.district_id=semester.district_id
left join 
(select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_score as uds left join 
(select district_id,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score group by district_id)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,
  ((rank () over ( order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from hc_periodic_exam_district_last30)) as district_level_rank_within_the_state, coalesce(1-round(( Rank() over (ORDER BY district_performance DESC) / ((select count(distinct(district_id)) from hc_semester_performance_district)*1.0)),2)) as state_level_score
 from hc_periodic_exam_district_last30 )as ped left join
(select district_id,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_last30 group by district_id)as pes
on ped.district_id= pes.district_id)as pat
on basic.district_id=pat.district_id
left join 
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
           || ' out of ' :: text )
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
on basic.district_id=crc.district_id
left join
hc_infra_district as infra
on basic.district_id=infra.district_id;


 create or replace view hc_pat_state as
select d.*,b.total_schools,b.students_count from
(select a.*,b.grade_wise_performance from
(select academic_year,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance
from periodic_exam_school_result group by academic_year) as a
left join
(select academic_year,json_object_agg(grade,percentage) as grade_wise_performance from
(select academic_year,cast('Grade '||grade as text)as grade,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as percentage
from periodic_exam_school_result group by academic_year,grade)as a
group by academic_year)as b
on a.academic_year=b.academic_year)as d
left join
 (select academic_year,sum(students_count) as students_count,sum(total_schools) as total_schools from (select a.school_id,b.assessment_year as academic_year,
	count(distinct(student_uid)) as students_count,count(distinct(a.school_id)) as total_schools
from
(select exam_id,school_id,student_uid
from periodic_exam_result_trans where school_id in (select school_id from periodic_exam_school_result)
group by exam_id,school_id,student_uid) as a
left join (select exam_id,assessment_year from periodic_exam_mst) as b on a.exam_id=b.exam_id
left join school_hierarchy_details as c on a.school_id=c.school_id
group by a.school_id,b.assessment_year)as a group by academic_year
  )as b
 on d.academic_year=b.academic_year;

/*Health card state views */

create or replace view hc_pat_state_overall as
 select (select round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (0)::numeric)), 1) as school_performance
        from periodic_exam_school_result),
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
 select (select round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (1)::numeric)), 1) as school_performance
        from periodic_exam_school_result  where exam_code in (select exam_code from pat_date_range where date_range='last30days')),
        (select json_object_agg(a_1.grade, a_1.percentage) as grade_wise_performance
                   from ( select ('grade '::text || periodic_exam_school_result.grade) as grade,
                            round(((coalesce(sum(periodic_exam_school_result.obtained_marks), (0)::numeric) * 100.0) / coalesce(sum(periodic_exam_school_result.total_marks), (1)::numeric)), 1) as percentage
                           from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')
                          group by periodic_exam_school_result.grade) a_1),
        (select sum(students_count) as students_count from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days')),
        (select count(distinct school_id) as total_schools from periodic_exam_school_result where exam_code in (select exam_code from pat_date_range where date_range='last30days'));


create or replace view hc_student_attendance_state_overall as
SELECT Round(Sum(total_present)*100.0/Sum(total_students),1)AS Attendance,
Sum(students_count) AS students_count,Count(DISTINCT(school_id)) AS total_schools,
(select Data_from_date(Min(year),min(month))  from student_attendance_trans where year = (select min(year) from student_attendance_trans) group by year) as data_from_date,
(select   case when year=extract(year from now()) and month=extract(month from now()) then to_char(now(),'DD-MM-YYYY')   else Data_upto_date(year,month) end as data_upto_date 
from (select max(month) as month ,max(year) as year from student_attendance_trans where year = (select max(year) from student_attendance_trans)) as matt)
FROM student_attendance_agg_overall WHERE district_latitude > 0 AND district_longitude > 0 AND block_latitude > 0 AND block_longitude > 0 AND cluster_latitude > 0 AND cluster_longitude > 0 AND school_latitude >0 AND school_longitude >0 
AND school_name IS NOT NULL and cluster_name is NOT NULL AND block_name is NOT NULL AND district_name is NOT NULL and total_students>0;


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


/* pat queries */
/*periodic exam school last 30 days */

create or replace view hc_periodic_exam_school_mgmt_last30 as
select d.*,b.total_schools,b.students_count from
(select c.*,d.subject_wise_performance from
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select school_id,initcap(school_name)as school_name,cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,
district_id,initcap(district_name)as district_name,school_latitude,school_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as school_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where  school_management_type is not null
 group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_latitude,school_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and  school_management_type is not null
group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
cluster_id,initcap(cluster_name)as cluster_name,block_id,initcap(block_name)as block_name,district_id,
initcap(district_name)as district_name,cluster_latitude,cluster_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as cluster_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
cluster_id,cluster_name,block_id,block_name,district_id,district_name,cluster_latitude,cluster_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
block_id,initcap(block_name)as block_name,district_id,initcap(district_name)as district_name,block_latitude,block_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as block_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')   from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
block_id,block_name,district_id,district_name,block_latitude,block_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,
(select to_char(min(exam_date),'DD-MM-YYYY')  from periodic_exam_school_result) as data_from_date,
(select to_char(now(),'DD-MM-YYYY') as data_upto_date),school_management_type
from periodic_exam_school_result where school_management_type is not null group by 
district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
(select a.*,b.grade_wise_performance from
(select 
district_id,initcap(district_name)as district_name,district_latitude,district_longitude,
round(coalesce(sum(obtained_marks),0)*100.0/coalesce(sum(total_marks),0),1) as district_performance,
(select to_char(min(days_in_period.day),'DD-MM-YYYY') as data_from_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
(select to_char(max(days_in_period.day),'DD-MM-YYYY') as data_upto_date from (select (generate_series('now()'::date-'30days'::interval,('now()'::date-'1day'::interval)::date,'1day'::interval)::date) as day) as days_in_period),
school_management_type
from periodic_exam_school_result 
where exam_code in (select exam_code from pat_date_range where date_range='last30days') and school_management_type is not null
group by 
district_id,district_name,district_latitude,district_longitude,school_management_type) as a
left join 
(select json_object_agg(grade,percentage) as grade_wise_performance,
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
 


CREATE OR REPLACE FUNCTION infra_areas_to_focus_mgmt()
RETURNS text AS
$$
DECLARE
school_atf text:='select ''select school_id,school_management_type, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_mgt_view)  then ''''''||
 case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_school_table_mgt_view'' 
from infrastructure_master where status = true order by 1';
school_atf_value text; 
cluster_atf text:='select ''select cluster_id,school_management_type, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_mgt_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_cluster_table_mgt_view'' 
from infrastructure_master where status = true order by 1';
cluster_atf_value text; 
block_atf text:='select ''select block_id,school_management_type, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_mgt_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_block_table_mgt_view'' 
from infrastructure_master where status = true order by 1';
block_atf_value text; 
district_atf text:='select ''select district_id, school_management_type,array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_mgt_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_district_table_mgt_view'' 
from infrastructure_master where status = true order by 1';
district_atf_value text; 
query text;
BEGIN
Execute district_atf into district_atf_value;
Execute school_atf into school_atf_value;
Execute cluster_atf into cluster_atf_value;
Execute block_atf into block_atf_value;
IF school_atf <> '' THEN 
query='create or replace view infra_district_atf_mgmt as 
select district_id,school_management_type,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||district_atf_value||') as a;
create or replace view infra_school_atf_mgmt as 
select school_id,school_management_type,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||school_atf_value||') as a;
create or replace view infra_cluster_atf_mgmt as 
select cluster_id,school_management_type,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||cluster_atf_value||') as a;
create or replace view infra_block_atf_mgmt as 
select block_id,school_management_type,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||block_atf_value||') as a;';
Execute query; 
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_areas_to_focus_mgmt();

/*udise*/

create or replace view hc_udise_mgmt_district as 
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_mgt_score as uds left join 
(select district_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by district_id,school_management_type)as usc
on uds.district_id= usc.district_id and uds.school_management_type=usc.school_management_type;

create or replace view hc_udise_mgmt_block as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_block_mgt_score as uds left join 
(select block_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by block_id,school_management_type)as usc
on uds.block_id= usc.block_id and uds.school_management_type=usc.school_management_type;

create or replace view hc_udise_mgmt_cluster as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_cluster_mgt_score as uds left join 
(select cluster_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by cluster_id,school_management_type)as usc
on uds.cluster_id= usc.cluster_id and uds.school_management_type=usc.school_management_type;

create or replace view hc_udise_mgmt_school as  
select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_school_mgt_score as uds left join 
(select udise_school_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and Infrastructure_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and Infrastructure_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by udise_school_id,school_management_type)as usc
on uds.udise_school_id= usc.udise_school_id and uds.school_management_type=usc.school_management_type;



/*school - infra*/

create or replace view hc_infra_mgmt_school as
select b.*,atf.areas_to_focus,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_mgt_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
   from infra_school_table_mgt_view group by school_id,school_management_type)as ist
on idt.school_id= ist.school_id and idt.school_management_type=ist.school_management_type) as b
left join(select usc.school_id,infra_score,a.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,a.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (PARTITION BY a.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state, 
coalesce(1-round(( Rank()
             over (PARTITION BY a.school_management_type
               ORDER BY usc.infra_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_mgt_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
   from infra_school_table_mgt_view group by school_id,school_management_type)as ist
on idt.school_id= ist.school_id and idt.school_management_type=ist.school_management_type) as usc
left join
(select a.*
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district,d.school_management_type,e.total_schools from infra_school_table_mgt_view as scl
left join 
(SELECT cluster_id,school_management_type,Count(DISTINCT infra_school_table_mgt_view.school_id) AS schools_in_cluster FROM   infra_school_table_mgt_view 
where school_management_type is not null group by cluster_id,school_management_type) as c
on scl.cluster_id=c.cluster_id and scl.school_management_type=c.school_management_type
left join
(SELECT block_id,school_management_type,Count(DISTINCT infra_school_table_mgt_view.school_id) AS schools_in_block FROM   infra_school_table_mgt_view 
where school_management_type is not null group by block_id,school_management_type)as b
on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
left join 
(SELECT district_id,school_management_type,Count(DISTINCT infra_school_table_mgt_view.school_id) AS schools_in_district FROM   infra_school_table_mgt_view 
where school_management_type is not null group by district_id,school_management_type) as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join
(select school_management_type,count(DISTINCT(school_id)) as total_schools from infra_school_table_mgt_view where school_management_type is not null group by school_management_type)as e 
on scl.school_management_type=e.school_management_type)as a)as a
on usc.school_id=a.school_id  and usc.school_management_type=a.school_management_type
group by usc.school_id,infra_score,a.cluster_id,a.block_id,a.district_id,a.total_schools,a.school_management_type) as c
ON b.school_id = c.school_id  and b.school_management_type=c.school_management_type
left join infra_school_atf_mgmt as atf on b.school_id=atf.school_id and b.school_management_type=atf.school_management_type;

/*cluster*/
	create or replace view hc_infra_mgmt_cluster as
	select b.*,atf.areas_to_focus,c.cluster_level_rank_within_the_state,
	c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
	(select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
	infra_cluster_table_mgt_view as idt
	left join
	(select cluster_id,
	sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
	 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
	   from infra_school_table_mgt_view group by cluster_id,school_management_type)as ist
	on idt.cluster_id= ist.cluster_id and idt.school_management_type=ist.school_management_type) as b
	left join(select usc.cluster_id,infra_score,a.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.block_id,a.school_management_type
				   ORDER BY usc.infra_score DESC)
			   || ' out of ' :: text )
			 || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,a.school_management_type
				   ORDER BY usc.infra_score DESC)
			   || ' out of ' :: text )
			 || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
	( ( Rank()
				 over (PARTITION BY a.school_management_type
				   ORDER BY usc.infra_score DESC)
			   || ' out of ' :: text )
			 ||  a.total_clusters) AS cluster_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by a.school_management_type
				   ORDER BY usc.infra_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                           
	 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
	infra_cluster_table_mgt_view as idt
	left join
	(select cluster_id,
	 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
	 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
	   from infra_school_table_mgt_view group by cluster_id,school_management_type)as ist
	on idt.cluster_id= ist.cluster_id and idt.school_management_type=ist.school_management_type) as usc
	left join
	(select a.*
	from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id,d.school_management_type,e.total_clusters from infra_school_table_mgt_view as scl
	left join
	(SELECT block_id,Count(DISTINCT infra_school_table_mgt_view.cluster_id) AS clusters_in_block,school_management_type FROM   infra_school_table_mgt_view group by block_id,school_management_type)as b
	on scl.block_id=b.block_id and scl.school_management_type=b.school_management_type
	left join 
	(SELECT district_id,Count(DISTINCT infra_school_table_mgt_view.cluster_id) AS clusters_in_district,school_management_type FROM   infra_school_table_mgt_view group by district_id,school_management_type) as d
	on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type 
	left join
	(select school_management_type,count(DISTINCT(cluster_id)) as total_clusters from infra_school_table_mgt_view group by school_management_type)as e
	on scl.school_management_type=e.school_management_type)as a)as a
	on usc.cluster_id=a.cluster_id and usc.school_management_type=a.school_management_type
	group by infra_score,a.school_management_type,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
	ON b.cluster_id = c.cluster_id and b.school_management_type=c.school_management_type
	left join infra_cluster_atf_mgmt as atf on b.cluster_id=atf.cluster_id and b.school_management_type=atf.school_management_type;

/*block*/

create or replace view  hc_infra_mgmt_block as
select b.*,atf.areas_to_focus,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_mgt_view as idt
left join
(select block_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
   from infra_school_table_mgt_view group by block_id,school_management_type)as ist
on idt.block_id= ist.block_id and idt.school_management_type=ist.school_management_type) as b
left join(select usc.block_id,infra_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (PARTITION BY usc.school_management_type
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (PARTITION BY usc.school_management_type
               ORDER BY usc.infra_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_mgt_view as idt
left join
(select block_id,school_management_type,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_mgt_view group by block_id,school_management_type)as ist
on idt.block_id= ist.block_id and idt.school_management_type=ist.school_management_type) as usc
left join
(select a.*
from (select distinct(scl.block_id),blocks_in_district,d.district_id,d.school_management_type,e.total_blocks from infra_school_table_mgt_view as scl
left join
(SELECT district_id,school_management_type,Count(DISTINCT infra_school_table_mgt_view.block_id) AS blocks_in_district FROM   infra_school_table_mgt_view 
group by district_id,school_management_type)as d
on scl.district_id=d.district_id and scl.school_management_type=d.school_management_type
left join 
(select school_management_type,count(DISTINCT(block_id)) as total_blocks from infra_school_table_mgt_view group by school_management_type )as e
on scl.school_management_type=e.school_management_type) as a)as a
on usc.block_id=a.block_id and usc.school_management_type=a.school_management_type
group by infra_score,usc.school_management_type
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id and b.school_management_type=c.school_management_type
left join infra_block_atf_mgmt as atf on b.block_id=atf.block_id and b.school_management_type=atf.school_management_type;



/*district*/

create or replace view hc_infra_mgmt_district as 
select idt.*,atf.areas_to_focus,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
(select *,((rank () over ( partition by school_management_type order by infra_score desc))||' out of '||(select count(distinct(district_id)) 
from infra_district_table_mgt_view)) as district_level_rank_within_the_state,coalesce(1-round(( Rank() over (partition by school_management_type ORDER BY infra_score DESC) / ((select count(distinct(district_id)) from infra_district_table_mgt_view)*1.0)),2)) as state_level_score from infra_district_table_mgt_view) as idt
left join
(select district_id,school_management_type,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_mgt_view group by district_id,school_management_type)as ist
on idt.district_id= ist.district_id and idt.school_management_type=ist.school_management_type
left join infra_district_atf_mgmt as atf on idt.district_id=atf.district_id and idt.school_management_type=atf.school_management_type;


/* Health card main views management */


create or replace view health_card_index_school_mgmt_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,shd.school_management_type,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,school_management_type)as basic
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_school_mgmt_overall as sad left join
(select school_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_overall group by school_id,school_management_type)as sac
on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type) as b
left join(select usc.school_id,attendance,usc.school_management_type,
	   ( ( Rank()
			 over (
			   PARTITION BY a.cluster_id,usc.school_management_type
			   ORDER BY usc.attendance DESC)
		   || ' out of ' :: text )
		 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
	 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
	 from hc_student_attendance_school_mgmt_overall as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
	pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75,ped.grade_wise_performance,ped.school_management_type from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester,school_management_type
	 from semester_exam_school_mgmt_all where semester=(select max(semester) from semester_exam_school_mgmt_all))as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
	   from semester_exam_school_mgmt_all 
	   group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as b
	left join(select usc.school_id,school_performance,usc.semester,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_block )) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
	 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester,school_management_type
	from semester_exam_school_mgmt_all)as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score 
from hc_udise_mgmt_school as b
left join
(select usc.udise_school_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (Partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) 
           || ' out of ' :: text )
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
on basic.school_id=udise.udise_school_id and basic.school_management_type=udise.school_management_type
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_school_mgmt_all)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_all 
   group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.school_id,school_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
from hc_periodic_exam_school_mgmt_all)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=pat.school_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.school_id=crc.school_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_school as infra
on basic.school_id=infra.school_id and basic.school_management_type=infra.school_management_type;


create or replace view health_card_index_school_mgmt_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,shd.school_management_type,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,school_management_type)as basic
left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
	 from hc_student_attendance_school_mgmt_last_30_days as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
	   from hc_student_attendance_school_mgmt_overall group by school_id,school_management_type)as sac
	on sad.school_id= sac.school_id and sad.school_management_type=sac.school_management_type) as b
	left join(select usc.school_id,attendance,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC)
			   || ' out of ' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.school_management_type
				   ORDER BY usc.attendance DESC) / (a.total_schools*1.0)),2)) AS state_level_score
	 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
	 from hc_student_attendance_school_mgmt_last_30_days as sad left join
	(select school_id,school_management_type,
	 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
left join 
(	select b.*,c.school_level_rank_within_the_state,
	c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
	(select ped.block_id,ped.block_name,ped.cluster_id,ped.cluster_name,ped.school_id,ped.school_name,ped.district_id,ped.district_name,ped.performance,ped.semester,
	pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75,ped.grade_wise_performance,ped.school_management_type from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance as performance,semester,school_management_type
	 from semester_exam_school_mgmt_last30 where semester=(select max(semester) from semester_exam_school_mgmt_last30))as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
	   from semester_exam_school_mgmt_last30 
	   group by school_id,semester,school_management_type)as pes
	on ped.school_id= pes.school_id and ped.semester=pes.semester and ped.school_management_type=pes.school_management_type) as b
	left join(select usc.school_id,school_performance,usc.semester,usc.school_management_type,
		   ( ( Rank()
				 over (
				   PARTITION BY a.cluster_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
	( ( Rank()
				 over (
				   PARTITION BY a.block_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_block )) AS school_level_rank_within_the_block, 
	( ( Rank()
				 over (
				   PARTITION BY a.district_id,usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
	( ( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC)
			   || ' out of ' :: text )
			 ||  a.total_schools) AS school_level_rank_within_the_state,
	coalesce(1-round(( Rank()
				 over (partition by usc.semester,usc.school_management_type
				   ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
	 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
	(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,semester,school_management_type
	from semester_exam_school_mgmt_last30)as ped left join
	(select school_id,semester,school_management_type,
	 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
	 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
	 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
	 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=semester.school_id and basic.school_management_type=semester.school_management_type
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score 
from hc_udise_mgmt_school as b
left join
(select usc.udise_school_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (Partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC) 
           || ' out of ' :: text )
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
on basic.school_id=udise.udise_school_id and basic.school_management_type=udise.school_management_type
left join 
(select b.*,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_school_mgmt_last30)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_last30 
   group by school_id,school_management_type)as pes
on ped.school_id= pes.school_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.school_id,school_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.school_performance DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,school_id,school_name,grade_wise_performance,school_performance,data_from_date,data_upto_date,school_management_type
from hc_periodic_exam_school_mgmt_last30)as ped left join
(select school_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.school_id=pat.school_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.school_id=crc.school_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_school as infra
on basic.school_id=infra.school_id and basic.school_management_type=infra.school_management_type;




create or replace view health_card_index_cluster_mgmt_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,school_management_type)as basic
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_mgmt_overall as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_overall  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.cluster_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_mgmt_overall as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=student_attendance.cluster_id and basic.school_management_type=student_attendance.school_management_type
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,school_management_type,semester
 from semester_exam_cluster_mgmt_all where semester=(select max(semester) from semester_exam_cluster_mgmt_all))as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_all group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,school_management_type,semester
 from semester_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=semester.cluster_id and basic.school_management_type=semester.school_management_type
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_mgmt_cluster as b
left join(select usc.cluster_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_all group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_all 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=pat.cluster_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.cluster_id=crc.cluster_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_cluster as infra
on basic.cluster_id=infra.cluster_id and basic.school_management_type=infra.school_management_type;



create or replace view health_card_index_cluster_mgmt_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,school_management_type)as basic
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_mgmt_last_30_days as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_last_30_days  group by cluster_id,school_management_type)as sac
on sad.cluster_id= sac.cluster_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.cluster_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                        
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_cluster_mgmt_last_30_days as sad left join
(select cluster_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
left join 
(
select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance as performance,school_management_type,semester
 from semester_exam_cluster_mgmt_last30 where semester=(select max(semester) from semester_exam_cluster_mgmt_last30))as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_last30 group by cluster_id,school_management_type,semester)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,school_management_type,semester
 from semester_exam_cluster_mgmt_last30 
)as ped left join
(select cluster_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=semester.cluster_id and basic.school_management_type=semester.school_management_type
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from hc_udise_mgmt_cluster as b
left join(select usc.cluster_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
left join 
(select b.*,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_last30
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_last30 group by cluster_id,school_management_type)as pes
on ped.cluster_id= pes.cluster_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.cluster_id,cluster_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.block_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.cluster_performance DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,cluster_id,cluster_name,grade_wise_performance,cluster_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_cluster_mgmt_last30 
)as ped left join
(select cluster_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.cluster_id=pat.cluster_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id,a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
left join
hc_infra_mgmt_cluster as infra
on basic.cluster_id=infra.cluster_id and basic.school_management_type=infra.school_management_type;




create or replace view health_card_index_block_mgmt_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(sem_res.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,
sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,school_management_type)as basic
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_mgmt_overall as sad left join
(select block_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_overall  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.block_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_mgmt_overall as sad left join
(select block_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.block_id=student_attendance.block_id and basic.school_management_type=student_attendance.school_management_type
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,school_management_type,semester
 from semester_exam_block_mgmt_all
where semester=(select max(semester) from semester_exam_block_mgmt_all) )as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_all  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,school_management_type,semester
 from semester_exam_block_mgmt_all 
)as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
)as sem_res
on basic.block_id=sem_res.block_id and basic.school_management_type=sem_res.school_management_type
left join 

(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_mgmt_block as b
left join(select usc.block_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_all )as ped left join
(select block_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from periodic_exam_school_mgmt_all  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.block_id,block_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_all 
)as ped left join
(select block_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
on basic.block_id=pat.block_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.block_id=crc.block_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_block as infra
on basic.block_id=infra.block_id and basic.school_management_type=infra.school_management_type;



create or replace view health_card_index_block_mgmt_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(sem_res.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,count(distinct(usmt.udise_school_id)) as total_schools,
sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,school_management_type)as basic
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_mgmt_last_30_days as sad left join
(select block_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_last_30_days  group by block_id,school_management_type)as sac
on sad.block_id= sac.block_id and sad.school_management_type=sac.school_management_type
) as b
left join(select usc.block_id,attendance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.attendance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
 from (select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75
 from hc_student_attendance_block_mgmt_last_30_days as sad left join
(select block_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
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
on basic.block_id=student_attendance.block_id and basic.school_management_type=student_attendance.school_management_type
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance as performance,school_management_type,semester
 from semester_exam_block_mgmt_last30
where semester=(select max(semester) from semester_exam_block_mgmt_last30) )as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_last30  group by block_id,school_management_type,semester)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester) as b
left join(select usc.block_id,block_performance,usc.school_management_type,usc.semester,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type,usc.semester
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,school_management_type,semester
 from semester_exam_block_mgmt_last30
)as ped left join
(select block_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
)as sem_res
on basic.block_id=sem_res.block_id and basic.school_management_type=sem_res.school_management_type
left join 

(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from hc_udise_mgmt_block as b
left join(select usc.block_id,infrastructure_score,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.infrastructure_score DESC)
           || ' out of ' :: text )
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
left join 
(select b.*,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_last30 )as ped left join
(select block_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from periodic_exam_school_mgmt_last30  group by block_id,school_management_type)as pes
on ped.block_id= pes.block_id and ped.school_management_type=pes.school_management_type) as b
left join(select usc.block_id,block_performance,usc.school_management_type,
       ( ( Rank()
             over (
               PARTITION BY a.district_id,usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (partition by usc.school_management_type
               ORDER BY usc.block_performance DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                            
                         
 from (select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,block_id,block_name,grade_wise_performance,block_performance,data_from_date,data_upto_date,school_management_type
 from hc_periodic_exam_block_mgmt_last30 
)as ped left join
(select block_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
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
left join 
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
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (partition by a.school_management_type
               ORDER BY a.visit_score DESC)
           || ' out of ' :: text )
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
on basic.block_id=crc.block_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_block as infra
on basic.block_id=infra.block_id and basic.school_management_type=infra.school_management_type;




create or replace view health_card_index_district_mgmt_overall as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,
shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,school_management_type)as basic
left join 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75,((rank () over (partition by sac.school_management_type order by attendance desc))||' out of '||(select count(distinct(district_id)) 
from school_student_total_attendance)) as district_level_rank_within_the_state,coalesce(1-round((Rank() over (partition by sac.school_management_type ORDER BY attendance DESC) / ((select count(distinct(district_id)) 
from school_student_total_attendance)*1.0)),2)) as state_level_score
 from hc_student_attendance_district_mgmt_overall as sad left join
(select district_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_overall group by district_id,school_management_type)as sac
on sad.district_id= sac.district_id and sad.school_management_type=sac.school_management_type
)as student_attendance
on basic.district_id=student_attendance.district_id and basic.school_management_type=student_attendance.school_management_type
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,school_management_type,semester,
  ((rank () over ( partition by school_management_type,semester order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from semester_exam_district_mgmt_all)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type,semester ORDER BY district_performance DESC) /
 ((select count(distinct(district_id)) from semester_exam_district_mgmt_all)*1.0)),2)) as state_level_score
 from semester_exam_district_mgmt_all where semester=(select max(semester) from semester_exam_district_mgmt_all))as ped left join
(select district_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_all group by district_id,school_management_type,semester)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id and basic.school_management_type=semester.school_management_type
left join 
(select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_mgt_score as uds left join 
(select district_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by district_id,school_management_type)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id and basic.school_management_type=udise.school_management_type
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,school_management_type,
  ((rank () over ( partition by school_management_type order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from hc_periodic_exam_district_mgmt_all)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type ORDER BY district_performance DESC) / ((select count(distinct(district_id)) from semester_exam_district_mgmt_all)*1.0)),2)) as state_level_score
 from hc_periodic_exam_district_mgmt_all )as ped left join
(select district_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_all group by district_id,school_management_type)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type)as pat
on basic.district_id=pat.district_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
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
on basic.district_id=crc.district_id and basic.school_management_type=crc.school_management_type
left join
hc_infra_mgmt_district as infra
on basic.district_id=infra.district_id and basic.school_management_type=infra.school_management_type;


create or replace view health_card_index_district_mgmt_last30 as 
select basic.*,row_to_json(student_attendance.*) as student_attendance,row_to_json(semester.*) as student_semester,row_to_json(udise.*) as udise,
row_to_json(pat.*) as PAT_performance,row_to_json(crc.*) as CRC_visit,row_to_json(infra.*) as school_infrastructure
 from 
(select shd.district_id,initcap(shd.district_name)as district_name,count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and school_management_type is not null
group by shd.district_id,shd.district_name,school_management_type)as basic
left join 
(select sad.*,sac.value_below_33,sac.value_between_33_60,sac.value_between_60_75,sac.value_above_75,((rank () over (partition by sac.school_management_type order by attendance desc))||' out of '||(select count(distinct(district_id)) 
from school_student_total_attendance)) as district_level_rank_within_the_state,
1-round((Rank() over (partition by sac.school_management_type ORDER BY attendance DESC) / coalesce((select count(distinct(district_id)) from school_student_total_attendance),1)*1.0),2) as state_level_score
 from hc_student_attendance_district_mgmt_last_30_days as sad left join
(select district_id,school_management_type,
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_mgmt_last_30_days group by district_id,school_management_type)as sac
on sad.district_id= sac.district_id and sad.school_management_type=sac.school_management_type
)as student_attendance
on basic.district_id=student_attendance.district_id and basic.school_management_type=student_attendance.school_management_type
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance as performance,school_management_type,semester,
  ((rank () over ( partition by school_management_type,semester order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from semester_exam_district_mgmt_last30)) as district_level_rank_within_the_state, 
coalesce(1-round(( Rank() over (partition by school_management_type,semester ORDER BY district_performance DESC) /
 ((select count(distinct(district_id)) from semester_exam_district_mgmt_last30)*1.0)),2)) as state_level_score
 from semester_exam_district_mgmt_last30 where semester=(select max(semester) from semester_exam_district_mgmt_last30))as ped left join
(select district_id,school_management_type,semester,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_mgmt_last30 group by district_id,school_management_type,semester)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type and ped.semester=pes.semester)as semester
on basic.district_id=semester.district_id and basic.school_management_type=semester.school_management_type
left join 
(select uds.*,usc.value_below_33,usc.value_between_33_60,usc.value_between_60_75,usc.value_above_75 from udise_district_mgt_score as uds left join 
(select district_id,school_management_type,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_mgt_score group by district_id,school_management_type)as usc
on uds.district_id= usc.district_id)as udise
on basic.district_id=udise.district_id and basic.school_management_type=udise.school_management_type
left join 
(select ped.*,pes.value_below_33,pes.value_between_33_60,pes.value_between_60_75,pes.value_above_75 from 
(Select district_id,district_name,grade_wise_performance,district_performance,data_from_date,data_upto_date,school_management_type,
  ((rank () over ( partition by school_management_type order by district_performance desc))||' out of '||(select count(distinct(district_id)) 
from hc_periodic_exam_district_mgmt_last30)) as district_level_rank_within_the_state, 
1-round( Rank() over (partition by school_management_type ORDER BY district_performance DESC) / coalesce(((select count(distinct(district_id)) from semester_exam_district_mgmt_last30)*1.0),1),2) as state_level_score
 from hc_periodic_exam_district_mgmt_last30 )as ped left join
(select district_id,school_management_type,
 sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from hc_periodic_exam_school_mgmt_last30 group by district_id,school_management_type)as pes
on ped.district_id= pes.district_id and ped.school_management_type=pes.school_management_type)as pat
on basic.district_id=pat.district_id and basic.school_management_type=pat.school_management_type
left join 
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
           || ' out of ' :: text )
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
left join
hc_infra_mgmt_district as infra
on basic.district_id=infra.district_id and basic.school_management_type=infra.school_management_type;


/* Student attendance management overall */

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

/* PAT MGMT overall */
create or replace view hc_pat_state_mgmt_overall as 
select sp.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance
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
        FROM periodic_exam_school_result where school_management_type is not null group by school_management_type) sp on sp.school_management_type=smt.school_management_type
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
          GROUP BY c.school_management_type) b ON smt.school_management_type::text = b.school_management_type::text;


/* PAT MGMT last 30 days */
create or replace view hc_pat_state_mgmt_last30 as 
select sp.school_performance,smt.grade_wise_performance,b.school_management_type,b.students_count,b.total_schools from
        (SELECT school_management_type,json_object_agg(a_1.grade, a_1.percentage) AS grade_wise_performance
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
        FROM periodic_exam_school_result where school_management_type is not null AND (exam_code::text IN ( SELECT pat_date_range.exam_code
                           FROM pat_date_range
                          WHERE pat_date_range.date_range = 'last30days'::text))
                 group by school_management_type) sp on sp.school_management_type=smt.school_management_type
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


/* Health Card index overall state */

create or replace function health_card_index_state()
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
create_state_view text;
BEGIN
Execute udise_query into udise_cols;
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_state_view=
'create or replace view health_card_index_state as select ''basic_details'' as data_source,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as data
)as basic_details
union
(select ''student_attendance''as data,row_to_json(state_attendance)::text from
  (select hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date,
 sum(case when data.attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when data.attendance > 33 and data.attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when data.attendance > 60 and data.attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when data.attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_overall as data, hc_student_attendance_state_overall hsao
   group by hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date)as state_attendance)
union
(select ''student_semester'' as data,
  row_to_json(sat)::text from (select hc_sat_state_overall.school_performance as performance,hc_sat_state_overall.grade_wise_performance,hc_sat_state_overall.students_count,hc_sat_state_overall.total_schools,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_all) as data, hc_sat_state_overall) as sat)
union
(select ''pat_performance''as data,
  row_to_json(pat)::text from (select hc_pat_state_overall.*,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from periodic_exam_school_all) as data, hc_pat_state_overall) as pat)
union
(select ''udise''as data,row_to_json(udise)::text from (select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score)as udise)
  union
 (select ''school_infrastructure''as data,row_to_json(infra)::text 
 from (select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
 from hc_infra_school)as infra)
 union
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
				   ) crc';
Execute create_state_view; 
return 0;
END;
$$LANGUAGE plpgsql;

select health_card_index_state();

/* Health Card index last 30 days state */

create or replace function health_card_index_state_last_30()
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
create_state_view text;
BEGIN
Execute udise_query into udise_cols;
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_state_view=
'create or replace view health_card_index_state_last30 as select ''basic_details'' as data_source,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name)as data
)as basic_details
union
(select ''student_attendance''as data,row_to_json(state_attendance)::text from
  (select hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date,
 sum(case when data.attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when data.attendance > 33 and data.attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when data.attendance > 60 and data.attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when data.attendance > 75 then 1 else 0 end)as value_above_75
   from hc_student_attendance_school_last_30_days as data, hc_student_attendance_state_last30 hsao
   group by hsao.attendance,hsao.students_count,hsao.total_schools,hsao.data_from_date,hsao.data_upto_date)as state_attendance)
union
(select ''student_semester'' as data,
  row_to_json(sat)::text from (select hc_sat_state_last30.school_performance as performance,hc_sat_state_last30.grade_wise_performance,hc_sat_state_last30.students_count,hc_sat_state_last30.total_schools,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from semester_exam_school_last30) as data, hc_sat_state_last30) as sat)
union
(select ''pat_performance'' as data,
  row_to_json(pat)::text from (select hc_pat_state_last30.*,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75
   from periodic_exam_school_last30) as data, hc_pat_state_last30) as pat)
union
(select ''udise''as data,row_to_json(udise)::text from (select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75
   from udise_school_score)as udise)
  union
 (select ''school_infrastructure''as data,row_to_json(infra)::text 
 from (select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
 from hc_infra_school)as infra)
 union
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
                   FROM crc_school_report_last_30_days) as spd)as res ) crc;';
Execute create_state_view; 
return 0;
END;
$$LANGUAGE plpgsql;

select health_card_index_state_last_30();

/* Health Card index overall state */

create or replace function health_card_index_state_mgmt_overall()
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
create_state_view text;
BEGIN
Execute udise_query into udise_cols;
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_state_view=
'create or replace view health_card_index_state_mgmt_overall as select ''basic_details'' as data_source,school_management_type,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students,school_management_type from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and shd.school_management_type IS NOT NULL
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,shd.school_management_type) as data group by school_management_type)as basic_details
union
(select ''student_attendance'' as data,school_management_type,row_to_json(state_attendance)::text from
  (select hsamo.attendance,hsamo.students_count,hsamo.total_schools,hsamo.data_from_date,hsamo.data_upto_date,
  hsamo.school_management_type,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from (select
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75,school_management_type
from hc_student_attendance_school_mgmt_overall hsao group by school_management_type) as data
left join hc_student_attendance_state_mgmt_overall hsamo on 
hsamo.school_management_type=data.school_management_type)as state_attendance)
union
(select ''pat_performance'' as data,school_management_type,
  row_to_json(pat)::text from (select hs.*,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75,school_management_type
   from hc_periodic_exam_school_mgmt_all where school_management_type is not null group by school_management_type) as data left join hc_pat_state_mgmt_overall hs on data.school_management_type=hs.school_management_type) as pat)
union
(select ''student_semester'' as data,school_management_type,
  row_to_json(sat)::text from (select hs.school_performance as performance,hs.grade_wise_performance,hs.school_management_type,hs.students_count,hs.total_schools,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75,school_management_type
   from hc_semester_exam_school_mgmt_all where school_management_type is not null group by school_management_type) as data left join hc_sat_state_mgmt_overall hs on data.school_management_type=hs.school_management_type) as sat)
union
(select ''udise''as data,school_management_type,row_to_json(udise)::text from (select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75,school_management_type
   from udise_school_mgt_score group by school_management_type)as udise)
  union
 (select ''school_infrastructure''as data,school_management_type,row_to_json(infra)::text 
 from (select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
 from hc_infra_mgmt_school group by school_management_type)as infra)
 union
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
                   FROM crc_school_mgmt_all group by school_management_type) as spd) as res
				   ) crc';
Execute create_state_view; 
return 0;
END;
$$LANGUAGE plpgsql;

select health_card_index_state_mgmt_overall();


/* Health Card index overall state */

/* Health Card index last 30 days state */

create or replace function health_card_index_state_mgmt_last30()
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
create_state_view text;
BEGIN
Execute udise_query into udise_cols;
Execute infra_query into infra_cols;
Execute infra_atf_query into infra_atf_cols;
Execute infra_atf_cols into infra_atf;
create_state_view=
'create or replace view health_card_index_state_mgmt_last30 as select ''basic_details'' as data_source,school_management_type,row_to_json(basic_details)::text as values  from 
(select distinct(substring(cast(avg(district_id) as text),1,2))as state_id,sum(total_schools)as total_schools,sum(total_students)as total_students,school_management_type from 
(select shd.district_id,initcap(shd.district_name)as district_name,shd.block_id,initcap(shd.block_name)as block_name,shd.cluster_id,initcap(shd.cluster_name)as cluster_name,
  shd.school_id,initcap(shd.school_name)as school_name,
  count(distinct(usmt.udise_school_id)) as total_schools,sum(usmt.total_students)as total_students,shd.school_management_type from
(select udise_school_id,sum(no_of_students) as total_students from udise_school_metrics_trans group by udise_school_id)as usmt right join school_hierarchy_details as shd
on usmt.udise_school_id=shd.school_id where 
cluster_name is not null and school_name is not null and block_name is not null and district_name is not null and shd.school_management_type IS NOT NULL
group by shd.district_id,shd.district_name,shd.block_id,shd.block_name,shd.cluster_id,shd.cluster_name,shd.school_id,shd.school_name,shd.school_management_type) as data group by school_management_type)as basic_details
union
(select ''student_attendance'' as data,school_management_type,row_to_json(state_attendance)::text from
  (select hsamo.attendance,hsamo.students_count,hsamo.total_schools,hsamo.data_from_date,hsamo.data_upto_date,
  hsamo.school_management_type,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from (select
 sum(case when attendance <=33 then 1 else 0 end)as value_below_33,
 sum(case when attendance > 33 and attendance<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when attendance > 60 and attendance<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when attendance > 75 then 1 else 0 end)as value_above_75,school_management_type
from hc_student_attendance_school_mgmt_last_30_days hsao group by school_management_type) as data
left join hc_student_attendance_state_mgmt_last30 hsamo on 
hsamo.school_management_type=data.school_management_type)as state_attendance)
union
(select ''pat_performance'' as data,school_management_type,
  row_to_json(pat)::text from (select hs.*,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75,school_management_type
   from hc_periodic_exam_school_mgmt_last30 where school_management_type is not null group by school_management_type) as data left join hc_pat_state_mgmt_last30 hs on data.school_management_type=hs.school_management_type) as pat)
union
(select ''student_semester'' as data,school_management_type,
  row_to_json(sat)::text from (select hs.school_performance as performance,hs.grade_wise_performance,hs.school_management_type,hs.students_count,hs.total_schools,value_below_33,value_between_33_60,value_between_60_75,value_above_75
from
(select sum(case when school_performance <=33 then 1 else 0 end)as value_below_33,
 sum(case when school_performance > 33 and school_performance<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when school_performance > 60 and school_performance<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when school_performance >75 then 1 else 0 end)as value_above_75,school_management_type
   from hc_semester_exam_school_mgmt_last30 where school_management_type is not null group by school_management_type) as data left join hc_sat_state_mgmt_last30 hs on data.school_management_type=hs.school_management_type) as sat)
union
(select ''udise''as data,school_management_type,row_to_json(udise)::text from (select sum(total_schools) as total_schools
  ,'||udise_cols||',
    cast(avg(infrastructure_score)as int)as infrastructure_score,
 sum(case when Infrastructure_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when Infrastructure_score > 33 and infrastructure_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when Infrastructure_score > 60 and infrastructure_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when Infrastructure_score >75 then 1 else 0 end)as value_above_75,school_management_type
   from udise_school_mgt_score group by school_management_type)as udise)
  union
 (select ''school_infrastructure''as data,school_management_type,row_to_json(infra)::text 
 from (select sum(total_schools_data_received) as total_schools_data_received, 
   cast(avg(infra_score)as int)as infra_score,
'||infra_cols||','''||infra_atf||''' as areas_to_focus,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<= 60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<= 75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75,school_management_type
 from hc_infra_mgmt_school group by school_management_type)as infra)
 union
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
                   FROM crc_school_report_mgmt_last_30_days group by school_management_type) as spd)as res ) crc;';
Execute create_state_view; 
return 0;
END;
$$LANGUAGE plpgsql;

select health_card_index_state_mgmt_last30();
