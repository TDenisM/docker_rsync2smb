FROM ubuntu:18.04

ENV SRC_SHARE_SERVER="10.150.5.71/src"
ENV SRC_SHARE_USER="bmd"
ENV SRC_SHARE_PASS="bmd"
ENV SRC_SHARE_DOMAIN=""
ENV SRC_SMB_VER="3.0"

ENV DST_SHARE_SERVER="10.150.5.71/dst"
ENV DST_SHARE_USER="bmd"
ENV DST_SHARE_PASS="bmd"
ENV DST_SHARE_DOMAIN=""
ENV DST_SMB_VER="3.0"

ENV RSYNC_OPTS="--include=DF[0-9][0-9][0-9][0-9][0-9][0-9].TXT --exclude=*"
ENV CRON_PATTERN="* * * * *"

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y rsync cifs-utils cron \
 && touch /var/log/cron.log \
 && mkdir /mnt/src \
 && mkdir /mnt/dst

COPY run.sh /run.sh
COPY rsyncwrapper.sh /rsyncwrapper.sh
RUN chmod +x /run.sh /rsyncwrapper.sh

ENTRYPOINT /run.sh
