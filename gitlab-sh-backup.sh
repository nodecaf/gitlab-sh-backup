#!/bin/sh



#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" https://${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/subgroups | jq .[].web_url


#list all projects in group
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].web_url 	
#list all projects
#curl  -sH "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/projects | jq .[].ssh_url_to_repo
HEADER="Authorization: Bearer ${GITLAB_TOKEN}"
PROJECT_ATTRIBUTES="per_page=100"
RESPONSE=$( \
	curl --include -sH "Authorization: Bearer $GITLAB_TOKEN" \
	"https://${GITLAB_SERVER}/api/v4/projects?${PROJECT_ATTRIBUTES}" \
        ) || { script_banner "ERROR: Could not retrieve group project."; exit $?; }
#echo $RESPONSE
LAST_PAGE=$(echo "$RESPONSE" | grep -i "x-total-pages" | sed 's|X-Total-Pages: ||g' | tr -d '\r')
#echo $LAST_PAGE
ALL_PROJECTS=$(echo "$RESPONSE" | grep "\[" | jq '.[].ssh_url_to_repo' )
#echo $ALL_PROJECTS

# If the list of forks has more than one page
if [[ "$LAST_PAGE" -gt "1" ]]; then
  # Get the next pages
  for PAGE in $( seq 2 "$LAST_PAGE" ); do
    echo "Listing projects - Getting page $PAGE / $LAST_PAGE"
    # Getting ID, Path and Last Activity
    RESPONSE=$( \
                curl -sH  "${HEADER}" \
                "https://${GITLAB_SERVER}/api/v4/projects?${PROJECT_ATTRIBUTES}&page=${PAGE}" | jq '.[].ssh_url_to_repo' ) || { echo "ERROR: Could not retrieve existing project."; exit $?; }
                #"${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects?${PROJECT_ATTRIBUTES}&page=${PAGE}" | jq '.[].ssh_url_to_repo' ) || { echo "ERROR: Could not retrieve existing project."; exit $?; }
#echo $RESPONSE
    ALL_PROJECTS+=$'\n'"$RESPONSE"
  done
fi
echo $ALL_PROJECTS | jq | grep -i ${GITLAB_GROUP} | sed -e 's/.*://g' -e 's/"//g' | xargs -n 1 -I {}  git clone https://${GITLAB_USER}:${GITLAB_TOKEN}@${GITLAB_SERVER}/{}

#Process all repos we pulled down
for GIT_REPO in $( echo $ALL_PROJECTS | jq | grep -i ${GITLAB_GROUP} | sed -e 's/.*://g' -e 's/"//g' | xargs -n 1 basename -s .git)
  do
    #enter each repo
    cd $GIT_REPO
    #Pull down all branches
    for branch in $(git branch --all | grep '^\s*remotes' | egrep --invert-match '(:?HEAD|master)$'); do
    echo "Now pulling branch ${branch} for ${GIT_REPO}"
    git branch --track "${branch##*/}" "$branch"
    done
    #exit 
    cd ..
done
 
#curl  -H "Authorization: Bearer $GITLAB_TOKEN" ${GITLAB_SERVER}/api/v4/groups/${GITLAB_GROUP}/projects | jq .[].ssh_url_to_repo
