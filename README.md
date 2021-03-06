Docker container for synchronization with rsync and cron of two mounted Samba CIFS folders.
Based on https://hub.docker.com/r/tcousin/cifs-rsync with some modifications:
- Based on Ubuntu 18.04.
- Domain authorisation variables SRC_SHARE_DOMAIN and DST_SHARE_DOMAIN if needed (leave empty if not, default: none).
- rsync options variable RSYNC_OPTS added (-ahv are already included): it is possible to add any additional options if you need - I use it for file patterns - see default variable in Dockerfile.
- cron pattern set with variable CRON_PATTERN (every minute as default: * * * * *).
- Source and destenation Samba version set with SRC_SMB_VER and DST_SMB_VER (default: 3.0)
- rsync lock mechanism to prevent "a racing condition" - if you ran it every minute, there is a risk that one or more of the rsync processes would still be running due to file size or network speed and the next process would just be in competition with it; a racing condition (https://superuser.com/a/848123).

Full list of available environment variables:
- SRC_SHARE_SERVER
- SRC_SHARE_USER
- SRC_SHARE_PASS
- SRC_SHARE_DOMAIN
- SRC_SMB_VER
- DST_SHARE_SERVER
- DST_SHARE_USER
- DST_SHARE_PASS
- DST_SHARE_DOMAIN
- DST_SMB_VER
- RSYNC_OPTS
- CRON_PATTERN

If ```/env``` file exists in container, environment variables set in command line will be ignored - all values will be gotten from this file. File format:

```
export SRC_SHARE_SERVER='192.168.88.102/src'
export SRC_SHARE_USER='bmd'
export SRC_SHARE_PASS='bmd'
export SRC_SHARE_DOMAIN=''
export SRC_SMB_VER='3.0'
export DST_SHARE_SERVER='192.168.88.103/dst'
export DST_SHARE_USER='bmd'
export DST_SHARE_PASS='bmd'
export DST_SHARE_DOMAIN=''
export DST_SMB_VER='3.0'
export RSYNC_OPTS='--include=* --exclude=*'
export CRON_PATTERN='* * * * *'
```

Changing **RSYNC_OPTS** value apply without container restart. All other require container restart.

CIFS mounting require additional capabilities, so run container in privileged mode or add --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH

Usage (sync every 10 minutes):
```
docker run -d --privileged -e SRC_SHARE_SERVER=sambaserver/src -e SRC_SHARE_USER=bmd -e SRC_SHARE_PASS=bmd -e DST_SHARE_SERVER=sambaserver/dst -e DST_SHARE_USER=bmd -e DST_SHARE_PASS=bmd -e RSYNC_OPTS="--include=DF[0-9][0-9][0-9][0-9][0-9][0-9].TXT --exclude=*" -e CRON_PATTERN="*/10 * * * *" dentrunov/rsync2smb:latest
```
*Important! In this example rsync filter set - it will sync only file name like FD123456.TXT Please edit filter according to your needs!*

To run test SAMBA server you can use sixeyed/samba container:
```
docker run -p 139:139 -p 445:445 -p 137:137/udp -p 138:138/udp -v ~/src/:/src -v ~/dst/:/dst -d sixeyed/samba -p -u "bmd;bmd" -s "src;/src;no;no;no;bmd" -s "dst;/dst;no;no;no;bmd"
```

Arguments of -u (user) key:
  name) for user
  password) for user
  id) for user
  group) for user
  gid) for group

Arguments of -s (share) key:
  share) share name
  path) path to share
  browsable) 'yes' or 'no'
  readonly) 'yes' or 'no'
  guest) 'yes' or 'no'
  users) list of allowed users
  admins) list of admin users
  writelist) list of users that can write to a RO share
  comment) description of share

Other arguments could be found here: https://github.com/dperson/samba/blob/master/samba.sh



