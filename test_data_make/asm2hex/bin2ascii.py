#!/usr/bin/env python
import os
import sys
import binascii
#transfer the .bin file to hexadecimal data
INPUT = sys.argv[1]
OUTPUT = sys.argv[2]

s = open(INPUT, 'rb').read()
s = binascii.b2a_hex(s).decode('ascii')  # Decode bytes to string

with open(OUTPUT, 'w') as f:
    for i in range(0, len(s), 8):
        f.write(s[i:i+8])
        f.write('\n')
