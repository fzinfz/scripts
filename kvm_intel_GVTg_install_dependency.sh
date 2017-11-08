#!/bin/bash

# https://github.com/intel/gvt-linux/wiki/GVTg_Setup_Guide#23-library-dependence 

apt-get install -y \
	git vim \
	libfdt-dev libpixman-1-dev libssl-dev socat libsdl1.2-dev libspice-server-dev \
	autoconf libtool \
	xtightvncviewer tightvncserver x11vnc \
	libsdl1.2-dev uuid-runtime uuid uml-utilities \
	bridge-utils python-dev liblzma-dev libc6-dev

