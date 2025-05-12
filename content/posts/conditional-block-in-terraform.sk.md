+++
categories = ["iac", "navody", "automatizacia"]
date = 2021-07-14T20:39:02
description = "niekedy chcete vytvoriť určitý blok iba vtedy, keď je nastavená premenná .. "
externalLink = ""
images = ["/images/asf9fsf8hg.png"]
series = ["terraform tipy a triky"]
slug = "tf-conditional-block"
tags = ["terraform", "cloud"]
title = "Podmienený blok v Terraforme? "

+++
Áno, niekedy chcete vytvoriť / nastaviť určitý blok v rámci resource iba vtedy, keď je nastavená konkrétna časť premennej.

... a áno, je to možné, vďaka [try](https://www.terraform.io/docs/language/functions/try.html) a [dynamic blocks](https://www.terraform.io/docs/language/expressions/dynamic-blocks.html) ako aj [for_each](https://www.terraform.io/docs/language/meta-arguments/for_each.html) :)

Ukážem vám, ako to dosiahnuť.

Povedzme napríklad, že chcete v gcp vytvoriť niekoľko rôznych segmentov a chcete použiť premennú terraformu na „ďalšiu“ definíciu niektorých detailov, okrem „predvolených“ nastavení definovaných v súbore .tf.

Nech je toto vaša konfiguračná premenná segmentov, pomenujme ju `gcp_buckets`, ktorá je pochopiteľne vo formáte json:

```json
{
    "test-bucket": {
        "cors": [
            {
                "origin": [
                    "*"
                ],
                "method": [
                    "GET",
                    "HEAD"
                ],
                "responseHeader": [
                    "Content-Type"
                ],
                "maxAgeSeconds": 3600
            }
        ]
    },
    "test-bucket-two": {
        "ttlDays": 2
    }
}
```

Teraz chcete vytvoriť blok „cors“ iba keď má objekt „bucket“ v premennej `gcp_buckets` kľúč s názvom „cors“ a odtiaľ prevezmete konfiguráciu. Tiež chcete nastaviť `lifecycle_rule`, iba ak existuje kľúč s názvom „ttlDays“ a odtiaľ použiť hodnotu ..

Takto to robím ja, dovoľte mi vysvetliť základné veci.

* Tento resource sa generuje iba vtedy, keď existuje premenná `gcp_storage` a vďaka vyššie uvedenej funkcii try sa pokúsi extrahovať údaje kódované v json formáte a ak zlyhá, vráti prázdny objekt, čo znamená, že nie sú generované žiadne resources, inak generuje resource pre každý objekt, ktorý iterujeme vďaka for_each.
* Ako je vysvetlené vyššie, blok `cors` pre resource sa vytvára iba „dynamicky“, keď v objekte existuje kľúč cors a potom použije hodnoty odtiaľ.
* Rovnako ako v prípade bloku cors, jeden z parametrov `lifecycle_rule`-s sa vygeneruje iba ak existuje kľúč s názvom ttlDays a odtiaľ potom získa hodnotu.
* Posledná nedynamický lifecycle_rule slúži ako príklad 'predvoleného' bloku, ktorý sa vytvára pre každý vytvorený resource, rovnako ako s definíciou nastavení pre tento resource atď.

```terraform
resource "google_storage_bucket" "global" {
  for_each = try(jsondecode(var.gcp_storage), {})
  name                        = each.key
  project                     = google_project.project.project_id
  location                    = "US-EAST1"
  storage_class               = "STANDARD"
  requester_pays              = "false"
  default_event_based_hold    = "false"
  force_destroy               = "false"
  uniform_bucket_level_access = "false"

  dynamic "cors" {
    for_each = try(each.value.cors, {})
    content {
      max_age_seconds = cors.value.maxAgeSeconds
      method          = cors.value.method
      origin          = cors.value.origin
      response_header = cors.value.responseHeader
    }
  }

  dynamic "lifecycle_rule" {
    for_each = try(["${each.value.ttlDays}"], {})
    content {
      action {
        type = "Delete"
      }

      condition {
        age                        = lifecycle_rule.value
        created_before             = ""
        days_since_custom_time     = "0"
        days_since_noncurrent_time = "0"
        num_newer_versions         = "0"
        with_state                 = "ANY"
      }
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age                        = "0"
      created_before             = ""
      days_since_custom_time     = "0"
      days_since_noncurrent_time = "30"
      num_newer_versions         = "0"
      with_state                 = "ANY"
    }
  }

  versioning {
    enabled = "true"
  }

  lifecycle {
    ignore_changes = [labels,]
  }
}
```

Dúfam, že vám to pomôže a užite si prácu s Terraform !