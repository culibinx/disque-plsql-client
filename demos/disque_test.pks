--------------------------------------------------------
--  DDL for Package DISQUE_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "DISQUE_TEST" 
as
  procedure test_size_recv( 
    p_hostname in varchar2, 
    p_portno in number );
  procedure test_add_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue',
    p_body in varchar2 default 'simple message ' || TO_CHAR(dbms_random.value(1,10)));
  procedure test_stat_queue( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' );
  procedure test_scan_queues( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' );
  procedure test_scan_jobs( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' );
  procedure test_working_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' );
  procedure test_del_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' );
    
end;

/