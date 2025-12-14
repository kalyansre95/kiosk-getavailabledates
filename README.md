# Azure Terraform Infrastructure & Azure DevOps CI/CD – Kiosk GetAvailableDates API

## Project Overview

This repository contains **end‑to‑end Azure Infrastructure as Code (IaC)** using **Terraform** along with **Azure DevOps CI/CD automation** for deploying a **.NET Web API** (`kiosk-getavailabledates`).

The project provisions a **secure, production‑ready Azure environment** including App Services, VNet integration, Azure SQL with Private Endpoint, Key Vault, subnets, and networking controls. It also includes an **Azure DevOps pipeline** for automated build and deployment of the API.

---

## Architecture Summary

This project follows a **secure, enterprise healthcare-grade architecture** with controlled ingress, private networking, and downstream EHR integration.

**End-to-end request flow:**

```
Store Kiosk
   │
   ▼
ExpressRoute (On‑Prem → Azure)
   │
   ▼
Azure Virtual Network (VNet)
   │
   ▼
Azure API Management (APIM)
   │   • Authentication / Authorization
   │   • Request validation & throttling
   │   • Centralized API governance
   ▼
Azure App Service (.NET API)
   │   • Business logic
   │   • Appointment orchestration
   ▼
Azure SQL Database (Private Endpoint)
   │
   ▼
Mirth Connect (Integration Engine)
   │   • HL7 / FHIR message transformation
   ▼
Epic EHR System

Patient Confirmation
   ▲
   └── Notification triggered after appointment creation
```

**Key architecture goals:**

* Secure ingress via ExpressRoute (no public exposure)
* API governance and protection using APIM
* Private connectivity to data layer
* Reliable healthcare system integration (Epic)

---

## Repository Structure

```
.
├── api/                         # .NET Web API source code
│   └── kiosk-getavailabledates
│
├── infra/
│   └── kiosk-infra/             # Terraform infrastructure code
│       ├── app.tf               # App Service & App Service Plan
│       ├── vnet.tf              # VNet & subnet definitions
│       ├── keyvault.tf          # Azure Key Vault & access policies
│       ├── sql.tf               # Azure SQL Server & Database
│       ├── main.tf              # Core resources & wiring
│       ├── provider.tf          # AzureRM provider configuration
│       ├── variables.tf         # Input variables
│       ├── outputs.tf           # Terraform outputs
│       ├── terraform.tfvars     # Environment‑specific values
│       └── tfplan               # Terraform execution plan (generated)
│
├── azure-pipelines.yml          # Azure DevOps CI/CD pipeline
├── kiosk-getavailabledates.sln  # .NET solution file
├── .gitignore
└── README.md
```

---

## Terraform Infrastructure Details

### App Service

* App Service Plan + Web App
* Configured for .NET API
* Integrated with VNet for outbound traffic control
* Uses Managed Identity

### Networking (VNet & Subnets)

* Dedicated VNet
* Separate subnets for:

  * App Service VNet Integration
  * Private Endpoint
* NSGs applied with least‑privilege rules

### Azure SQL Database

* Azure SQL Server & Database
* Public network access **disabled**
* Accessible only through Private Endpoint

### Private Endpoint

* Secure connectivity between App Service and SQL
* Prevents data exfiltration over public internet

### Azure Key Vault

* Stores sensitive configuration:

  * SQL connection strings
  * Application secrets
* Accessed via Managed Identity (no secrets in code)

---

## Security Best Practices Implemented

* No secrets committed to source code
* Managed Identity authentication
* Azure Key Vault secret references
* SQL access via Private Endpoint only
* Network isolation using NSGs

> **Note:** Terraform state files (`terraform.tfstate`) should ideally be stored in **remote backend (Azure Storage + state locking)** and not committed. This repo reflects an earlier internal setup.

---

## 🔁 CI/CD – Azure DevOps Pipeline

### Pipeline Capabilities

* Triggered on `main` branch
* Builds and publishes .NET API
* Deploys API to Azure App Service
* Supports infrastructure‑first deployment model

### Typical Stages

1. **Build**

   * Restore NuGet packages
   * Build .NET solution
   * Run tests (optional)

2. **Deploy**

   * Deploy API to Azure App Service
   * Uses service connection to Azure

---

## Prerequisites

* Azure Subscription
* Azure DevOps Project
* Terraform >= 1.x
* Azure CLI
* .NET 6 / 7 SDK

---

## How to Deploy Infrastructure

```bash
cd infra/kiosk-infra
terraform init
terraform plan
terraform apply
```

---

## How to Deploy Application

Deployment is automated via **Azure DevOps Pipelines** using:

* `azure-pipelines.yml`
* Azure Resource Manager service connection

No manual deployment steps required after pipeline setup.

---

## Environments

Designed to support multiple environments (Dev / QA / Prod) by:

* Updating `terraform.tfvars`
* Using separate resource groups
* Isolating network resources

---

## Why This Project Is Valuable

This repository demonstrates:

* Real‑world Azure enterprise infrastructure
* Terraform best practices for networking & security
* Secure private connectivity patterns
* Full CI/CD automation for cloud‑native APIs

---

## Author

**Kalyan Chakravarthy Ala**
|Azure | Terraform | DevOps | Cloud Infrastructure
---
