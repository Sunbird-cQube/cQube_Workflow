/*update infrastructure names*/

update infrastructure_master set infrastructure_name=lower(replace(infrastructure_name,' ','_'));

/*Drop functions if exists*/

drop function IF exists insert_infra_master;
drop function IF exists create_infra_table;
drop function IF exists update_infra_score;
drop function IF exists insert_infra_trans;
drop function IF exists insert_infra_agg;
drop function IF exists infra_district_reports;
drop function IF exists infra_block_reports;
drop function IF exists infra_cluster_reports;
drop function IF exists infra_school_reports;
drop function IF exists Infra_jolt_spec;
drop function IF exists insert_diksha_trans;
drop function IF exists insert_diksha_agg;
drop view if exists infra_district_table_mgt_view cascade;
drop view if exists infra_district_map_mgt_view cascade;
drop view if exists infra_block_map_mgt_view cascade;
drop view if exists infra_block_table_mgt_view cascade;
drop view if exists infra_cluster_table_mgt_view cascade;
drop view if exists infra_cluster_map_mgt_view cascade;
drop view if exists infra_school_table_mgt_view cascade;
drop view if exists infra_school_map_mgt_view cascade;


/* Create infra tables */

CREATE OR REPLACE FUNCTION create_infra_table()
RETURNS text AS
$$
DECLARE
infra_query text:='select string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||'' smallint'','','') from infrastructure_master where status = true ';
infra_cols text; 
temp_table text;
transaction_table text;
aggregation_table text;
BEGIN
Execute infra_query into infra_cols;
IF infra_cols <> '' THEN 
temp_table='create table if not exists infrastructure_temp (last_inspection_id bigint, school_id bigint primary key not null,'||infra_cols||','||'created_on timestamp,updated_on timestamp)';
transaction_table='create table if not exists infrastructure_trans (last_inspection_id bigint, school_id bigint primary key not null,'||infra_cols||','||'created_on timestamp,updated_on timestamp)';
aggregation_table='create table if not exists school_infrastructure_score (id serial,inspection_id bigint,year int,month int,school_id bigint primary key not null,school_name varchar(200),school_latitude double precision
,school_longitude double precision,district_id bigint,district_name varchar(100),district_latitude double precision,district_longitude double precision,
block_id bigint,block_name varchar(100),block_latitude double precision,block_longitude double precision,
cluster_id bigint,cluster_name varchar(100),cluster_latitude double precision,cluster_longitude double precision,'||infra_cols||','||'created_on timestamp,updated_on timestamp)';
Execute temp_table;
Execute transaction_table; 
Execute aggregation_table; 
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select create_infra_table();

/* Inserting/updating infrastructure transaction details into trans table*/

CREATE OR REPLACE FUNCTION insert_infra_trans()
RETURNS text AS
$$
DECLARE
infra_query text:='select string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','') from infrastructure_master where status = true ';
infra_cols text; 
update_query text:='select string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||'' = excluded.''||replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','')from infrastructure_master where status = true';
update_cols text;
transaction_insert text;
BEGIN
Execute infra_query into infra_cols;
Execute update_query into update_cols;
IF infra_cols <> '' THEN 
transaction_insert='insert into infrastructure_trans(school_id,'||infra_cols||',created_on,updated_on) 
select school_id,'||infra_cols||',now(),now() from (select school_id,'||infra_cols||' from infrastructure_temp except select school_id,'||infra_cols||'
 from infrastructure_trans )as a 
on conflict(school_id) do update
set '||update_cols||',updated_on=now()';
Execute transaction_insert; 
END IF;
return 0;
END;
$$LANGUAGE plpgsql;


alter table school_infrastructure_score add column if not exists school_management_type varchar(100);
alter table school_infrastructure_score add column if not exists school_category varchar(100);

/* Inserting/updating Aggregated data from trans to aggregation table */

create or replace FUNCTION insert_infra_agg() RETURNS text AS $$
DECLARE infra_trans text := 'select string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''*(select score from infrastructure_master where infrastructure_name=''
	||''''''''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''''''''||'') as ''||replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','')
from infrastructure_master where status = true';
infra_trans_cols text;
select_1 text := 'select string_agg(''a.''||replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','') from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text := 'select string_agg(''c.''||replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','') from infrastructure_master where status = true 
order by 1';
select_2_cols text;
select_3 text := 'select string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'','') from infrastructure_master where status = true order by 1';
select_3_cols text;
insert_infra_agg text := 'select string_agg(column_name,'','') from information_schema.columns WHERE table_name = ''school_infrastructure_score'' and column_name not in 
                         (''created_on'',''updated_on'',''id'',''inspection_id'',''year'',''month'') order by 1';
insert_infra_agg_cols text;
update_query text := 'select string_agg(column_name||'' = excluded.''||column_name,'','') from information_schema.columns WHERE table_name = ''school_infrastructure_score'' 
and column_name not in (''created_on'',''updated_on'',''id'',''inspection_id'',''year'',''month'') order by 1';
update_cols text;
infra_score text;
aggregation_select text;
aggregation_insert text;
BEGIN Execute infra_trans into infra_trans_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
Execute select_3 into select_3_cols;
Execute insert_infra_agg into insert_infra_agg_cols;
Execute update_query into update_cols;
IF infra_trans_cols <> '' THEN infra_score = '
create or replace view infra_score_view as 
select c.school_id,' || select_2_cols || ',initcap(c.school_name) as school_name,c.district_id,
initcap(c.district_name) as district_name,c.block_id,initcap(c.block_name) as block_name,c.cluster_id,initcap(c.cluster_name) as cluster_name,d.school_latitude,d.school_longitude,d.cluster_latitude,
d.cluster_longitude,d.block_latitude,d.block_longitude,d.district_latitude,d.district_longitude,c.school_management_type,c.school_category from  
(select a.school_id,' || select_1_cols || ',b.school_name,b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.school_management_type,b.school_category
from (select school_id,' || infra_trans_cols || ' from infrastructure_trans) as a left join school_hierarchy_details as b on a.school_id=b.school_id
where cluster_name is not null)as c left join school_geo_master as d on c.school_id=d.school_id
WHERE district_name IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null AND block_name IS NOT NULL';
Execute infra_score;
aggregation_select = 'create or replace view insert_infra_agg_view as
select c.school_id,' || select_2_cols || ',initcap(c.school_name) as school_name,c.district_id,
initcap(c.district_name) as district_name,c.block_id,initcap(c.block_name) as block_name,c.cluster_id,initcap(c.cluster_name) as cluster_name,d.school_latitude,d.school_longitude,d.cluster_latitude,
d.cluster_longitude,d.block_latitude,d.block_longitude,d.district_latitude,d.district_longitude,c.school_management_type,c.school_category from  
(select a.school_id,' || select_1_cols || ',b.school_name,b.district_id,b.district_name,b.block_id,b.block_name,b.cluster_id,b.cluster_name,b.school_management_type,b.school_category
from (select school_id,' || select_3_cols || ' from infrastructure_trans) as a left join school_hierarchy_details as b on a.school_id=b.school_id
where cluster_name is not null)as c left join school_geo_master as d on c.school_id=d.school_id
WHERE district_name IS NOT NULL AND school_name IS NOT NULL and cluster_name is not null AND block_name IS NOT NULL';
Execute aggregation_select;
aggregation_insert = 'insert into school_infrastructure_score(' || insert_infra_agg_cols || ')
select ' || insert_infra_agg_cols || ' from (select ' || insert_infra_agg_cols || ' from insert_infra_agg_view except select ' || insert_infra_agg_cols || '
 from school_infrastructure_score )as a
 on conflict(school_id) do update
set ' || update_cols || ',updated_on=now()';
Execute aggregation_insert;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;


select insert_infra_agg();

/* Visualization */
/*  District - reports (map and table) */

drop view if exists infra_district_table_view cascade;

create or replace FUNCTION infra_district_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_district_table_view as 
select d.district_id,
initcap(c.district_name)as district_name,c.total_schools,d.total_schools_data_received,c.infra_score,
d.average_value,d.average_percent,'||select_1_cols||' from (
select district_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||'
 from school_infrastructure_score group by district_id)as d
inner join 
(select a.district_id,a.district_name,b.total_schools,c.infra_score 
from 
(select district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by district_id,district_name)as a 
inner join (select district_id,count(distinct(school_id)) as total_schools from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by district_id)as b on a.district_id=b.district_id
inner join (select district_id,'||select_infra_score_cols||'
from infra_score_view group by district_id) as c on a.district_id=c.district_id) as c
on d.district_id=c.district_id ';
infra_map= 'create or replace view infra_district_map_view as 
select d.district_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,c.district_latitude,c.district_longitude
 from (
select district_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||' from school_infrastructure_score group by district_id)as d
inner join 
(select a.district_id,a.district_name,b.district_latitude,b.district_longitude,c.infra_score,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent
 from 
(select district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by district_id,district_name)as a inner join 
(select district_id,district_latitude,district_longitude from school_geo_master
  group by district_id,district_latitude,district_longitude)as b
 on a.district_id=b.district_id
 inner join (select district_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||'
from infra_score_view group by district_id) as c on a.district_id=c.district_id)as c
on d.district_id=c.district_id';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_district_reports('water','toilet');

/* Block - reports (map and table) */

drop view if exists infra_block_table_view cascade;

create or replace FUNCTION infra_block_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_block_table_view as 
select d.block_id,
initcap(c.block_name)as block_name,c.district_id,initcap(c.district_name)as district_name,c.total_schools,
d.total_schools_data_received,c.infra_score,d.average_value,d.average_percent,'||select_1_cols||'
 from (
select block_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||'
from school_infrastructure_score group by block_id ) as d
inner join 
(select a.block_id,a.block_name,a.district_id,a.district_name,b.total_schools,c.infra_score from 
(select block_id,block_name,district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by block_id,block_name,district_id,district_name)as a inner join 
(select block_id,count(distinct(school_id)) as total_schools from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by block_id)as b on a.block_id=b.block_id
inner join (select block_id,'||select_infra_score_cols||'
from infra_score_view group by block_id) as c on a.block_id=c.block_id) as c
on d.block_id=c.block_id';
infra_map= 'create or replace view infra_block_map_view as 
select d.block_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.block_name)as block_name,c.district_id,c.block_latitude,c.block_longitude
from 
(select block_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||' from school_infrastructure_score group by block_id)as d
inner join 
(select a.block_id,a.block_name,a.district_id,a.district_name,b.block_latitude,b.block_longitude,c.infra_score,
  c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select block_id,block_name,district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by block_id,block_name,district_id,district_name)as a inner join 
(select block_id,block_latitude,block_longitude from school_geo_master 
  group by block_id,block_latitude,block_longitude)as b
 on a.block_id=b.block_id
 inner join (select block_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||'
from infra_score_view group by block_id)as c on a.block_id=c.block_id)as c
on d.block_id=c.block_id';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_block_reports('water','toilet');

/*  Cluster - reports (map and table) */

drop view if exists infra_cluster_table_view cascade;

create or replace FUNCTION infra_cluster_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_cluster_table_view as 
select d.cluster_id,
initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,
c.district_id,initcap(c.district_name)as district_name,c.total_schools,d.total_schools_data_received,
c.infra_score,d.average_value,d.average_percent,'||select_1_cols||' from 
(
select cluster_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||'
from school_infrastructure_score group by cluster_id ) as d
inner join 
(select a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.total_schools,c.infra_score from 
(select cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select cluster_id,count(distinct(school_id)) as total_schools from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by cluster_id)as b on a.cluster_id=b.cluster_id
inner join (select cluster_id,'||select_infra_score_cols||'
from infra_score_view group by cluster_id) as c on a.cluster_id=c.cluster_id) as c
on d.cluster_id=c.cluster_id';
infra_map= 'create or replace view infra_cluster_map_view as 
select d.cluster_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,c.district_id,c.cluster_latitude,c.cluster_longitude
from 
(select cluster_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||' 
 from school_infrastructure_score group by cluster_id)as d
inner join 
(select a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.cluster_latitude,b.cluster_longitude,c.infra_score
,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select cluster_id,cluster_latitude,cluster_longitude from school_geo_master 
  group by cluster_id,cluster_latitude,cluster_longitude)as b
 on a.cluster_id=b.cluster_id
 inner join (select cluster_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||'
from infra_score_view group by cluster_id)as c on a.cluster_id=c.cluster_id)as c
on d.cluster_id=c.cluster_id';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_cluster_reports('water','toilet');

/*  school - reports (map and table) */

drop view if exists infra_school_table_view cascade;

create or replace FUNCTION infra_school_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_school_table_view as 
select d.school_id,
initcap(c.school_name)as school_name,c.cluster_id,initcap(c.cluster_name)as cluster_name,c.block_id,
initcap(c.block_name)as block_name,c.district_id,initcap(c.district_name)as district_name,c.total_schools
,d.total_schools_data_received,c.infra_score,d.average_value,d.average_percent,'||select_1_cols||' from 
(
  select school_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||'
 from school_infrastructure_score group by school_id ) as d
inner join 
(select a.school_id,a.school_name,a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.total_schools,c.infra_score from 
(select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select school_id,count(distinct(school_id)) as total_schools from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by school_id)as b on a.school_id=b.school_id
inner join (select school_id,'||select_infra_score_cols||'
from infra_score_view group by school_id)as c on a.school_id=c.school_id) as c
on d.school_id=c.school_id';
infra_map= 'create or replace view infra_school_map_view as 
select d.school_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.school_name)as school_name,
c.cluster_id,initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,c.district_id,c.school_latitude,c.school_longitude
from 
(select school_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||' 
  from school_infrastructure_score group by school_id)as d
inner join 
(select a.school_id,a.school_name,a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.school_latitude,b.school_longitude,c.infra_score 
  ,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select school_id,school_latitude,school_longitude from school_geo_master 
  group by school_id,school_latitude,school_longitude)as b
 on a.school_id=b.school_id
 inner join (select school_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||'
from infra_score_view group by school_id)as c on a.school_id=c.school_id)as c
on d.school_id=c.school_id';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_school_reports('water','toilet');

/* JOLT spec dynamic */
-- old and current jolt structure

create or replace function Infra_jolt_spec(category_1 text,category_2 text)
    RETURNS text AS
    $$
    declare
infra_table_value text:='select string_agg(''"''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value": "[&1].''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''.value"'','','')
 from infrastructure_master where status = true';
infra_table_value_cols text;
infra_table_percent text:='select string_agg(''"''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent": "[&1].''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''.percent"'','','')
 from infrastructure_master where status = true';   
infra_table_percent_cols text;
jolt_table_query text;
infra_map_percent text:='select string_agg(''"''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent": "data.[&1].metrics.''||
 replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent"'','','')
from infrastructure_master where status = true;';   
infra_map_percent_cols text;

composite_infra_1 text:='select string_agg(''"access_to_'||category_1||'_percent": "data.[&1].access_to_'||category_1||'_percent"'','','')';
composite_infra_1_cols text;
composite_infra_2 text:='select string_agg(''"access_to_'||category_2||'_percent": "data.[&1].access_to_'||category_2||'_percent"'','','')';
composite_infra_2_cols text;

composite_inframap_1 text:='select string_agg(''"access_to_'||category_1||'_percent": "data.[&1].metrics.access_to_'||category_1||'_percent"'','','')';
composite_inframap_1_cols text;
composite_inframap_2 text:='select string_agg(''"access_to_'||category_2||'_percent": "data.[&1].metrics.access_to_'||category_2||'_percent"'','','')';
composite_inframap_2_cols text;

jolt_map_query text;
BEGIN
execute infra_table_value into infra_table_value_cols;
execute infra_table_percent into infra_table_percent_cols;
execute composite_infra_2 into composite_infra_2_cols;
execute composite_infra_1 into composite_infra_1_cols;
execute infra_map_percent into infra_map_percent_cols;
execute composite_inframap_2 into composite_inframap_2_cols;
execute composite_inframap_1 into composite_inframap_1_cols;
IF infra_table_value_cols <> '' THEN 
jolt_table_query = '
create or replace view Infra_jolt_district_table as 
select ''[
    {
      "operation": "shift",
      "spec": {
        "*": {
          "district_id": "[&1].district.id",
          "district_name": "[&1].district.value",
          "total_schools": "[&1].total_schools.value",
          "total_schools_data_received": "[&1].total_schools_data_received.value",
          "infra_score": "[&1].infra_score.value",
          "average_value": "[&1].average.value",
          "average_percent": "[&1].average.percent",
'||infra_table_value_cols||','||infra_table_percent_cols||'         
        }
      }
    }
  ]
''as jolt_spec;
create or replace view Infra_jolt_block_table
as select ''
[
    {
      "operation": "shift",
      "spec": {
        "*": {
          "district_id": "[&1].district.id",
          "district_name": "[&1].district.value",
          "block_name" : "[&1].block.value",
          "block_id" : "[&1].block.id",
          "total_schools": "[&1].total_schools.value",
          "total_schools_data_received": "[&1].total_schools_data_received.value",
          "infra_score": "[&1].infra_score.value",
          "average_value": "[&1].average.value",
          "average_percent": "[&1].average.percent",
'||infra_table_value_cols||','||infra_table_percent_cols||'
        }
      }
    }
  ]
'' as jolt_spec;
create or replace view Infra_jolt_cluster_table
as select ''
[
    {
      "operation": "shift",
      "spec": {
        "*": {
          "district_id": "[&1].district.id",
          "district_name": "[&1].district.value",
          "block_id" : "[&1].block.id",
          "block_name" : "[&1].block.value",
          "cluster_id" : "[&1].cluster.id",
          "cluster_name" : "[&1].cluster.value",
          "total_schools": "[&1].total_schools.value",
          "total_schools_data_received": "[&1].total_schools_data_received.value",
          "infra_score": "[&1].infra_score.value",
          "average_value": "[&1].average.value",
          "average_percent": "[&1].average.percent",
'||infra_table_value_cols||','||infra_table_percent_cols||'
        }
      }
    }
  ]
''as jolt_spec;
create or replace view Infra_jolt_school_table
as select ''
[
    {
      "operation": "shift",
      "spec": {
        "*": {          
          "district_id": "[&1].district.id",
          "district_name": "[&1].district.value",
          "block_id" : "[&1].block.id",
          "block_name" : "[&1].block.value",
          "cluster_id" : "[&1].cluster.id",
          "cluster_name" : "[&1].cluster.value",
          "school_id" : "[&1].school.id",
          "school_name" : "[&1].school.value",
          "total_schools": "[&1].total_schools.value",
          "total_schools_data_received": "[&1].total_schools_data_received.value",
          "infra_score": "[&1].infra_score.value",
          "average_value": "[&1].average.value",
          "average_percent": "[&1].average.percent",
'||infra_table_value_cols||','||infra_table_percent_cols||'        }
      }
    }
  ]
''as jolt_spec;
    ';
Execute jolt_table_query;
jolt_map_query = '
create or replace view Infra_jolt_district_map as 
select ''
[{
		"operation": "shift",
		"spec": {
			"*": {
				"district_id": "data.[&1].details.district_id",
			   "district_latitude": "data.[&1].details.latitude",
              "district_longitude": "data.[&1].details.longitude",
              "district_name": "data.[&1].details.district_name",
              "infra_score": "data.[&1].details.infrastructure_score",
			'||infra_map_percent_cols||','||composite_inframap_1_cols||','||composite_inframap_2_cols||',
              
              "@total_schools_data_received": "data.[&1].details.total_schools_data_received",
			  "total_schools_data_received": "allDistrictsFooter.totalSchools[]"
			}
		}
	}, {
		"operation": "modify-overwrite-beta",
		"spec": {
			"*": {
				
				"totalSchools": "=intSum(@(1,totalSchools))"
			}
		}
	}
]
''as jolt_spec;
create or replace view Infra_jolt_block_map
as select ''
[{
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "data.[&1].details.district_id",
        "block_id": "data.[&1].details.block_id",
        "block_latitude": "data.[&1].details.latitude",
        "block_longitude": "data.[&1].details.longitude",
        "district_name": "data.[&1].details.district_name",
        "block_name": "data.[&1].details.block_name",
        "infra_score": "data.[&1].details.infrastructure_score",
        "average_value": "data.[&1].details.average_value",
        "average_percent": "data.[&1].details.average_percent",
              '||infra_map_percent_cols||','||composite_inframap_1_cols||','||composite_inframap_2_cols||',
        "total_schools": "data.[&1].total_schools",
        "@total_schools_data_received": "data.[&1].details.total_schools_data_received",
        "total_schools_data_received": "footer.@(1,district_id).totalSchools[]"
      }
    }
	},
  {
    "operation": "shift",
    "spec": {
      "data": {
        "*": {
          "details": "data.[&1].&",
          "metrics": "data.[&1].&",
          "@details.total_schools_data_received": "allBlocksFooter.totalSchools[]"
        }
      },
      "footer": "&"
    }
	},
  {
    "operation": "modify-overwrite-beta",
    "spec": {
      "footer": {
        "*": {
          "totalSchools": "=intSum(@(1,totalSchools))"
        }
      }
    }
	}
, {
    "operation": "modify-overwrite-beta",
    "spec": {
      "*": {
        "totalSchools": "=intSum(@(1,totalSchools))"
      }
    }
	}
]
'' as jolt_spec;
create or replace view Infra_jolt_cluster_map
as select ''
[{
    "operation": "shift",
    "spec": {
      "*": {
        "district_id": "data.[&1].details.district_id",
        "block_id": "data.[&1].details.block_id",
        "cluster_id": "data.[&1].details.cluster_id",
        "cluster_latitude": "data.[&1].details.latitude",
        "cluster_longitude": "data.[&1].details.longitude",
        "district_name": "data.[&1].details.district_name",
        "block_name": "data.[&1].details.block_name",
        "cluster_name": "data.[&1].details.cluster_name",
        "infra_score": "data.[&1].details.infrastructure_score",
        "average_value": "data.[&1].details.average_value",
        "average_percent": "data.[&1].details.average_percent",
'||infra_map_percent_cols||','||composite_inframap_1_cols||','||composite_inframap_2_cols||',
        "total_schools": "data.[&1].total_schools",
        "@total_schools_data_received": "data.[&1].details.total_schools_data_received",
        "total_schools_data_received": "footer.@(1,block_id).totalSchools[]"
      }
    }
	},
  {
    "operation": "shift",
    "spec": {
      "data": {
        "*": {
          "details": "data.[&1].&",
          "metrics": "data.[&1].&",
          "@details.total_schools_data_received": "allClustersFooter.totalSchools[]"
        }
      },
      "footer": "&"
    }
	},
  {
    "operation": "modify-overwrite-beta",
    "spec": {
      "footer": {
        "*": {
          "totalSchools": "=intSum(@(1,totalSchools))"
        }
      }
    }
	}
, {
    "operation": "modify-overwrite-beta",
    "spec": {
      "*": {
        "totalSchools": "=intSum(@(1,totalSchools))"
      }
    }
	}
]
''as jolt_spec;
create or replace view Infra_jolt_school_map
as select ''
[{
		"operation": "modify-overwrite-beta",
		"spec": {
			"*": {
				"cluster_id": ["=toString", null]
			}
		}
	},
  {
		"operation": "shift",
		"spec": {
			"*": {
				"district_id": "data.[&1].details.district_id",
				"block_id": "data.[&1].details.block_id",
				"cluster_id": "data.[&1].details.cluster_id",
              "school_id": "data.[&1].details.school_id",
				"school_latitude": "data.[&1].details.latitude",
				"school_longitude": "data.[&1].details.longitude",
				"district_name": "data.[&1].details.district_name",
				"block_name": "data.[&1].details.block_name",
				"cluster_name": "data.[&1].details.cluster_name",
              "school_name": "data.[&1].details.school_name",
				"infra_score": "data.[&1].details.infrastructure_score",
				"average_value": "data.[&1].details.average_value",
				"average_percent": "data.[&1].details.average_percent",
'||infra_map_percent_cols||','||composite_inframap_1_cols||','||composite_inframap_2_cols||',
				"total_schools": "data.[&1].total_schools",
				"@total_schools_data_received": "data.[&1].details.total_schools_data_received",
				"total_schools_data_received": "footer.@(1,cluster_id).totalSchools[]"
			}
		}
	}, {
		"operation": "shift",
		"spec": {
			"data": {
				"*": {
					"details": "data.[&1].&",
					"metrics": "data.[&1].&",
					"@details.total_schools_data_received": "allSchoolsFooter.totalSchools[]"
				}
			},
			"footer": "&"
		}
	},
	{
		"operation": "modify-overwrite-beta",
		"spec": {
			"footer": {
				"*": {
					"totalSchools": "=intSum(@(1,totalSchools))"
				}
			}
		}
	}, {
		"operation": "modify-overwrite-beta",
		"spec": {
			"*": {
				"totalSchools": "=intSum(@(1,totalSchools))"
			}
		}
	}
]
''as jolt_spec;';
Execute jolt_map_query;
END IF;
return 0;
END;
$$
LANGUAGE plpgsql;

/*Create jolt spec for Infra reports*/

select Infra_jolt_spec('water','toilet');


/*truncate infra init tables*/

truncate table infrastructure_staging_init;


CREATE OR REPLACE FUNCTION infra_areas_to_focus()
RETURNS text AS
$$
DECLARE
school_atf text:='select ''select school_id, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_view)  then ''''''||
 case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_school_table_view'' 
from infrastructure_master where status = true order by 1';
school_atf_value text; 
cluster_atf text:='select ''select cluster_id, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_cluster_table_view'' 
from infrastructure_master where status = true order by 1';
cluster_atf_value text; 
block_atf text:='select ''select block_id, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_block_table_view'' 
from infrastructure_master where status = true order by 1';
block_atf_value text; 
district_atf text:='select ''select district_id, array[''||string_agg(''case when ''||
replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent<(select abs(avg(coalesce(''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent,0))::int-5) from infra_district_table_view)  then ''''''||
case when infrastructure_name ~* ''^[^aeyiuo]+$'' then replace(trim(upper(infrastructure_name)),''_'','' '')
else replace(trim(initcap(infrastructure_name)),''_'','' '') end ||'''''' else ''''0'''' end'','','')||
'']as areas_to_focus from infra_district_table_view'' 
from infrastructure_master where status = true order by 1';
district_atf_value text; 
query text;
BEGIN
Execute district_atf into district_atf_value;
Execute school_atf into school_atf_value;
Execute cluster_atf into cluster_atf_value;
Execute block_atf into block_atf_value;
IF school_atf <> '' THEN 
query='create or replace view infra_district_atf as 
select district_id,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||district_atf_value||') as a;
create or replace view infra_school_atf as 
select school_id,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||school_atf_value||') as a;
create or replace view infra_cluster_atf as 
select cluster_id,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||cluster_atf_value||') as a;
create or replace view infra_block_atf as 
select block_id,array_remove(areas_to_focus,''0'')as areas_to_focus from ('||block_atf_value||') as a;';
Execute query; 
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_areas_to_focus();

/*school - infra*/
create or replace view hc_infra_school as
select b.*,atf.areas_to_focus,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by school_id)as ist
on idt.school_id= ist.school_id) as b
left join(select usc.school_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state, 
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by school_id)as ist
on idt.school_id= ist.school_id) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from infra_school_table_view)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from infra_school_table_view as scl
left join 
(SELECT cluster_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_cluster FROM   infra_school_table_view group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_block FROM   infra_school_table_view group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_district FROM   infra_school_table_view group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,infra_score
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id
left join infra_school_atf as atf on b.school_id=atf.school_id;

/*cluster*/

create or replace view hc_infra_cluster as
select b.*,atf.areas_to_focus,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_cluster_table_view as idt
left join
(select cluster_id,
sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by cluster_id)as ist
on idt.cluster_id= ist.cluster_id) as b
left join(select usc.cluster_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                           
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_cluster_table_view as idt
left join
(select cluster_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by cluster_id)as ist
on idt.cluster_id= ist.cluster_id) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from infra_school_table_view)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from infra_school_table_view as scl
left join
(SELECT block_id,Count(DISTINCT infra_school_table_view.cluster_id) AS clusters_in_block FROM   infra_school_table_view group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT infra_school_table_view.cluster_id) AS clusters_in_district FROM   infra_school_table_view group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by infra_score
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id
left join infra_cluster_atf as atf on b.cluster_id=atf.cluster_id;

/*block*/


create or replace view  hc_infra_block as
select b.*,atf.areas_to_focus,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_view as idt
left join
(select block_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by block_id)as ist
on idt.block_id= ist.block_id) as b
left join(select usc.block_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_view as idt
left join
(select block_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by block_id)as ist
on idt.block_id= ist.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from infra_school_table_view)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from infra_school_table_view as scl
left join
(SELECT district_id,Count(DISTINCT infra_school_table_view.block_id) AS blocks_in_district FROM   infra_school_table_view group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by infra_score
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id
left join infra_block_atf as atf on b.block_id=atf.block_id;


/*district*/

create or replace view hc_infra_district as 
select idt.*,atf.areas_to_focus,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
(select *,((rank () over ( order by infra_score desc))||' out of '||(select count(distinct(district_id)) 
from infra_district_table_view)) as district_level_rank_within_the_state,coalesce(1-round(( Rank() over (ORDER BY infra_score DESC) / ((select count(distinct(district_id)) from infra_district_table_view)*1.0)),2)) as state_level_score from infra_district_table_view) as idt
left join
(select district_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by district_id)as ist
on idt.district_id= ist.district_id
left join infra_district_atf as atf on idt.district_id=atf.district_id;


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

/* Infrstructure management changes */

create or replace FUNCTION infra_district_mgt_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_district_table_mgt_view as 
select d.district_id,
initcap(c.district_name)as district_name,c.total_schools,d.total_schools_data_received,c.infra_score,
d.average_value,d.average_percent,'||select_1_cols||',c.school_management_type,'||'''overall_category'''||' as school_category from (
select district_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||',school_management_type
 from school_infrastructure_score where school_management_type is not null group by district_id,school_management_type)as d
inner join 
(select a.district_id,a.district_name,a.total_schools,c.infra_score,a.school_management_type 
from 
(select district_id,district_name,count(distinct(school_id)) as total_schools,school_management_type from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and school_management_type is not null
  group by district_id,district_name,school_management_type)as a 
inner join (select district_id,'||select_infra_score_cols||',school_management_type
from infra_score_view where school_management_type is not null group by district_id,school_management_type) as c on a.district_id=c.district_id and a.school_management_type=c.school_management_type) as c
on d.district_id=c.district_id and d.school_management_type=c.school_management_type';
infra_map= 'create or replace view infra_district_map_mgt_view as 
select d.district_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,c.district_latitude,c.district_longitude,c.school_management_type,'||'''overall_category'''||' as school_category
 from (
select district_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||',school_management_type from school_infrastructure_score where school_management_type is not null group by district_id,school_management_type)as d
inner join 
(select a.district_id,a.district_name,b.district_latitude,b.district_longitude,c.infra_score,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,school_management_type
 from 
(select district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by district_id,district_name)as a inner join 
(select district_id,district_latitude,district_longitude from school_geo_master 
  group by district_id,district_latitude,district_longitude)as b
 on a.district_id=b.district_id
 inner join (select district_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||',school_management_type
from infra_score_view where school_management_type is not null group by district_id,school_management_type) as c on a.district_id=c.district_id)as c
on d.district_id=c.district_id and d.school_management_type=c.school_management_type';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_district_mgt_reports('water','toilet');


create or replace FUNCTION infra_block_mgt_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_block_table_mgt_view as 
select d.block_id,
initcap(c.block_name)as block_name,c.district_id,initcap(c.district_name)as district_name,c.total_schools,
d.total_schools_data_received,c.infra_score,d.average_value,d.average_percent,'||select_1_cols||',c.school_management_type,'||'''overall_category'''||' as school_category
 from (
select block_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||',school_management_type
from school_infrastructure_score where school_management_type is not null group by block_id,school_management_type) as d
inner join 
(select a.block_id,a.block_name,a.district_id,a.district_name,a.total_schools,c.infra_score,c.school_management_type from 
(select block_id,block_name,district_id,district_name,count(distinct(school_id)) as total_schools,school_management_type from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and school_management_type is not null
  group by block_id,block_name,district_id,district_name,school_management_type)as a
inner join (select block_id,'||select_infra_score_cols||',school_management_type
from infra_score_view where school_management_type is not null group by block_id,school_management_type) as c on a.block_id=c.block_id and a.school_management_type=c.school_management_type) as c
on d.block_id=c.block_id and d.school_management_type=c.school_management_type';
infra_map= 'create or replace view infra_block_map_mgt_view as 
select d.block_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.block_name)as block_name,c.district_id,c.block_latitude,c.block_longitude,c.school_management_type,'||'''overall_category'''||' as school_category
from 
(select block_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||',school_management_type from school_infrastructure_score where school_management_type is not null group by block_id,school_management_type)as d
inner join 
(select a.block_id,a.block_name,a.district_id,a.district_name,b.block_latitude,b.block_longitude,c.infra_score,c.school_management_type,
  c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select block_id,block_name,district_id,district_name from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null
  group by block_id,block_name,district_id,district_name)as a inner join 
(select block_id,block_latitude,block_longitude from school_geo_master 
  group by block_id,block_latitude,block_longitude)as b
 on a.block_id=b.block_id
 inner join (select block_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||',school_management_type 
from infra_score_view where school_management_type is not null group by block_id,school_management_type)as c on a.block_id=c.block_id)as c
on d.block_id=c.block_id and d.school_management_type=c.school_management_type';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_block_mgt_reports('water','toilet');


create or replace FUNCTION infra_cluster_mgt_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_cluster_table_mgt_view as 
select d.cluster_id,
initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,
c.district_id,initcap(c.district_name)as district_name,c.total_schools,d.total_schools_data_received,
c.infra_score,d.average_value,d.average_percent,'||select_1_cols||',c.school_management_type,'||'''overall_category'''||' as school_category from 
(
select cluster_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||',school_management_type
from school_infrastructure_score where school_management_type is not null group by cluster_id,school_management_type ) as d
inner join 
(select a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,a.total_schools,c.infra_score,c.school_management_type from 
(select cluster_id,cluster_name,block_id,block_name,district_id,district_name,count(distinct(school_id)) as total_schools,school_management_type from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null and school_management_type is not null
  group by cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type)as a
inner join (select cluster_id,'||select_infra_score_cols||',school_management_type
from infra_score_view where school_management_type is not null group by cluster_id,school_management_type) as c on a.cluster_id=c.cluster_id and a.school_management_type=c.school_management_type) as c
on d.cluster_id=c.cluster_id and d.school_management_type=c.school_management_type';
infra_map= 'create or replace view infra_cluster_map_mgt_view as 
select d.cluster_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,c.district_id,c.cluster_latitude,c.cluster_longitude,c.school_management_type,'||'''overall_category'''||' as school_category
from 
(select cluster_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||',school_management_type 
 from school_infrastructure_score where school_management_type is not null group by cluster_id,school_management_type)as d
inner join 
(select a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.cluster_latitude,b.cluster_longitude,c.infra_score,c.school_management_type
,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select cluster_id,cluster_latitude,cluster_longitude from school_geo_master 
  group by cluster_id,cluster_latitude,cluster_longitude)as b
 on a.cluster_id=b.cluster_id
 inner join (select cluster_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||',school_management_type
from infra_score_view where school_management_type is not null group by cluster_id,school_management_type)as c on a.cluster_id=c.cluster_id)as c
on d.cluster_id=c.cluster_id and d.school_management_type=c.school_management_type';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_cluster_mgt_reports('water','toilet');


create or replace FUNCTION infra_school_mgt_reports(category_1 text,category_2 text)
RETURNS text AS
$$
DECLARE
select_infra_score text:= 'select concat(''round(coalesce(''||''SUM('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),
  '')/count(distinct(school_id)),0),0) as infra_score'') as a from infrastructure_master where status = true order by 1';
select_infra_score_cols text;
select_average_value text:= 'select concat(''sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')
||'' =0 then 0 else 1 end)'',''/'',''(select count(infrastructure_name) from infrastructure_master where status=true) as average_value'') 
from infrastructure_master where status = true order by 1';
select_average_value_cols text;
select_average_percent text:= 'select concat(''round((sum(case when '',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end + case when '')||'' =0 then 0 else 1 end)'',''/'',
''(select count(infrastructure_name) from infrastructure_master where status=true))*100.0/count(distinct(school_id)),0) as average_percent'') 
from infrastructure_master where status = true order by 1';
select_average_percent_cols text;
select_infra_value text:= 'select string_agg(concat(''sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),'' =0 then 0 else 1 end) as '',
replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_value'','','') from infrastructure_master where status = true order by 1';
select_infra_value_cols text;
select_infra_percent text:= 'select string_agg(concat(''round(sum(case when '',replace(trim(LOWER(infrastructure_name)),'' '',''_''),
'' =0 then 0 else 1 end)*100.0/count(distinct(school_id)),0)as '',replace(trim(LOWER(infrastructure_name)),'' '',''_''))||''_percent'','','')  
 from infrastructure_master where status = true order by 1';
select_infra_percent_cols text;
select_1 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_value''||'',''||''d.''
||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_1_cols text;
select_2 text:='select string_agg(''d.''||replace(trim(LOWER(infrastructure_name)),'' '',''_'')||''_percent'','','')
 from infrastructure_master where status = true order by 1';
select_2_cols text;
composite_infra_1 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_1||''''') ),0),0) as access_to_'||category_1||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_1||''' order by 1';
composite_infra_1_cols text;
composite_infra_2 text:='select concat(''round(coalesce(sum('',string_agg(replace(trim(LOWER(infrastructure_name)),'' '',''_''),''+''),'')*100.0/(count(distinct(school_id))* (select sum(score) from infrastructure_master
where infrastructure_category ='''''||category_2||''''') ),0),0) as access_to_'||category_2||'_percent'')
from infrastructure_master where status = true and infrastructure_category ='''||category_2||''' order by 1';
composite_infra_2_cols text;
composite_1 text;
infra_table text;
infra_map text;
BEGIN
Execute select_infra_score into select_infra_score_cols;
Execute select_average_value into select_average_value_cols;
Execute select_average_percent into select_average_percent_cols;
Execute select_infra_value into select_infra_value_cols;
Execute select_infra_percent into select_infra_percent_cols;
Execute composite_infra_1 into composite_infra_1_cols;
Execute composite_infra_2 into composite_infra_2_cols;
Execute select_1 into select_1_cols;
Execute select_2 into select_2_cols;
IF select_infra_score_cols <> '' THEN 
infra_table= 'create or replace view infra_school_table_mgt_view as 
select d.school_id,
initcap(c.school_name)as school_name,c.cluster_id,initcap(c.cluster_name)as cluster_name,c.block_id,
initcap(c.block_name)as block_name,c.district_id,initcap(c.district_name)as district_name,c.total_schools
,d.total_schools_data_received,c.infra_score,d.average_value,d.average_percent,'||select_1_cols||',c.school_management_type,'||'''overall_category'''||' as school_category from 
(
  select school_id,count(distinct(school_id)) as total_schools_data_received,'||select_average_value_cols||',
'||select_average_percent_cols||','||select_infra_value_cols||','||select_infra_percent_cols||',school_management_type
 from school_infrastructure_score where school_management_type is not null group by school_id,school_management_type ) as d
inner join 
(select a.school_id,a.school_name,a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,a.total_schools,c.infra_score,c.school_management_type from 
(select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,count(distinct(school_id)) as total_schools,school_management_type from school_hierarchy_details where cluster_name is not null and block_name is not null and school_name is not null and school_management_type is not null
  group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name,school_management_type)as a
inner join (select school_id,'||select_infra_score_cols||',school_management_type
from infra_score_view where school_management_type is not null group by school_id,school_management_type)as c on a.school_id=c.school_id and a.school_management_type=c.school_management_type) as c
on d.school_id=c.school_id';
infra_map= 'create or replace view infra_school_map_mgt_view as 
select d.school_id,d.total_schools_data_received,c.infra_score,'||select_2_cols||',c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent,
initcap(c.district_name)as district_name,initcap(c.school_name)as school_name,
c.cluster_id,initcap(c.cluster_name)as cluster_name,c.block_id,initcap(c.block_name)as block_name,c.district_id,c.school_latitude,c.school_longitude,c.school_management_type,'||'''overall_category'''||' as school_category 
from 
(select school_id,count(distinct(school_id)) as total_schools_data_received,'||select_infra_percent_cols||',school_management_type 
  from school_infrastructure_score where school_management_type is not null group by school_id,school_management_type)as d
inner join 
(select a.school_id,a.school_name,a.cluster_id,a.cluster_name,a.block_id,a.block_name,a.district_id,a.district_name,b.school_latitude,b.school_longitude,c.infra_score,c.school_management_type 
  ,c.access_to_'||category_1||'_percent,c.access_to_'||category_2||'_percent from 
(select school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name from school_hierarchy_details 
  where cluster_name is not null and block_name is not null and school_name is not null
  group by school_id,school_name,cluster_id,cluster_name,block_id,block_name,district_id,district_name)as a inner join 
(select school_id,school_latitude,school_longitude from school_geo_master 
  group by school_id,school_latitude,school_longitude)as b
 on a.school_id=b.school_id
 inner join (select school_id,'||select_infra_score_cols||','||composite_infra_1_cols||',
 '||composite_infra_2_cols||',school_management_type
from infra_score_view where school_management_type is not null group by school_id,school_management_type) as c on a.school_id=c.school_id)as c
on d.school_id=c.school_id';
Execute infra_table; 
Execute infra_map;
END IF;
return 0;
END;
$$LANGUAGE plpgsql;

select infra_school_mgt_reports('water','toilet');

/* health card infra  queries*/
/*school - infra*/
create or replace view hc_infra_school as
select b.*,atf.areas_to_focus,c.school_level_rank_within_the_state,
c.school_level_rank_within_the_district,c.school_level_rank_within_the_block,c.school_level_rank_within_the_cluster,c.state_level_score from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by school_id)as ist
on idt.school_id= ist.school_id) as b
left join(select usc.school_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.cluster_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_cluster) ) AS school_level_rank_within_the_cluster,
( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_block) ) AS school_level_rank_within_the_block, 
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.schools_in_district) ) AS school_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_schools) AS school_level_rank_within_the_state, 
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_schools*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_school_table_view as idt
left join
(select school_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by school_id)as ist
on idt.school_id= ist.school_id) as usc
left join
(select a.*,(select count(DISTINCT(school_id)) from infra_school_table_view)as total_schools 
from (select school_id,c.cluster_id,schools_in_cluster,b.block_id,schools_in_block,d.district_id,schools_in_district from infra_school_table_view as scl
left join 
(SELECT cluster_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_cluster FROM   infra_school_table_view group by cluster_id) as c
on scl.cluster_id=c.cluster_id
left join
(SELECT block_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_block FROM   infra_school_table_view group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT infra_school_table_view.school_id) AS schools_in_district FROM   infra_school_table_view group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.school_id=a.school_id
group by usc.school_id,infra_score
,a.cluster_id,a.block_id,a.district_id,a.total_schools) as c
ON b.school_id = c.school_id
left join infra_school_atf as atf on b.school_id=atf.school_id;

/*cluster*/

create or replace view hc_infra_cluster as
select b.*,atf.areas_to_focus,c.cluster_level_rank_within_the_state,
c.cluster_level_rank_within_the_district,c.cluster_level_rank_within_the_block,c.state_level_score from 
(select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_cluster_table_view as idt
left join
(select cluster_id,
sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by cluster_id)as ist
on idt.cluster_id= ist.cluster_id) as b
left join(select usc.cluster_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.block_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_block) ) AS cluster_level_rank_within_the_block,
( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.clusters_in_district) ) AS cluster_level_rank_within_the_district, 
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_clusters) AS cluster_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_clusters*1.0)),2)) AS state_level_score                           
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_cluster_table_view as idt
left join
(select cluster_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by cluster_id)as ist
on idt.cluster_id= ist.cluster_id) as usc
left join
(select a.*,(select count(DISTINCT(cluster_id)) from infra_school_table_view)as total_clusters
from (select distinct(scl.cluster_id),clusters_in_block,b.block_id,clusters_in_district,d.district_id from infra_school_table_view as scl
left join
(SELECT block_id,Count(DISTINCT infra_school_table_view.cluster_id) AS clusters_in_block FROM   infra_school_table_view group by block_id)as b
on scl.block_id=b.block_id
left join 
(SELECT district_id,Count(DISTINCT infra_school_table_view.cluster_id) AS clusters_in_district FROM   infra_school_table_view group by district_id) as d
on scl.district_id=d.district_id)as a)as a
on usc.cluster_id=a.cluster_id
group by infra_score
,usc.cluster_id,a.total_clusters,a.block_id,a.district_id) as c
ON b.cluster_id = c.cluster_id
left join infra_cluster_atf as atf on b.cluster_id=atf.cluster_id;

/*block*/

create or replace view  hc_infra_block as
select b.*,atf.areas_to_focus,c.block_level_rank_within_the_state,
c.block_level_rank_within_the_district,c.state_level_score from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_view as idt
left join
(select block_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by block_id)as ist
on idt.block_id= ist.block_id) as b
left join(select usc.block_id,infra_score,
       ( ( Rank()
             over (
               PARTITION BY a.district_id
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         || sum(a.blocks_in_district) ) AS block_level_rank_within_the_district,
( ( Rank()
             over (
               ORDER BY usc.infra_score DESC)
           || ' out of ' :: text )
         ||  a.total_blocks) AS block_level_rank_within_the_state,
coalesce(1-round(( Rank()
             over (
               ORDER BY usc.infra_score DESC) / (a.total_blocks*1.0)),2)) AS state_level_score                         
 from (select idt.*,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
infra_block_table_view as idt
left join
(select block_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by block_id)as ist
on idt.block_id= ist.block_id) as usc
left join
(select a.*,(select count(DISTINCT(block_id)) from infra_school_table_view)as total_blocks
from (select distinct(scl.block_id),blocks_in_district,d.district_id from infra_school_table_view as scl
left join
(SELECT district_id,Count(DISTINCT infra_school_table_view.block_id) AS blocks_in_district FROM   infra_school_table_view group by district_id)as d
on scl.district_id=d.district_id)as a)as a
on usc.block_id=a.block_id
group by infra_score
,usc.block_id,a.total_blocks,a.district_id) as c
ON b.block_id = c.block_id
left join infra_block_atf as atf on b.block_id=atf.block_id;


/*district*/

create or replace view hc_infra_district as 
select idt.*,atf.areas_to_focus,ist.value_below_33,ist.value_between_33_60,ist.value_between_60_75,ist.value_above_75 from 
(select *,((rank () over ( order by infra_score desc))||' out of '||(select count(distinct(district_id)) 
from infra_district_table_view)) as district_level_rank_within_the_state,coalesce(1-round(( Rank() over (ORDER BY infra_score DESC) / ((select count(distinct(district_id)) from infra_district_table_view)*1.0)),2)) as state_level_score from infra_district_table_view) as idt
left join
(select district_id,
 sum(case when infra_score <=33 then 1 else 0 end)as value_below_33,
 sum(case when infra_score > 33 and infra_score<=60 then 1 else 0 end)as value_between_33_60,
 sum(case when infra_score > 60 and infra_score<=75 then 1 else 0 end)as value_between_60_75,
 sum(case when infra_score >75 then 1 else 0 end)as value_above_75
   from infra_school_table_view group by district_id)as ist
on idt.district_id= ist.district_id
left join infra_district_atf as atf on idt.district_id=atf.district_id;

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

