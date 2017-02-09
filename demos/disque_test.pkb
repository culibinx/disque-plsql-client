--------------------------------------------------------
--  DDL for Package Body DISQUE_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DISQUE_TEST" 
as
  
  procedure test_size_recv( p_hostname in varchar2, p_portno in number )
  is
    s DisqueType := DisqueType(null);
    
    v_min_recv_size number := 7;
    v_max_recv_size number := 7;
    v_recv_buffer varchar2(7);
    
    v_max_reply_size number := 4;
    v_reply_buffer varchar2(4);
    
  begin
    -- connect -------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    -- ping ----------------------------------------------
    s.ping;
    -- get response
    v_recv_buffer := s.recv(v_max_recv_size,v_min_recv_size);
    -- parse response
    v_reply_buffer := s.reply(v_max_reply_size, v_recv_buffer);
    -- check
    dbms_output.put_line( 'min receive size: ' || v_min_recv_size);
    dbms_output.put_line( 'max receive size: ' || v_max_recv_size );
    dbms_output.put_line( 'max parse response size: ' || v_max_reply_size );
    dbms_output.put_line( 'receive buffer length: ' || length(v_recv_buffer) );
     dbms_output.put_line( 'parse response buffer length: ' || length(v_reply_buffer) );
    dbms_output.put_line( '> PING:' || v_reply_buffer );
    
    -- disconnect -----------------------------------------
    s.close;
  end;
  
  procedure test_add_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue',
    p_body in varchar2 default 'simple message ' || TO_CHAR(dbms_random.value(1,10)))
  is
    s DisqueType := DisqueType(null);
    
    v_recv_buffer varchar2(4096);
    v_max_recv_size number := 4096;
    v_recv_clob clob;
    
    v_reply_buffer varchar2(4096);
    v_max_reply_size number := 4096;
    
    v_job_id varchar2(40);
    
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_param_clob clob;
    
  begin
    -- connect ------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    -- addjob -------------------------------------------
    s.addjob(p_queue, p_body);
    -- get response
    v_recv_buffer := s.recv(v_max_recv_size);
    -- parse response
    v_reply_buffer := s.reply(v_max_reply_size, v_recv_buffer);
    -- check response
    if (length(v_reply_buffer) = 40) then 
      dbms_output.put_line( '> ADDJOB: ' || v_reply_buffer );
      v_job_id := v_reply_buffer;
    else
      dbms_output.put_line( '> ADDJOB: return error' );
      return; 
    end if;
    
    -- show job info ---------------------------------------
    s.show(v_job_id);
    -- get response
    -- response may be very long, take this in clob
    v_recv_clob := s.recv_clob();
    dbms_output.put_line( '> SHOW:' || v_job_id );
    
    -- multiple iterate in response body for target parameters
    
    v_param_name := 'id';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    -- queue value may be very long, take this in clob
    v_param_name := 'queue';
    v_param_clob := s.reply(v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_clob );
    
    v_param_name := 'state';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'repl';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'ttl';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
  
    v_param_name := 'ctime';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'delay';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'retry';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'nacks';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'additional-deliveries';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    -- nodes-delivered become with sub parameters, pass position for each sub parameter
    v_param_name := 'nodes-delivered';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 1);
    dbms_output.put_line( v_param_name || '[1]:' || v_param_value );
    
    v_param_name := 'nodes-delivered';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 2);
    dbms_output.put_line( v_param_name || '[2]:' || v_param_value );
    
    -- nodes-confirmed become with sub parameters, pass position for each sub parameter
    v_param_name := 'nodes-confirmed';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 1);
    dbms_output.put_line( v_param_name || '[1]:' || v_param_value );
    
    v_param_name := 'nodes-confirmed';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 2);
    dbms_output.put_line( v_param_name || '[2]:' || v_param_value );
    
    v_param_name := 'next-requeue-within';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'next-awake-within';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    -- body value may be to very long, take this in clob
    v_param_name := 'body';
    v_param_clob := s.reply(v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_clob );
    
    -- disconnect ---------------------------------------------------
    s.close;
  end;
  
  procedure test_scan_queues( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' )
  is
    s DisqueType := DisqueType(null);
    
    v_max_recv_size number := 4096;
    v_recv_buffer varchar2(4096);
    
    v_max_reply_size number := 4096;
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_job_id varchar2(40);
    v_cursor number;
    v_index number;
    
  begin
    -- connect ------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    dbms_output.put_line( '> QSCAN [MAX 2]:' );
    s.qscan(2);
    -- get response
    v_recv_buffer := s.recv(v_max_recv_size);
    
    -- parse response
    -- queue one
    v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 1, 1);
    dbms_output.put_line( 'queue[1]:' || v_param_value ); 
    -- queue two
    v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 2, 1);
    dbms_output.put_line( 'queue[2]:' || v_param_value ); 
    
    -- parse cursor
    v_cursor := TO_NUMBER(s.reply(v_max_reply_size, v_recv_buffer, null));
    if (v_cursor > 0) then
      dbms_output.put_line( 'next queues exists with cursor:' || v_cursor );
    else
      dbms_output.put_line( 'no more queues' );
    end if;
    
    dbms_output.put_line( '> QSCAN [ONE QUEUE PER REQUEST MAX 10]:' );
    -- jscan for only one job per request -------------------------------------------
    v_cursor := -1;
    v_index := 1;
    loop
      s.qscan(1, 0, 0, 0, 0, v_cursor);
      -- get response
      v_recv_buffer := s.recv(v_max_recv_size);
      -- parse response (set p_pass_error_in_out=0 for not handling error value)
      v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 1, 1, 0);
      dbms_output.put_line( 'queue[' || v_index || ']:' || v_param_value ); 
      -- parse cursor
      v_cursor := TO_NUMBER(s.reply(v_max_reply_size, v_recv_buffer, null));
      dbms_output.put_line( 'cursor for next queue:' || v_cursor );
      --
      v_index := v_index + 1;
      exit when v_cursor = 0 or v_index > 10 or length(v_param_value) = 0;
    end loop;
    
    
    -- disconnect ---------------------------------------------------
    s.close;
  end;
  
  procedure test_scan_jobs( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' )
  is
    s DisqueType := DisqueType(null);
    
    v_max_recv_size number := 4096;
    v_recv_buffer varchar2(4096);
    
    v_max_reply_size number := 4096;
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_job_id varchar2(40);
    v_cursor number;
    v_index number;
    
  begin
    -- connect ------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    dbms_output.put_line( '> JSCAN [MAX 2]:' );
    s.jscan(p_queue, 2);
    -- get response
    v_recv_buffer := s.recv(v_max_recv_size);
    
    -- parse response
    -- job one
    v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 1, 1);
    dbms_output.put_line( 'job[1]:' || v_param_value ); 
    -- job two
    v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 2, 1);
    dbms_output.put_line( 'job[2]:' || v_param_value ); 
    
    -- parse cursor
    v_cursor := TO_NUMBER(s.reply(v_max_reply_size, v_recv_buffer, null));
    if (v_cursor > 0) then
      dbms_output.put_line( 'next jobs exists with cursor:' || v_cursor );
    else
      dbms_output.put_line( 'no more jobs' );
    end if;
    
    dbms_output.put_line( '> JSCAN [ONE JOB PER REQUEST MAX 10]:' );
    -- jscan for only one job per request -------------------------------------------
    v_cursor := -1;
    v_index := 1;
    loop
      s.jscan(p_queue, 1, null, null, 0, v_cursor);
      -- get response
      v_recv_buffer := s.recv(v_max_recv_size);
      -- parse response (set p_pass_error_in_out=0 for not handling error value)
      v_param_value := s.reply(v_max_reply_size, v_recv_buffer, 'any', 1, 1, 0);
      dbms_output.put_line( 'job[' || v_index || ']:' || v_param_value ); 
      -- parse cursor
      v_cursor := TO_NUMBER(s.reply(v_max_reply_size, v_recv_buffer, null));
      dbms_output.put_line( 'cursor for next job:' || v_cursor );
      --
      v_index := v_index + 1;
      exit when v_cursor = 0 or v_index > 10 or length(v_param_value) = 0;
    end loop;
    
    
    -- disconnect ---------------------------------------------------
    s.close;
  end;
  
  procedure test_stat_queue( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' )
  is
    s DisqueType := DisqueType(null);
    
    v_recv_buffer varchar2(4096);
    v_max_recv_size number := 4096;
    v_recv_clob clob;
    
    v_reply_buffer varchar2(4096);
    v_max_reply_size number := 4096;
    
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_param_clob clob;
    
  begin
    -- connect -------------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    -- qlen -----------------------------------------------------
    s.qlen(p_queue);
    -- get response
    v_recv_buffer := s.recv(v_max_recv_size);
    -- parse response
    v_reply_buffer := s.reply(v_max_reply_size, v_recv_buffer);
    -- check response
    dbms_output.put_line( '> QLEN:' || v_reply_buffer );
    
    -- qstat ----------------------------------------------------
    s.qstat(p_queue);
    -- get response
    -- response may be very long, take this in clob
    v_recv_clob := s.recv_clob();
    dbms_output.put_line( '> QSTAT:' );
    
    -- multiple iterate in response body for target parameters
    
    -- queue value may be very long, take this in clob
    v_param_name := 'name';
    v_param_clob := s.reply(v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_clob );
    
    v_param_name := 'len';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'age';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'idle';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'blocked';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    -- import-from become with sub parameters, pass position for each sub parameter
    v_param_name := 'import-from';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 1);
    dbms_output.put_line( v_param_name || '[1]:' || v_param_value );
    
    v_param_name := 'import-from';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name, 1);
    dbms_output.put_line( v_param_name || '[2]:' || v_param_value );
    
    v_param_name := 'import-rate';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'jobs-in';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'jobs-out';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    v_param_name := 'pause';
    v_param_value := s.reply(v_max_reply_size, v_recv_clob, v_param_name);
    dbms_output.put_line( v_param_name || ':' || v_param_value );
    
    -- disconnect
    s.close;
  end;
  
  procedure test_working_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' )
  is
    s DisqueType := DisqueType(null);
    
    v_recv_buffer varchar2(4096);
    v_max_recv_size number := 4096;
    v_recv_clob clob;
    
    v_reply_buffer varchar2(4096);
    v_max_reply_size number := 4096;
    
    v_job_id varchar2(40);
    
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_param_clob clob;
    
    v_count number;
    
  begin
    -- connect ------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    -- getjob for two jobs nohang -------------------------------------------
    s.getjob(p_queue, 2);
    -- get response
    -- response may be very long, take this in clob
    v_recv_clob := s.recv_clob();
    
    -- get count elements
    v_count := s.reply_elements_count(v_recv_clob);
    dbms_output.put_line( '> GETJOB:' || v_count);
    
    -- multiple iterate in response body for target parameters
    -- response become with sub parameters, pass position for each sub parameter
    
    -- [ First job ]
    if (v_count > 0) then
      dbms_output.put_line( '[ First job ]' );
      -- queue value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 1, 1);
      dbms_output.put_line( 'queue[1][1]:' || v_param_clob );
    
      v_param_value := s.reply(v_max_reply_size, v_recv_clob, 'any', 2, 1);
      dbms_output.put_line( 'jobid[1][2]:' || v_param_value );
    
      -- get job id for manipulate
      if (length(v_param_value) = 40) then
        v_job_id := v_param_value;
      end if;
      
      -- body value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 3, 1);
      dbms_output.put_line( 'body[1][3]:' || v_param_clob );
    
    end if;  
    
    --v_job_id := 'D-66954a7e-RGrGRolxcf/6+nAISFs0dI38-05a1';
    
    if (v_count > 0 and length(v_job_id) > 0) then
      
      dbms_output.put_line( '=> Try working job with id:' || v_job_id );
      -- working job ------------------------------------------------------
      s.working(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> WORKING:' || v_reply_buffer );
      
      -- after working with job ~ 300 sec use
      -- nack or ackjob or fastack or 
      -- dequeue or deljob or again enqueue
      -- or set new working state
      
      dbms_output.put_line( '=> Try nack job with id:' || v_job_id );
      -- nack job ------------------------------------------------------
      s.nack(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> NACK:' || v_reply_buffer );
      
      dbms_output.put_line( '=> Try dequeue job with id:' || v_job_id );
      -- dequeue job ------------------------------------------------------
      s.dequeue(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> DEQUEUE:' || v_reply_buffer );
      
      dbms_output.put_line( '=> Try enqueue job with id:' || v_job_id );
      -- enqueue job ------------------------------------------------------
      s.enqueue(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> ENQUEUE:' || v_reply_buffer );
      
      dbms_output.put_line( '=> Try ack job with id:' || v_job_id );
      -- ack job ------------------------------------------------------
      s.ackjob(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> ACKJOB:' || v_reply_buffer );
      
      -- after ACKJOB attempt change state on working raise error
      
      dbms_output.put_line( '=> For error try working job with id:' || v_job_id );
      -- working job ------------------------------------------------------
      s.working(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> WORKING:' || v_reply_buffer );
      
    end if;
    
    -- [ Second job ]
    if (v_count > 1) then
      dbms_output.put_line( '[ Second job ]' );
      -- queue value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 1, 2);
      dbms_output.put_line( 'queue[2][1]:' || v_param_clob );
    
      v_param_value := s.reply(v_max_reply_size, v_recv_clob, 'any', 2, 2);
      dbms_output.put_line( 'jobid[2][2]:' || v_param_value );
      
      -- get job id for manipulate
      if (length(v_param_value) = 40) then
        v_job_id := v_param_value;
      end if;
    
      -- body value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 3, 2);
      dbms_output.put_line( 'body[2][3]:' || v_param_clob );
    end if;
    
    if (v_count > 1 and length(v_job_id) > 0) then
      
      dbms_output.put_line( '=> Try working job with id:' || v_job_id );
      -- working job ------------------------------------------------------
      s.working(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> WORKING:' || v_reply_buffer );
      
      dbms_output.put_line( '=> Try nack job with id:' || v_job_id );
      -- nack job ------------------------------------------------------
      s.nack(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> NACK:' || v_reply_buffer );
      
      dbms_output.put_line( '=> Try fastack job with id:' || v_job_id );
      -- fastack job ------------------------------------------------------
      s.fastack(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> FASTACK:' || v_reply_buffer );
      
      -- after FASTACK attempt to delete job raise error
      
      dbms_output.put_line( '=> For error try del job with id:' || v_job_id );
      -- del job ------------------------------------------------------
      s.deljob(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> DELJOB:' || v_reply_buffer );
    
    end if;
    
    -- disconnect ---------------------------------------------------
    s.close;
  end;
  
  procedure test_del_job( 
    p_hostname in varchar2, 
    p_portno in number, 
    p_queue in varchar2 default 'test_stat_queue' )
  is
    s DisqueType := DisqueType(null);
    
    v_recv_buffer varchar2(4096);
    v_max_recv_size number := 4096;
    v_recv_clob clob;
    
    v_reply_buffer varchar2(4096);
    v_max_reply_size number := 4096;
    
    v_job_id varchar2(40);
    
    v_param_name varchar2(4096);
    v_param_value varchar2(4096);
    v_param_clob clob;
    
    v_count number;
    
  begin
    -- connect ------------------------------------------
    s.open( p_hostname, p_portno );
    s.set_timeout(25);
    s.set_tcp_no_delay(1);
    s.set_keep_alive(1);
    dbms_output.put_line( '------------------------------' );
    
    -- qpeek for two jobs -------------------------------------------
    s.qpeek(p_queue, 2);
    -- get response
    -- response may be very long, take this in clob
    v_recv_clob := s.recv_clob();
    
    -- get count elements
    v_count := s.reply_elements_count(v_recv_clob);
    dbms_output.put_line( '> QPEEK:' || v_count);
    
    -- multiple iterate in response body for target parameters
    -- response become with sub parameters, pass position for each sub parameter
    
    -- [ First job ]
    if (v_count > 0) then
      dbms_output.put_line( '[ First job ]' );
      -- queue value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 1, 1);
      dbms_output.put_line( 'queue[1][1]:' || v_param_clob );
    
      v_param_value := s.reply(v_max_reply_size, v_recv_clob, 'any', 2, 1);
      dbms_output.put_line( 'jobid[1][2]:' || v_param_value );
    
      -- get job id for delete
      if (length(v_param_value) = 40) then
        v_job_id := v_param_value;
      end if;
      
      -- body value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 3, 1);
      dbms_output.put_line( 'body[1][3]:' || v_param_clob );
    end if;  
    
    
    -- [ Second job ]
    if (v_count > 1) then
      dbms_output.put_line( '[ Second job ]' );
      -- queue value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 1, 2);
      dbms_output.put_line( 'queue[2][1]:' || v_param_clob );
    
      v_param_value := s.reply(v_max_reply_size, v_recv_clob, 'any', 2, 2);
      dbms_output.put_line( 'jobid[2][2]:' || v_param_value );
    
      -- body value may be very long, take this in clob
      v_param_clob := s.reply(v_recv_clob, 'any', 3, 2);
      dbms_output.put_line( 'body[2][3]:' || v_param_clob );
    end if;
    
    if (v_count > 0 and length(v_job_id) > 0) then
      dbms_output.put_line( 'Try delete job with id:' || v_job_id );
      -- del job ------------------------------------------------------
      s.deljob(v_job_id);
      -- get and parse response
      v_reply_buffer := s.reply(v_max_reply_size, s.recv(v_max_recv_size));
      -- check response
      dbms_output.put_line( '> DELJOB:' || v_reply_buffer );
    end if;
    
    -- disconnect ---------------------------------------------------
    s.close;
  end;
  
  
end;

/