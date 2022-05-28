---
layout: default
title: Operations
---
<img src="{{'/assets/images/traffic-lights.jpg' | relative_url }}" alt="Traffic lights" style="margin:35px 35px 10px 15px; float: right; width:280px" />
# {{ page.title }}

## Sections in this Page

- [Setup](#setup)
- [Alerting Policies and Uptime Checks](#custom-dashboard)
- [Custom Dashboard](#custom-dashboard)

## Setup

The monitoring projects themselves are created by the Terraform project factory. However, some steps have yet to be automated and need to be carried out manually.  Specifically:

- The non-prod projects have been added as monitored projects.
- The Google [Ops Agent](https://cloud.google.com/blog/products/operations/ops-agent-now-ga-and-it-includes-opentelemetry){:target="_blank"} has been deployed on all instances, using Terraform.

## Alerting Policies and Uptime Checks

- An alerting policy has been configured, currently sending emails to the org admins group. This is monitoring the URL that points to the external load balancer.
- CPU, memory and disk alerts have been set, based on high thresholds.
- An uptime check has been defined, which alerts if the Ghost service is unavailable.

<img src="{{'/assets/images/uptime-check.jpg' | relative_url }}" alt="Uptime Check" style="margin:15px 0px 10px 0px" />

## Custom Dashboard

A custom dashboard has been created, showing some key indicators.

<img src="{{'/assets/images/metrics-dashboard.jpg' | relative_url }}" alt="Metrics Dashboard" style="margin:15px 0px 10px 0px" />


