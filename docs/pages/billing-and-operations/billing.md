---
layout: default
title: Billing and Dashboards
---
<img src="{{'/assets/images/cost-dial.jpg' | relative_url }}" alt="Cost" style="margin:35px 35px 10px 15px; float: right; width:280px" />
# {{ page.title }}

## Sections in this Page

- [Access and Roles](#access-and-roles)
- [Labels](#labels)
- [Billing Alerts](#billing-alerts)
- [Custom Billing Reports](#custom-billing-reports)
- [Biling Exports](#biling-exports)
- [Billing Dashboards](#billing-dashboards)
- [Indicative Costs](#indicative-costs)

## Access and Roles

- **Billing Administration** is only possible by members of the _gcp-billing-admins_ group.
- **Read-only** billing visibility is currently provided to the _gcp-project-viewers_ group, for convenience. (Through the Billing Account User role.)
- Furthermore, groups and identities can be given access to billing information related to their projects, without giving access to entire billing account.

## Labels

Resources are labelled to facilitate slicing and dicing of data.  Furthermore, the Project Factory enforces standard labels. These include:
- Application name
- Component type
- Environment (e.g. _dev-1_, _dev-2_, etc)
- Environment category (e.g. _Non-Prod_ and _Prod_).  

Other labels could be added. This screenshot demonstrates how such views can be filtered:

<img src="{{'/assets/images/cost-by-environment.jpg' | relative_url }}" alt="Cost by Env Type" style="margin:15px 10px 0px 25px; width:820px" />

## Billing Alerts

Billing alerts have been configured at 50%, 75%, 90%, and 100% of a specified threshold, with email alerts going to billing admins and billing account users.

<img src="{{'/assets/images/budget_report.jpg' | relative_url }}" alt="Budget report" style="margin:15px 10px 0px 25px; width:820px" />

## Custom Billing Reports

- Here we can see the billing report for all resources used during the creation of this solution. Steady state is now at about £4/day.

<img src="{{'/assets/images/billing-total.jpg' | relative_url }}" alt="Billing Total" style="margin:15px 10px 0px 15px; width:860px" />

- Costs can be viewed at **resource (SKU) level**.  A custom report has been created to do this:

<img src="{{'/assets/images/billing_report_chart_daily_skus.jpg' | relative_url }}" alt="SKU report" style="margin:15px 10px 0px 25px; width:820px" />

## Biling Exports

**Billing exports** have been enabled, meaning that billing data is automatically exported to Google **BigQuery**.  From here:
- Direct **analytics** can be performed, e.g. using SQL queries.
- E.g. this billing report shows the total cost of all projects with a spend (excluding promotional credits) greater than 0.01:

<img src="{{'/assets/images/billing-bq.jpg' | relative_url }}" alt="SKU report" style="margin:15px 10px 0px 20px; width:840px" />

## Billing Dashboards

The billing exports in BigQuery can be used as a data source to custom dashboards in Data Studio.  Here I have configured a sample dashboard, presenting various views of the billing data, e.g. costs by service, costs by project, etc.

<img src="{{'/assets/images/billing-dashboard.jpg' | relative_url }}" alt="Billing Dashboard" style="margin:15px 10px 0px 20px; width:840px" />

The dashboard is available [here (please request access)](https://datastudio.google.com/u/0/reporting/a0f62bfa-ba65-46d8-aa15-e121c834150e/page/b2yX){:target="_blank"}.

## Indicative Costs

Costs can be estimated from two main sources:

1. The [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator/){:target="_blank"}.
1. The generated billing data.

Some headlines:

- A single highly available non-prod environment runs at under £4/day, or approximately £1500/year.
- Most of this cost is attributable to compute.  (Many services in the architecture have negligible cost.)
- The production environment would cost more, on account of using larger application server and DB instances.  A reasonable estimate would be £2000/year.  This could go higher, depending on demand on the application.
- Clearly, the more environments that are running in parallel, the higher the overall TCO. 
  - If we were running 5 dev environments, a QA environment, a Pre-Prod environment and a Prod environment in parallel, 24x7, the cost would be in excess of £12000/year.
  - Consequently, it is advisable to stop or tear down environments that are not in use.