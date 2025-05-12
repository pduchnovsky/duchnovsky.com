+++
categories = ["snippets", "navody"]
date = 2024-08-04T00:33:00
description = "Konvertujte Linux /proc/net/tcp (momentálne aktívne pripojenia tcp) z hex do formátu čitateľného človekom - IP adresy s portami"
slug = "convert-hex-to-human-readable"
tags = ["linux"]
title = "Previesť /proc/net/tcp hex na čitateľné pre človeka"

+++

Chcem sa podeliť o tento veľmi krátky úryvok kódu, ktorý mi pomohol konvertovať Linux /proc/net/tcp (momentálne aktívne pripojenia tcp) z hex do formátu čitateľného pre človeka - IP s portami, pomáha pri riešení problémov :)

```bash
# by pduchnovsky, https://duchnovsky.com/sk/2024/08/convert-hex-to-human-readable

cat /proc/net/tcp | awk '{x=strtonum("0x"substr($3,index($3,":")-2,2)); for (i=5; i>0; i-=2) x = x"."strtonum("0x"substr($3,i,2))}{print x":"strtonum("0x"substr($3,index($3,":")+1,4))}' | uniq

```
