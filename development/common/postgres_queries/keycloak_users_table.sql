/* table creation statement */
create table if not exists keycloak_users(
keycloak_username text,
status varchar(100),
qr_secret text,
primary key(keycloak_username));

/* inserting record */
insert into keycloak_users(keycloak_username,status) values('admin','true');

