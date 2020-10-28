
#!/usr/bin/python3
# -*- coding: utf-8 -*-

import socket
import threading

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)       
s.bind(('106.52.20.247', 8081))
s.listen(5)

def fun(sock, addr):
	print('Accept new connection from {}'.format(addr))
	sock.send('Hello!'.encode())
	while True:
		data = sock.recv(1024)	
		if data == 'exit' or not data:
			break
		# sock.send('hello,{}'.format(data).encode())	
		print('receive,{}'.format(data).encode())
		print('receive,{}'.data.hex())
	sock.close()
	print('Connection closed {}'.format(addr))

print('Waiting for connection...')
while True:
	sock, addr = s.accept()	
	t = threading.Thread(target=fun, args=(sock, addr))
	t.start()