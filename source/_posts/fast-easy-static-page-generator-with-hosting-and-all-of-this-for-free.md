---
title: Fast & easy static page generator with hosting and all of this.. for free ?
date: 2020-11-04T20:07:55.139Z
updated: 2020-11-04T23:03:26.346Z
thumbnail: /images/staticgenerator.jpg
---
Yes !
And it's quite easy and most importantly, if you are a little bit like me, it's also quite enjoyable.

So let's get in to it, my setup is already done so this guide is being done as retrospective, this way should be the least painful.

The last time I tried static page generators was quite a while.. going years back, it was a terrible experience back then if I'm to be honest.. those times are long gone.

I was looking for lightweight, fast and easy to understand and set up static site generator and I decided for [Hexo](https://hexo.io)

This guide is written in a way which expects you to be at least familiar with some basics of git, npm, linux systems in general.

###### Prerequisites:

* Free accounts on both [GitHub](https://github.com) and [Netlify](https://www.netlify.com)
* Linux system or Windows 10 WSL/2
* Installed [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [nodejs](https://nodejs.org/en/download) + [npm](https://www.npmjs.com/get-npm)

##### Let's begin !

1. Create new repository on GitHub using [this link](https://github.com/new)

   * You can select private repository

     ![github private](/images/rftocwl0cz.jpg)
2. Now let's install & configure hexo.

   ```bash
   # Install prerequisite packages
   sudo apt install libtool automake autoconf nasm
   # Install hexo npm package globally (-g)
   sudo npm install -g hexo-cli
   ```

   Now let's create a new directory and initialize it

   ```bash
   mkdir -p your/repo/dir
   hexo init your/repo/dir
   cd your/repo/dir
   # Install hexo packages
   npm install
   # Install additional hexo plugins, --save ensures that these plugins are
   # saved to package.json file, so netlify can install them too !
   npm install --save hexo-all-minifier
   npm install --save hexo-asset-link
   ```

   Let me show you how the basic directory structure looks like and which config files there are:

   ![hexo tree structure](/images/bh87wgsqlm.jpg)
3. It is now the time to edit your _config file located in your newly initialized directory, configure basics such as **url, title, description, keywords** etc..

   then add these lines at the end, so above installed additional plugins would work.

   ```yaml
   # hexo-all-minifier
   all_minifier: true
   image_minifier:
     optimizationLevel: 2
     progressive: true
   ```
4. Optionally you can install custom theme from various available [here](https://hexo.io/themes) or straight away continue setup of `_config.yml` file of your default theme here: `themes/landscape/_config.yml` where you need to also edit some fields such as page **title, owner, info, description** etc.. (depending on theme).
5. You add new posts by executing `hexo new post <post name>` and this will generate a new post in to `source/_posts` directory where you can edit them, initially there is 'hello-world.md' located there so you can get familiar with it.
7. Once both main config as well as theme config files are set up based on your preferences, you can test your page locally by starting hexo local server.

   ```bash
   hexo server
   ```

   Once you are happy with your barebone page we can continue to the deployment part.

##### Deployment

1. Firstly, add your [ssh key](https://www.ssh.com/ssh/keygen) [to your github account here](https://github.com/settings/keys)
2. From your hexo 'root' directory (or so called git project directory) you will be performing initial (and subsequent) deployment to the GitHub repository this way:

   ```bash
   # Get in to your directory where you initialized hexo
   cd your/repo/dir
   # Initialize git
   git init
   # now connect to your remote git repository
   git remote add origin git@github.com:username/repo_name.git
   # Stage all changes
   git add .
   # Commit all changes
   git commit -a
   # Push your commit
   git push
   ```

   For easier management I created following 'alias' function, you can add this piece of code in your `.bashrc` or `.bash_aliases` in your home directory (~/).

   ```bash
   push () {
       read -p "Commit description: " desc
       git add . && git add . && git commit -a --allow-empty-message -m "$desc" && git push
   }
   # 'git add .' is there twice so it also catches renamed files in one commit
   ```

   Then execute `exec $SHELL` to load the changes, from now command `push` will work and perform stage, commit and push all at once with or without commit message (for repo in your current directory).
3. Once the code is published to github, we can set up netlify page :) go to [app.netlify.com](https://app.netlify.com) and click '**new site from git**' and follow on screen instructions, netlify will detect that you are using hexo and prepare deployment commands/directory for you, so you can just continue to 'deploy site'.

   ![netlify build settings](/images/iqmylptbnl.jpg)
4. Set following options on netlify to optimize build and experience, under **site settings**:

   > **General** -> Site details -> Change site name -> Choose custom name ;)
   >
   > **Build & deploy** -> Post Processing -> Asset Optimization -> Edit settings -> Enable **Bundle CSS** only*.
   >
   > \*Other options are not as effective as the plugin we installed for hexo (hexo-all-minifier)
   >
   > **Domain Management**: Optionally set up custom domain and definitely set up **https** certificate, which is of course free, thanks to AWESOME [Let's encrypt](https://letsencrypt.org) !
6. Now.. every time you 'push' changes in your repo, netlify will auto**magic**ally build the site using hexo and publish it.

##### Optional stuff

I personally use following two plugins:

```
npm install --save hexo-generator-sitemap
npm install --save hexo-helper-obfuscate
```
This must be put in hexo config for sitemap generator
   ```yaml
   # hexo-generator-sitemap
   sitemap:
     path: /sitemap.xml
     template: ./sitemap_template.xml
     rel: true
     tags: true
     categories: true
   ```

**In order to use sitemap automatic generation** add this code in your themes files so it is being used somewhere under <head> html tag, in case of my theme this was possible in **layout.ejs** file.

   ```html
   <% if (config.sitemap.rel) { %>
   <link rel="sitemap" href="<%-config.url + config.sitemap.path %>" />
   <% } %>
   ```

Also create this `sitemap_template.xml` in the project root directory:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
     {% for post in posts %}
     <url>
       <loc>{{ post.permalink | uriencode }}</loc>
       {% if post.updated %}
       <lastmod>{{ post.updated | formatDate }}</lastmod>
       {% elif post.date %}
       <lastmod>{{ post.date | formatDate }}</lastmod>
       {% endif %}
     </url>
     {% endfor %}

     <url>
       <loc>{{ config.url | uriencode }}</loc>
       <lastmod>{{ sNow | formatDate }}</lastmod>
       <changefreq>daily</changefreq>
       <priority>1.0</priority>
     </url>

     {% for tag in tags %}
     <url>
       <loc>{{ tag.permalink | uriencode }}</loc>
       <lastmod>{{ sNow | formatDate }}</lastmod>
       <changefreq>daily</changefreq>
       <priority>0.6</priority>
     </url>
     {% endfor %}

     {% for cat in categories %}
     <url>
       <loc>{{ cat.permalink | uriencode }}</loc>
       <lastmod>{{ sNow | formatDate }}</lastmod>
       <changefreq>daily</changefreq>
       <priority>0.6</priority>
     </url>
     {% endfor %}
   </urlset>
   ```
Now you could enable optional plugin "Submit Sitemap"  by cdeleeuwe in **Plugins** section of Netlify, which automatically sends our sitemap to Google, Bing, and Yandex after every build.

As for obfuscation plugin, you can use this html code in your posts or theme files to obfuscate email addresses either taken from config or directly used in the code.
This should provide at least minimal protection.

   ```html
   <a href="mailto:<%- obfuscate(email@address.here) %>" target="_blank">email me</a>
   ```
I put it in my menu and ensured that it's taking email address from newly defined 'email' variable that I put in my theme config.
   ```html
   <% if (theme.email) { %>
   <a href="mailto:<%- obfuscate(theme.email) %>" target="_blank" class="ml">email</a>
   <% } %>
   ```