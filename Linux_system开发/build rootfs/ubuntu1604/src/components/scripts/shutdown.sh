#!/bin/sh

wakeup_time=$1

if [ -z $wakeup_time ]; then
  echo "usage: $0 <time in second>"
  exit 1
fi

supervisorctl stop adm

/app/bootstrap/scripts/super_power_off 5 $wakeup_time
