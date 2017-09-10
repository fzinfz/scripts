#!/usr/bin/python3
# Modified based on http://cpp.wesc.webfactional.com/cpp3ev2/book3v2/ch02/tsTclnt3.py

from socket import *
import argparse

parser = argparse.ArgumentParser(description='TCP/UDP socket test')

parser.add_argument('-H','--host', nargs='?', default='127.0.0.1 ')
parser.add_argument('-P','--port', nargs=1)
parser.add_argument('-t','--sockettype', nargs=1)
parser.add_argument('-i','--interactive', action='store_true')

args = parser.parse_args()

HOST = args.host
PORT = int(args.port[0])
BUFSIZ = 1506
ADDR = (HOST, PORT)

if 'u' in args.sockettype: socket_type = SOCK_DGRAM
elif 't' in args.sockettype: socket_type = SOCK_STREAM

tcpCliSock = socket(AF_INET, socket_type)
tcpCliSock.connect(ADDR)

while args.interactive:
    data = input('> ')
    if not data:
        break
    tcpCliSock.send(bytes(data, 'utf-8'))
    data = tcpCliSock.recv(BUFSIZ)
    if not data:
        break
    print(data.decode('utf-8'))

while not args.interactive:
    data = tcpCliSock.recv(BUFSIZ)
    print(data.decode('utf-8'))


tcpCliSock.close()
