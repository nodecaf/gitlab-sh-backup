#!/bin/sh

curl  -H "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/subgroups | jq .[].web_url 	


curl  -H "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].web_url 	
