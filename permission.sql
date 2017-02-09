--------------------------------------------------------
--  DDL for setting permission
--------------------------------------------------------

-- run as user SYS:
-- set target SCHEMA

dbms_java.grant_permission(
	grantee => &&your_schema,
	permission_type => 'java.net.SocketPermission',
	permission_name => '*',
	permission_action => 'connect,resolve' );

/