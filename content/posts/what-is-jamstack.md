+++
categories = []
date = 2020-12-03T09:27:33Z
description = "JAMstack is a modern web development architecture based on client-side JavaScript, APIs and content written in Markup format. The Static Site Generators are closely related to the JAMstack architecture which in itself isjust an acronym. Why closely related ? Because without them it would not be possible to compete with dynamic CMS."
externalLink = ""
images = ["/images/Mknql70lm3.png"]
series = []
slug = "what-is-jamstack"
tags = ["jamstack", "netlify", "hugo"]
title = "What is JAMstack ?"

+++
{{< notice info >}}
JAMstack is a modern web development architecture based on client-side **J**avaScript, **A**PIs and content written in **M**arkup format. The Static Site Generators are closely related to the JAMstack architecture which in itself is just an acronym. Why closely related ? Because without them it would not be possible to compete with dynamic CMS.
{{< /notice >}}

![><](/images/F09IGjZjtp.png)

##### JavaScript
Dynamic functionalities are handled by JavaScript. Imagine that I want a contact form on my page.. how do I implement it only with static pages ? There would be no way, since a static page is a static page.

##### APIs
Server side operations are abstracted into APIs and accessed over HTTPS with JavaScript.

##### Markup
Websites are served as static HTML files. These can be generated from source files, such as Markdown, using a Static Site Generator.

{{< notice info >}}
Static Site Generators are not used on their own but rather as part of the entire JAMstack.
{{< /notice >}}

##### Static Site Generators

Static site generators are not a new idea but most webhosting companies deploy new websites using WordPress, etc. where the content of pages/articles is stored on the server in a database. Static site generators on the other hand go in direction of static pages generated in advance and then serving them to the users directly via CDN.

Let's recall how "traditional" most common CMS on the market work: if you visit a page, the [URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) will first download the content of that page from the database on the server side, then relevant template and only then the page is stacked and shown in a browser. It doesn't matter if you use MySQL as a database on the server side and PHP as the language that composes those pages or MongoDB with Node and you compose the pages using JavaScript. This is the principle - the content is in the database and the site does not really exists yet - it's created on the fly only after receiving a request for a page from the user.

On the other hand, Static Site Generators (SSG) work differently: if you request a page, the page in html format is already on the server side ready to be served nearly instantaneously, every piece of data on the page was prepared in advance and is served in the same manner to everyone who visits your page. Now let's dive a little deeper.. All of your 'content' is written in .md files (Markdown) and this content is then injected within theme files (html templates) of your choice according to set of rules, it all depends on the chosen static site generator platform, where you start the build process that does this for you, this results in a static HTML page with content from the appropriate .md file and a look according to the chosen template. Development with the JAMstack architecture takes place mostly locally, but there are headless CMS systems out there that work with most of SSGs (more on that later). You can run the build process locally and just copy html files to your hosting or offload whole build process to your hosting provider end (if they support it) for finishing the deploy process, which places your html files on the CDN of your choice.

{{< notice info >}}
It’s like photocopying a letter instead of writing a new copy every time somebody wants to read it.
{{< /notice >}}

##### What are the benefits ?

Well, since JAMstack content is generated during build and it is served using CDN, there is **faster performance.**

Considering you don't need to worry about server/database vulnerabilities, it is also **more secure.**

Static files hosting is **dirt cheap or even free**..

From **developers** perspective, it is **better experience**, you can focus on front end without caring about architecture in the background. This also brings **quicker development**.

At last but not least it is **scalable**, CDN takes care of user-demand compensation :)

##### Workflow

![><](/images/bVGg2diSHW.png)

JAMstack workflow is quite simple, as an example we can take a look at this site and publishing of new blog post.

1. I create content using markdown files, these files can be written manually or using headless CMS such as [forestry.io](https://forestry.io/) or [Netlify CMS](https://www.netlifycms.org/) and many more.

   ![](/images/qwak29Af1Y.png)
2. Once the content is ready, I simply commit my changes using git to my repository which is connected to [Netlify](https://www.netlify.com/) for automated deployment. [Netlify](https://www.netlify.com/) then starts build using [Hugo](https://gohugo.io/) static site generator, this build takes average of 30 seconds for my site since Hugo is extremely fast ;)

   ![](/images/4AaWGM08OD.png)
3. Once build is complete, Netlify publishes changes to its CDN and invalidates cache.

Changes are live from start to the end in up to one minute.. :)

As a footnote, there are services that combine all of the above mentioned features and advantages, one of those is [stackbit](https://www.stackbit.com/), check it out !