+++
categories = ["iac", "guides", "automation"]
date = 2021-07-14T20:39:02Z
description = "sometimes you only want to create a certain block when a variable is set.."
externalLink = ""
images = ["/images/asf9fsf8hg.png"]
series = ["terraform tips and tricks"]
slug = "tf-conditional-block"
tags = ["terraform", "cloud"]
title = "Conditional block in Terraform ?"

+++
Yes, sometimes you only want to create/set up a certain block within a resource only when a specific part of a variable is set..

...and yes, it's possible, thanks to [try](https://www.terraform.io/docs/language/functions/try.html) and [dynamic blocks](https://www.terraform.io/docs/language/expressions/dynamic-blocks.html) as well as [for_each](https://www.terraform.io/docs/language/meta-arguments/for_each.html) :)

Let me show you how to achieve this.

As an example, let's say, you want to create several different buckets in gcp and you want to use a terraform variable for 'additional' definition of some details, apart from 'default' settings defined in your .tf file.

Let this be your buckets config variable, let's name it `gcp_buckets`, which is understandably in json format:

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

Now, you only want to create 'cors' block when an 'bucket' object in variable `gcp_buckets` has a key named 'cors' and take configuration from there, also you only want to set up specific lifecycle rule only if there is a key named 'ttlDays' and take value from there..

This is how I do it, let me explain basics.

* This resource is only generated when a variable gcp_storage exists and thanks to above mentioned `try` function it tries to extract json encoded data and if it fails it returns empty object which means no resources are generated, otherwise it generates a resource per each object that we iterate over using `for_each`.
* As explained above, block `cors` for a resource is only 'dynamically' created when a key `cors` exists within the object and then it uses values from there.
* Same as with cors block, one of the `lifecycle_rule`-s is also only generated when key with name ttlDays exists and then takes value from there.
* Last non-dynamic lifecycle_rule serves as an example of 'default' block that is being created for every created resource, same as with definition of options for this resource etc..

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

Hope this is helpful to you and enjoy working with Terraform !