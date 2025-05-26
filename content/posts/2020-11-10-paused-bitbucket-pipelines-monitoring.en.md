+++
categories = ["scripts"]
date = 2020-11-10T23:00:00
description = "This is one of the problems we experience with Bitbucket Pipelines, if there are multiple commits/merges to our main branches within short period of time, only first commit is basically deployed because bitbucket pauses the rest."
externalLink = ""
images = ["images/LS2lziJFHP.png"]
slug = "bitbucket-pipelines-monitoring"
tags = ["bitbucket", "pipelines", "monitoring", "bash"]
title = "Paused Bitbucket pipelines monitoring"

+++

This is one of the problems we experience with Bitbucket Pipelines, if there are multiple commits/merges to our main branches within short period of time, only first commit is basically deployed because bitbucket pauses the rest.

This is somewhat understandable in terms of CI/CD logic and is fine if you only have one big merge at a time, but causes numerous problems for teams with multiple people working on features in paralel.

Unfortunately, it seems Atlassian does not give much priority to bitbucket pipelines since the problem is well known for over 2 years as per [BCLOUD-16304](https://jira.atlassian.com/browse/BCLOUD-16304), and is not actively being worked on even though this issue has over 100 votes.

I had to come up with some workaround and so I created a simple [BASH](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>) script which works with bitbucket API.

This script uses bitbucket credentials (`BITBUCKET_CREDS`) with [app password](https://bitbucket.org/account/settings/app-passwords/) for authentication and does following:

1. For every repo defined in `BITBUCKET_REPO_LIST`, it gets list of `MANUAL` or `PUSH` initiated pipelines and saves it to _api_response.json_ file.
2. For every branch from `BITBUCKET_BRANCH_LIST` it checks if there are `RUNNING` or `PENDING` pipes, if there are, it does nothing, but if there are none at the moment, it checks if latest pipeline is `HALTED` and if it is, it triggers a new one based on that commit, ensuring that the latest changes are always deployed.

Quite simple script, but it saves a lot of effort.. we use it as monitoring script that runs every minute.

**Requirements**

- installed [jq](https://stedolan.github.io/jq/download/) package on the system where script is running

```shell
#!/bin/bash
# Script developed by pduchnovsky
# https://duchnovsky.com/2020/11/bitbucket-pipelines-monitoring/

#Variables definition:
BITBUCKET_CREDS="username:app_password"
BITBUCKET_WORKSPACE="workspace-name"
BITBUCKET_REPO_LIST="repo-1 repo-2 repo-3"
BITBUCKET_BRANCH_LIST="primary secondary tertiary"

#The actual hard work:
for BITBUCKET_REPO_SLUG in $BITBUCKET_REPO_LIST; do
    curl -s -u $BITBUCKET_CREDS \
    "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines/?sort=-created_on&pagelen=20"|
    jq -r '[.values[] | select((.trigger.name == "PUSH" or .trigger.name == "MANUAL"))]' > api_response.json
    for BITBUCKET_BRANCH in $BITBUCKET_BRANCH_LIST; do
        if [[ $(jq -r '.[]| select(.target.ref_name == "'$BITBUCKET_BRANCH'")|
                select((.state.stage.name == "RUNNING") or (.state.stage.name == "PENDING"))' api_response.json) ]]
        then
            echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> There is a deployment in progress, doing nothing"
        else
            if [[ $(jq -r '[.[]| select(.target.ref_name == "'$BITBUCKET_BRANCH'")]|
                    .[0]|select(.state.stage.name == "HALTED")' api_response.json) ]]
            then
                echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> The latest deployment is paused, triggering new deployment"
                curl -X POST -is -u $BITBUCKET_CREDS -H 'Content-Type: application/json' \
                    "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines/" \
                    -d '{ "target": { "ref_type": "branch", "type": "pipeline_ref_target", "ref_name": "'$BITBUCKET_BRANCH'" } }'
            else
                echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> Latest pipeline is not paused, doing nothing"
            fi
        fi
    done
done
```
