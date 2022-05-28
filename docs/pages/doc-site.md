---
layout: default
title: Rendering This Site
---
<img src="{{'/assets/images/jekyll-og.png' | relative_url }}" alt="Jekyll" style="margin:15px 10px 10px 15px; float: right; width:300px" />

# {{ page.title }}

This documentation website has been built using the [Jekyll](https://jekyllrb.com/){:target="_blank"} static site generator.

## In a Nutshell

- Static content is mostly written using markdown. Jekyll renders markdown to HTML using templates.
- Templates are written in plain old HTML.
- Jekyll supports embedded intelligence using a language called [Liquid](https://shopify.github.io/liquid/){:target="_blank"}.
- Jekyll can read configuration files - e.g. yaml files - using Liquid. For example, the navigation of this site is built using yaml.

## How to Run Jekyll

The Jekyll engine must be installed and running, in order to render your site. One way to install Jekyll is to:

1. Install Ruby, which is a dependency for Jekyll.
1. Instal Jekyll, and it's required Ruby Gems.
1. Run Jekyll.

The main issues with this approach are:

1. It requires quite a lot of configuration on the host machine.  This might break other applications. And the dependencies can be hard to maintain.
1. Where's the fun in doing it that way?

So I've opted to run Jekyll using a **Docker container**.

## Installing Jekyll as a Container and Building this Site

```bash
# create the site folder in your project
my-proj> mkdir docs
my-proj> cd docs

# Pull and run the Jekyll container interactively, and launch the shell
my-proj/docs> docker run -e "JEKYLL_ENV=docker"
	--rm -it 
 	-v "${PWD}:/srv/jekyll" -v "${PWD}/vendor/bundle:/usr/local/bundle"
	-p 127.0.0.1:4000:4000
	jekyll/jekyll sh

# Initialise the new site
/srv/jekyll $ chown -R jekyll /srv/jekyll/
/srv/jekyll $ jekyll new --force --skip-bundle .
```

Edit the newly created Gemfile to include these two lines. (Check the latest versions [here](https://pages.github.com/versions/){:target="_blank"}.)

```text
gem "jekyll", "~> 3.9"
gem "github-pages", "~> 219", group: :jekyll_plugins
```

Edit the newly created _config.yml:

```yaml
title: Acme Blogging App on Google Cloud
description: Acme Blogging App Hosting on Google Cloud Platform

repository: <your-repo-path>
baseurl: /
url: https://acme-blogging-docs.just2good.co.uk

github_username: Derailed-Dash
author: Dazbo

# Build settings
theme: jekyll-theme-modernist
plugins:
  - jekyll-feed

exclude:
  - docker-compose.yml
```

```bash
/srv/jekyll $ bundle update
/srv/jekyll $ exit
```

## Launching Jekyll, to Update the Site

For this, I've created a Docker compose file:

```yaml
version: '3.9'
services:
  acme-blogging-docs:
    environment:
      - JEKYLL_ENV=docker # to stop Jekyll from overriding site.url to http://0.0.0.0:4000
    command: jekyll serve --watch --config _config.yml,_config.docker.yml
    image: jekyll/jekyll
    container_name: dazbo-jekyll-acme-blogging
    volumes:
      - .:/srv/jekyll
      - ./vendor/bundle:/usr/local/bundle  # to cache bundle configuration
    ports:
      - 127.0.0.1:4000:4000
```

So all we need to do is:

```
docker compose up
```

And that's how this site was generated!