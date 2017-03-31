#!/bin/bash
go run jenkins_get_all_list_ids.go  | jq '.network_lists[]."unique-id"'
