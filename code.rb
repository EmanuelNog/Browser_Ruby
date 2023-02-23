#!/usr/bin/env ruby

require 'socket'


# socket = Socket.new(:INET, :STREAM )
# sockaddr = Socket.sockaddr_in(80,host)
# socket.connect(sockaddr)
# socketMesgReceive = socket.recv(10000) 
# print socketMesgReceive
# print "\n"

url = "http://example.org/index.html"

def request(url)
	url = url[7..-1]

	host, path = url.split("/")
	path = "/" + path

	socket = TCPSocket.new(host,80)

	socketMesg = "GET %s HTTP/1.0\r\n" % [path] +
				     "HOST: %s\r\n\r\n" % [host] 
	socketMesg = socketMesg.encode("UTF-8")
	socketMesg = socket.send(socketMesg,0) 

	File.write("socket_return_data.txt","")

	File.open("socket_return_data.txt",'w'){
		|f|
		while line = socket.gets
			f.write line
		end
	}

	webPage = File.open("socket_return_data.txt",'r')

	firstLine = webPage.readline
	flVersion, flStatus, flExplanation = firstLine.split(" ",3) #em python era para ser 2 


	headers = {}
	while 1
		line = webPage.readline
		if line == "\r\n" 
			break
		end
		header, value = line.split(":",2) 
		headers[header.downcase] = value.strip
	end

	body = webPage.read
	webPage.close

	return headers, body
end

File.write("test.txt", " ")
def show(body)

	testFile = File.open("test.txt", 'a')
	
	in_angle = false
	body.each_char { 
		|content| 
		if content == "<"
			in_angle = true
		elsif content == ">"
			in_angle = false
		elsif not in_angle
			print content 
			testFile.write content
		end 
	}	
	testFile.close
end

def load(url)
	headers, body = request(url)
	show(body)
end


load(url)





