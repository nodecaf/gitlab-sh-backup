#!/bin/sh



#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/subgroups | jq .[].web_url


#list all projects in group
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].web_url 	
#list all projects
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/projects | jq .[].ssh_url_to_repo
HEADER="Authorization: Bearer ${GITLAB_TOKEN}"
PROJECT_ATTRIBUTES="per_page=20"
RESPONSE=$( \
	curl --include -sH "Authorization: Bearer $GITLAB_TOKEN" \
	"${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects?${PROJECTS_ATTRIBUTES}" \
        ) || { script_banner "ERROR: Could not retrieve group project."; exit $?; }
#echo $RESPONSE
LAST_PAGE=$(echo "$RESPONSE" | grep -i "x-total-pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r')
echo $LAST_PAGE
ALL_PROJECTS=$(echo "$RESPONSE" | grep "\[" | jq '.[].ssh_url_to_repo')
echo $ALL_PROJECTS

# If the list of forks has more than one page
if [[ "$LAST_PAGE" -gt "1" ]]; then
  # Get the next pages
  for PAGE in $( seq 2 "$LAST_PAGE" ); do
#    echo "Listing projects - Getting page $PAGE / $LAST_PAGE"
    # Getting ID, Path and Last Activity
    RESPONSE=$( \
                curl -sH  "${HEADER}" \
                "${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects?${PROJECT_ATTRIBUTES}&page=${PAGE}" | jq '.[].ssh_url_to_repo' ) || { echo "ERROR: Could not retrieve existing project."; exit $?; }
#echo $RESPONSE
    ALL_PROJECTS+=$'\n'"$RESPONSE"
  done
fi
echo $ALL_PROJECTS
#curl  -H "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].ssh_url_to_repo
