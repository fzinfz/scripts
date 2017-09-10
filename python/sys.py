#!/usr/bin/env python3

import sys
print(sys.version + "\n")

import psutil
print("CPU count - Pysical: " + str( psutil.cpu_count(logical=False) ) 
	     + " / Logical: " + str( psutil.cpu_count() )
     )
