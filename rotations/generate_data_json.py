#!/usr/bin/env python3

import sys
import json

data = dict()
with open(sys.argv[1]) as f:
    for line in f:
        parts = line.split(',')
        if len(parts) == 2:
            data[parts[0]]= { 'rot': int(parts[1].strip('\n').strip('ROT')) }

with open(sys.argv[len(sys.argv) - 1], 'w') as f:
    json.dump(data, f)