# EKS OIDC Helm Prometheus Grafana

AWS EKS infrastructure with GitHub Actions OIDC, ArgoCD GitOps, and Prometheus/Grafana monitoring.

## Features

![2048 Game Deployment](images/2048-secure.png)

![ArgoCD Dashboard](images/argocd-1.png)

![Prometheus Monitoring](images/prometheus-1.png)

![Grafana Visualization](images/grafana-1.png)

- Infrastructure as Code with Terraform
- GitHub Actions CI/CD using OIDC (no long-lived credentials)
- GitOps deployment with ArgoCD
- Monitoring with Prometheus & Grafana
- Automatic SSL certificates via cert-manager
- DNS management with external-dns

## Setup

### Bootstrap OIDC

```bash
./scripts/bootstrap-oidc.sh
```

### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### Configure kubectl

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

## Cleanup

```bash
./scripts/cleanup.sh
```

## Stack

- **Infrastructure**: AWS EKS (1.31), VPC, IAM
- **Kubernetes Add-ons**: NGINX Ingress, cert-manager, external-dns, ArgoCD
- **Monitoring**: Prometheus, Grafana
- **CI/CD**: GitHub Actions with OIDC
- **Application**: 2048 game 

