---
layout: default
title: Options and Design
---
# {{ page.title }}

<ol>
  {% assign cat = site.data.navigation.pages | where: 'name', page.title %}
  {% for member in cat[0].members %}
      <li><a href="{{ member.link | absolute_url }}">{{ member.name }}</a></li>
  {% endfor %}
</ol>