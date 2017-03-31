package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/akamai-open/AkamaiOPEN-edgegrid-golang"
)

func main() {
	listID := os.Args[1]
	jsonfile := os.Args[2]

	file, e := ioutil.ReadFile(jsonfile)
	if e != nil {
		fmt.Printf("File error: %v\n", e)
		os.Exit(1)
	}
	fmt.Printf("%s\n", string(file))

	client := http.Client{}
	config := edgegrid.InitConfig("~/.edgerc", "default")

	req, _ := http.NewRequest("POST", fmt.Sprintf("https://%s//network-list/v1/network_lists/%s/activate?env=staging", config.Host, listID), bytes.NewBuffer(file))
	req = edgegrid.AddRequestHeader(config, req)
	resp, _ := client.Do(req)
	byt, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(byt))

}
