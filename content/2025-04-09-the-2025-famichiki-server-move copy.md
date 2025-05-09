+++
title = "The 2025 Famichiki Great Server Move"
date = 2025-04-12
+++

We recently moved our Mastodon server [Famichiki](https://famichiki.jp) to a Japanese VPS.  
It used to be hosted on servers of an American company, but given the state of the U.S. 
and the increasingly hostile rhetoric toward its allies, it felt inappropriate to continue to send  
money to U.S. companies. Also, being an instance for users in Japan, the very least we could do  
is spend our money on a Japanese company to provide us with hosting.

So now we're hosted on [Conoha](https://conoha.jp), a Japanese company whose parent, GMO,  
is arguably one of the first internet companies in Japan. I've used them in the past to host  
[isitdelayed](https://isitdelayed.com) and other websites, so I'm quite confident we'll be alright here.

Because we're now being charged in yennies instead of dollars, our costs are decreasing too.
Before, our Mastodon instance (sans ElastichSearch or Pixelfed) was hosted on a $60 USD machine  with 4 cores and 8 GiB of memory. 
We're currently hosted on two 4-core, 4 GiB machines, at 4,000 JPY which off the top of my head comes down to around $32 — almost half the price for two extra cores. 
We still have to move Pixelfed and the Elasticsearch instance over, 
but we'll do that some other time. 
[Andrew](https://famichiki.jp/@piepants) will take care of Pixelfed, and I'll do Elasticsearch. One day.

We're still using Cloudflare as our CDN, but Andrew has been looking at  
Bunny, a European object storage platform, to completely move our dependency away from American providers.

Thanks as always for using our instance as your gateway into the Fediverse, and a double thank you if you're sending some coin our way to keep the servers up and running.