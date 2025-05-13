#!/bin/bash

# Kiểm tra có truyền tên test không
if [ -z "$1" ]; then
  echo "Usage: ./run_ams.sh <UVM_TESTNAME>"
  exit 1
fi

TESTNAME=$1
LOGFILE="logs/${TESTNAME}.log"

# Tạo thư mục logs nếu chưa tồn tại
mkdir -p logs

# In thông báo đang chạy
echo "Running simulation with test: $TESTNAME"
echo "Log output will be saved to: $LOGFILE"

# Chạy mô phỏng
# xrun -f run_xrun_ams +UVM_TESTNAME=$TESTNAME -logfile $LOGFILE

rm -rf  xrun_ams_sim
mkdir   xrun_ams_sim
cd      xrun_ams_sim
xrun -f ../xrun_ams.f +UVM_TESTNAME=$TESTNAME -logfile $LOGFILE
cd ..

!/bin/bash
