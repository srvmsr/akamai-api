package main

import (
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/akamai-open/AkamaiOPEN-edgegrid-golang"
)

func main() {
	client := http.Client{}
	config := edgegrid.Config{

		Host:         "akab-o7rb5jqp5qbqhupc-4vbwncs2w5r2tqed.luna.akamaiapis.net",
		ClientToken:  "akab-2pmsputzhlkgmwzm-ktkqa4kff6j5znsd",
		ClientSecret: "lf8IYpYCrpfDNLbqEMcz5H+KK85hdmGbk6Qd8br8hF8=",
		AccessToken:  "akab-26i3pkzuizyn3fvr-bvw5zqblqaehegdf",
		MaxBody:      131072,
		Debug:        false,
	}

	req, _ := http.NewRequest("GET", fmt.Sprintf("https://%s/network-list/v1/network_lists?listType=IP&extended=false&includeDeprecated=false&includeElements=false", config.Host), nil)
	req = edgegrid.AddRequestHeader(config, req)
	resp, _ := client.Do(req)
	byt, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(byt))
}
