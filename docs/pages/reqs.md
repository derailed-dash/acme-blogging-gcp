---
layout: default
title: Requirements, Assumptions and Other Supporting Information
---
<img src="{{'/assets/images/reqs-list.jpg' | relative_url }}" alt="Requirements" style="margin:15px 10px 10px 15px; float: right; width:255px" />

# {{ page.title }}

## Headings on This Page

- [Customer-Provided Business Case](#customer-provided-business-case)
- [Objective](#objective)
- [Case Study Acceptance Criteria](#case-study-acceptance-criteria)
- [About Ghost](#about-ghost)
- [Assumptions](#assumptions)
- [Other Considerations](#other-considerations)
- [Summary of Requirements](#summary-of-requirements)

## Customer-Provided Business Case

The customer _Acme Ltd Ltd._ is currently running their website on an outdated platform hosted in their own datacenter. They are about to launch a new product that will revolutionize the market and want to increase their social media presence with a blogging platform. During their ongoing modernization process, they decided they want to use the _Ghost Blog_ platform for their marketing efforts.

They do not know what kind of traffic to expect so the solution should be able to adapt to **traffic spikes**. It is expected that during the new product **launch** or **marketing campaigns** there could be increases of up to 4 times the typical load. It is crucial that the platform remains online even in case of a significant **geographical failure**. The customer is also interested in **disaster recovery** capabilities in case of a region failure.

As _Ghost_ will be a crucial part of the marketing efforts, the customer plans to have **5 DevOps teams** working on the project. The teams want to be able to release new versions of the application **multiple times per day, without requiring any downtime.** The customer wants to have **multiple separated environments** to support their development efforts. As they are also tasked with maintaining the environment they need tools to support their operations and help them with **visualising and debugging** the state of the environment. The website will be **exposed to the internet**, thus the **security team** also needs to have visibility into the platform and its operations. The customer has also asked for the **ability to delete all posts at once** using a **serverless function.**

## Objective

You are tasked to deliver a Proof of Concept for their new website. Your role is to design and implement a solution architecture that covers the previously mentioned requirements, using the **Google Cloud Platform**. The solution should be **optimised for costs** and **easy to maintain/develop** in the future.

## Case Study Acceptance Criteria

- The application should be able to **scale** depending on the load.
- There should be no obvious **security** flaws.
- The application must return **consistent results** across sessions.
- The implementation should be built in a **resilient** manner.
- **Observability** must be taken into account when implementing the solution.
- The **deployment** of the application and environment should be **automated**.

## About Ghost

**[Ghost](https://ghost.org/){:target="_blank"}** is an open source **content publishing platform**, built on a Node.js stack. It is one of the most popular open source projects in the world, and is the number 1 CMS on [GitHub](https://github.com/tryghost/ghost){:target="_blank"}.

Whilst Ghost offer a managed hosting option, our desire here is to deploy Ghost to GCP.  The [Ghost documentation](https://ghost.org/docs/install/){:target="_blank"} recommends self hosting Ghost using one of the following options:

- Ubuntu Linux / MySQL 5.7 or 8.0 / Nginx
- [Docker community image](https://hub.docker.com/_/ghost/){:target="_blank"}

## Assumptions

Here is a summary of the some of my assumptions, when tackling this case study:

- There is **no existing on-prem** solution or content to migrate.
- Blogging will be done by **Acme Ltd employees only**; there is currently no need for visitors to contribute or upload their own content.
- The master identity provider is an existing on-premise system (e.g. Active Directory). In a real environment, we might synchronise into Cloud Identity using GCDS. But for the purposes of this demo, I'll use **demo identities**.
- **All persistence will be done in the DB tier.** The application servers are **stateless**.
- The requirements are somewhat ambiguous when saying _"online even in case of a significant geographic failure"_, whilst also saying _"interested in disaster recovery capabilities in case of a region failure."_ 
  - Regions are themselves defined as an _independent geographic area_. 
  - Multi-zonal resources in a given region _may_ not be sufficiently geographically separated to tolerate a large disaster. Zones are typically anywhere between a few hundred metres to several kilometres apart. 
  - Given this ambiguity in the requirements, I will assume that that we **require high availability within a region, and DR capability between regions.** Thus, I will assume an RTO of 30 minutes is acceptable, for a regional disaster.

## Other Considerations

- A demonstration of the solution is required, which can be deployed from code.

## Summary of Requirements

Here I've summarised my thoughts on what the final solution needs to deliver:

- Hosting for Ghost CMS - Internet accesssible.
- Serverless functionality to delete all posts at once - authorised users only.
- Consistent results between sessions.
- Scalable and elastic.
- Highly available.
- Disaster recovery for region failure.
- Automated deployment of environments and application.
- Support multiple daily releases, with no downtime.
- Five DevOps teams, each with their own environment, plus other pipeline environments, as required.
- Operational tools and observability.
- Secure.
- Cost optimised.