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
cat removeIPList
## cleanup
export IFS=","
while read remove listid
do
  go run ${delete_akamai_element} ${listid} 
  if [ $?  -eq 0 ]; then
    sed -i  "/^${remove},${listid}/d" ${blockedIPList}
  fi
done < ${removeIPList}
