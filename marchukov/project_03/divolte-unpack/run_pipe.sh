#!/bin/bash

set -e
set -o pipefail

python3 unpack.py | clickhouse-client -n -t --stacktrace --query="INSERT INTO event FORMAT JSONEachRow" --host 10.111.128.254
#python3 unpack.py

