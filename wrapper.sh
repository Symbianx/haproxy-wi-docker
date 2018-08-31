#!/bin/bash

/usr/sbin/httpd -DFOREGROUND
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache: $status"
  exit $status
fi

cd /var/www/haproxy-wi/app
tools/metrics_master.py &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Metrics HAProxy: $status"
  exit $status
fi

tools/checker_master.py &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Chcker HAProxy: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep /usr/sbin/httpd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep metrics_master.py |grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux |grep checker_master.py.py |grep -q -v grep
  PROCESS_3_STATUS=$?
  
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done

