#!/bin/bash

#첫번째 파라미터 값
param=$1

#pid 추출
pid=`ps -ef | grep -v "grep" | grep $1 | awk '{print $2}'`

#pid kill
kill -9 $pid
