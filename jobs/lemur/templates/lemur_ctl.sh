#!/bin/bash

set -ex
JOB_DIR=/var/vcap/jobs/lemur
CONFIG_DIR=$JOB_DIR/etc
CONFIG_FILE=$CONFIG_DIR/lemur.conf.py
RUN_DIR=/var/vcap/sys/run/lemur
LOG_DIR=/var/vcap/sys/log/lemur
PIDFILE=$RUN_DIR/lemur.pid
LEMUR_ROOT=/var/vcap/store/nginx/www
source /var/vcap/packages/pid_utils/pid_utils.sh
case "$1" in
  start)

pid_guard $PIDFILE "lemur"
mkdir -p $RUN_DIR
chown vcap:vcap $RUN_DIR

      mkdir -p $LOG_DIR
      chown vcap:vcap $LOG_DIR
      echo "chowning...."
      chown -R vcap:vcap $LEMUR_ROOT

      echo $$ > /var/vcap/sys/run/lemur/lemur.pid
/usr/local/bin/virtualenv -p python3 $LEMUR_ROOT
source $LEMUR_ROOT/bin/activate

pushd $LEMUR_ROOT/lemur
chpst -u vcap:vcap lemur --config=$CONFIG_FILE init -p lemur
popd
exec chpst -u vcap:vcap $LEMUR_ROOT/bin/lemur start -b 127.0.0.1:8000 -c $CONFIG_FILE \
1>>$LOG_DIR/lemur.stdout.log \
2>>$LOG_DIR/lemur.stderr.log 
;;
stop)
    kill_and_wait $PIDFILE
;;
*)
    echo "Usage: $0 {start|stop}"

    ;;

esac
