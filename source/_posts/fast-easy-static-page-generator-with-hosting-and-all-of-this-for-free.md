---
title: Fast & easy static page generator with hosting and all of this.. for free ?
date: 2020-11-04T20:07:55.139Z
thumbnail: /images/staticgenerator.jpg
---
Yes !
And it's quite easy and most importantly, if you are a little bit like me, it's also quite enjoyable.

So let's get in to it, my setup is already done so this guide is being done as retrospective, this way should be the least painful.

The last time I tried static page generators was quite a while.. going years back, it was a terrible experience back then if im to be honest.. those times are long gone.

I was looking for lightweight, fast and easy to understand and set up static site generator and I decided for [Hexo](https://hexo.io)

Now.. this guide is written in a way which expects you to be at least familiar with some basics of git, npm, linux systems in general.

###### Prerequisites:

* Free accounts on both [GitHub](https://github.com) and [Netlify](https://www.netlify.com)

##### Let's begin !

1. Create new repository on GitHub using [this link](https://github.com/new)

   * You can select private repository

     ![github private](/images/rftocwl0cz.jpg)
2. 'Clone' newly created repo locally based on your preference.
3. Now let's install & configure hexo.

   ```shell
   # Install prerequisite packages
   sudo apt install libtool automake autoconf nasm
   # Install hexo npm package globally (-g)
   sudo npm install -g hexo-cli
   # Initialize your locally cloned git directory
   hexo init your/repo/dir
   # Switch to the initialized directory
   cd your/repo/dir
   # Install hexo packages
   npm install
   # Install additional hexo plugins
   npm install --save hexo-all-minifier
   npm install --save hexo-generator-sitemap
   npm install --save hexo-helper-obfuscate
   ```
4. It is now the time to edit your _config file located in your newly initialized directory, configure basics such as **url, title, description, keywords** etc..

   then add these lines at the end, so above installed additional plugins would work.

   ```yaml
   # hexo-all-minifier
   all_minifier: true
   image_minifier:
     optimizationLevel: 2
     progressive: true
   # hexo-generator-sitemap
   sitemap:
     path: /sitemap.xml
     template: ./sitemap_template.xml
     rel: true
     tags: true
     categories: true
   ```

   Also create this `sitemap_template.xml` in the current directory:

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
5. Optionally ou can install custom theme from various available [here](https://hexo.io/themes) or straight away continue setup of `_config.yml` file of your default theme here: `themes/landscape/_config.yml` where you need to also edit some fields such as page **title, owner, info, description** etc.. (depending on theme).
6. Once both main config as well as theme config files are set up based on your preferences, you can test your page locally by starting hexo local server.

   ```shell
   hexo server
   ```

   Once you are happy with your barebone page we can continue to the deployment part.

##### Deployment

1. From your 'root' directory (the directory where your repo is cloned) you will be performing initial (and subsequent) deployment to the GitHub repository this way:

   ```shell
   # Get in to your repo directory
   cd your/repo/dir
   # Stage all changes
   git add .
   # Commit all changes
   git commit -a
   # Push your commit
   git push
   ```

   For easier management I created following 'alias' function, you can add this piece of code in your `.bashrc` or `.bash_aliases` in your home directory (~/).

   ```shell
   push () {
       read -p "Commit description: " desc
       git add . && git add . && git commit -a --allow-empty-message -m "$desc" && git push
   }
   # 'git add .' is there twice so it also catches renamed files in one commit
   ```

   Then execute `exec $SHELL` to load the changes, from now command `push` will work and perform stage, commit and push all at once with or without commit message (for repo in your current directory).
2. Once the code is published to github, we can set up netlify page :) go to [app.netlify.com](https://app.netlify.com) and click '**new site from git**' and follow on screen instructions, netlify will detect that you are using hexo and prepare deployment commands/directory for you, so you can just continue to 'deploy site'.

   ![netlify build settings](/images/iqmylptbnl.jpg)
3. Set following options on netlify to optimize build and experience, under **site settings**:

   > **General** -> Site details -> Change site name -> Choose custom name ;)
   >
   > **Build & deploy** -> Post Processing -> Asset Optimization -> Edit settings -> Enable **Bundle CSS** only*.
   >
   > \*Other options are not as effective as the plugin we installed for hexo (hexo-all-minifier)
   >
   > **Domain Management**: Optionally set up custom domain and definitely set up **https** certificate, which is of course free, thanks to AWESOME [Let's encrypt](https://letsencrypt.org) !
4. Enable optional plugins in **Plugins** section, I use only "Submit Sitemap"  by cdeleeuwe, which automatically sends our sitemap to Google, Bing, and Yandex after every build.
5. Now.. every time you 'push' changes in your repo, netlify will auto**magic**ally build the site using hexo and publish it.