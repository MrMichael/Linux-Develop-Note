#!/bin/sh

suspend_time=$1

if [ -z $suspend_time ]; then
  echo "usage: $0 <time in second>"
  exit 1
fi

rtcwake -v -u -s $suspend_time -m freeze

# echo +$suspend_time > /sys/class/rtc/rtc0/wakealarm
# cat /sys/class/rtc/rtc0/wakealarm
# cat /proc/driver/rtc

# systemctl suspend