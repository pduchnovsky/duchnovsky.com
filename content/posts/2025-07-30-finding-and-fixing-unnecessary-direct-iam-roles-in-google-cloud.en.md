+++
title = "Finding and Fixing Unnecessary Direct IAM Roles in Google Cloud"
description = "This GCP IAM audit script helps you identify and clean up unnecessary direct role assignments across your Google Cloud organization. Quickly enhance GCP security by promoting least privilege access and simplifying IAM management."
date = "2025-07-30T16:44:00.000+02:00"
slug = "gcp-iam-audit-direct-roles"
images = ["images/89as987d7as98.png"]
categories = ["automation", "scripts", "snippets"]
tags = ["bash", "gcp", "cloud", "permissions", "iam"]
+++
Maintaining a secure and manageable access control policy in Google Cloud requires minimizing overly broad or unnecessary direct IAM role assignments. As organizations grow, it’s common for user-specific IAM bindings to accumulate, often leading to misconfigurations or excessive access permissions.

To help address this, I’ve developed a script that identifies **unnecessary direct IAM role assignments** across all projects within a GCP organization. This can be a powerful tool for auditing and cleaning up direct bindings in favor of group-based or managed identities.

### 🎯 Purpose

The script analyzes IAM policies across an entire GCP organization and searches for **explicit user-based role assignments**, then cross-references them against a list of users you're interested in auditing.

```shell
# by pduchnovsky, https://duchnovsky.com/2025/07/gcp-iam-audit-direct-roles
# Find unnecessary direct roles assigned
org=1234567890
USERS=(
  "xxxxx" "xxxxx"
)
USERS_JSON=$(printf '%s\n' "${USERS[@]}" | jq -R . | jq -s .)
QUERY=$(printf "policy:\"user:%s\" OR " "${USERS[@]}") && QUERY="${QUERY% OR }"
gcloud asset search-all-iam-policies \
  --scope="organizations/$org" \
  --query="${QUERY}" \
  --format=json | jq --argjson users "$USERS_JSON" -r '
  group_by(.project) |
  map({
    projectId: .[0].project,
    projectName: (.[0].resource | capture("projects/(?<name>[^/]+)").name // .[0].project),
    userRoles: (
      [.[]
        | .resource as $res
        | .policy.bindings[]
        | {role, members: [.members[]
            | select(startswith("user:"))
            | sub("^user:"; "")
          ], resource: $res}
      ]
      | map({role, resource, member: .members[]})
      | map(select((.member | split("@")[0]) as $id | $users | index($id)))
      | group_by(.member)
      | map({
          member: .[0].member,
          rolesByResource: (
            group_by(.resource) 
            | map({
                resource: .[0].resource,
                roles: map(.role) | unique
              })
          )
        })
    )
  }) |
  .[] |
  "--- Project: \(.projectName) (\(.projectId)) ---",
  "Google Cloud Console IAM Link: https://console.cloud.google.com/iam-admin/iam?project=\(.projectName)",
  (.userRoles[]? |
    "  Member: \(.member)",
    (.rolesByResource[] | 
      "    Resource: \(.resource)",
      (.roles[] | "      Role: " + .)
    )
  ),
  ""
'
```
