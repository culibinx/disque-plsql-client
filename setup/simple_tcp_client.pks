--------------------------------------------------------
--  DDL for Package SIMPLE_TCP_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "SIMPLE_TCP_CLIENT" 
as
	-- A function to connect to a host. Returns a 'socket',
	-- which is really just a number.
	
	function connect_to( p_hostname in varchar2, p_portno in number ) return number;

	-- Send data. We only know how to send RAW data here. Callers
	-- must cast VARCHAR2 data to RAW. At the lowest level, all
	-- data on a socket is really just 'bytes'.

	procedure send( p_sock in number, p_data in raw );

	-- recv will receive data.
	-- If maxlength is -1, we try for 4k of data. If maxlength
	-- is set to anything OTHER than -1, we attempt to
	-- read up to the length of p_data bytes. In other words,
	-- I restrict the receives to 4k unless otherwise told not to.
	
	procedure recv( p_sock in number, p_data out raw, p_maxlength in number default -1 );
 

	-- Gets a line of data from the input socket. That is, data
	-- up to a \n.
 
 	procedure getline( p_sock in number, p_data out raw );
 


	-- Disconnects from a server you have connected to.
 
	procedure disconnect( p_sock in number );
 

	-- Gets the server time in GMT in the format yyyyMMdd HHmmss z
 
	procedure get_gmt( p_gmt out varchar2 );
 

	-- Gets the server's timezone. Useful for some Internet protocols.
 
	procedure get_timezone( p_timezone out varchar2 );
 

	-- Gets the hostname of the server you are running on. Again,
	-- useful for some Internet protocols.
 
	procedure get_hostname( p_hostname out varchar2 );
 

	-- Returns the number of bytes available to be read.
 
	function peek( p_sock in number ) return number;
  
  -- Enable/disable SO_TIMEOUT with the specified timeout, in milliseconds. 
  -- With this option set to a non-zero timeout, a read() call on the InputStream 
  -- associated with this Socket will block for only this amount of time. 
  -- If the timeout expires, a java.net.SocketTimeoutException is raised, 
  -- though the Socket is still valid. 
  -- The option must be enabled prior to entering the blocking operation to have effect. 
  -- The timeout must be > 0. A timeout of zero is interpreted as an infinite timeout.
  
  procedure set_timeout( p_sock in number, p_timeout in number );
  
  -- Enable/disable TCP_NODELAY (disable/enable Nagle's algorithm)
  
  procedure set_tcp_no_delay( p_sock in number, p_on in number );
  
  -- Enable/disable SO_KEEPALIVE
  
  procedure set_keep_alive( p_sock in number, p_on in number );
  
end;

/