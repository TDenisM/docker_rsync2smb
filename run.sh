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

echo "Creating source $SRC_SHARE_SERVER"
if grep -Fxq "//$SRC_SHARE_SERVER /mnt/src cifs uid=0,gid=0,user=$SRC_SHARE_USER,password=$SRC_SHARE_PASS,domain=$SRC_SHARE_DOMAIN,_netdev,vers=$SRC_SMB_VER 0 0" /etc/fstab
then
    echo "Source existed. Pass."
else
    echo "//$SRC_SHARE_SERVER /mnt/src cifs uid=0,gid=0,user=$SRC_SHARE_USER,password=$SRC_SHARE_PASS,domain=$SRC_SHARE_DOMAIN,_netdev,vers=$SRC_SMB_VER 0 0" >> /etc/fstab
fi


echo "Creating destenation $DST_SHARE_SERVER"
if grep -Fxq "//$DST_SHARE_SERVER /mnt/dst cifs uid=0,gid=0,user=$DST_SHARE_USER,password=$DST_SHARE_PASS,domain=$DST_SHARE_DOMAIN,_netdev,vers=$DST_SMB_VER 0 0" /etc/fstab
then
    echo "Destenation existed. Pass."
else
    echo "//$DST_SHARE_SERVER /mnt/dst cifs uid=0,gid=0,user=$DST_SHARE_USER,password=$DST_SHARE_PASS,domain=$DST_SHARE_DOMAIN,_netdev,vers=$DST_SMB_VER 0 0" >> /etc/fstab
fi

echo "Mounting..."
mount -av
/rsyncwrapper.sh

echo "Creating rsync cron job"
echo "$CRON_PATTERN   root    /rsyncwrapper.sh >> /var/log/cron.log 2>&1" > /etc/crontab

echo $RSYNC_OPTS > /root/rsync_opts
/usr/sbin/cron && tail -f /var/log/cron.log
