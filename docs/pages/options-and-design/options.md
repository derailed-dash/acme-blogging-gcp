---
layout: default
title: Solution Options and Recommendations
---
# {{ page.title }}

Here I summarise some of the key decision options and options considered.

## Sections in this Page

- [Ghost Application Frontend](#ghost-application-frontend)
- [Pruning Application Frontend](#pruning-application-frontend)
- [Application Persistence / Database](#application-persistence--database)
- [Infrastructure-as-Code](#infrastructure-as-code-iac)
- [CI/CD Pipeline](#cicd-pipeline)

## Ghost Application Frontend

These are the hosting options for the Ghost web application itself.

<table class="dazbo-table" style="width: 100%;">
    <tr>
        <th style="width: 15%">Option</th>
        <th style="width: 38%">Pros</th>
        <th style="width: 38%">Cons</th>
        <th>Recommendation</th>
    </tr>
    <tr>
        <td>GCE instances</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Standard Ghost stack.</li>
                <li>Can provide scalability and HA using managed instance group and load balancer.</li>
                <li>Rolling upgrades possible with managed instance group.</li>
                <li>Can securely connect to Cloud SQL using Cloud SQL proxy.</li>
                <li>Would use hardened OS with no external IP address.</li>
                <li>If we need local persistence, then this will be preferable to Cloud Run.  We can provide HA block persistence using a regional persistent disk (though it has limitations), or HA managed NFS using Cloud Filestore.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">
            <ul>
                <li>Need to maintain OS. Option to maintain by patching or replacing OS</li>
                <li>Off-the-shelf Ghost installation not fully automated / scripted. Can be mitigated by deploying as a container.</li>  
            </ul>
        </td>
        <td>Fallback, if Cloud Run proves unworkable.</td>
    </tr>
    <tr>
        <td>Cloud Run</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Fully-managed serverless container runtime environment. No need to manage a cluster.</li>
                <li>Off-the-shelf community-supported container available</li>
                <li>Much more lightweight than GCE instances</li>
                <li>Can still use HTTPS LB, in order to leverage CDN, Cloud Armor, etc</li>
                <li>Easy to set up CI/CD using Cloud Build</li>
                <li>Google Container Registry can scan for vulnerabilities</li>
            </ul>
        </td>
        <td style="background: #f4cccc">Default container is SQLite; tricky to configure with Cloud SQL.</td>
        <td>Recommend</td>
    </tr>
    <tr>
        <td>Google Kubernetes Engine (GKE)</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Managed Kubernetes.</li>
                <li>Powerfull orchestration and scheduling capabilities.</li>
                <li>Supports complex multi-service architectures.</li>
                <li>Supports stateful containers.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">
            <ul>
                <li>Significant management overhead, compared to Cloud Run.</li>
                <li>Higher base cost. Can't scale to 0.</li>
                <li>Overkill for a single service.</li>
            </ul>
        </td>
        <td>Reject</td>
    </tr>    
    <tr>
        <td>App Engine</td>
        <td style="background: #b6d7a8">Serverless PaaS, in which we can run nginx and deploy the Ghost application code.</td>
        <td style="background: #f4cccc">Limited support or documentaton for this configuration.</td>
        <td>Reject</td>
    </tr>
</table>

## Pruning Application Frontend

These are the hosting options for the application that will allow authorised users to prune all posts in the Ghost database.

<table class="dazbo-table">
    <tr>
        <th style="width: 15%">Option</th>
        <th style="width: 38%">Pros</th>
        <th style="width: 38%">Cons</th>
        <th>Recommendation</th>
    </tr>
    <tr>
        <td>Cloud Functions</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>The brief strongly hints at wanting a <i>"serverless function"</i>.</li>
                <li>Trivial to implement code to delete records from a database.</li>
                <li>Easy to implement to respond to an HTTP event</li>
                <li>Can scale down to 0. Given the low level of expected invocations, this service will effectively be free.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">Not easy to provide a means to authenticate the user.</td>
        <td>Not ideal, but requested</td>
    </tr>
    <tr>
        <td>Cloud Run</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Fully-managed serverless container runtime environment.</li>
                <li>Easy to deploy a web application in a container.</li>
                <li>Highly portable.</li>
                <li>Still a lightweight serverless approach.</li>
                <li>Can scale to 0, which is ideal for a service that is rarely invoked.</li>
                <li>Easy to repackage images in response to source code changes, using Cloud Build.</li>
                <li>Google Container Registry can scan for vulnerabilities</li>
                <li>Easy to implement user authentication and authorisation to the service. Since the service will only be accessed by authorised individuals in the organisation, we can use IAP on the load balancer, with an ingress.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">Need to package the application in a container image.</td>
        <td><i>Would</i> recommend</td>
    </tr>  
    <tr>
        <td>App Engine</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Serverless PaaS.</li>
                <li>No need to package as a container.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">Less portable than using containers.</td>
        <td>Reject</td>
    </tr>
</table>

## Application Persistence / Database

<table class="dazbo-table">
    <tr>
        <th style="width: 15%">Option</th>
        <th style="width: 38%">Pros</th>
        <th style="width: 38%">Cons</th>
        <th>Recommendation</th>
    </tr>
    <tr>
        <td>Cloud SQL MySQL DB</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>MySQL is an endorsed database for Ghost.</li>
                <li>Fully-managed relational DB.</li>
                <li>Supports both intra-region HA, and cross-region replicas for DR.</li>
                <li>Database engine itself is open source and free.</li>
                <li>No DB installation, management or patching.</li>
                <li>No DBA overhead.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">Promotion of cross-region replica to "master" cannot be done using declarative IaC. Some manual steps required in DR process.</td>
        <td>Recommend</td>
    </tr>
    <tr>
        <td>Build your own MySQL DB (install onto GCE instance)</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>(None, over Cloud SQL implementation.)</li>
            </ul>
        </td>
        <td style="background: #f4cccc">
            <ul>
                <li>DBA overhead: this is not a managed implementation.</li>
                <li>Requires installation and management of the DB.</li>
                <li>OS engineer overhead: Requires installation and management of GCE instances.</li>
            </ul>
        </td>
        <td>Reject</td>
    </tr>
    <tr>
        <td>SQLlite</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Default off-the-shelf implementation for Ghost.</li>
                <li>Lightweight.</li>
                <li>Little or no configuration required.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">
            <ul>
                <li>Local (per-instance) persistence only. Won't meet consistency requirement! Nor HA.</li>
                <li>If we implement within a container, the data would not be persisted.</li>
            </ul>
        </td>
        <td>Reject</td>
    </tr>
    <tr>
        <td>Cloud Spanner</td>
        <td style="background: #b6d7a8">Fully cloud-native.</td>
        <td style="background: #f4cccc">
            <ul>
                <li>Massive overkill for this scale.</li>
                <li>Very expensive.</li>
                <li>Unlikely to be supported by the application.</li>
            </ul>
        </td>
        <td>Reject</td>
    </tr>
</table>

## Infrastructure-as-Code (IaC)

<table class="dazbo-table">
    <tr>
        <th style="width: 15%">Option</th>
        <th style="width: 38%">Pros</th>
        <th style="width: 38%">Cons</th>
        <th>Recommendation</th>
    </tr>
    <tr>
        <td>Terraform</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Declarative.</li>
                <li>Cloud agnostic and therefore helps avoid cloud vendor lock-in.</li>
                <li>Extremely lightweight installation. (And installed by default on Google Cloud Shell.)</li>
                <li>No agents.</li>
                <li>Open source.</li>
                <li>Endorsed / certified modules from HashiCorp, and from cloud vendors (including Google)</li>
                <li>Supports IaC of components across a wide ecosystem.</li>
                <li>Strong validation capabilities.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">N/A</td>
        <td>Recommend</td>
    </tr>
    <tr>
        <td>Google Cloud Deployment Manager</td>
        <td style="background: #b6d7a8">
            <ul>
                <li>Fully-managed Google Cloud solution, integrated into the Google Cloud ecosystem.</li>
                <li>No installation or management required.</li>
                <li>Declarative.</li>
                <li>No agents.</li>
            </ul>
        </td>
        <td style="background: #f4cccc">
            <ul>
                <li>Limited support for products outside of Google Cloud's native offering.  (E.g. Kubernetes).</li>
                <li>Google only.</li>
                <li>Google are now promoting Terraform over their own Cloud Deployments. Implies deprecation.</li>
            </ul>
        </td>
        <td>Reject</td>
    </tr>
</table>

## CI/CD Pipeline

<table class="dazbo-table">
    <tr>
        <th style="width: 15%">Option</th>
        <th style="width: 38%">Pros</th>
        <th style="width: 38%">Cons</th>
        <th>Recommendation</th>
    </tr>
    <tr>
        <td>Google Cloud Build</td>
        <td style="background: #b6d7a8">
          <ul>
            <li>Fully managed, serverless Google-native CI/CD tooling.</li>
            <li>Can consume various backends, including GitHub, Google Cloud Source Repositories, and BitBucket.</li>
            <li>Native container support.</li>
            <li>Vulnerability scanning and binary authorisation of containers are built-in.</li>
          </ul>
        </td>
        <td style="background: #f4cccc">Not cloud agnostic.</td>
        <td>Recommend</td>
    </tr>
    <tr>
        <td>Jenkins</td>
        <td style="background: #b6d7a8">
          <ul>
            <li>Open source - no license cost.</li>
            <li>Can integrate with any upstream or downstream components.</li>
            <li>Cloud agnostic.</li>
            <li>Very powerful.</li>
          </ul>
        </td>
        <td style="background: #f4cccc">
          <ul>
            <li>Requires installation and maintenance. Would typically be deployed on Kubernetes (or GKE in Google Cloud).</li>
            <li>Whilst Jenkins is free, remember that the run infrastructure is not.</li>
            <li>With sophistication comes skills overheads.</li>
          </ul>
        </td>
        <td>Reject</td>
    </tr>
    <tr>
        <td>GitLab</td>
        <td style="background: #b6d7a8">
          <ul>
            <li>Very mature CI/CD workflow, integrated with its own Git repos.</li>
            <li>Basically an all-in-one CI/CD SaaS.</li>
            <li>Cloud agnostic.</li>            
          </ul>
        </td>
        <td style="background: #f4cccc">Not free.</td>
        <td>Reject</td>
    </tr>
    <tr>
        <td>GitHub Actions</td>
        <td style="background: #b6d7a8">
          <ul>
            <li>Embedded with the GitHub ecosystem.</li>
            <li>Good choice if we already have a lot of GitHub repos.</li>
            <li>Cloud agnostic.</li>            
            <li>Actions has a market place for consuming workflows.</li>
            <li>Free up to a point. A lot of free minutes!</li>
          </ul>
        </td>
        <td style="background: #f4cccc">
          <ul>
            <li>Relatively new product, so not as mature as others.</li>
            <li>Dependent on load, may have a cost.</li>
          </ul>
        </td>
        <td>Second choice.</td>
    </tr>          
</table>