+++
title = "Nájsť a opraviť nepotrebné priame role IAM v Google Cloud"
description = "Skript na auditovanie IAM v GCP vám pomôže identifikovať a odstrániť nepotrebné priame priradenia rolí v rámci vašej organizácie Google Cloud. Rýchlo tak zvýšite bezpečnosť GCP podporou prístupu s najnižšími oprávneniami a zjednodušíte správu IAM."
date = "2025-07-30T16:44:00.000+02:00"
slug = "gcp-iam-audit-direct-roles"
images = ["images/89as987d7as98.png"]
categories = ["automatizacia", "scripty", "snippets"]
tags = ["bash", "gcp", "cloud", "prava", "iam"]
+++
Udržiavanie bezpečnej a spravovateľnej politiky kontroly prístupu v Google Cloud si vyžaduje minimalizáciu príliš širokých alebo zbytočných priamych priradení rolí IAM. S rastom organizácií sa bežne hromadia väzby IAM špecifické pre používateľov, čo často vedie k nesprávnym konfiguráciám alebo nadmerným prístupovým oprávneniam.

Na pomoc s týmto problémom som vyvinul skript, ktorý identifikuje **nepotrebné priame priradenia rolí IAM** naprieč všetkými projektmi v rámci GCP organizácie. Toto môže byť silný nástroj na auditovanie a čistenie priamych väzieb v prospech identít založených na skupinách alebo spravovaných identít.

### 🎯 Účel

Skript analyzuje politiky IAM v celej organizácii GCP a vyhľadáva **explicitné priradenia rolí** založené na používateľoch, potom ich krížovo overuje so zoznamom používateľov, ktorých chcete auditovať.

```shell
# by pduchnovsky, https://duchnovsky.com/sk/2025/07/gcp-iam-audit-direct-roles
# Nájsť nepotrebné priame priradenia rolí
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
