/* Infra tables*/

/* infrastructure_staging_init */

create table if not exists infrastructure_staging_init
(  infrastructure_name varchar(30),
   infrastructure_category varchar(20),
   status boolean,
   created_on timestamp,
   updated_on timestamp
); 

/* infrastructure_staging_score */

create table if not exists infrastructure_staging_score
(  infrastructure_name varchar(30),
   infrastructure_category varchar(20),
   score numeric DEFAULT 0 not null,
   created_on timestamp,
   updated_on timestamp
); 

/* infrastructure_hist */

create table if not exists infrastructure_hist
(
id serial,
school_id bigint,
inspection_id bigint,
infrastructure_name varchar(20), 
new_value int,
old_value int,
created_on TIMESTAMP without time zone,
operation varchar(20)
);

/* infrastructure_master */

create sequence if not exists infra_seq;
alter sequence infra_seq restart; 

create table if not exists infrastructure_master
(  infrastructure_id text CHECK (infrastructure_id ~ '^infrastructure_[0-9]+$' ) 
                                    DEFAULT 'infrastructure_'  || nextval('infra_seq'),
   infrastructure_name varchar(30),
   infrastructure_category varchar(20),
   score numeric DEFAULT 0 not null,
   status boolean,
   created_on timestamp,
   updated_on timestamp,
primary key(infrastructure_name,infrastructure_id)
); 

/*Table name: infra_null_col*/

create table if not exists infra_null_col( filename varchar(200),
 ff_uuid varchar(200),
count_null_schoolid int);

