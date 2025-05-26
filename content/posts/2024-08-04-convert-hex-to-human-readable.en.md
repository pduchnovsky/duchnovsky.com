+++
categories = ["snippets", "guides"]
date = 2024-08-04T00:33:00
description = "Convert Linux /proc/net/tcp (currently active tcp connections) from hex to human readable format - IPs with ports"
slug = "convert-hex-to-human-readable"
tags = ["linux"]
title = "Convert /proc/net/tcp hex to human readable"

+++

Just want to share this very short code snippet that helped me to Convert Linux /proc/net/tcp (currently active tcp connections) from hex to human readable format - IPs with ports, helps with troubleshooting :)

```bash
# by pduchnovsky, https://duchnovsky.com/2024/08/convert-hex-to-human-readable

cat /proc/net/tcp | awk '{x=strtonum("0x"substr($3,index($3,":")-2,2)); for (i=5; i>0; i-=2) x = x"."strtonum("0x"substr($3,i,2))}{print x":"strtonum("0x"substr($3,index($3,":")+1,4))}' | uniq

```
