#!/bin/bash

set -e

# include Global file
source ./akamai-blocked-ips.inc

### GET List of ips and the other parameters
while (( "$#" )); do
  if [ "$1" == "-l" ]; then
    shift
    akamai_list_id=$1
		shift
		continue
  fi

	if [ "$1" == "-d" ]
	then
		shift 
		expireDate="${1}"
		shift
	else
		allIps="$1,${allIps}"
		shift
	fi
done

allIps=${allIps%%,}

### helper function

function valid_ip() {
	local input=${1}
  local ip=${1%%/*}
	local cidrblock=${1#*/}
  local stat=1
  local privateips="10.,172.16.,172.17.,172.18.,172.19.,172.20.,172.21.,172.22.,172.23.,172.24.,172.25.,172.26.,172.27.,172.28.,172.29.,172.30.,172.31.,192.168."

  OIFS=$IFS
  IFS=','
  for check in ${privateips}
  do
    if echo ${input} | grep -q ^${check} 
    then
      echo "ERROR: $input is a private IP Address"
      exit 1
    fi
  done

  IFS=$OIFS
  
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
      OIFS=$IFS
      IFS='.'
      ip=($ip)
      IFS=$OIFS
      [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && 
			   ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
      stat=$?
  fi

	if $( echo $input | grep -q "/" )
	then
		[[ $cidrblock -le 32 ]]
 			stat=$(($stat + $? ))
	fi
  return $stat
}

function valid_expireDate() {
	local c_today=$(date +%s)
	local c_date=$(date -d ${1} +%s)

	[[ $c_date -gt $c_today ]]

	return $?
}



### check if inputs are correct
export IFS=","
for ip in ${allIps}; do
	if ! valid_ip $ip
	then
		echo "ERROR: $ip is not a valid IP oder CIDR Block"
		exit 1
	fi 
done

if ! valid_expireDate ${expireDate}
then
  echo "ERROR: ${expireDate} is not in the future"
	exit 1
fi

if [ "${akamai_list_id}" == "" ]; then
  echo "ERROR: no akamai list id provided ... exiting."
	exit 1
fi

### get list name of akamai network list
# akamai_list_name=$( go run $get_akamai_network_list | jq -r '.network_lists[] | select(."unique-id"=="'${akamai_list_id}'").name' )

### create json to import on akamai
#    "name": "${akamai_list_name}",
#    "type": "IP",
#    "unique-id": "${akamai_list_id}",
#    "sync-point": 0


cat <<EOF >${akamai_extend_ips_json}
{
    "list": [ "${allIps//,/\",\"}"]
}
EOF

### now, do the work of the script ;-)
export IFS=","
for ipToBlock in ${allIps}; do
  if $( grep -q ${ipToBlock} ${blockedIPList} )
	then
	  echo "The expire Date on $ipToBlock will be updated."
		sed -i "s/${ipToBlock},${akamai_list_id},.*/${ipToBlock},${akamai_list_id},${expireDate}/g" ${blockedIPList}
	else
	  echo "Adding $ipToBlock to black list (${blockedIPList})"
		echo "${ipToBlock},${akamai_list_id},${expireDate}" >> ${blockedIPList}
	fi
done

### write it back to akamai
go run ${put_akamai_network_list} ${akamai_list_id} ${akamai_extend_ips_json}

### activate the list
cat <<EOF >${akamai_activate_json}
{
 "siebel-ticket-id": "",
 "notification-recipients": [ "USERNAME" ],
 "comments": "$(date) - Activation via API"
}
EOF
go run ${akamai_activate_list} ${akamai_list_id} ${akamai_activate_json}

