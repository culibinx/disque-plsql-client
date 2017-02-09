--------------------------------------------------------
--  DDL for Type SOCKETTYPE BODY
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE TYPE BODY "SOCKETTYPE" 
as

  -- Private data

	static function crlf return varchar2
	is
	begin
		return chr(13)||chr(10);
	end;
  
  -- Socket functions
  
  member procedure initiate_connection( p_hostname in varchar2, p_portno in number )
	is
		l_data varchar2(4069);
	begin
		-- we try to connect 10 times and if the tenth time
		-- fails, we reraise the exception to the caller
		for i in 1 .. 10 loop
		begin
			g_sock := simple_tcp_client.connect_to( p_hostname, p_portno );
    		exit;
		exception
    		when others then
        		if ( i = 10 ) then raise; end if;
		end;
		end loop;
	end;
  
  member procedure close_connection
	is
	begin
		simple_tcp_client.disconnect( g_sock );
		g_sock := NULL;
	end;
  
  member function peek return number
	is
	begin
		return simple_tcp_client.peek( g_sock );
	end;
  
  member procedure send( p_data in varchar2 )
	is
	begin
		simple_tcp_client.send( g_sock, utl_raw.cast_to_raw(p_data) );
	end;

	member procedure send_raw( p_data in raw )
	is
	begin
		simple_tcp_client.send( g_sock, p_data );
	end;

	member procedure send( p_data in clob )
	is
		l_offset number default 1;
		l_length number default dbms_lob.getlength(p_data);
		l_amt number default 4096;
	begin
		loop
			exit when l_offset > l_length; 
			simple_tcp_client.send( g_sock, utl_raw.cast_to_raw( dbms_lob.substr(p_data,l_amt,l_offset) ) );
			l_offset := l_offset + l_amt;
		end loop;
	end;

	member procedure send_raw( p_data in blob )
	is
		l_offset number default 1;
		l_length number default dbms_lob.getlength(p_data);
		l_amt number default 4096;
	begin
		loop
			exit when l_offset > l_length; 
			simple_tcp_client.send( g_sock, dbms_lob.substr(p_data,l_amt,l_offset) ); l_offset := l_offset + l_amt;
		end loop;
	end;

  member function recv return varchar2
	is
		l_raw_data raw(4096);
	begin
		simple_tcp_client.recv( g_sock, l_raw_data );
		return utl_raw.cast_to_varchar2(l_raw_data);
	end;
  
  member function recv_raw return raw 
	is
		l_raw_data raw(4096);
	begin
		simple_tcp_client.recv( g_sock, l_raw_data );
		return l_raw_data;
	end;
  
  member function getline( p_remove_crlf in boolean default FALSE )
	return varchar2
	is
		l_raw_data raw(4096);
	begin
		simple_tcp_client.getline( g_sock, l_raw_data );
		if ( p_remove_crlf ) then 
			return rtrim(utl_raw.cast_to_varchar2(l_raw_data), SocketType.crlf ); 
		else 
			return utl_raw.cast_to_varchar2(l_raw_data);
		end if;
	end;
  
end;

/