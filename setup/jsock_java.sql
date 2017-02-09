--------------------------------------------------------
--  DDL for JAVA SOURCE jsock
--------------------------------------------------------

CREATE or replace and compile JAVA SOURCE
NAMED "jsock"
AS

import java.net.*;
import java.io.*;
import java.util.*;
import java.text.*;


public class jsock
{
	static int 				socketUsed[] = { 0,0,0,0,0,0,0,0,0,0 };
	static Socket 			sockets[] = new Socket[socketUsed.length];
	static DateFormat 		tzDateFormat = new SimpleDateFormat( "z" );
	static DateFormat 		gmtDateFormat = new SimpleDateFormat( "yyyyMMdd HHmmss z" );
	
	static public int java_connect_to( String p_hostname, int p_portno ) throws java.io.IOException
	{
		int i;

		for( i = 0; i < socketUsed.length && socketUsed[i] == 1; i++ );
		if ( i < socketUsed.length )
		{
			sockets[i] = new Socket( p_hostname, p_portno );
      sockets[i].setSoTimeout(25);
      sockets[i].setTcpNoDelay(true);
      sockets[i].setKeepAlive(true);
      socketUsed[i] = 1;
		}
		return i<socketUsed.length?i:-1;
	}

	static public void java_send_data( int p_sock, byte[] p_data ) throws java.io.IOException
	{
		(sockets[p_sock].getOutputStream()).write( p_data );
	}
  
  static public void java_send_data_utf8( int p_sock, byte[] p_data ) throws java.io.IOException
	{
		String p_string = new String(p_data, "UTF-8");
    (sockets[p_sock].getOutputStream()).write( p_string.getBytes("UTF-8") );
	}

	static public void java_recv_data( int p_sock, byte[][] p_data, int[] p_length) throws java.io.IOException
	{
		p_data[0] = new byte[ p_length[0] == -1 ? 4096 : p_length[0] ];
		try {
      p_length[0] = (sockets[p_sock].getInputStream()).read( p_data[0] );
    } catch (java.net.SocketTimeoutException ex) {
    }
	}

	static public void java_getline( int p_sock, String[] p_data ) throws java.io.IOException
	{
		DataInputStream d = new DataInputStream((sockets[p_sock].getInputStream()));
    try {
      p_data[0] = d.readLine();
    } catch (java.net.SocketTimeoutException ex) {
    }
    if ( p_data[0] != null ) p_data[0] += "\n";
	}

	static public void java_disconnect( int p_sock ) throws java.io.IOException
	{
		socketUsed[p_sock] = 0;
		(sockets[p_sock]).close();
	}

	static public int java_peek_sock( int p_sock ) throws java.io.IOException
	{
		return (sockets[p_sock].getInputStream()).available();
	}

	static public void java_timeout_sock( int p_sock, int p_timeout ) throws java.io.IOException
	{
		sockets[p_sock].setSoTimeout(p_timeout);
	}
  
  static public void java_tcp_no_delay_sock( int p_sock, int p_on ) throws java.io.IOException
	{
		sockets[p_sock].setTcpNoDelay(p_on > 0 ? true : false);
	}
  
  static public void java_keep_alive_sock( int p_sock, int p_on ) throws java.io.IOException
	{
		sockets[p_sock].setKeepAlive(p_on > 0 ? true : false);
	}
  
  static public void java_get_timezone( String[] p_timezone ) 
	{
		tzDateFormat.setTimeZone( TimeZone.getDefault() );
		p_timezone[0] = tzDateFormat.format(new Date());
	}
	
	static public void java_get_gmt( String[] p_gmt )
	{
		gmtDateFormat.setTimeZone( TimeZone.getTimeZone("GMT") );
		p_gmt[0] = gmtDateFormat.format(new Date());
	}

	static public void java_get_hostname( String[] p_hostname ) throws java.net.UnknownHostException
	{
		p_hostname[0] = (InetAddress.getLocalHost()).getHostName();
	}
	
}
/