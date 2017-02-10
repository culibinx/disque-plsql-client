--------------------------------------------------------
--  DDL for Type DISQUETYPE BODY
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE TYPE BODY "DISQUETYPE" 
as

  -- Helper functions

	static function crlf return varchar2
	is
	begin
		return chr(13)||chr(10);
	end;
  
  static function count_by_delimeter(p_data in varchar2, 
    p_delimeter in varchar2 default ',')
  return number
  is
    v_count number := 0;
    v_length number := length(p_data);
    v_length_delimeter number := length(p_delimeter);
    v_start number := 1;
    v_end number;
  begin
    if (p_data is null or v_length = 0) then return v_count; end if;
    if (v_length_delimeter is null or v_length_delimeter = 0) then 
      v_count := v_count + 1;
      return v_count; 
    end if;
    loop
      v_end := instr(p_data, p_delimeter, v_start);
      if (v_end = v_start) then
        v_start := v_start + v_length_delimeter;
      else
        if (v_end > 0) then
          v_count := v_count + 1;
          v_start := v_end + v_length_delimeter;
        else
          v_count := v_count + 1;
          exit;
        end if;
      end if;
      exit when v_start > v_length;
    end loop;
    return v_count;
  end;
  
  static function element_by_delimeter(p_data in varchar2, 
    p_delimeter in varchar2 default ',', 
    p_position in number default 1)
  return varchar
  is
    v_position number := 1;
    v_length number := length(p_data);
    v_length_delimeter number := length(p_delimeter);
    v_start number := 1;
    v_end number;
  begin
    if (p_data is null or v_length = 0) then return ''; end if;
    if (p_delimeter is null or v_length_delimeter = 0) then 
      return p_data; 
    end if;
    loop
      v_end := instr(p_data, p_delimeter, v_start);
      if (v_end = v_start) then
        v_start := v_start + v_length_delimeter;
      else
        if (v_end > 0) then
          if (v_position = p_position) then 
            return substr(p_data, v_start, v_end - v_start);
          end if;
          v_position := v_position + 1;
          v_start := v_end + v_length_delimeter;
        else
          if (v_position = p_position) then 
            return substr(p_data, v_start, v_length - v_start + 1);
          end if;
          exit;
        end if;
      end if;
      exit when v_start > v_length;
    end loop;
    return '';
  end;
  
  static function count_by_prefix(p_data in varchar2, 
    p_prefix in varchar2, p_length in number)
  return number
  is
    v_count number := 0;
    v_length number := length(p_data);
    v_length_prefix number := length(p_prefix);
    v_start number := 1;
    v_find number;
  begin
    if (p_length = 0 or v_length_prefix = 0 or v_length = 0) then 
      return v_count; 
    end if;
    loop
      v_find := instr(p_data, p_prefix, v_start);
      if (v_find > 0 and (v_find + p_length <= v_length + 1)) then
        v_count := v_count + 1;
        v_start := v_find + p_length;
      else exit; end if;
    end loop;
    return v_count;
  end;
  
  static function element_by_prefix(p_data in varchar2, 
    p_prefix in varchar2, p_length in number, 
    p_position in number default 1)
  return varchar
  is
    v_position number := 1;
    v_length number := length(p_data);
    v_length_prefix number := length(p_prefix);
    v_start number := 1;
    v_find number;
  begin
    if (p_length = 0 or v_length_prefix = 0 or v_length = 0) then 
      return ''; 
    end if;
    loop
      v_find := instr(p_data, p_prefix, v_start);
      if (v_find > 0 and (v_find + p_length <= v_length + 1)) then
        if (v_position = p_position) then 
          return substr(p_data, v_find, p_length);
        end if;
        v_position := v_position + 1;
        v_start := v_find + p_length;
      else exit; end if;
    end loop;
    return '';
  end;
  
  static function to_array(p_data in varchar2, 
    p_delimeter in varchar2 default ',')
  return t_array
  is
    v_array t_array := t_array();
    v_length number := length(p_data);
    v_length_delimeter number := length(p_delimeter);
    v_start number := 1;
    v_end number;
  begin
    if (p_data is null or v_length = 0) then return v_array; end if;
    if (p_delimeter is null or v_length_delimeter = 0) then 
      v_array.extend;
      v_array(v_array.count) := p_data;
      return v_array; 
    end if;
    loop
      v_end := instr(p_data, p_delimeter, v_start);
      if (v_end = v_start) then
        v_start := v_start + v_length_delimeter;
      else
        if (v_end > 0) then
          v_array.extend;
          v_array(v_array.count) := substr(p_data, v_start, v_end - v_start);
          v_start := v_end + v_length_delimeter;
        else
          v_array.extend;
          v_array(v_array.count) := substr(p_data, v_start, v_length - v_start + 1);
          exit;
        end if;
      end if;
      exit when v_start > v_length;
    end loop;
    return v_array;
  end;
  
  static procedure print_array(p_array in t_array)
  is
  begin
    for i in 1 .. p_array.count loop
      dbms_output.put_line(p_array(i));
    end loop;
  end;
  
  -- Socket functions
  
  member procedure open( p_hostname in varchar2, p_portno in number )
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
  
  member procedure set_timeout( p_timeout in number )
	is
	begin
		simple_tcp_client.set_timeout( g_sock, p_timeout );
	end;
  
  member procedure set_tcp_no_delay( p_on in number )
	is
	begin
		simple_tcp_client.set_tcp_no_delay( g_sock, p_on );
	end;
  
  member procedure set_keep_alive( p_on in number )
	is
	begin
		simple_tcp_client.set_keep_alive( g_sock, p_on );
	end;
  
  member procedure close
	is
	begin
		simple_tcp_client.disconnect( g_sock );
		g_sock := NULL;
	end;
  
  -- Receive buffer functions
  
  member function recv(
    p_max_size in number default -1, 
    p_min_size in number default -1) 
  return varchar2
	is
		l_raw_data raw(4096);
    v_buffer varchar2(4096);
    v_min_size number := p_min_size;
    v_max_size number := p_max_size;
    v_body varchar2(32767);
    v_length number := 0;
    v_written number := 0;
    v_pos_end number;
	begin
    if (v_min_size = 0 or v_max_size = 0) then return v_body; end if;
    if (v_min_size = -1 and v_max_size = -1) then 
      simple_tcp_client.recv( g_sock, l_raw_data );
      return utl_raw.cast_to_varchar2(l_raw_data);
    end if;
    if (v_min_size <= -1 or v_min_size > 4096) then v_min_size := 4096; end if;
    if (p_max_size < 0 or p_max_size > 32767) then v_max_size := 32767; end if;
    loop
      simple_tcp_client.recv( g_sock, l_raw_data, v_min_size );
      v_buffer := utl_raw.cast_to_varchar2(l_raw_data);
      exit when v_buffer is null or ascii(substr(v_buffer, 1, 1)) = 0;
      if (v_max_size > 0)
      then 
        v_length := LEAST(v_max_size - v_written, length(v_buffer));
        if (v_length = 0) then exit; end if;
        v_body := v_body || substr(v_buffer, 1, v_length);
        v_written := v_written + v_length;
      else
        v_body := v_body || v_buffer;
      end if;
      if (length(v_buffer) < v_min_size) then exit; end if;
    end loop;
    return v_body;
	end;
  
  member function recv_clob(
    p_max_size in number default -1, 
    p_min_size in number default -1) 
  return clob
	is
		l_raw_data raw(4096);
    v_buffer varchar2(4096);
    v_min_size number := p_min_size;
    v_max_size number := p_max_size;
    v_body clob;
    v_length number := 0;
    v_written number := 0;
    v_pos_end number;
	begin
    if (v_min_size = 0 or v_max_size = 0) then return v_body; end if;
    if (v_min_size = -1 and v_max_size = -1) then 
      simple_tcp_client.recv( g_sock, l_raw_data );
      v_body := v_body || utl_raw.cast_to_varchar2(l_raw_data);
      return v_body; 
    end if;
    if (v_min_size <= -1 or v_min_size > 4096) then v_min_size := 4096; end if;
    loop
      simple_tcp_client.recv( g_sock, l_raw_data, v_min_size );
      v_buffer := utl_raw.cast_to_varchar2(l_raw_data);
      exit when v_buffer is null or ascii(substr(v_buffer, 1, 1)) = 0;
      if (v_max_size > 0)
      then 
        v_length := LEAST(v_max_size - v_written, length(v_buffer));
        if (v_length = 0) then exit; end if;
        v_body := v_body || substr(v_buffer, 1, v_length);
        v_written := v_written + v_length;
      else
        v_body := v_body || v_buffer;
      end if;
      if (length(v_buffer) < v_min_size) then exit; end if;
    end loop;
    return v_body;
	end;
  
	-- Protocol specific functions
  
  member procedure send_count( p_count in number )
	is
	begin
		simple_tcp_client.send( g_sock, utl_raw.cast_to_raw('*'||TO_CHAR(p_count)||DisqueType.CRLF));
	end;
  
  member procedure send_name( p_name in varchar2 )
	is
	begin
		simple_tcp_client.send( g_sock, utl_raw.cast_to_raw('$'||length(p_name)||DisqueType.CRLF||p_name||DisqueType.CRLF));
  end;
  
  member procedure send_number( p_number in number )
	is
	begin
		simple_tcp_client.send( g_sock, utl_raw.cast_to_raw('$'||length(TO_CHAR(p_number))||DisqueType.CRLF||TO_CHAR(p_number)||DisqueType.CRLF));
	end;
  
  member procedure send_data( p_data in varchar2 )
	is
	begin
		simple_tcp_client.send( g_sock, utl_raw.cast_to_raw('$'||length(convert(p_data,'UTF8','US7ASCII'))||DisqueType.CRLF||p_data||DisqueType.CRLF));
	end;
  
  member procedure send_command_for_jobs( 
    p_command in varchar2, 
    p_data in varchar2, 
    p_max in number default 0 )
	is
		v_params number := 1;
    v_count number := DisqueType.count_by_prefix(p_data, 'D-', 40);
	begin
		
    if (v_count = 0) then return; 
    else 
      if (p_max > 0) then v_params := v_params + LEAST(p_max, v_count); 
      else v_params := v_params + v_count; end if;
    end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(p_command);
    -- job
    for i in 1 .. v_count loop
      simple_tcp_client.send( g_sock, utl_raw.cast_to_raw('$40'||DisqueType.CRLF||DisqueType.element_by_prefix(p_data, 'D-', 40, i)||DisqueType.CRLF));
      if (p_max > 0 and p_max = i) then exit; end if;
    end loop;
    
	end;
  
  
  member function reply(
    p_max_size in number,
    p_body in varchar2, 
    p_param_name in varchar2 default 'any',
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return varchar2
  is 
    v_delim varchar2(2) := DisqueType.CRLF;
    v_delim_length number := 2;
    v_param_name varchar2(32767);
    v_param_position number := 1;
    v_element_position number := 1;
    v_length  number := length(p_body);
    v_start number := 1;
    v_end number;
    v_ch   varchar2(1);
    v_total number;
    v_subtotal number;
    v_numb number;
    v_temp number;

  begin
    if (p_body is null or v_length = 0) then return ''; end if;
    -- get parameters
    v_ch := substr(p_body, v_start, 1);
    if (v_ch = '+' or v_ch = ':' or v_ch = '-') then 
      v_start := v_start + 1;
      v_end := instr(p_body, v_delim, v_start);
      if (v_ch = '-') then
        -- for out error
        if (v_end < 1) then return ''; else
          if (p_pass_error_in_out > 0) then
            return substr(p_body, v_start, LEAST(v_end - v_start, p_max_size));
          else
            dbms_output.put_line('error:' || substr(p_body, v_start, LEAST(v_end - v_start, 32767)));
          end if;
        end if;
        return '';
      else
        -- for ok
        if (v_end < 1) then return ''; else
          return substr(p_body, v_start, LEAST(v_end - v_start, p_max_size));
        end if;
      end if;
    elsif (v_ch = '$') then
      v_start := v_start + 1;
      v_end := instr(p_body, v_delim, v_start);
      if (v_end < 1) then return ''; else
        -- get parameter value length
        v_numb := to_number(substr(p_body, v_start, v_end - v_start));
        v_start := v_end + v_delim_length;
        if (v_numb > 0) then
          -- return parameter value string
          return substr(p_body, v_start, LEAST(v_numb, p_max_size));
        end if;
      end if;
    elsif (v_ch = '*') then
      v_start := v_start + 1;
      v_end := instr(p_body, v_delim, v_start);
      if (v_end < 1) then return ''; else
        -- get count parameters
        v_total := to_number(substr(p_body, v_start, v_end - v_start));
        v_start := v_end + v_delim_length;
        if (v_total > 0) then
          -- index out parameter
          if (p_element_position > v_total) then
              return '';
          end if;
          -- cycle
          v_element_position := 1;
          loop
            v_temp := v_start;
            -- get parameter name
            v_ch := substr(p_body, v_start, 1);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get parameter name length
                v_numb := to_number(substr(p_body, v_start, v_end - v_start));
                v_start := v_end + v_delim_length;
                if (v_numb > 0) then
                  -- return parameter name if need
                  if (p_param_name is null) then
                    return substr(p_body, v_start, LEAST(v_numb, p_max_size));
                  end if;
                  -- get parameter name string
                  v_param_name := substr(p_body, v_start, LEAST(v_numb, 32767));
                  v_start := v_start + v_numb + v_delim_length; 
                end if;
              end if;
            end if;
            -- end get parameter name
            
            -- get parameter value
            v_ch := substr(p_body, v_start, 1);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get parameter value length
                v_numb := to_number(substr(p_body, v_start, v_end - v_start));
                if (v_numb > 0) then
                  v_start := v_end + v_delim_length;
                  -- get parameter value string
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    return substr(p_body, v_start, LEAST(v_numb, p_max_size));
                  end if;
                  v_start := v_start + v_numb + v_delim_length; 
                else
                  -- parameter value is empty
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    return '';
                  end if;
                end if;
              end if;
              -- end get parameter value string
            elsif (v_ch = ':') then
              v_start := v_start + 1;
              v_end := instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                if (p_param_name = 'any' or v_param_name = p_param_name) then
                  return substr(p_body, v_start, LEAST(v_end - v_start, p_max_size));
                end if;
                v_start := v_end + v_delim_length;
              end if;
              -- end get parameter value count
            elsif (v_ch = '*') then
              v_start := v_start + 1;
              v_end := instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get count sub parameters
                v_subtotal := to_number(substr(p_body, v_start, v_end - v_start));
                v_start := v_end + v_delim_length;
                if (v_subtotal > 0) then
                  -- index out sub parameter
                  if (p_param_position > v_subtotal and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                      return '';
                  end if;
                  -- cycle
                  v_param_position := 1;
                  loop
                    -- get sub parameter
                    v_ch := substr(p_body, v_start, 1);
                    if (v_ch = '$') then
                      v_start := v_start + 1;
                      v_end := instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return ''; else
                        -- get sub parameter length
                        v_numb := to_number(substr(p_body, v_start, v_end - v_start));
                        v_start := v_end + v_delim_length;
                        if (v_numb > 0) then
                          -- get sub parameter value string
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            return substr(p_body, v_start, LEAST(v_numb, p_max_size));
                          end if;
                          v_start := v_start + v_numb + v_delim_length; 
                        else
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            -- sub parameter value empty
                            return '';
                          end if;
                        end if;
                      end if;
                    elsif (v_ch = '+') then
                      v_start := v_start + 1;
                      v_end := dbms_lob.instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return ''; else
                        if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            return substr(p_body, v_start, LEAST(v_end - v_start, p_max_size));
                        end if;
                        v_start := v_end + v_delim_length; 
                      end if;
                    end if;
                    -- check get sub parameter
                    v_subtotal := v_subtotal - 1;
                    v_param_position := v_param_position + 1;
                    exit when v_subtotal = 0; 
                    -- end get sub parameter
                  end loop;
                end if;
              end if;
              -- end get parameter sub parameters
            end if;
            -- end get parameter value
            v_total := v_total - 1;
            v_element_position := v_element_position + 1;
            -- return name only value
            exit when v_total = 0 or v_temp = v_start or v_start >= v_length;
          end loop;
        else
          -- *-1
          if (p_pass_error_in_out > 0) then
            return to_char(v_total);
          else
            dbms_output.put_line('error: empty data');
          end if;
        end if;
        -- end get total parameters
      end if;
    end if;
    -- return
    return '';
  
  end;
  
  member function reply(
    p_max_size in number,
    p_body in clob, 
    p_param_name in varchar2 default 'any',
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return varchar2
  is 
    v_delim varchar2(2) := DisqueType.CRLF;
    v_delim_length number := 2;
    v_param_name varchar2(32767);
    v_param_position number := 1;
    v_element_position number := 1;
    v_length  number := dbms_lob.getlength(p_body);
    v_start number := 1;
    v_end number;
    v_ch   varchar2(1);
    v_total number;
    v_subtotal number;
    v_numb number;
    v_temp number;

  begin
    if (p_body is null or v_length = 0) then return ''; end if;
    -- get parameters
    v_ch := dbms_lob.substr(p_body, 1, v_start);
    if (v_ch = '+' or v_ch = ':' or v_ch = '-') then 
      v_start := v_start + 1;
      v_end := dbms_lob.instr(p_body, v_delim, v_start);
      if (v_ch = '-') then
        -- for out error
        if (v_end < 1) then return ''; else
          if (p_pass_error_in_out > 0) then
            return dbms_lob.substr(p_body, LEAST(v_end - v_start, p_max_size), v_start);
          else
            dbms_output.put_line('error:' || dbms_lob.substr(p_body, LEAST(v_end - v_start, 32767), v_start));
          end if;
        end if;
        return '';
      else
        -- for ok
        if (v_end < 1) then return ''; else
          return dbms_lob.substr(p_body, LEAST(v_end - v_start, p_max_size), v_start);
        end if;
      end if;
    elsif (v_ch = '$') then
      v_start := v_start + 1;
      v_end := instr(p_body, v_delim, v_start);
      if (v_end < 1) then return ''; else
        -- get parameter value length
        v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
        v_start := v_end + v_delim_length;
        if (v_numb > 0) then
          -- return parameter value string
          return dbms_lob.substr(p_body, LEAST(v_numb, p_max_size), v_start);
        end if;
      end if;
    elsif (v_ch = '*') then
      v_start := v_start + 1;
      v_end := dbms_lob.instr(p_body, v_delim, v_start);
      if (v_end < 1) then return ''; else
        -- get count parameters
        v_total := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
        v_start := v_end + v_delim_length;
        if (v_total > 0) then
          -- index out parameter
          if (p_element_position > v_total) then
              return '';
          end if;
          -- cycle
          v_element_position := 1;
          loop
            v_temp := v_start;
            -- get parameter name
            v_ch := dbms_lob.substr(p_body, 1, v_start);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get parameter name length
                v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                v_start := v_end + v_delim_length;
                if (v_numb > 0) then
                  -- return parameter name if need
                  if (p_param_name is null) then
                    return dbms_lob.substr(p_body, LEAST(v_numb, p_max_size), v_start);
                  end if;
                  -- get parameter name string
                  v_param_name := dbms_lob.substr(p_body, LEAST(v_numb, 32767), v_start);
                  v_start := v_start + v_numb + v_delim_length; 
                end if;
              end if;
            end if;
            -- end get parameter name
        
            -- get parameter value
            v_ch := dbms_lob.substr(p_body, 1, v_start);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get parameter value length
                v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                if (v_numb > 0) then
                  v_start := v_end + v_delim_length;
                  -- get parameter value string
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    return dbms_lob.substr(p_body, LEAST(v_numb, p_max_size), v_start);
                  end if;
                  v_start := v_start + v_numb + v_delim_length; 
                else
                  -- parameter value is empty
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    return '';
                  end if;
                end if;
              end if;
              -- end get parameter value string
            elsif (v_ch = ':') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                if (p_param_name = 'any' or v_param_name = p_param_name) then
                  return dbms_lob.substr(p_body, LEAST(v_end - v_start, p_max_size), v_start);
                end if;
                v_start := v_end + v_delim_length;
              end if;
              -- end get parameter value count
            elsif (v_ch = '*') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return ''; else
                -- get count sub parameters
                v_subtotal := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                v_start := v_end + v_delim_length;
                if (v_subtotal > 0) then
                  -- index out sub parameter
                  if (p_param_position > v_subtotal and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                      return '';
                  end if;
                  -- cycle
                  v_param_position := 1;
                  loop
                    -- get sub parameter
                    v_ch := dbms_lob.substr(p_body, 1, v_start);
                    if (v_ch = '$') then
                      v_start := v_start + 1;
                      v_end := dbms_lob.instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return ''; else
                        -- get sub parameter length
                        v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                        v_start := v_end + v_delim_length;
                        if (v_numb > 0) then
                          -- get sub parameter value string
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            return dbms_lob.substr(p_body, LEAST(v_numb, p_max_size), v_start);
                          end if;
                          v_start := v_start + v_numb + v_delim_length; 
                        else
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            -- sub parameter value empty
                            return '';
                          end if;
                        end if;
                      end if;
                    elsif (v_ch = '+') then
                      v_start := v_start + 1;
                      v_end := dbms_lob.instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return ''; else
                        if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            return dbms_lob.substr(p_body, LEAST(v_end - v_start, p_max_size), v_start);
                        end if;
                        v_start := v_end + v_delim_length;
                      end if;
                    end if;
                    -- check get sub parameter
                    v_subtotal := v_subtotal - 1;
                    v_param_position := v_param_position + 1;
                    exit when v_subtotal = 0; 
                    -- end get sub parameter
                  end loop;
                end if;
              end if;
              -- end get parameter sub parameters
            end if;
            -- end get parameter value
            v_total := v_total - 1;
            v_element_position := v_element_position + 1;
            exit when v_total = 0 or v_temp = v_start or v_start >= v_length;
          end loop;
        else
          -- *-1
          if (p_pass_error_in_out > 0) then
            return to_char(v_total);
          else
            dbms_output.put_line('error: empty data');
          end if;
        end if;
        -- end get total parameters
      end if;
    end if;
    -- return
    return '';
  
  end;
  
  member function reply(
    p_body in clob, 
    p_param_name in varchar2 default 'any', 
    p_param_position in number default 1,
    p_element_position in number default 1,
    p_pass_error_in_out in number default 1)
  return clob
  is 
    p_body_out clob;
    v_delim varchar2(2) := DisqueType.CRLF;
    v_delim_length number := 2;
    v_param_name varchar2(32767);
    v_param_position number := 1;
    v_element_position number := 1;
    v_length  number := dbms_lob.getlength(p_body);
    v_start number := 1;
    v_end number;
    v_ch   varchar2(1);
    v_total number;
    v_subtotal number;
    v_numb number;
    v_temp number;

  begin
    if (p_body is null or v_length = 0) then return p_body_out; end if;
    -- get parameters
    v_ch := dbms_lob.substr(p_body, 1, v_start);
    if (v_ch = '+' or v_ch = ':' or v_ch = '-') then 
      v_start := v_start + 1;
      v_end := dbms_lob.instr(p_body, v_delim, v_start);
      if (v_ch = '-') then
        -- for error
        if (v_end < 1) then return p_body_out; else
          if (p_pass_error_in_out > 0) then
            dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
            dbms_lob.copy(p_body_out, p_body, v_end - v_start, 1, v_start);
          else
            dbms_output.put_line('error:' || dbms_lob.substr(p_body, LEAST(v_end - v_start, 32767), v_start));
          end if;
        end if;
      else
        -- for ok
        -- out result
        if (v_end < 1) then return p_body_out; else
          dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
          dbms_lob.copy(p_body_out, p_body, v_end - v_start, 1, v_start);
        end if;
      end if;
      return p_body_out;
    elsif (v_ch = '$') then
      v_start := v_start + 1;
      v_end := instr(p_body, v_delim, v_start);
      if (v_end < 1) then return ''; else
        -- get parameter value length
        v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
        v_start := v_end + v_delim_length;
        if (v_numb > 0) then
          -- return parameter value string
          dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
          dbms_lob.copy(p_body_out, p_body, v_numb, 1, v_start);
          return p_body_out;
        end if;
      end if;
    elsif (v_ch = '*') then
      v_start := v_start + 1;
      v_end := dbms_lob.instr(p_body, v_delim, v_start);
      if (v_end < 1) then return p_body_out; else
        -- get count parameters
        v_total := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
        v_start := v_end + v_delim_length;
        if (v_total > 0) then
          -- index out parameter
          if (p_element_position > v_total) then
              return p_body_out;
          end if;
          -- cycle
          v_element_position := 1;
          loop
            v_temp := v_start;
            -- get parameter name
            v_ch := dbms_lob.substr(p_body, 1, v_start);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return p_body_out; else
                -- get parameter name length
                v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                v_start := v_end + v_delim_length;
                if (v_numb > 0) then
                  -- return parameter name if need
                  if (p_param_name is null) then
                    dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
                    dbms_lob.copy(p_body_out, p_body, v_numb, 1, v_start);
                    return p_body_out;
                  end if;
                  -- get parameter name string
                  v_param_name := dbms_lob.substr(p_body, LEAST(v_numb, 32767), v_start);
                  v_start := v_start + v_numb + v_delim_length; 
                end if;
              end if;
            end if;
            -- end get parameter name
        
            -- get parameter value
            v_ch := dbms_lob.substr(p_body, 1, v_start);
            if (v_ch = '$') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return p_body_out; else
                -- get parameter value length
                v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                if (v_numb > 0) then
                  v_start := v_end + v_delim_length;
                  -- get parameter value string
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
                    dbms_lob.copy(p_body_out, p_body, v_numb, 1, v_start);
                    return p_body_out;
                  end if;
                  v_start := v_start + v_numb + v_delim_length; 
                else
                  -- parameter value is empty
                  if (p_param_name = 'any' or v_param_name = p_param_name) then
                    return p_body_out;
                  end if;
                end if;
              end if;
              -- end get parameter value string
            elsif (v_ch = ':') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return p_body_out; else
                if (p_param_name = 'any' or v_param_name = p_param_name) then
                  dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
                  dbms_lob.copy(p_body_out, p_body, v_end - v_start, 1, v_start);
                  return p_body_out;
                end if;
                v_start := v_end + v_delim_length;
              end if;
              -- end get parameter value count
            elsif (v_ch = '*') then
              v_start := v_start + 1;
              v_end := dbms_lob.instr(p_body, v_delim, v_start);
              if (v_end < 1) then return p_body_out; else
                -- get count sub parameters
                v_subtotal := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                v_start := v_end + v_delim_length;
                if (v_subtotal > 0) then
                  -- index out sub parameter
                  if (p_param_position > v_subtotal and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                      return p_body_out;
                  end if;
                  -- cycle
                  v_param_position := 1;
                  loop
                    -- get sub parameter
                    v_ch := dbms_lob.substr(p_body, 1, v_start);
                    if (v_ch = '$') then
                      v_start := v_start + 1;
                      v_end := dbms_lob.instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return p_body_out; else
                        -- get sub parameter length
                        v_numb := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
                        v_start := v_end + v_delim_length;
                        if (v_numb > 0) then
                          -- get sub parameter value string
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
                            dbms_lob.copy(p_body_out, p_body, v_numb, 1, v_start);
                            return p_body_out;
                          end if;
                          v_start := v_start + v_numb + v_delim_length; 
                        else
                          -- sub parameter value is empty
                          if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            return p_body_out;
                          end if;
                        end if;
                      end if;
                    elsif (v_ch = '+') then
                      v_start := v_start + 1;
                      v_end := dbms_lob.instr(p_body, v_delim, v_start);
                      if (v_end < 1) then return p_body_out; else
                        if (p_param_position = v_param_position and p_element_position = v_element_position and (p_param_name = 'any' or v_param_name = p_param_name)) then
                            dbms_lob.createtemporary(p_body_out, true, dbms_lob.session);
                            dbms_lob.copy(p_body_out, p_body, v_end - v_start, 1, v_start);
                            return p_body_out;
                        end if;
                        v_start := v_end + v_delim_length;
                      end if;
                    end if;
                    -- check get sub parameter
                    v_subtotal := v_subtotal - 1;
                    v_param_position := v_param_position + 1;
                    exit when v_subtotal = 0; 
                    -- end get sub parameter
                  end loop;
                end if;
              end if;
              -- end get parameter sub parameters
            end if;
            -- end get parameter value
            v_total := v_total - 1;
            v_element_position := v_element_position + 1;
            exit when v_total = 0 or v_temp = v_start or v_start >= v_length;
          end loop;
        else
          -- *-1
          if (p_pass_error_in_out > 0) then
            p_body_out := p_body_out || to_char(v_total);
          else
            dbms_output.put_line('error: empty data');
          end if;
        end if;
        -- end get total parameters
      end if;
    end if;
    -- return
    return p_body_out;
  
  end;
  
  member function reply_elements_count(p_body in varchar2)
  return number
  is 
    v_start number := 1;
    v_end number;
    v_ch   varchar2(1);
    v_total number := 0;
  begin
    if (p_body is null or length(p_body) = 0) then return v_total; end if;
    v_ch := substr(p_body, v_start, 1);
    if (v_ch = '*') then 
      v_start := v_start + 1;
      v_end := instr(p_body, DisqueType.CRLF, v_start);
      if (v_end > 0) then
        -- get count parameters
        v_total := to_number(dbms_lob.substr(p_body, v_start, v_end - v_start));
      end if;
    end if;
    return v_total;
  end;
  
  member function reply_elements_count(p_body in clob)
  return number
  is 
    v_start number := 1;
    v_end number;
    v_ch   varchar2(1);
    v_total number := 0;
    v_length number := dbms_lob.getlength(p_body);
  begin
    if (v_length = 0) then return v_total; end if;
    v_ch := dbms_lob.substr(p_body, 1, v_start);
    if (v_ch = '*') then 
      v_start := v_start + 1;
      v_end := dbms_lob.instr(p_body, DisqueType.CRLF, v_start);
      if (v_end > 0) then
        -- get count parameters
        v_total := to_number(dbms_lob.substr(p_body, v_end - v_start, v_start));
      end if;
    end if;
    return v_total;
  end;
  
  -- API commands
  
  -- Common
  
  member procedure ping
	is
		v_params number := 1;
    v_command varchar2(255) := 'PING';
	begin
		-- PING
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    
	end;
  
  member procedure hello
	is
		v_params number := 1;
    v_command varchar2(255) := 'HELLO';
	begin
		-- HELLO
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    
	end;
  
  member procedure info
	is
		v_params number := 1;
    v_command varchar2(255) := 'INFO';
	begin
		-- INFO
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    
	end;
  
  -- Scan queue
  
  member procedure jscan( 
    p_queue in varchar2 default null,
    p_count in number default 0, 
    p_state in varchar2 default null, 
    p_reply in varchar2 default null,
    p_busyloop in number default 0,
    p_cursor in number default -1 )
	is
		v_params number := 1;
    v_command varchar2(255) := 'JSCAN';
    v_count varchar2(5) := 'COUNT';
    v_busyloop varchar2(8) := 'BUSYLOOP';
    v_queue varchar2(5) := 'QUEUE';
    v_state varchar2(5) := 'STATE';
    v_reply varchar2(5) := 'REPLY';
    v_state_count number := 0;
    v_delimeter varchar2(1);
	begin
		-- JSCAN [<cursor>] [COUNT <count>] [BUSYLOOP] [QUEUE <queue>] 
    -- [STATE <state1> STATE <state2> ... STATE <stateN>] [REPLY all|id]
    
    -- check common delimeters for state option string
    if (v_state_count = 0) then 
      v_delimeter := ' ';
      v_state_count := DisqueType.count_by_delimeter(p_state, v_delimeter);
    end if;
    if (v_state_count = 0) then 
      v_delimeter := ',';
      v_state_count := DisqueType.count_by_delimeter(p_state, v_delimeter);
    end if;
    
    if (p_cursor >= 0) then v_params := v_params + 1; end if;
    if (p_count > 0) then v_params := v_params + 2; end if;
    if (p_busyloop > 0) then v_params := v_params + 1; end if;
    if (p_queue is not null and length(p_queue) > 0) then v_params := v_params + 2; end if;
    if (v_state_count > 0) then v_params := v_params + v_state_count*2; end if;
    if (p_reply is not null and length(p_reply) > 0) then v_params := v_params + 2; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- cursor
    if (p_cursor >= 0) then
      send_number(p_cursor); 
    end if;
    -- count
    if (p_count > 0) then 
      send_name(v_count);
      send_number(p_count);
    end if;
    -- busyloop
    if (p_busyloop > 0) then 
      send_name(v_busyloop);
    end if;
    -- queue
    if (p_queue is not null and length(p_queue) > 0) then
      send_name(v_queue);
      send_data(p_queue);
    end if;
    -- state
    if (v_state_count > 0) then 
      for i in 1 .. v_state_count loop
        send_name(v_state);
        send_name(DisqueType.element_by_delimeter(p_state, v_delimeter, i));
      end loop;
    end if;
    -- reply
    if (p_reply is not null and length(p_reply) > 0) then
      send_name(v_reply);
      send_data(p_reply);
    end if;

	end;
  
  member procedure qscan( 
    p_count in number default 0, 
    p_minlen in number default 0, 
    p_maxlen in number default 0, 
    p_importrate in number default 0,
    p_busyloop in number default 0, 
    p_cursor in number default -1)
	is
		v_params number := 1;
    v_command varchar2(255) := 'QSCAN';
    v_count varchar2(5) := 'COUNT';
    v_busyloop varchar2(8) := 'BUSYLOOP';
    v_minlen varchar2(6) := 'MINLEN';
    v_maxlen varchar2(6) := 'MAXLEN';
    v_importrate varchar2(10) := 'IMPORTRATE';
	begin
		-- QSCAN [<cursor>] [COUNT <count>] [BUSYLOOP] [MINLEN <len>] [MAXLEN <len>] [IMPORTRATE <rate>]
    
    if (p_cursor >= 0) then v_params := v_params + 1; end if;
    if (p_count > 0) then v_params := v_params + 2; end if;
    if (p_busyloop > 0) then v_params := v_params + 1; end if;
    if (p_minlen > 0) then v_params := v_params + 2; end if;
    if (p_maxlen > 0) then v_params := v_params + 2; end if;
    if (p_importrate > 0) then v_params := v_params + 2; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- cursor
    if (p_cursor >= 0) then 
      send_number(p_cursor);
    end if;
    -- count
    if (p_count > 0) then 
      send_name(v_count);
      send_number(p_count);
    end if;
    -- busyloop
    if (p_busyloop > 0) then 
      send_name(v_busyloop);
    end if;
    -- minlen
    if (p_minlen > 0) then 
      send_name(v_minlen);
      send_number(p_minlen);
    end if;
    -- maxlen
    if (p_maxlen > 0) then 
      send_name(v_maxlen);
      send_number(p_maxlen);
    end if;
    -- importrate
    if (p_importrate > 0) then 
      send_name(v_importrate); 
      send_number(p_importrate); 
    end if;
    
    
	end;
  
  -- Stats and manipulate state of queue
  
  member procedure qstat( p_queue in varchar2 )
	is
		v_params number := 2;
    v_command varchar2(255) := 'QSTAT';
	begin
		-- QSTAT <queue-name>
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- queue
    send_data(p_queue);
    
	end;
  
  member procedure qlen( p_queue in varchar2 )
	is
		v_params number := 2;
    v_command varchar2(255) := 'QLEN';
	begin
		-- QLEN <queue-name>
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- queue
    send_data(p_queue);
    
	end;
  
  member procedure pause( p_queue in varchar2, p_option in varchar2 )
	is
		v_params number := 2;
    v_command varchar2(255) := 'PAUSE';
    v_option_count number := 0;
    v_delimeter varchar2(1);
	begin
		-- PAUSE <queue-name> option1 [option2 ... optionN]
    -- in: pause the queue in input, out: pause the queue in output,
    -- all: pause the queue in input and output (same as specifying both the in and out options)
    -- none: clear the paused state in input and output
    -- state: just report the current queue state
    -- bcast: send a PAUSE command to all the reachable nodes of the cluster to set the same queue in the other nodes to the same state
    -- examples
    -- PAUSE myqueue out bcast
    -- PAUSE myqueue in out
    -- PAUSE myqueue all
    -- PAUSE myqueue state
    
    -- check common delimeters for parse option string
    if (v_option_count = 0) then 
      v_delimeter := ' ';
      v_option_count := DisqueType.count_by_delimeter(p_option, v_delimeter);
    end if;
    if (v_option_count = 0) then 
      v_delimeter := ',';
      v_option_count := DisqueType.count_by_delimeter(p_option, v_delimeter);
    end if;
    
    if (v_option_count = 0) then return;
    else v_params := v_params + v_option_count; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- queue
    send_data(p_queue);
    -- option
    for i in 1 .. v_option_count loop
      send_name(DisqueType.element_by_delimeter(p_option, v_delimeter, i));
    end loop;
    
	end;
  
  -- Append job to queue
  
  member procedure addjob( p_queue in varchar2, p_body in varchar2, p_timeout in number default 0, 
    p_replicate in number default 0, p_delay in number default 0, p_retry in number default 0, 
    p_ttl in number default 0, p_maxlen in number default 0, p_async in number default 0 )
  is
		v_params number := 4;
    v_command varchar2(255) := 'ADDJOB';
    v_replicate varchar2(9) := 'REPLICATE';
    v_delay varchar2(5) := 'DELAY';
    v_retry varchar2(5) := 'RETRY';
    v_ttl varchar2(3) := 'TTL';
    v_maxlen varchar2(6) := 'MAXLEN';
    v_async varchar2(5) := 'ASYNC';
	begin
		-- ADDJOB queue_name job <ms-timeout> 
    -- [REPLICATE <count>] [DELAY <sec>] [RETRY <sec>] [TTL <sec>] [MAXLEN <count>] [ASYNC]
    
    if (p_replicate > 0) then v_params := v_params + 2; end if;
    if (p_delay > 0) then v_params := v_params + 2; end if;
    if (p_retry > 0) then v_params := v_params + 2; end if;
    if (p_ttl > 0) then v_params := v_params + 2; end if;
    if (p_maxlen > 0) then v_params := v_params + 2; end if;
    if (p_async > 0) then v_params := v_params + 1; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- queue
    send_data(p_queue);
    -- body
    send_data(p_body);
    -- timeout
    send_number(p_timeout);
    
    -- replicate
    if (p_replicate > 0) then
      send_name(v_replicate);
      send_number(p_replicate);
    end if;
    -- delay
    if (p_delay > 0) then
      send_name(v_delay);
      send_number(p_delay);
    end if;
    -- retry
    if (p_retry > 0) then
      send_name(v_retry);
      send_number(p_retry);
    end if;
    -- ttl
    if (p_ttl > 0) then 
      send_name(v_ttl);
      send_number(p_ttl);
    end if;
    -- maxlen
    if (p_maxlen > 0) then
      send_name(v_maxlen);
      send_number(p_maxlen);
    end if;
    -- async
    if (p_async > 0) then
      send_name(v_async);
    end if;
    
	end;
  
  -- Get jobs from queue
  
  member procedure getjob( p_queue in varchar2, 
    p_count in number default 1, p_nohang in number default 1, 
    p_timeout in number default 0, p_withcounters in number default 0 )
	is
		v_params number := 2;
    v_command varchar2(255) := 'GETJOB';
    v_nohang varchar2(6) := 'NOHANG';
    v_timeout varchar2(7) := 'TIMEOUT';
    v_count varchar2(5) := 'COUNT';
    v_withcounters varchar2(12) := 'WITHCOUNTERS';
    v_from varchar2(4) := 'FROM';
	begin
		-- GETJOB [NOHANG] [TIMEOUT <ms-timeout>] [COUNT <count>] [WITHCOUNTERS] FROM queue
    
    if (p_queue is null or length(p_queue) = 0) then return; 
    else v_params := v_params + 1; end if;
    
    if (p_nohang > 0) then v_params := v_params + 1; end if;
    if (p_timeout > 0) then v_params := v_params + 2; end if;
    if (p_count > 0) then v_params := v_params + 2; end if;
    if (p_withcounters > 0) then v_params := v_params + 1; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- nohang
    if (p_nohang > 0) then 
      send_name(v_nohang);
    end if;
    -- timeout
    if (p_timeout > 0) then
      send_name(v_timeout);
      send_number(p_timeout);
    end if;
    -- count
    if (p_count > 0) then
      send_name(v_count);
      send_number(p_count);
    end if;
    -- withcounters
    if (p_withcounters > 0) then
      send_name(v_withcounters);
    end if;
    -- from
    send_name(v_from);
    -- queue
    send_data(p_queue);
    
	end;
  
  member procedure getjob( p_queue in t_array, 
    p_count in number default 1, p_nohang in number default 1, 
    p_timeout in number default 0, p_withcounters in number default 0 )
	is
		v_params number := 2;
    v_command varchar2(255) := 'GETJOB';
    v_nohang varchar2(6) := 'NOHANG';
    v_timeout varchar2(7) := 'TIMEOUT';
    v_count varchar2(5) := 'COUNT';
    v_withcounters varchar2(12) := 'WITHCOUNTERS';
    v_from varchar2(4) := 'FROM';
	begin
		-- GETJOB [NOHANG] [TIMEOUT <ms-timeout>] [COUNT <count>] [WITHCOUNTERS] FROM queue1 queue2 ... queueN
    
    if (p_queue.count = 0) then return; 
    else v_params := v_params + p_queue.count; end if;
    
    if (p_nohang > 0) then v_params := v_params + 1; end if;
    if (p_timeout > 0) then v_params := v_params + 2; end if;
    if (p_count > 0) then v_params := v_params + 2; end if;
    if (p_withcounters > 0) then v_params := v_params + 1; end if;
    
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- nohang
    if (p_nohang > 0) then 
      send_name(v_nohang);
    end if;
    -- timeout
    if (p_timeout > 0) then
      send_name(v_timeout);
      send_number(p_timeout);
    end if;
    -- count
    if (p_count > 0) then
      send_name(v_count);
      send_number(p_count);
    end if;
    -- withcounters
    if (p_withcounters > 0) then
      send_name(v_withcounters);
    end if;
    -- from
    send_name(v_from);
    -- queue
    for i in 1 .. p_queue.count loop
      send_data(p_queue(i));
    end loop;
    
	end;
  
  member procedure qpeek( p_queue in varchar2, p_count in number default 1 )
	is
		v_params number := 3;
    v_command varchar2(255) := 'QPEEK';
    
	begin
		-- QPEEK <queue-name> <count>
    -- +>=1 from the oldest to the newest like GETJOB, -<=1 from the newest from the oldest 
    -- send
    send_count(v_params);
    -- command
    send_name(v_command);
    -- queue
    send_data(p_queue);
    -- count
    send_number(p_count);
    
	end;
  
  -- Manipulate jobs in queue
  
  member procedure show( p_job in varchar2 )
	is
		v_command varchar2(255) := 'SHOW';
	begin
		-- SHOW <job-id>
    send_command_for_jobs(v_command, p_job, 1);
	end;
  
  member procedure enqueue( p_job in varchar2 )
	is
		v_command varchar2(255) := 'ENQUEUE';
	begin
		-- ENQUEUE <job-id> ... <job-id>
    send_command_for_jobs(v_command, p_job);
	end;
  
  member procedure dequeue( p_job in varchar2 )
	is
		v_command varchar2(255) := 'DEQUEUE';
	begin
		-- DEQUEUE <job-id> ... <job-id>
    send_command_for_jobs(v_command, p_job);
	end;
  
  member procedure deljob( p_job in varchar2 )
	is
		v_command varchar2(255) := 'DELJOB';
	begin
		-- DELJOB <job-id> ... <job-id>
    send_command_for_jobs(v_command, p_job);
	end;
  
  -- Working cycle with jobs
  
  member procedure ackjob( p_job in varchar2 )
	is
		v_command varchar2(255) := 'ACKJOB';
	begin
		-- ACKJOB jobid1 jobid2 ... jobidN
    send_command_for_jobs(v_command, p_job);
	end;
  
  member procedure working( p_job in varchar2 )
	is
		v_command varchar2(255) := 'WORKING';
	begin
		-- WORKING jobid
    send_command_for_jobs(v_command, p_job, 1);
	end;
  
  member procedure nack( p_job in varchar2 )
	is
		v_command varchar2(255) := 'NACK';
	begin
		-- NACK <job-id> ... <job-id>
    send_command_for_jobs(v_command, p_job);
	end;
  
  member procedure fastack( p_job in varchar2 )
	is
		v_command varchar2(255) := 'FASTACK';
	begin
		-- FASTACK jobid1 jobid2 ... jobidN
    send_command_for_jobs(v_command, p_job);
    
	end;
  
end;

/