#!/usr/bin/env ruby

require 'socket'
require "openssl"


# socket = Socket.new(:INET, :STREAM )
# sockaddr = Socket.sockaddr_in(80,host)
# socket.connect(sockaddr)
# socketMesgReceive = socket.recv(10000) 
# print socketMesgReceive
# print "\n"

# url = "http://example.org/index.html"


def request_to(url)
  scheme, url = url.split("://",2)
  port = 80
  # print scheme, url
  if scheme == 'https'
    port = 443
  end

  # url = url[0..-1]
  host, path = url.split("/")
  path = "/" + path

  tcp_socket = TCPSocket.new(host,port)
  
  if scheme == 'https'
    new_context = OpenSSL::SSL::SSLContext.new
    tcp_socket = OpenSSL::SSL::SSLSocket.new tcp_socket, new_context
    tcp_socket.sync_close = true
    tcp_socket.connect
  end

  request_payload = "GET %s HTTP/1.0\r\n" % [path] +
			           "HOST: %s\r\n\r\n" % [host] 
  request_payload = request_payload.encode("UTF-8")
  # socket_send_return = tcp_socket.send(request_payload,0)
  # puts tcp_socket.class
  socket_res = tcp_socket.write(request_payload)
  puts socket_res

  File.write("socket_return_data.txt","")

  File.open("socket_return_data.txt",'w'){
    |file|
	while line = tcp_socket.gets
	  file.write line
	end
  }

  web_page = File.open("socket_return_data.txt",'r')

  first_line = web_page.readline
  fl_version, fl_status, fl_explanation = first_line.split(" ",3) #em python era para ser 2 

  headers = {}
  while 1
    line = web_page.readline
    if line == "\r\n" 
      break
    end
    header, value = line.split(":",2) 
    headers[header.downcase] = value.strip
  end

  body = web_page.read
  web_page.close

  return headers, body
end
# File.write("test.txt", " ")

def show(body)

  # testFile = File.open("test.txt", 'a')
	
  inside_tag = false
  body.each_char { 
    |content| 
    if content == "<"
      inside_tag = true
	elsif content == ">"
	  inside_tag = false
	elsif not inside_tag
	  # print content 
	  # testFile.write content
	end
  }	
  # testFile.close
end

def load_n_display(url)
  headers, body = request_to(url)
  show(body)
end


load_n_display("https://example.org/index.html")
# load_n_display("https://google.com/maps")

