# Global Variable (necessary for other scripts)

base_source=$( dirname $0 )
base=$(readlink -f $base_source)

blockedIPList="${base}/data/blocked-ips-with-expiredate.csv"
removeIPList="${base}/data/remove-expired-ips.txt"
akamai_extend_ips_json="${base}/json/add_blocked_ips.json"
akamai_activate_json="${base}/json/akamai_activate_message.json"


today=$( date +%Y%m%d )
expireDate=$(date -d "+7 days" +%Y%m%d)


get_akamai_network_list="${base}/golang/get_network_list_overview.go"
put_akamai_network_list="${base}/golang/modify_network_list.go"
delete_akamai_element="${base}/golang/remove_an_element.go"
akamai_activate_list="${base}/golang/activate_network_list.go"