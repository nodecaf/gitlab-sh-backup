#!/bin/sh



#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/subgroups | jq .[].web_url


#list all projects in group
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].web_url 	
#list all projects
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/projects | jq .[].ssh_url_to_repo
curl  --head -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/projects 