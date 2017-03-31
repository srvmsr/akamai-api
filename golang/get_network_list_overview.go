package main

import (
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/akamai-open/AkamaiOPEN-edgegrid-golang"
)

func main() {
	client := http.Client{}

	config := edgegrid.InitConfig("~/.edgerc", "default")

	req, _ := http.NewRequest("GET", fmt.Sprintf("https://%s/network-list/v1/network_lists?listType=IP&extended=false&includeDeprecated=false&includeElements=false", config.Host), nil)
	req = edgegrid.AddRequestHeader(config, req)
	resp, _ := client.Do(req)
	byt, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(byt))

}
