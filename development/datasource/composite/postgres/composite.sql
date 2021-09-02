
/* composite config */

CREATE TABLE IF NOT EXISTS composite_config ( 
 id serial,
 template text, 
 status boolean,
 select_query text,
 table_join text,
 category text,
 jolt_spec text,
 primary key(template,category)
);

