package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/akamai-open/AkamaiOPEN-edgegrid-golang"
)

func main() {

	client := http.Client{}
	ipAddress := os.Args[1]
	listID := os.Args[2]

	config := edgegrid.InitConfig("~/.edgerc", "default")

	req, _ := http.NewRequest("DELETE", fmt.Sprintf("https://%s/network-list/v1/network_lists/%s/element?element=%s", config.Host, listID, ipAddress), nil)
	req = edgegrid.AddRequestHeader(config, req)
	resp, _ := client.Do(req)
	byt, _ := ioutil.ReadAll(resp.Body)

	fmt.Println(string(byt))
}
