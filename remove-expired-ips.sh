#!/bin/bash

set -e

# include Global file
source ./akamai-blocked-ips.inc

export IFS=","
while read ip listid expire
do
  if [ $today -ge $expire ]
        then
                echo "${ip},${listid}" >> ${removeIPList}
        fi
done < $blockedIPList

## sort remove list if some duplicate entry
sort -u -n ${removeIPList} -o ${removeIPList}

## cleanup
export IFS=","
while read ip listid
do
  go run ${delete_akamai_element} ${ip} ${listid}
  if [ $?  -eq 0 ]; then
    sed -i  "/^${ip},${listid}/d" ${blockedIPList}
  fi
done < ${removeIPList}
### activate the list
cat <<EOF >${akamai_activate_json}
{
 "siebel-ticket-id": "",
 "notification-recipients": [ "USERNAME" ],
 "comments": "$(date) - Activation via API"
}
EOF
go run ${akamai_activate_list} ${listid} ${akamai_activate_json} 
