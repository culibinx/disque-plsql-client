--------------------------------------------------------
--  DDL for Type SOCKETTYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SOCKETTYPE" 
as object
(
	-- 'Private data', rather than you
	-- passing a context to each procedure, like you
	-- do with UTL_FILE.
	g_sock number,
  
  -- A function to return a CRLF. Just a convenience.
	static function crlf return varchar2,
  
  -- Procedures to send data over a socket.
	member procedure send( p_data in varchar2 ),
	member procedure send( p_data in clob ),

	member procedure send_raw( p_data in raw ),
	member procedure send_raw( p_data in blob ),

	-- Functions to receive data from a socket. These return
	-- Null on eof. They will block waiting for data. If
	-- this is not desirable, use PEEK below to see if there
	-- is any data to read.
	member function recv return varchar2,
	member function recv_raw return raw,
  
	-- Convienence function. Reads data until a CRLF is found.
	-- Can strip the CRLF if you like (or not, by default).
	member function getline( p_remove_crlf in boolean default FALSE ) return varchar2,

	-- Procedures to connect to a host and disconnect from a host.
	-- It is important to disconnect, else you will leak resources
	-- and eventually will not be able to connect.
	member procedure initiate_connection( p_hostname in varchar2, p_portno in number ),
	member procedure close_connection,

	-- Function to tell you how many bytes (at least) might be
	-- ready to be read.
	member function peek return number
  
  
);
/