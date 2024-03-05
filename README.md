# Ingenio DevOps test

## Table of Contents  
  - [Table of Contents](#table-of-contents)
  - [Summary](#summary)
  - [Architecture](#architecture)
  - [Infrastructure as Code](#infrastructure-as-code)
  - [Kubernetes](#kubernetes)
  - [Continuous Integration & Continuous Deployment](#continuous-integration--continuous-deployment)
  - [Artifacts](#artifacts)
  - [Improvements](#improvements)



## Summary
This repo contains the necessary code to deploy the Ingenio DevOps test, which encourages people to use best practices to deploy an application to an environment that's fully automated, scalable, high available and reliable.

**Notes:** 
- Due to the ammount of testing done, using the real Let'sEncrypt server, domain snwbr.net got blocked a couple of times. At the time of reading, sites such as https://snwbr.net/ may present you an invalid cert, that if you check using Chrome, it will show you it's not invalid, but using Let'sEncrypt staging servers (which is the one should be used for development purposes). Real certificates can be enabled by changing `name: ingress-staging` to `name: ingress` in the ingress controller's [issuers](k8s/charts/hello-world/templates/ingress.yaml), commit, push to `main` and it will be applied by GitHub Actions.
- **IMPORTANT**: In order to avoid costs associated with having GKE and instances running up, I destroyed the GKE cluster. It can be easily put it back with all the stack in minutes. Please create a [Github issue](https://github.com/snwbr/gl-test/issues/new) saying you want the environment up and I'll create it as soon as I see the issue and reply it back when's done.

## Architecture
### Toolset and technologies

- Cloud provider: Google Cloud
- Infrastructure as Code: Terraform
- CI/CD: Github Actions
- K8s teamplating: kustomize
- K8s installation manager: Helm
- Reverse proxy, routing, service discovery and TLS termination: GCE (for quickness, but I don't like it honestly)
- K8s CNI: Calico
- Certificates management: Cert-manager
- Domain provider: Google Domains

### High level architecture diagram
TBD

## Infrastructure as Code

For creating objects in the cloud, Terraform was chosen. Terraform code is splitted by enviornments (see the [README](terraform/README.md)).

Terraform manages the construction of the Virtual Private Network, as well as the Identity-Aware Proxy (Cloud IAP) to connect from remote locations to the private network resources. Also, the GCP project's API are managed through Terraform. Rest of objects (firewall rules, dns names, NAT, routers, service accounts, etc) are part of it.

## Kubernetes

During this challenge, Google Kubernetes Enginer (GKE) was chosen. The configuration is as follows:
- Private cluster, with no direct access to internet (no node has public IP).
- Node autoscaling is enabled in prod, for High Availability. It is disabled in dev due to costs.
- Terraform-managed nodepool.
- Ingress is served through default GCE.
- One single service using a public IP through a LoadBalancer K8s service which is the only source of access to K8s services.
- Internet access is provider at VPC level through a Router using NAT.
- SSL Certificates for the application are managed through cert-manager, auto-renewing when needed.
- Services and pods interconnections is done through internal routing and DNS.

## Continuous Integration & Continuous Deployment

Github Actions runs mainly during two important SDLC phases:
- **Git push to branch:** GHA listens to the repo and build every push to the monitored branches (develop and main).
  - If the branch that gets the push (or merge) event is "main", GHA will not only run the CI pipeline (build, validate and test) but the CD pipeline as well (deploy the code to K8s).
- **Pull requests creation:** GHA detects any pull request created, checks out the pull request data and then it runs the CI pipeline. Results of the run are reported back to Github to decision on whether or not to merge into "main".

## Artifacts

The main artifacts created by GHA are the docker images to be deployed.

## Improvements

To stick to the challenge request and deliver it on time, a good ammount of good practices were not done, but they're not heavily required for a demo purpose. Still though, they're listed here as things I would improve to this solution:

- Addition of an OAuth or an authentication forward to some authentication service at load balancer or Traefik layers.
- Addition of proper liveness and readiness probes to K8s deployments.
- Creation a secret management tool such as Vault.
- Split Terraform code from K8s into different repositories to be able to manage them through different access controls and strategies.
- Introduce security vulnerabilities scan to generated docker images.
- Added some lint rules to code (SonarQube perhaps).
- Implementing monitoring and alerting to the stack (through Prometheus & Grafana or New Relic if there is a license for that).
- Adding a logging stack, either EFK or stackdriver metrics (because it's in Google).
- Configure apps and/or managed objects using ansible.
- Adding Atlantis for TF plan/apply via Github PRs (and achieve true GitOps).
- Creation of granular RBAC rules through all the tools and processes.
- Add more testing (unit, integration, contract, E2E, regression, performance/stress, smoke, etc).
- Use of tools like terragrunt for managing multiple environments.
- Use of Cillium for eBPF enhanced traceability and service mesh, or at least some router like Traefik.