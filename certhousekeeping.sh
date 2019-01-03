#!/bin/sh

lebase="/etc/letsencrypt/"

for i in `ls ${lebase}live/`
do
  echo $i
  # if [ ${lebase}archive/${i}/cert.pem  -nt ${lebase}archive/${i}/web.pem ]
  if [ ! -e ${lebase}live/${i}/web.pem ] || [ ${lebase}live/${i}/cert.pem  -nt ${lebase}live/${i}/web.pem ]
  then
    echo "certificate was updated"
    echo "cat ${lebase}live/${i}/cert.pem ${lebase}live/${i}/privkey.pem > ${lebase}live/${i}/web.pem"
    cat ${lebase}live/${i}/cert.pem ${lebase}live/${i}/privkey.pem > ${lebase}live/${i}/web.pem
    echo "restarting lighttpd: systemctl restart lighttpd!"
    /bin/systemctl restart lighttpd
  else
    echo "web.pm is newer than the certificate"
  fi
done
