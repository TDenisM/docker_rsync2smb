#!/bin/bash
ENV_FILE="/env"
ENV_LIST=(SRC_SHARE_SERVER SRC_SHARE_USER SRC_SHARE_PASS SRC_SHARE_DOMAIN SRC_SMB_VER DST_SHARE_SERVER DST_SHARE_USER DST_SHARE_PASS DST_SHARE_DOMAIN DST_SMB_VER RSYNC_OPTS CRON_PATTERN)

if test -f "$ENV_FILE"; then
        echo "$ENV_FILE exists. Load from file..."
        source "$ENV_FILE"
        env
else
        echo "$ENV_FILE does not exist. Save env..."
        touch $ENV_FILE
        for VAR in ${ENV_LIST[@]}; do
                echo "export $VAR='${!VAR}'" >> "$ENV_FILE"
        done
fi

echo "Mounting $SRC_SHARE_SERVER"
mount.cifs -o vers=$SRC_SMB_VER,username=$SRC_SHARE_USER,password=$SRC_SHARE_PASS,domain=$SRC_SHARE_DOMAIN,ro,soft //$SRC_SHARE_SERVER /mnt/src
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
mount.cifs -o vers=$DST_SMB_VER,username=$DST_SHARE_USER,password=$DST_SHARE_PASS,domain=$DST_SHARE_DOMAIN,rw,soft //$DST_SHARE_SERVER /mnt/dst
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

/rsyncwrapper.sh

echo "Creating rsync cron job"
echo "$CRON_PATTERN   root    /rsyncwrapper.sh >> /var/log/cron.log 2>&1" > /etc/crontab

echo $RSYNC_OPTS > /root/rsync_opts
/usr/sbin/cron && tail -f /var/log/cron.log
