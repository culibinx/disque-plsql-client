--------------------------------------------------------
--  DDL for Package Body SIMPLE_TCP_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "SIMPLE_TCP_CLIENT" 
as
	function connect_to( p_hostname in varchar2, p_portno in number ) return number
	as language java
	name 'jsock.java_connect_to( java.lang.String, int ) return int';
	
	procedure send( p_sock in number, p_data in raw ) 
	as language java
	name 'jsock.java_send_data( int, byte[] )';
	
	procedure recv_i ( p_sock in number, p_data out raw, p_maxlength in out number )
	as language java
	name 'jsock.java_recv_data( int, byte[][], int[] )';
	
	procedure recv( p_sock in number, p_data out raw, p_maxlength in number default -1 )
	is
		l_maxlength number default p_maxlength;
	begin
		recv_i( p_sock, p_data, l_maxlength ); 
		if ( l_maxlength <> -1 )
		then
			p_data := utl_raw.substr( p_data, 1, l_maxlength ); 
		else
			p_data := NULL;
		end if;
	end;

	procedure getline_i( p_sock in number, p_data out varchar2 )
	as language java
	name 'jsock.java_getline( int, java.lang.String[] )';

	procedure getline( p_sock in number, p_data out raw )
	as
		l_data long;
	begin
		getline_i( p_sock, l_data );
		p_data := utl_raw.cast_to_raw( l_data );
	end getline;

	procedure disconnect( p_sock in number )
	as language java
	name 'jsock.java_disconnect( int )';

	procedure get_gmt( p_gmt out varchar2 )
	as language java
	name 'jsock.java_get_gmt( java.lang.String[] )';

	procedure get_timezone( p_timezone out varchar2 )
	as language java
	name 'jsock.java_get_timezone( java.lang.String[] )';

	procedure get_hostname( p_hostname out varchar2 )
	as language java
	name 'jsock.java_get_hostname( java.lang.String[] )';

	function peek( p_sock in number ) return number
	as language java
	name 'jsock.java_peek_sock( int ) return int';
  
  procedure set_timeout( p_sock in number, p_timeout in number ) 
	as language java
	name 'jsock.java_timeout_sock( int, int )';
  
  procedure set_tcp_no_delay( p_sock in number, p_on in number ) 
	as language java
	name 'jsock.java_tcp_no_delay_sock( int, int )';
  
  procedure set_keep_alive( p_sock in number, p_on in number ) 
	as language java
	name 'jsock.java_keep_alive_sock( int, int )';
  
end;

/