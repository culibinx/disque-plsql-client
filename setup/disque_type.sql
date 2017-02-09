--------------------------------------------------------
--  DDL for Type DISQUETYPE
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE TYPE "DISQUETYPE" 
as object
(
	-- Private data
	
  -- Socket number
  g_sock number,
  
  -- Helper functions
  
  static function crlf return varchar2,
  
  static function count_by_delimeter(p_data in varchar2, 
    p_delimeter in varchar2 default ',')
  return number,
  static function element_by_delimeter(p_data in varchar2, 
    p_delimeter in varchar2 default ',', 
    p_position in number default 1)
  return varchar,
  
  static function count_by_prefix(p_data in varchar2, 
    p_prefix in varchar2, p_length in number)
  return number,
  static function element_by_prefix(p_data in varchar2, 
    p_prefix in varchar2, p_length in number, 
    p_position in number default 1)
  return varchar,
  
  static function to_array(p_data in varchar2, 
    p_delimeter in varchar2 default ',')
  return t_array,
  static procedure print_array(p_array in t_array),
  
  -- Socket functions
	
  member procedure open( p_hostname in varchar2, p_portno in number ),
	member procedure set_timeout( p_timeout in number ),
  member procedure set_tcp_no_delay( p_on in number ),
  member procedure set_keep_alive( p_on in number ),
  member procedure close,
  
  -- Receive buffer functions
  
  member function recv(
    p_max_size in number default -1, p_min_size in number default -1) 
  return varchar2,
  member function recv_clob(
    p_max_size in number default -1, p_min_size in number default -1) 
  return clob,
  
  -- Protocol specific functions
  
  member procedure send_count( p_count in number ),
  member procedure send_name( p_name in varchar2 ),
  member procedure send_number( p_number in number ),
  member procedure send_data( p_data in varchar2 ),
  member procedure send_command_for_jobs( 
    p_command in varchar2, 
    p_data in varchar2, 
    p_max in number default 0 ),
  
  member function reply(
    p_max_size in number,
    p_body in varchar2, 
    p_param_name in varchar2 default 'any',
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return varchar2,
  
  member function reply(
    p_max_size in number,
    p_body in clob, 
    p_param_name in varchar2 default 'any',
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return varchar2,
  
  member function reply(
    p_body in clob, 
    p_param_name in varchar2 default 'any', 
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return clob,
  
  member function reply_elements_count(p_body in varchar2)
  return number,
  member function reply_elements_count(p_body in clob)
  return number,
  
  -- API commands
  
  -- Common
  
  member procedure ping,
  member procedure hello,
  member procedure info,
  
  -- Scan queue
  
  member procedure jscan( 
    p_queue in varchar2 default null,
    p_count in number default 0, 
    p_state in varchar2 default null, 
    p_reply in varchar2 default null,
    p_busyloop in number default 0,
    p_cursor in number default -1),
  member procedure qscan( 
    p_count in number default 0, 
    p_minlen in number default 0, 
    p_maxlen in number default 0, 
    p_importrate in number default 0,
    p_busyloop in number default 0, 
    p_cursor in number default -1),
  
  -- Stats and manipulate state of queue
  
  member procedure qstat( p_queue in varchar2 ),
  member procedure qlen( p_queue in varchar2 ),
  member procedure pause( p_queue in varchar2, p_option in varchar2 ),
  
  -- Append job to queue
  
  member procedure addjob( p_queue in varchar2, p_body in varchar2, 
    p_timeout in number default 0, p_replicate in number default 0, 
    p_delay in number default 0, p_retry in number default 0, 
    p_ttl in number default 0, p_maxlen in number default 0, 
    p_async in number default 0 ),
  
  -- Get jobs from queue
  
  member procedure getjob( p_queue in varchar2, 
    p_count in number default 1, p_nohang in number default 1, 
    p_timeout in number default 0, p_withcounters in number default 0 ),
  member procedure getjob( p_queue in t_array, 
    p_count in number default 1, p_nohang in number default 1, 
    p_timeout in number default 0, p_withcounters in number default 0 ),
  member procedure qpeek( p_queue in varchar2, p_count in number default 1 ),
  
  -- Manipulate jobs in queue
  
  member procedure show( p_job in varchar2 ),
  member procedure enqueue( p_job in varchar2 ),
  member procedure dequeue( p_job in varchar2 ),
  member procedure deljob( p_job in varchar2 ),
  
  -- Working cycle with jobs
  
  member procedure ackjob( p_job in varchar2 ),
  member procedure working( p_job in varchar2 ),
  member procedure nack( p_job in varchar2 ),
  member procedure fastack( p_job in varchar2 )
  
);
/