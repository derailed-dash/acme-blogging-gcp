---
layout: default
title: Business Case
---
<img src="{{'/assets/images/advantages.jpg' | relative_url }}" alt="Advantages" style="margin:35px 35px 10px 15px; float: right; width:200px" />
# {{ page.title }}

## Sections in this Page

- [Benefits](#benefits)
- [Gotchas](#gotchas)
- [Cost Saving Considerations in the Design](#cost-saving-considerations-in-the-design)

Since public cloud with Google Cloud Platform has already been selected as the preferred hosting venue, I won't spend too much time retrospectively justifying the decision here.

However, I will call out some key points.

## Benefits

Public cloud delivers **agility** (getting products to market faster), **reduced operational overheads and costs**, and ultimately **improves the ROI** for all initiatives with a significant IT footprint.  Most oganisations see payback on cloud transformation within two years.

Breaking down some of the benefits:

<img src="{{'/assets/images/cloud-wins.png' | relative_url }}" alt="Benefits of Cloud" style="margin:15px 10px 10px 0px;" />

In addition: the ability for any developer to build any solution - from PoC all the way to a production systems - without being dependent on many other teams.

## Gotchas

It is easy to make mistakes that can negate these benefits.  Here are some things to be mindful of:

- **Stick to open source** where possible.  Avoid using proprietary licensed code.  Licensed products will typically eliminate almost all of the scalability and elasticity benefit. (Consider where you might have to buy enough licenses to cover your peak utilisation.)
- **Stick to cloud native and/or fully-managed services** where possible.  E.g. if you need a relational database, consider a cloud native solution or a fully-managed solution.  That way, all deployment, maintenance, patching, and security are taken care of.  Don't build your own on IaaS.  If you do that, you need to manage and patch your operating systems, and then manage and patch software deployed to them (e.g. databases).
- **Always build with automation.** One of the main advantages of cloud is that it is software defined.  This means we can build infrastructure using code. And this means our builds can be repeatable, consistent and fast.  It also means that the infrastructure-as-code (IaC) is self-documenting, reducing the need for heavy low-level design docs.  Avoid building by hand; this leads to configuration drift.
- **Turn off services that are not in use.**  Pay for what you use!
- **Organisational and cultural change are very important.** Cloud requires a different mode of operation, with significant elimination of the barrier between traditional operations and development teams.

## Cost Saving Considerations in the Design

- Terraform modules are configured to deploy smaller VM instances to dev environments, compared to Prod.
- Terraform modules are configured to limit scale out on smaller environments.