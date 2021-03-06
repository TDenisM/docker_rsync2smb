#!/bin/bash
#Original https://superuser.com/questions/847850/behavior-of-rsync-with-file-thats-still-being-written
ENV_FILE="/env"
LOCK_NAME="RSYNC_PROCESS"
LOCK_DIR='/tmp/'${LOCK_NAME}.lock
PID_FILE=${LOCK_DIR}'/'${LOCK_NAME}'.pid'

source "$ENV_FILE"

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}
  
  echo "Mounting $SRC_SHARE_SERVER"
  /sbin/mount.cifs -o vers=$SRC_SMB_VER,username=$SRC_SHARE_USER,password=$SRC_SHARE_PASS,domain=$SRC_SHARE_DOMAIN,ro,soft //$SRC_SHARE_SERVER /mnt/src
  case $? in
  0) echo "Success"
     ;;

  1) echo "Incorrect invocation or permissions. Exiting."
     ;;

  2) echo "System error (out of memory, cannot fork, no more loop devices)"
     ;;

  4) echo "Internal mount bug or missing nfs support in mount"
     ;;

  8) echo "User interrupt"
     ;;

  16) echo "Problems writing or locking /etc/mtab"
      ;;

  32) echo "Mount failure"
      ;;

  64) echo "Some mount succeeded"
      ;;

  *) echo "Unknown error. Exit code $?"
     ;;
  esac

  echo "Mounting $DST_SHARE_SERVER"
  /sbin/mount.cifs -o vers=$DST_SMB_VER,username=$DST_SHARE_USER,password=$DST_SHARE_PASS,domain=$DST_SHARE_DOMAIN,rw,soft //$DST_SHARE_SERVER /mnt/dst
  case $? in
  0) echo "Success"
     ;;

  1) echo "Incorrect invocation or permissions. Exiting."
     ;;

  2) echo "System error (out of memory, cannot fork, no more loop devices)"
     ;;

  4) echo "Internal mount bug or missing nfs support in mount"
     ;;

  8) echo "User interrupt"
     ;;

  16) echo "Problems writing or locking /etc/mtab"
      ;;

  32) echo "Mount failure"
      ;;

  64) echo "Some mount succeeded"
      ;;

  *) echo "Unknown error. Exit code $?"
     ;;
  esac

  rsync -ahv $RSYNC_OPTS /mnt/src/ /mnt/dst 2>&1
  umount /mnt/src
  umount /mnt/dst

  rm -rf ${LOCK_DIR}
  exit
else
  if [ -f ${PID_FILE} ] && kill -0 $(cat ${PID_FILE}) 2>/dev/null; then
    # Confirm that the process file exists & a process
    # with that PID is truly running.
    echo "Running [PID "$(cat ${PID_FILE})"]" >&2
    exit
  else
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash or sudden reboot--then get rid of the ${LOCK_DIR}
    rm -rf ${LOCK_DIR}
    exit
  fi
fi
