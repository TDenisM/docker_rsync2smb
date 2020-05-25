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

echo "Creating rsync cron job"
if grep -Fxq "$CRON_PATTERN   root    /rsyncwrapper.sh >> /var/log/cron.log 2>&1" /etc/crontab
then
    echo "Cron job existing. Pass."
else
    echo "$CRON_PATTERN   root    /rsyncwrapper.sh >> /var/log/cron.log 2>&1" >> /etc/crontab
fi

echo $RSYNC_OPTS > /root/rsync_opts
/usr/sbin/cron && tail -f /var/log/cron.log
