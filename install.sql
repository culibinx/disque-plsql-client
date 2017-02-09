set scan off;

prompt Creating Java module

@./setup/jsock_java.sql

prompt Creating packages

@./setup/simple_tcp_client.pks
@./setup/simple_tcp_client.pkb

prompt Creating types

@./setup/t_array_type.sql
@./setup/socket_type.sql
@./setup/socket_type_body.sql
@./setup/disque_type.sql
@./setup/disque_type_body.sql

prompt Creating demo packages

@./demos/disque_test.pks
@./demos/disque_test.pkb

prompt Done!